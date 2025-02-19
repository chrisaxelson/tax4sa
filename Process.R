#### Processing updates to package ####

library(dplyr)
library(tidyr)

## If I need to add a package for an R function
# use_package("data.table")

## Add data to package
# Create data in data-raw folder
# And then include data with "usethis::use_data(SARS_monthly, overwrite = TRUE)"
# Descriptions of data in "data.R" file in R folder

# Tax tables
load("data-raw/SARS/Tax_tables.rda")
usethis::use_data(Tax_tables, overwrite = TRUE)

# Revenue data
load("data-raw/SARS/SARS_monthly.rda")

SARS <- SARS_monthly %>%
  pivot_longer(c(-Revenue, -Category_number)) %>%
  filter(!is.na(value)) %>%
  separate(name, into = c("Month", "Year"), sep = "_") %>%
  mutate(Year = as.numeric(Year),
         Fiscal_year = if_else(Month %in% c("January", "February", "March"), Year, Year + 1)) %>%
  select(Tax = Revenue, Year, Fiscal_year, Month, Revenue = value)

usethis::use_data(SARS, overwrite = TRUE)

## Readme
usethis::use_readme_rmd(open = rlang::is_interactive())

## Update version number by changing it in the DESCRIPTION file

## Update package documentation
devtools::document()

## Build into tar.gz file
devtools::build()

## Install, either directly or through tar.gz file
devtools::install("../tax4sa")
install.packages("../tax4sa_0.1.0.tar.gz", repos = NULL, type = "source")

