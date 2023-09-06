
# Update NT monthly data ------------------------------------------------

# Latest information - UPDATE THIS EACH MONTH
Latest_link <- "https://www.treasury.gov.za/comm_media/press/monthly/2309/Hardcoded%20database%20July%202023.xlsx"
Latest_month <- "July"
Latest_year <- "2023"

# This should run the same way each month ---------------------------------

# Packages
options(scipen = 999)
library(dplyr)
library(readxl)
library(stringr)
library(httr)
library(tidyr)
library(openxlsx)

# Download and import data - NB CHANGE THE EXTENSION IF CHANGES TO XLSX or vice versa
GET(Latest_link, write_disk(S32 <- tempfile(fileext = sub('.*\\.', '', Latest_link))))

NT_temp <- read_excel(S32, sheet = "Table 1", range = "A4:T148")

# If xls and doesn't parse, then can save as xlsx and bring in manually
# NT_temp <- read_excel("Hardcoded database August 2022.xlsx", sheet = "Table1", range = "A4:T148")

NT_temp <- NT_temp %>%
  mutate(Tax_category = case_when(
    !is.na(`...2`) ~ 1,
    !is.na(`...3`) ~ 2,
    !is.na(`...5`) ~ 3,
    TRUE ~ 0))

NT_temp <- NT_temp %>%
  mutate(Revenue = coalesce(`...1`, `...2`, `...3`, `...4`, `...5`)) %>%
  select(Revenue, Amount = !!Latest_month, Tax_category)

New_column_name <- paste0(Latest_month, "_", Latest_year)

# Create T1, T2 and T3 columns
NT_temp <- NT_temp %>%
  mutate(Revenue = if_else(Revenue == "Taxes on goods and services", "Domestic taxes on goods and services", Revenue)) %>%
  filter(Tax_category != 0) %>%
  mutate(T1 = if_else(Tax_category == 1, Revenue, NA_character_)) %>%
  fill(T1) %>%
  mutate(T2 = if_else(Tax_category == 1, T1, if_else(Tax_category == 2, Revenue, NA_character_))) %>%
  fill(T2) %>%
  mutate(T3 = if_else(Tax_category == 1, T1,
                      if_else(Tax_category == 2, T2,
                              if_else(Tax_category == 3, Revenue, NA_character_)))) %>%
  select(T1, T2, T3, Amount)

# Sum up per group
Group_sum <- NT_temp %>%
  filter(T2 == T3, is.na(Amount)) %>%
  pull(T3)

Group_sum_results <- NT_temp %>%
  filter(T2 %in% Group_sum) %>%
  group_by(T2) %>%
  summarise(Amount = sum(Amount, na.rm = TRUE)) %>%
  rename(T3 = T2)

Group_sum_results <- Group_sum_results %>%
  left_join(NT_temp %>% select(T1, T2, T3),
            by = "T3")

# Remove T3 with NA
NT_temp <- NT_temp %>%
  filter(!(T3 %in% Group_sum))

NT_temp <- NT_temp %>%
  bind_rows(Group_sum_results)


# Now add back with summed groups
NT_temp <- NT_temp %>%
  rename(!!New_column_name := Amount)

# Adjust names

# Bring in current monthly data
NT_monthly <- read_excel(path = "data-raw/NT/Revenue.xlsx", sheet = "Monthly")

NT_monthly_new <- NT_monthly %>%
  left_join(NT_temp, by = c("T1", "T2", "T3"))

NT_monthly_new %>% select(T1, T2, T3, last_col())

# Check that all rows are completed
NT_monthly_new %>%
  select(last_col(offset = 1), last_col()) %>%
  summarise_all(list(~ sum(is.na(.))))

# Write to xlsx
wb2 <- loadWorkbook(file = "data-raw/NT/Revenue.xlsx")

writeData(wb2,
          "Monthly",
          NT_monthly_new %>% select(!!New_column_name),
          startCol = ncol(readWorkbook("data-raw/NT/Revenue.xlsx", sheet = "Monthly"))+1)

saveWorkbook(wb2, file = "data-raw/NT/Revenue.xlsx", overwrite = TRUE)

source("data-raw/NT/Importing original revenue data.R")
# source("README.Rmd")
devtools::document()

