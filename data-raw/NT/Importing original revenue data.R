
# Original revenue data ---------------------------------------------------

library(readxl)
library(dplyr)
library(tidyr)
library(stringr)

# Annual sheet
NT_Budget_revenue <- read_excel(path = "data-raw/NT/Revenue.xlsx", sheet = "Annual")

NT_Budget_revenue <- NT_Budget_revenue %>%
  pivot_longer(cols = !(T1:T3), names_to = "Year", values_to = "Revenue") %>%
  mutate(Fiscal_year = as.numeric(paste0(str_sub(Year, 1, 2), str_sub(Year, 6, 7))),
         Fiscal_year = if_else(Fiscal_year == 1900, 2000, Fiscal_year)) %>%
  filter(!is.na(Revenue)) %>%
  relocate(Revenue, .after = "Fiscal_year")

# Create subset where sum equals the total
NT_Budget_revenue <- NT_Budget_revenue %>%
  filter(!(T1 == T3 & T3 != "State miscellaneous revenue"),
         !(T3 %in% c("Tax on corporate income","Specific excise duties")),
         !(Fiscal_year > 2009 & T3 %in% c("Value-added tax")),
         !grepl("Total", T3),
         !grepl("SACU", T3))

# Check revenue per year
x <- NT_Budget_revenue %>%
  group_by(Fiscal_year) %>%
  summarise(sum(Revenue))

save(NT_Budget_revenue, file = "data-raw/NT/NT_Budget_revenue.rda", version = 2)

# Change name
usethis::use_data(NT_Budget_revenue, overwrite = TRUE)


# Monthly sheet
NT_S32_revenue <- read_excel(path = "data-raw/NT/Revenue.xlsx", sheet = "Monthly")

NT_S32_revenue <- NT_S32_revenue %>%
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
NT_S32_revenue <- NT_S32_revenue %>%
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

NT_S32_revenue <- NT_S32_revenue %>%
  mutate(Month = factor(Month, levels = c("April", "May", "June", "July", "August", "September",
                                          "October", "November", "December", "January", "February",
                                          "March")))

# Check revenue per year
y <- NT_S32_revenue %>%
  # filter(Fiscal_year == 2006) %>%
  group_by(Fiscal_year) %>%
  summarise(sum(Revenue))

save(NT_S32_revenue, file = "data-raw/NT/NT_S32_revenue.rda", version = 2)

# Change name
usethis::use_data(NT_S32_revenue, overwrite = TRUE)
