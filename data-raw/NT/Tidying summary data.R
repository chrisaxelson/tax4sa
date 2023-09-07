# Bringing in excel data

library(tidyverse)
library(tidyxl)
library(unpivotr)

# Summary data
NT_S32_Summary_original <- xlsx_cells("data-raw/NT/Annual_S32_reports/NT_S32_combined_clean.xlsx",
                                  sheets = "Summary")

NT_S32_Summary <- NT_S32_Summary_original %>%
  filter(!is_blank, row >= 2) %>%
  behead("up", "Original_year") %>%
  behead("up-left", "Month") %>%
  behead("left", "H1") %>%
  behead("left", "H2") %>%
  behead("left", "H3") %>%
  behead("left", "H4") %>%
  arrange(row) %>%
  select(Original_year, Month, H1, H2, H3, H4,  numeric) %>%
  fill(Original_year) %>%
  fill(H1) %>%
  group_by(H1) %>%
  fill(H2) %>%
  group_by(H2) %>%
  fill(H3) %>%
  filter(numeric != 0)  %>%
  mutate(Fiscal_year = as.numeric(paste0(str_sub(Original_year, 1, 2), str_sub(Original_year, 6, 7))),
         Quarter = case_when(
           Month %in% c("January", "February", "March") ~ 1,
           Month %in% c("April", "May", "June") ~ 2,
           Month %in% c("July", "August", "September") ~ 3,
           Month %in% c("October", "November", "December") ~ 4,
           TRUE ~ NA),
         Year = if_else(Quarter == 1, Fiscal_year, Fiscal_year - 1)) %>%
  rename(value = numeric)

NT_S32_Table1_original <- xlsx_cells("data-raw/NT/Annual_S32_reports/NT_S32_combined_clean.xlsx",
                                     sheets = "Table1")

NT_S32_Table1_revenue <- NT_S32_Table1_original %>%
  filter(!is_blank, row >= 2) %>%
  behead("up", "Original_year") %>%
  behead("up-left", "Month") %>%
  behead("left", "H1") %>%
  behead("left", "H2") %>%
  behead("left", "H3") %>%
  behead("left", "H4") %>%
  arrange(row) %>%
  select(Original_year, Month, H1, H2, H3, H4,  numeric) %>%
  fill(Original_year) %>%
  fill(H1) %>%
  group_by(H1) %>%
  fill(H2) %>%
  group_by(H2) %>%
  fill(H3) %>%
  filter(numeric != 0)  %>%
  mutate(Month = str_trim(Month),
         Fiscal_year = as.numeric(paste0(str_sub(Original_year, 1, 2), str_sub(Original_year, 6, 7))),
         Quarter = case_when(
           Month %in% c("January", "February", "March") ~ 1,
           Month %in% c("April", "May", "June") ~ 2,
           Month %in% c("July", "August", "September") ~ 3,
           Month %in% c("October", "November", "December") ~ 4,
           TRUE ~ NA),
         Year = if_else(Quarter == 1, Fiscal_year, Fiscal_year - 1)) %>%
  rename(value = numeric)


NT_S32_Table2_original <- xlsx_cells("data-raw/NT/Annual_S32_reports/NT_S32_combined_clean.xlsx",
                                     sheets = "Table2")

NT_S32_Table2_expenditure <- NT_S32_Table2_original %>%
  filter(!is_blank, row >= 2) %>%
  behead("up-left", "Original_year") %>%
  behead("up-left", "Month") %>%
  behead("up-left", "Title1") %>%
  behead("up", "Title2") %>%
  behead("left", "H1") %>%
  behead("left", "H2") %>%
  arrange(row) %>%
  mutate(Type = if_else(!is.na(Title2), paste(Title1, Title2), Title1)) %>%
  select(Original_year, Month, Type, H1, H2,  numeric) %>%
  mutate(Fiscal_year = as.numeric(paste0(str_sub(Original_year, 1, 2), str_sub(Original_year, 6, 7))),
         Quarter = case_when(
           Month %in% c("January", "February", "March") ~ 1,
           Month %in% c("April", "May", "June") ~ 2,
           Month %in% c("July", "August", "September") ~ 3,
           Month %in% c("October", "November", "December") ~ 4,
           TRUE ~ NA),
         Year = if_else(Quarter == 1, Fiscal_year, Fiscal_year - 1)) %>%
  rename(value = numeric)

rm(NT_S32_Summary_original, NT_S32_Table1_original, NT_S32_Table2_original)

save(NT_S32_Summary, file = "data-raw/NT/NT_S32_Summary.rda", version = 2)
save(NT_S32_Table1_revenue, file = "data-raw/NT/NT_S32_Table1_revenue.rda", version = 2)
save(NT_S32_Table2_expenditure, file = "data-raw/NT/NT_S32_Table2_expenditure.rda", version = 2)

usethis::use_data(NT_S32_Summary, overwrite = TRUE)
usethis::use_data(NT_S32_Table1_revenue, overwrite = TRUE)
usethis::use_data(NT_S32_Table2_expenditure, overwrite = TRUE)

