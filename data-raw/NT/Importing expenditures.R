
# Download NT expenditure data --------------------------------------------

library(tidyverse)
library(readxl)
library(tidyxl)
library(unpivotr)

# Download files
download.file("https://www.treasury.gov.za/comm_media/press/monthly/2305/04-03/Hardcoded%20database%20April%20to%20March%202023.xlsx",
              "data-raw/NT/Annual_S32_reports/NT_S32_202223.xlsx", mode = "wb")

download.file("https://www.treasury.gov.za/comm_media/press/monthly/2205/04-03/Hardcoded%20database%20April%202021%20to%20March%202022.xlsm",
              "data-raw/NT/Annual_S32_reports/NT_S32_202122.xlsm", mode = "wb")

download.file("https://www.treasury.gov.za/comm_media/press/monthly/2105/04-04/HARDCODED%20APRIL%20TO%20MARCH%202021.xlsx",
              "data-raw/NT/Annual_S32_reports/NT_S32_202021.xlsx", mode = "wb")

download.file("https://www.treasury.gov.za/comm_media/press/monthly/2105/04-04/HARDCODED%20APRIL%20TO%20MARCH%202021.xlsx",
              "data-raw/NT/Annual_S32_reports/NT_S32_202021.xlsx", mode = "wb")

download.file("https://www.treasury.gov.za/comm_media/press/monthly/2005/04-03/HARDCODED%20APRIL%20TO%20MARCH%202020.xlsx",
              "data-raw/NT/Annual_S32_reports/NT_S32_201920.xlsx", mode = "wb")

download.file("https://www.treasury.gov.za/comm_media/press/monthly/1905/04-03/Hardcoded%20Database%20April%202018%20to%20March%202019.xls",
              "data-raw/NT/Annual_S32_reports/NT_S32_201819.xlsx", mode = "wb")


NT_files <- list.files(path = "data-raw/NT/Annual_S32_reports", pattern = "NT_S32")

for (i in NT_files) {

  NT_file_name <- paste0("data-raw/NT/Annual_S32_reports/", i)

  sheets_available <- excel_sheets(path = NT_file_name)

  table2_sheet <- sheets_available[grep("Table2|Table 2", sheets_available)[1]]

  NT_expenditure_original <- xlsx_cells(NT_file_name, sheets = table2_sheet)

  NT_expenditure_i <- NT_expenditure_original  %>%
    filter(!is_blank, row >= 2, row != 5) %>%
    select(row, col, data_type, character, numeric) %>%
    behead("up-left", "Original_year") %>%
    behead("up-left", "Month") %>%
    behead("up", "Type") %>%
    behead("left", "Direct") %>%
    behead("left", "Department")

  NT_expenditure_i <- NT_expenditure_i %>%
    mutate(Expenditure_programme = if_else(is.na(Department), "Direct charge", "Department"),
           Expenditure_item = coalesce(Department, Direct),
           Expenditure_type = if_else(Type == "Current", "Current payments",
                                      if_else(Type == "Transfers and", "Transfers and subsidies",
                                              if_else(Type == "Payments for" & lag(Type) == "Transfers and", "Payments for capital assets",
                                                      if_else(Type == "Payments for " & lag(Type) != "Transfers and", "Payments for financial assets", Type)))),
           Expenditure = numeric) %>%
    filter(!is.na(Expenditure)) %>%
    select(Original_year, Month, Expenditure_programme, Expenditure_item, Expenditure_type, Expenditure) %>%
    mutate(Month = str_to_sentence(Month),
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
             TRUE ~ NA))

  if (i == NT_files[1]) {
    NT_S32_expenditure <- NT_expenditure_i
  } else {
    NT_S32_expenditure <- NT_S32_expenditure %>%
      bind_rows(NT_expenditure_i)
  }
  print(i)
}
