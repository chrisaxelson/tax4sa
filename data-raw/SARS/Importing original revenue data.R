
# Original revenue data ---------------------------------------------------

library(readxl)
library(dplyr)
library(tidyr)
library(stringr)

# Annual sheet
SARS_annual <- read_excel(path = "data-raw/SARS/Revenue.xlsx", sheet = "Annual")

SARS_annual <- SARS_annual %>%
  pivot_longer(cols = !(T1:T3), names_to = "Year", values_to = "Revenue") %>%
  mutate(Fiscal_year = as.numeric(paste0(str_sub(Year, 1, 2), str_sub(Year, 6, 7))),
         Fiscal_year = if_else(Fiscal_year == 1900, 2000, Fiscal_year)) %>%
  filter(!is.na(Revenue)) %>%
  relocate(Revenue, .after = "Fiscal_year")

# Create subset where sum equals the total
SARS_annual <- SARS_annual %>%
  filter(!(T1 == T3 & T3 != "State miscellaneous revenue"),
         !(T3 %in% c("Tax on corporate income","Specific excise duties")),
         !(Fiscal_year > 2009 & T3 %in% c("Value-added tax")),
         !grepl("Total", T3),
         !grepl("SACU", T3))

# Check revenue per year
x <- SARS_annual %>%
  group_by(Fiscal_year) %>%
  summarise(sum(Revenue))

save(SARS_annual, file = "data-raw/SARS/SARS_annual.rda", version = 2)
usethis::use_data(SARS_annual, overwrite = TRUE)


# Monthly sheet
SARS_monthly <- read_excel(path = "data-raw/SARS/Revenue.xlsx", sheet = "Monthly")

SARS_monthly <- SARS_monthly %>%
  pivot_longer(cols = !(T1:T3), names_to = "Month", values_to = "Revenue") %>%
  rename(Month_year = Month) %>%
  separate(Month_year, into = c("Month", "Year"), remove = FALSE) %>%
  mutate(Year = as.numeric(Year),
         Fiscal_year = if_else(Month %in% c("January", "February", "March"), Year, Year + 1),
         Quarter = case_when(
           Month %in% c("January", "February", "March") ~ 1,
           Month %in% c("April", "May", "June") ~ 2,
           Month %in% c("July", "August", "September") ~ 3,
           TRUE ~ 4)) %>%
  select(T1, T2, T3, Month, Quarter, Year, Fiscal_year, Revenue) %>%
  filter(!is.na(Revenue))

# Subset which sums to total revenue
SARS_monthly <- SARS_monthly %>%
  filter(!(T1 == T3 & T3 != "State miscellaneous revenue"),
         !(T3 %in% c("Tax on corporate income",
                     "Estate, inheritance and gift taxes", "Taxes on financial and capital transactions",
                     "Specific excise duties", "Carbon fuel levy",
                     "CFL Domestic", "CFL Imported",
                     "Taxes on use of goods and on permission to use goods or perform activities", "Import duties")),
         !(Fiscal_year > 2017 & T3 %in% c("Personal income tax")),
         !(Fiscal_year > 2011 & T3 %in% c("Value-added tax")),
         !(T1 == "Taxes on income and profits" & T3 == "Other"),
         !(T1 == "Domestic taxes on goods and services" & T3 == "Other"),
         !(T1 == "Taxes on international trade and transactions" & T3 == "Other"),
         !grepl("Total", T3),
         !grepl("SACU", T3))

SARS_monthly <- SARS_monthly %>%
  mutate(Month = factor(Month, levels = c("April", "May", "June", "July", "August", "September",
                                          "October", "November", "December", "January", "February",
                                          "March")))

# Check revenue per year
y <- SARS_monthly %>%
  # filter(Fiscal_year == 2006) %>%
  group_by(Fiscal_year) %>%
  summarise(sum(Revenue))

save(SARS_monthly, file = "data-raw/SARS/SARS_monthly.rda", version = 2)
usethis::use_data(SARS_monthly, overwrite = TRUE)
