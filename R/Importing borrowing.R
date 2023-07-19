
# Importing S32 borrowing data --------------------------------------------

library(tidyverse)
library(readxl)
library(tidyxl)
library(unpivotr)

NT_files <- list.files(path = "data-raw/NT/Annual_S32_reports", pattern = "NT_S32")

for (i in NT_files) {

  NT_file_name <- paste0("data-raw/NT/Annual_S32_reports/", i)

  sheets_available <- excel_sheets(path = NT_file_name)

  table3_sheet <- sheets_available[grep("Table3|Table 3", sheets_available)[1]]

  NT_borrowing_original <- xlsx_cells(NT_file_name, sheets = table3_sheet)

  NT_borrowing_i <- NT_borrowing_original  %>%
    filter(!is_blank, row >= 8, row != 10, col <= 73) %>%
    # select(row, col, data_type, character, numeric, local_format_id, style_format) %>%
    filter(!is.na(coalesce(character, as.character(numeric)))) %>%
    behead("up-left", "Original_year") %>%
    behead("up-left", "Month") %>%
    behead("left", "Borrowing_type") %>%
    filter(!is.na(Borrowing_type))

  NT_borrowing_i <- NT_borrowing_i %>%
    mutate(Amount = numeric,
           Front_spaces = str_count(Borrowing_type, "\\G "),
           H1 = if_else(grepl("Domestic|Foreign|Change in cash and|Cash flow adjustment|Total", Borrowing_type), Borrowing_type, NA),
           H2 = if_else(between(Front_spaces, 1, 4), str_trim(Borrowing_type),
                        if_else(grepl("Corporation", Borrowing_type), str_trim(Borrowing_type), NA)),
           H2 = if_else(!is.na(H1) & is.na(H2), H1, H2),
           H3 = if_else(grepl("91|182|273|364", Borrowing_type), str_trim(Borrowing_type),
                        if_else(between(Front_spaces, 5, 6), str_trim(Borrowing_type), NA)),
           H3 = if_else(!is.na(H2) & is.na(H3), H2, H3),
           H4 = if_else(Front_spaces >= 7, str_trim(Borrowing_type), NA),
           H4 = if_else(!is.na(H3) & is.na(H4), H3, H4)) %>%
    fill(H1) %>%
    fill(H2) %>%
    fill(H3) %>%
    filter(!is.na(Amount), !is.na(Borrowing_type), !is.na(Original_year)) %>%
    select(Original_year, Month, Borrowing_type, H1, H2, H3, H4, Amount) %>%
    mutate(Month = if_else(Month == "Revised", "Revised estimate", Month),
           Year = if_else(Month %in% c("Revised estimate", "Year to date"), NA,
                          if_else(Month %in% c("January", "February", "March"),
                                  as.numeric(paste0(str_sub(Original_year, 1, 2), str_sub(Original_year, 6, 7))),
                                  as.numeric(str_sub(Original_year, 1, 4)))),
           Fiscal_year = if_else(Month %in% c("Revised estimate", "Year to date"),
                                 as.numeric(paste0(str_sub(Original_year, 1, 2), str_sub(Original_year, 6, 7))),
                                 if_else(Month %in% c("January", "February", "March"), Year, Year + 1)),
           Quarter = case_when(
             Month %in% c("January", "February", "March") ~ 1,
             Month %in% c("April", "May", "June") ~ 2,
             Month %in% c("July", "August", "September") ~ 3,
             Month %in% c("October", "November", "December") ~ 4,
             TRUE ~ NA)) %>%
    distinct()

  if (i == NT_files[1]) {
    NT_S32_borrowing <- NT_borrowing_i
  } else {
    NT_S32_borrowing <- NT_S32_borrowing %>%
      bind_rows(NT_borrowing_i)
  }
  print(i)
}


