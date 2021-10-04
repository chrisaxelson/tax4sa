#### Adding ad-hoc time series data ####

# Packages
library(tidyverse)
library(rvest)
library(stringr)
library(openxlsx)

# Link
zipped_url <- "http://www.statssa.gov.za/timeseriesdata/Excel/P0141%20-%20CPI%20Average%20Prices%20All%20urban%20(202107).zip"

# Create temporary files to download, unzip and save files
tmp_file <- tempfile()
download.file(url = zipped_url,
              destfile = tmp_file,
              mode = "wb")
unzipped_file_name <- unzip(tmp_file, list=TRUE)$Name
unzipped_file_name <- unzipped_file_name[grepl(".xls", unzipped_file_name)]

tmp_file2 <- tempfile()
tmp_file2 <- unzip(zipfile=tmp_file, files = unzipped_file_name[j], exdir=tempdir())

STATSSA_new <- read.xlsx(tmp_file2)

STATSSA_new <- STATSSA_new %>%
  select(-March.Online.Price) %>%
  pivot_longer(cols = -c(starts_with("H")))

STATSSA_descriptions_new <- STATSSA_new %>%
  select(-name, -value) %>%
  distinct() %>%
  mutate(Link = unzipped_file_name)

STATSSA_new <- STATSSA_new %>%
  rename(Date = name, Value = value) %>%
  mutate(Month = NA,
         Quarter = ifelse(H25 == "Quarterly", as.numeric(str_sub(Date, 6, 6)), NA),
         Year = ifelse(H25 == "Quarterly", as.numeric(str_sub(Date, 1, 4)),
                       as.numeric(str_sub(Date, 2, 5))),
         Fiscal_year = ifelse(!is.na(Quarter), ifelse(Quarter == 1, Year, Year + 1), NA))

STATSSA_new <- STATSSA_new %>%
  select(H01, H03, Date, Month, Quarter, Year, Fiscal_year, Value) %>%
  arrange(H01, H03, Month, Quarter, Year, Fiscal_year)

# Now replace current data with new data
load("data-raw/STATSSA/STATSSA.rda")
load("data-raw/STATSSA/STATSSA_descriptions.rda")


# Remove new data from saved data
STATSSA <- STATSSA %>%
  anti_join(STATSSA_new,
            by = c("H01", "H03"))

# Add on new data and arrange
STATSSA <- STATSSA %>%
  bind_rows(STATSSA_new) %>%
  arrange(H01, H03)

STATSSA <- STATSSA %>%
  distinct()

# Remove new data from saved data
STATSSA_descriptions <- STATSSA_descriptions %>%
  anti_join(STATSSA_descriptions_new,
            by = c("H01", "H03"))

# Add on new data and arrange
STATSSA_descriptions <- STATSSA_descriptions %>%
  bind_rows(STATSSA_descriptions_new) %>%
  arrange(H01, H03)

STATSSA_descriptions <- STATSSA_descriptions %>%
  distinct()

STATSSA <- STATSSA %>%
  mutate_if(is.character, str_trim)

STATSSA_descriptions <- STATSSA_descriptions %>%
  mutate_if(is.character, str_trim)

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
