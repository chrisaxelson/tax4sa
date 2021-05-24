
# Adding monthly SARS revenue data -----------------------------------------


# Latest information - UPDATE THIS EACH MONTH
Latest_link <- "http://www.treasury.gov.za/comm_media/press/monthly/2105/HARDCODED%20MARCH%202021.xlsx"
Latest_month <- "March"
Latest_year <- "2021"

# This should run the same way each month ---------------------------------

# Packages
options(scipen = 999)
library(dplyr)
library(readxl)
library(stringr)
library(httr)
library(tidyr)

# Download and import data - NB CHANGE THE EXTENSION IF CHANGES TO XLSX or vice versa
GET(Latest_link, write_disk(S32 <- tempfile(fileext = sub('.*\\.', '', Latest_link))))
SARS_temp <- read_excel(S32, sheet = "Table1", range = "A4:T148")

SARS_temp <- SARS_temp %>%
  mutate(Tax_category = case_when(
    !is.na(`...2`) ~ 1,
    !is.na(`...3`) ~ 2,
    !is.na(`...5`) ~ 3,
    TRUE ~ 0))

SARS_temp <- SARS_temp %>%
  mutate(Revenue = coalesce(`...1`, `...2`, `...3`, `...4`, `...5`)) %>%
  select(Revenue, Amount = !!Latest_month, Tax_category)

# Sum up rows which are empty
SARS_temp <- SARS_temp %>%
  mutate(Amount = if_else(Revenue == "Tax on corporate income",
                          lead(Amount, 1) + lead(Amount, 2) + lead(Amount, 3) + lead(Amount, 4) , Amount),
         Amount = if_else(Revenue == "Other" & lead(Revenue) == "Interest on overdue income tax",
                          lead(Amount, 1) + lead(Amount, 2), Amount),
         Amount = if_else(Revenue == "Estate, inheritance and gift taxes",
                          lead(Amount, 1) + lead(Amount, 2), Amount),
         Amount = if_else(Revenue == "Taxes on financial and capital transactions",
                          lead(Amount, 1) + lead(Amount, 2), Amount),
         Amount = if_else(Revenue == "Taxes on use of goods and on permission to use goods or perform activities",
                          lead(Amount, 1) + lead(Amount, 2) + lead(Amount, 3) + lead(Amount, 4) +
                            lead(Amount, 5) + lead(Amount, 6) + lead(Amount, 7) + lead(Amount, 8), Amount),
         Amount = if_else(Revenue == "Other" & lead(Revenue) == "Universal Service Fund",
                          lead(Amount, 1), Amount),
         Amount = if_else(Revenue == "Import duties",
                          lead(Amount, 1) + lead(Amount, 2), Amount),
         Amount = if_else(Revenue == "Other" & lead(Revenue) == "Miscellaneous customs and excise receipts",
                          lead(Amount, 1) + lead(Amount, 2), Amount))

# Change others
SARS_temp <- SARS_temp %>%
  mutate(Revenue = ifelse(Revenue == "Other" & lead(Revenue) == "Interest on overdue income tax", "Other: Taxes on income and profits", Revenue),
         Revenue = ifelse(Revenue == "Other" & lead(Revenue) == "Universal Service Fund", "Other: Taxes on goods and services", Revenue),
         Revenue = ifelse(Revenue == "Other" & lead(Revenue) == "Miscellaneous customs and excise receipts", "Other: Taxes on international trade and transactions", Revenue))

# Get rid of rows we don't need
SARS_temp <- SARS_temp %>%
  filter(!is.na(Revenue) & !(Revenue %in% c("R thousand", "Of which:")))

# Rename tax items to be consistent across all years
SARS_temp <- SARS_temp %>%
  mutate(Revenue = case_when(
    Revenue == "Taxes on income and profits" ~ "Taxes on income, profits and capital gains",
    Revenue == "Personal income tax" ~ "Income tax on persons and individuals",
    Revenue == "NRF receipts" ~ "National Revenue Fund receipts",
    Revenue == "Direct transfer from NRF to the RAF" ~
      "Direct transfer from National Revenue Fund to the Road Accident Fund",
    Revenue == "Direct transfer from NRF to the UIF" ~
      "Direct transfer from National Revenue Fund to the Unemployment Insurance Fund",
    Revenue == "Cash balance NRF" ~ "Cash balance National Revenue Fund",
    Revenue == "Provincial revenue collected by SARS and transferred by NRF" ~
      "Provincial revenue collected by SARS and transferred by National Treasury",
    Revenue == "CARA added as part of cash revenue in Table 4" ~
      "Recovery of criminal assets added as part of cash revenue in table 4",
    Revenue == "Revenue collected on behalf of the RAF" ~
      "Revenue collected on behalf of the Road Accident Fund",
    Revenue == "Revenue collected on behalf of the UIF" ~
      "Revenue collected on behalf of the Unemployment Insurance Fund",
    Revenue == "Value-added tax" ~ "Value added tax",
    Revenue == "Departmental revenue received but not yet paid to NRF" ~
      "Departmental revenue received but not yet paid to the National Revenue Fund",
    grepl(" - motor vehicle emissions", Revenue) ~
      "CO2 tax - motor vehicle emissions",
    TRUE ~ Revenue
  ))

SARS_temp <- SARS_temp %>%
  mutate(Revenue = str_replace(Revenue, "Table 4", "table 4"),
         Revenue = str_squish(Revenue))

New_column_name <- paste0(Latest_month, "_", Latest_year)

SARS_temp <- SARS_temp %>%
  mutate(Amount = round(Amount)) %>%
  rename(!!New_column_name := Amount)


# Bring in data
load("data-raw/SARS/SARS_monthly.rda")

# Check which rows don't match
x <- SARS_temp[!SARS_temp$Revenue %in% SARS_monthly$Revenue,]

# Combine with original data
SARS_monthly <- SARS_monthly %>%
  left_join(SARS_temp %>% select(-Tax_category), by = "Revenue") %>%
  arrange(Category_number)

SARS_monthly <- SARS_monthly %>%
  distinct()

# Check if any are missing compared to previous month
SARS_monthly %>%
  select(1, tail(names(.), 3))


# If seems ok, save
save(SARS_monthly, file = "data-raw/SARS/SARS_monthly.rda", version = 2)

SARS <- SARS_monthly %>%
  select(-Tax_category) %>%
  pivot_longer(c(-Revenue, -Category_number)) %>%
  filter(!is.na(value)) %>%
  separate(name, into = c("Month", "Year"), sep = "_") %>%
  mutate(Year = as.numeric(Year),
         Fiscal_year = if_else(Month %in% c("January", "February", "March"), Year, Year + 1)) %>%
  select(Tax = Revenue, Year, Fiscal_year, Month, Revenue = value)

usethis::use_data(SARS, overwrite = TRUE)


