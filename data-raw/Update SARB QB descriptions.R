#### SARB descriptions ####


# To include data
load(file = "data-raw/SARB/SARB.rda")
usethis::use_data(SARB_descriptions, overwrite = TRUE)


library(tidyverse)
library(rvest)
library(readxl)
library(janitor)
library(Hmisc)

# Get excel spreadsheet
SARB_descriptions_url <- "https://www.resbank.co.za/content/dam/sarb/publications/quarterly-bulletins/qb-time-series-descriptions/2021/QB%20Time%20Series%20Descriptions%20-%20March%202021.zip"

# QB xlsx site again for frequency descriptions
webpage <- read_html("https://www.resbank.co.za/en/home/publications/publication-detail-pages/quarterly-bulletins/download-information-from-xlsx-data-files/2021/download-information-from-xlsx-data-files")


# Download
download.file(SARB_descriptions_url, destfile = "data-raw/SARB/SARB_description.zip")

# Unzip
unzip(zipfile="data-raw/SARB/SARB_description.zip",
      files = "QB Time Series Descriptions - March 2021.xlsx",
      exdir="data-raw/SARB")

# Import and clean
SARB_descriptions <- read_excel("data-raw/SARB/QB Time Series Descriptions - March 2021.xlsx")
SARB_descriptions <- clean_names(SARB_descriptions)
colnames(SARB_descriptions) <- capitalize(colnames(SARB_descriptions))

# Get into a nice format
SARB_descriptions <- SARB_descriptions %>%
 fill(Time_series_code)

# Description
SARB_descriptions <- SARB_descriptions %>%
  mutate(Description_new = if_else(is.na(Frequency) & is.na(lead(Frequency)),
                                   paste(Description, lead(Description)),
                                   Description),
         check = if_else(nchar(lag(Description_new)) > nchar(Description_new) & nchar(lead(Description_new)) < nchar(Description_new), FALSE, TRUE)) %>%
  filter(check == TRUE | is.na(check)) %>%
  select(Time_series_code, Description = Description_new, Version_description, Frequency, Unit_of_measure)


temp_desc <- SARB_descriptions %>%
  select(Time_series_code, Description) %>%
  filter(nchar(Description) > 1) %>%
  distinct()

SARB_descriptions <- SARB_descriptions %>%
  rename(Desc_letter = Description) %>%
  filter(nchar(Desc_letter) == 1) %>%
  left_join(temp_desc, by = "Time_series_code")

SARB_descriptions <- SARB_descriptions %>%
  mutate(Time_series_code = paste0(Time_series_code, Desc_letter)) %>%
  select(Time_series_code, Description, Frequency, Unit_of_measure, Version_description)

# Add time descriptions


tbls <- html_nodes(webpage, "table")

Frequency_description <- webpage %>%
  html_nodes("table") %>%
  # .[11] %>%
  html_table(header = TRUE)

Frequency_description <- as.data.frame(Frequency_description[[1]])
colnames(Frequency_description) <- c("Frequency", "Frequency_description")

# Link to original data
SARB_descriptions <- SARB_descriptions %>%
  left_join(Frequency_description, by = "Frequency") %>%
  select(Code = Time_series_code, Description, Frequency, Frequency_description, Unit_of_measure, Version_description)

save(SARB_descriptions, file = "data-raw/SARB/SARB_descriptions.rda", version = 2)


SARB_Quarterly_Bulletin_info <- SARB_descriptions
usethis::use_data(SARB_Quarterly_Bulletin_info, overwrite = TRUE)

