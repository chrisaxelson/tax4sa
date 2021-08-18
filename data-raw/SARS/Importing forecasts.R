
# Importing forecasts -----------------------------------------------------

library(readxl)
library(dplyr)
library(tidyr)
library(stringr)

# Annual sheet
NT_forecasts <- read_excel(path = "data-raw/SARS/Forecasts.xlsx")

# Reshape
NT_forecasts <- NT_forecasts %>%
  pivot_longer(cols = contains("/"),
               names_to = "Forecast_year", values_to = "Forecast") %>%
  filter(!is.na(Forecast)) %>%
  select(-Category_order)

save(NT_forecasts, file = "data-raw/SARS/NT_forecasts.rda", version = 2)
usethis::use_data(NT_forecasts, overwrite = TRUE)
