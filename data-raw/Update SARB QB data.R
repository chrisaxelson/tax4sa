#### Updating SARB Quarterly Bulletin data ####

## The part of the script that needs to change is the URL of the website with the data
# Go to "https://www.resbank.co.za/Publications/QuarterlyBulletins/Pages/DownloadInformationFromXLSXDataFiles.aspx" and
# get link that states "Download information from xlsx files"

# OR go to "Publications and Notices" on the SARB site ("https://www.resbank.co.za/") and scroll to "Quarterly Bulletins" and then
# click on "Download information from XLSX data files" and click on link that is shown

# To include data in package
load(file = "data-raw/SARB/SARB.rda")
usethis::use_data(SARB, overwrite = TRUE)


# URL of page to download xlsx data
SARB_download_url <- "https://www.resbank.co.za/en/home/publications/publication-detail-pages/quarterly-bulletins/download-information-from-xlsx-data-files/2021/Downloadinformationfromxlsxdatafiles0"

# Packages
library(rvest)
library(readr)
library(dplyr)
library(readxl)
library(tidyr)
library(stringr)

# Scrape website to get links to zip files with the data
SARB_page <- read_html(SARB_download_url)
SARB_links <- SARB_page %>%
  html_nodes("a") %>%
  html_attr('href')

SARB_links <- SARB_links[grepl("\\.zip", SARB_links)]
SARB_links <- unique(SARB_links)
SARB_links <- paste0("https://www.resbank.co.za", SARB_links)

# Get date of publication
SARB_QB_date <- SARB_page %>%
  html_nodes(xpath = "//*/div[@class = 'value col-md-7 col-6']") %>%
  html_text()

SARB_QB_date <- str_replace_all(SARB_QB_date[2], "-", "")

# Create folder if it doesn't exist
SARB_folder <- paste0("data-raw/SARB/", SARB_QB_date ," Quarterly Bulletin")
dir.create(file.path(SARB_folder), showWarnings = FALSE)

# Loop through links to open zips and import xlsx data
for (i in seq_along(SARB_links)) {

  # Create temporary files to download, unzip and save files
  tmp <- tempfile()
  download.file(SARB_links[i], tmp)
  # tmp2 <- tempfile()
  tmp2 <- unzip(zipfile=tmp, files = unzip(tmp, list=TRUE)$Name[1], exdir=SARB_folder)

  if (i == 1) {
    # How many sheets in the excel file?
    sheets <- excel_sheets(tmp2)
    # Import data from excel
    QB_data <- read_excel(tmp2, sheet = sheets[1])
    # Rename first blank column
    colnames(QB_data)[1] <- "Date"
    # Record which description was used
    QB_data$Description <- sheets[1]
    # Remove columns if all NA
    QB_data <- QB_data[, colSums(is.na(QB_data)) < nrow(QB_data)]
    # Tidy data
    QB_data <- QB_data %>%
      gather(Code, Value, -c(Date, Description))

    # If more than one sheet, repeat and add to original data
    if (length(sheets) > 1) {
      for (j in 2:length(sheets)) {
        QB_data_next <- read_excel(tmp2, sheet = sheets[j])
        colnames(QB_data_next)[1] <- "Date"
        QB_data_next$Description <- sheets[j]
        QB_data_next <- QB_data_next[, colSums(is.na(QB_data_next)) < nrow(QB_data_next)]
        QB_data_next <- QB_data_next %>%
          gather(Code, Value, -c(Date, Description))
        QB_data <- bind_rows(QB_data, QB_data_next)
      }
    }
    unlink(tmp)
    # unlink(tmp2)
  } else {
    # How many sheets in the excel file?
    sheets <- excel_sheets(tmp2)
    # Import data from excel
    QB_data2 <- read_excel(tmp2, sheet = sheets[1])
    # Rename first blank column
    colnames(QB_data2)[1] <- "Date"
    # Record which description was used
    QB_data2$Description <- sheets[1]
    # Remove columns if all NA
    QB_data2 <- QB_data2[, colSums(is.na(QB_data2)) < nrow(QB_data2)]
    # Tidy data
    QB_data2 <- QB_data2 %>%
      gather(Code, Value, -c(Date, Description))

    # If more than one sheet, repeat and add to original data
    if (length(sheets) > 1) {
      for (j in 2:length(sheets)) {
        QB_data_next2 <- read_excel(tmp2, sheet = sheets[j])
        colnames(QB_data_next2)[1] <- "Date"
        QB_data_next2$Description <- sheets[j]
        QB_data_next2 <- QB_data_next2[, colSums(is.na(QB_data_next2)) < nrow(QB_data_next2)]
        QB_data_next2 <- QB_data_next2 %>%
          gather(Code, Value, -c(Date, Description))
        QB_data2 <- bind_rows(QB_data2, QB_data_next2)
      }
    }

    # Merge back into main data
    QB_data <- bind_rows(QB_data, QB_data2)
    # Clean up
    unlink(tmp)
    # unlink(tmp2)
  }
}

# Rename
SARB <- QB_data %>%
  filter(!is.na(Value))

SARB <- SARB %>%
  rename(Frequency = Description) %>%
  select(Code, Date, Frequency, Value)

# Remove remaining data
rm(QB_data2, QB_data_next, QB_data_next2, i, j, SARB_download_url, SARB_links, SARB_page,
   sheets, tmp, tmp2, QB_data)

SARB <- SARB %>%
  arrange(Code)

# Get rid of incorrect entry
SARB <- SARB %>%
  filter(!grepl("\\.\\.\\.", Code))

# Create month, quarter, year and fiscal year columns
SARB <- SARB %>%
  mutate(Month = ifelse(Frequency == "M1",
                        as.numeric(substr(Date, 5, 6)), NA),
         Month = month.name[Month],
         Month = factor(Month, levels = month.name),
         Quarter = ifelse(Frequency == "K1",
                          as.numeric(substr(Date, 5, 6)),
                   ifelse(Frequency == "M1",
                          ifelse(as.numeric(substr(Date, 5, 6)) <= 3, 1,
                          ifelse(as.numeric(substr(Date, 5, 6)) <= 6, 2,
                          ifelse(as.numeric(substr(Date, 5, 6)) <= 9, 3, 4))), NA)),
         Year = ifelse(Frequency %in% c("J1", "K1", "M1"),
                       as.numeric(substr(Date, 1, 4)), NA),
         Fiscal_year = ifelse(Frequency == "J2",
                              as.numeric(substr(Date, 1, 4)),
                       ifelse(Frequency == "K1",
                               ifelse(substr(Date, 6, 6) == "1",
                                       as.numeric(substr(Date, 1, 4)),
                                       as.numeric(substr(Date, 1, 4)) + 1),
                       ifelse(Frequency == "M1",
                              ifelse(as.numeric(substr(Date, 5, 6)) < 4,
                                     as.numeric(substr(Date, 1, 4)),
                                     as.numeric(substr(Date, 1, 4)) + 1), NA))))

# One correction
SARB <- SARB %>%
  mutate(Fiscal_year = if_else(Fiscal_year == 2, 2000, Fiscal_year)) %>%
  relocate(Value, .after = last_col())

# Save data
save(SARB, file = "data-raw/SARB/SARB.rda", version = 2)
load(file = "data-raw/SARB/SARB.rda")

usethis::use_data(SARB, overwrite = TRUE)


