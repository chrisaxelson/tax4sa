#### Downloading new STATSSA GDP data from spreadsheet ####

# Packages
library(tidyverse)
library(rvest)
library(stringr)
library(openxlsx)

# GDP link
GDP_url <- "https://www.statssa.gov.za/publications/P0441/GDP%20P0441%20-%20GDP%20Time%20series%202023Q1.xlsx"

Annual <- read.xlsx(GDP_url, sheet = "Annual") %>% pivot_longer(cols = -c(H01:H25))
AnnualP <- read.xlsx(GDP_url, sheet = "AnnualP") %>% pivot_longer(cols = -c(H01:H25))
Quarterly <- read.xlsx(GDP_url, sheet = "Quarterly") %>%  pivot_longer(cols = -c(H01:H25))
QuarterlyP <- read.xlsx(GDP_url, sheet = "QuarterlyP") %>%  pivot_longer(cols = -c(H01:H25))

STATSSA_P0441_GDP <- Quarterly %>%
  bind_rows(QuarterlyP) %>%
  bind_rows(Annual) %>%
  bind_rows(AnnualP)

STATSSA_P0441_GDP <- STATSSA_P0441_GDP %>%
  rename(Date = name, Value = value) %>%
  mutate(Quarter = ifelse(H25 == "Quarterly", as.numeric(str_sub(Date, 6, 6)), NA),
         Year = ifelse(H25 == "Quarterly", as.numeric(str_sub(Date, 1, 4)),
                       as.numeric(str_sub(Date, 2, 5))),
         Fiscal_year = ifelse(!is.na(Quarter), ifelse(Quarter == 1, Year, Year + 1), NA))


usethis::use_data(STATSSA_P0441_GDP, overwrite = TRUE)

