
# Downloading and including customs data ----------------------------------

# Go to https://tools.sars.gov.za/tradestatsportal/data_download.aspx

# Then click on Imports and download three months at a time, then do the same for exports

# Save as csv with filename SARS_imports_20211012.csv

library(data.table)
library(arrow)
library(piggyback)
library(dplyr)

# Imports
files_to_import <- list.files(path = "data-raw/SARS/Trade_data", pattern = "SARS_imports_2022")
files_to_import <- paste0("data-raw/SARS/Trade_data/", files_to_import)
SARS_imports_2022 <- rbindlist(lapply(files_to_import, fread))
SARS_imports_2022 <- SARS_imports_2022 %>% mutate_if(is.character, as.factor)
SARS_imports_2022 <- SARS_imports_2022 %>% mutate(CustomsValue = as.numeric(CustomsValue))

write_parquet(SARS_imports_2022, "data-raw/SARS/Trade_data/SARS_imports_2022.parquet")

pb_upload("data-raw/SARS/Trade_data/SARS_imports_2022.parquet",
          repo = "chrisaxelson/tax4sa",
          tag = "v0.0.1")

# Exports
files_to_import <- list.files(path = "data-raw/SARS/Trade_data", pattern = "SARS_exports_2022")
files_to_import <- paste0("data-raw/SARS/Trade_data/", files_to_import)
SARS_exports_2022 <- rbindlist(lapply(files_to_import, fread))
SARS_exports_2022 <- SARS_exports_2022 %>% mutate_if(is.character, as.factor)
SARS_exports_2022 <- SARS_exports_2022 %>% mutate(CustomsValue = as.numeric(CustomsValue))

write_parquet(SARS_exports_2022, "data-raw/SARS/Trade_data/SARS_exports_2022.parquet")

pb_upload("data-raw/SARS/Trade_data/SARS_exports_2022.parquet",
          repo = "chrisaxelson/tax4sa",
          tag = "v0.0.1")
