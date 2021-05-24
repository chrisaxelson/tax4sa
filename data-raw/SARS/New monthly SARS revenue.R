
# Adding monthly s32 revenue data -----------------------------------------

# Packages
library(dplyr)
library(readxl)
library(httr)

# Latest information
Latest_month <- "2020_June"
Latest_link <- "http://www.treasury.gov.za/comm_media/press/monthly/2008/HARDCODED%20JUNE%202020.xlsx"

# Download and import data
GET(Latest_link, write_disk(S32 <- tempfile(fileext = ".xlsx")))
SARS_temp <- read_excel(S32, sheet = "Table 1", range = "A4:K146")

SARS_temp <- SARS_temp %>%
  mutate(Revenue = coalesce(`...1`, `...2`, `...3`, `...4`, `...5`)) %>%
  select(12, Amount = 11)

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


# Bring in data
load("data-raw/Section 32/SARS_monthly.rda")


