
# Importing forecasts -----------------------------------------------------

library(readxl)
library(dplyr)
library(tidyr)
library(stringr)

# Annual sheet
NT_Budget_forecasts <- read_excel(path = "data-raw/NT/Forecasts.xlsx")

# Reshape
NT_Budget_forecasts <- NT_Budget_forecasts %>%
  pivot_longer(cols = contains("/"),
               names_to = "Forecast_year", values_to = "Forecast") %>%
  filter(!is.na(Forecast)) %>%
  select(-Category_order)

save(NT_Budget_forecasts, file = "data-raw/NT/NT_Budget_forecasts.rda", version = 2)
usethis::use_data(NT_Budget_forecasts, overwrite = TRUE)
