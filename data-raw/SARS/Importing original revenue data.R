
# Original revenue data ---------------------------------------------------

library(readxl)
library(dplyr)
library(tidyr)
library(stringr)

# Annual sheet
SARS_annual <- read_excel(path = "data-raw/SARS/Revenue.xlsx", sheet = "Annual")

SARS_annual <- SARS_annual %>%
  pivot_longer(cols = !(T1:T3), names_to = "Year", values_to = "Revenue") %>%
  mutate(Fiscal_year = as.numeric(paste0(str_sub(Year, 1, 2), str_sub(Year, 6, 7)))) %>%
  relocate(Revenue, .after = "Fiscal_year")

save(SARS_annual, file = "data-raw/SARS/SARS_annual.rda", version = 2)
usethis::use_data(SARS_annual, overwrite = TRUE)


# Monthly sheet
SARS_monthly <- read_excel(path = "data-raw/SARS/Revenue.xlsx", sheet = "Monthly")

SARS_monthly <- SARS_monthly %>%
  pivot_longer(cols = !(T1:T3), names_to = "Month", values_to = "Revenue") %>%
  rename(Month_year = Month) %>%
  separate(Month_year, into = c("Month", "Year"), remove = FALSE) %>%
  mutate(Year = as.numeric(Year),
         Fiscal_year = if_else(Month %in% c("January", "February", "March"), Year, Year + 1)) %>%
  relocate(Revenue, .after = "Fiscal_year") %>%
  filter(!is.na(Revenue))

save(SARS_monthly, file = "data-raw/SARS/SARS_monthly.rda", version = 2)
usethis::use_data(SARS_monthly, overwrite = TRUE)
