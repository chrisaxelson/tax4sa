#### Downloading new STATSSA GDP data from spreadsheet ####

# Packages
library(tidyverse)
library(rvest)
library(stringr)
library(openxlsx)

# GDP link
GDP_url <- "http://www.statssa.gov.za/publications/P0441/GDP%20P0441%20-%20GDP%20Time%20series%202021%20Q2.xlsx"

Annual <- read.xlsx(GDP_url, sheet = "Annual") %>% pivot_longer(cols = -c(H01:H25))
AnnualP <- read.xlsx(GDP_url, sheet = "AnnualP") %>% pivot_longer(cols = -c(H01:H25))
Quarterly <- read.xlsx(GDP_url, sheet = "Quarterly") %>%  pivot_longer(cols = -c(H01:H25))
QuarterlyP <- read.xlsx(GDP_url, sheet = "QuarterlyP") %>%  pivot_longer(cols = -c(H01:H25))

GDP_data <- Quarterly %>%
  bind_rows(QuarterlyP) %>%
  bind_rows(Annual) %>%
  bind_rows(AnnualP)

GDP_data_descriptions <- GDP_data %>%
  select(-name, -value) %>%
  distinct() %>%
  mutate(Link = "GDP P0441 - GDP Time series.xlsx")

GDP_data <- GDP_data %>%
  rename(Date = name, Value = value) %>%
  mutate(Month = NA,
         Quarter = ifelse(H25 == "Quarterly", as.numeric(str_sub(Date, 6, 6)), NA),
         Year = ifelse(H25 == "Quarterly", as.numeric(str_sub(Date, 1, 4)),
                       as.numeric(str_sub(Date, 2, 5))),
         Fiscal_year = ifelse(!is.na(Quarter), ifelse(Quarter == 1, Year, Year + 1), NA))

GDP_data <- GDP_data %>%
  select(H01, H03, Date, Month, Quarter, Year, Fiscal_year, Value) %>%
  arrange(H01, H03, Month, Quarter, Year, Fiscal_year)

# Now replace current data with new data
load("data-raw/STATSSA/STATSSA.rda")
load("data-raw/STATSSA/STATSSA_descriptions.rda")

STATSSA <- STATSSA %>%
  mutate_if(is.character, str_trim)

STATSSA_descriptions <- STATSSA_descriptions %>%
  mutate_if(is.character, str_trim)

# Add on new data and arrange
STATSSA <- STATSSA %>%
  bind_rows(GDP_data) %>%
  arrange(H01, H03)

# Add on new data and arrange
STATSSA_descriptions <- STATSSA_descriptions %>%
  bind_rows(GDP_data_descriptions) %>%
  arrange(H01, H03)

STATSSA <- STATSSA %>%
  distinct()

STATSSA_descriptions <- STATSSA_descriptions %>%
  distinct()

save(STATSSA, file = "data-raw/STATSSA/STATSSA.rda", version = 2)
save(STATSSA_descriptions, file = "data-raw/STATSSA/STATSSA_descriptions.rda", version = 2)

usethis::use_data(STATSSA, overwrite = TRUE)
usethis::use_data(STATSSA_descriptions, overwrite = TRUE)

# Check STATSSA descriptions for links
Imported_files <- STATSSA_descriptions %>%
  pull(Link) %>%
  unique()

Imported_files <- paste0("timeseriesdata/Ascii/", Imported_files)

# Save file names so don't need to redownload next time
saveRDS(Imported_files, file = "data-raw/STATSSA/Imported_files.rds")
