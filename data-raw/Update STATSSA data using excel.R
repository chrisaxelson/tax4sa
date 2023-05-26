
# Downloading STATSSA data through Selenium -------------------------------

library(RSelenium)
library(tidyverse)
library(readxl)
library(rvest)
library(janitor)
library(lubridate)
library(usethis)
library(tax4sa)

# Check if there are any docker containers running and remove them
con <- pipe("docker ps")
docker_df <- read.fwf(file = con, widths = c(12, 300))
rm(con)

container_id <- docker_df %>%
  filter(grepl("4448", V2)) %>%
  head(1) %>%
  pull(V1)

system(paste0("docker kill ", container_id))
system(paste0("docker rm ", container_id))

docker_check <- system("docker ps", intern = TRUE)

# Start new container
if (!any(str_detect(docker_check, "0:4448"))) {
  system("docker run -d -p 4448:4444 -p 7909:7900 -e SE_NODE_SESSION_TIMEOUT=57868143 --shm-size 2g selenium/standalone-chrome:4.2.2")
  Sys.sleep(10)
}

con <- pipe("docker ps")
docker_df <- read.fwf(file = con, widths = c(12, 300))
rm(con)

container_id <- docker_df %>%
  filter(grepl("4448", V2)) %>%
  head(1) %>%
  pull(V1)

# Open site
remDr <-  remoteDriver(port = 4448L, browserName = "chrome")
remDr$open(silent = TRUE)
remDr$maxWindowSize()
remDr$navigate("http://www.statssa.gov.za/?page_id=1847")

STATSSA_html <- read_html(remDr$getPageSource()[[1]])

STATSSA_links <- STATSSA_html %>%
  html_nodes(xpath = "//*/table[@id = 'mine']//a") %>%
  html_attr("href")

STATSSA_links <- STATSSA_links[grepl("Excel", STATSSA_links)]

# Specific details for each file to download
# file_number is the file you need from the unzipped folder
# sheet_number is the sheet in the excel file
# final column is the one just before the date
Data_info <- tribble(
  ~file_id, ~file_number, ~sheet_number, ~final_column, ~name, ~file_name,
  "P0141.*urban", 1, 1, "H08", "P0141_CPI_urban", "P0141 - CPI Average Prices All urban",
  "P0141.*Province", 1, 1, "Province_code", "P0141_CPI_province", "P0141 - CPI Average Prices Provinces",
  "P0141.*digit", 1, 1, "Weight (All urban)", "P0141_CPI_digit", "P0141 - CPI(5 and 8 digit) from Jan 2017",
  "P0141.*COICOP", 1, 1, "H25", "P0141_CPI_COICOP", "P0141 - CPI(COICOP) from Jan 2008",
  "P6410", 1, 1, "H25", "P6410_tourists", "P6410 - Tourist Accomodation",
  "P5041", 2, 1, "H25", "P5041.1_building", "P5041.1 Building Statistics",
  "P0151.*Construction", 1, 1, "H25", "P0151.1_construction", "P0151.1 Construction Materials Price Indices, 2006-2023",
  "P4141.*Electricity", 3, 1, "H25", "P4141_electricity", "P4141 Electricity generated and available for distribution",
  "P0142.*Export", 1, 1, "H25", "P0142.7_trade", "P0142.7 Export and import unit value indices",
  "P6420.*Food", 1, 1, "H18", "P6420_food", "P6420 Food and beverages",
  "P7162", 1, 1, "_LABEL_", "P7162_transport","P7162 Land transport survey",
  "P0043\\.", 1, 1, "H25", "P0043.1_liquidations","P0043.1 Liquidations",
  "P0043.*insolvencies", 1, 1, "H25", "P0043_insolvencies","P0043 Liquidations and insolvencies",
  "P3041", 1, 1, "H25", "P3041.2_manufacturing","P3041.2 Manufacturing: Production and sales",
  "P2041.*\\(", 2, 1, "H25", "P2041_mining","P2041 Mining Production and sales",
  "P6343.*\\(20", 2, 1, "H25", "P6343.2_vehicles","P6343.2 Motor trade sales",
  "P0142\\.1.*New", 1, 1, "H25", "P0142.1_PPI","P0142.1 PPI New series from 2013",
  "P6242.*New", 1, 1, "H25", "P6242.1_retail","P6242.1 Retail trade sales from January 2002",
  "P6141\\.2", 2, 1, "H25", "P6141.2_wholesale","P6141.2 Wholesale trade sales")

# Check which data has been downloaded already
# Load all STATSSA datasets
Package_links <- bind_rows(STATSSA_P0141_CPI_urban,
                           STATSSA_P0141_CPI_province,
                           STATSSA_P0141_CPI_digit,
                           STATSSA_P0141_CPI_COICOP,
                           STATSSA_P6410_tourists,
                           STATSSA_P5041.1_building,
                           STATSSA_P0151.1_construction,
                           STATSSA_P4141_electricity,
                           STATSSA_P0142.7_trade,
                           STATSSA_P6420_food) %>%
  select(Link) %>%
  distinct()

Links_to_check <- STATSSA_links[grepl(paste(Data_info$file_id, collapse = "|"), STATSSA_links)]
Links_to_check <- Links_to_check[!grepl("discontinued", Links_to_check)]
Links_to_check <- Links_to_check[!grepl("Previous", Links_to_check)]

Links_df <- tibble(Original_links = Links_to_check,
                   Link = str_replace(Links_to_check, " https://www.statssa.gov.za/../timeseriesdata/Excel/", ""))

Links_to_download <- Links_df %>%
  anti_join(Package_links, by = "Link")

# Get name of file without date
Updated_files <- str_sub(Links_to_download$Link, 1, 20)

if (nrow(Links_to_download) == 0) {

  print("All data up to date.")

} else {

  # Only keep rows where new data is available
  Data_info <- Data_info %>%
    filter(str_detect(file_name, paste(Updated_files, collapse = "|")))

  # Remove all files that are there already
  unlink("data-raw/STATSSA/Downloads/*")
  unlink("data-raw/STATSSA/Unzipped/*")
  unlink("data-raw/STATSSA/Unzipped/Excel/*")

  # Click on link to download
  for (i in Links_to_download$Link) {
    webElem <- remDr$findElement("xpath", paste0("//a[contains(@href, '", i,"')]"))
    Sys.sleep(1)
    webElem$clickElement()
    Sys.sleep(2)
    print(i)
  }

  # Wait for downloads to finish
  Sys.sleep(10)

  system(paste0("docker cp ",container_id,":/home/seluser/Downloads data-raw/STATSSA"))

  downloaded_files <- list.files(path = "data-raw/STATSSA/Downloads",
                                 pattern = ".zip",
                                 full.names = TRUE)

  # Function to unzip and save file and read excel sheet
  unzip_and_read <- function(file_id, file_number, sheet_number) {

    zipped_file <- downloaded_files[grepl(file_id, downloaded_files)]
    zipped_file <- zipped_file[!grepl("discontinued", zipped_file)]
    unzipped_file_name <- unzip(zipped_file, list = TRUE)
    unzipped_file <- unzip(zipfile=zipped_file,
                           files = unzipped_file_name$Name[file_number],
                           exdir="data-raw/STATSSA/Unzipped")
    xlsx_sheet_names <- excel_sheets(unzipped_file)
    read_excel(unzipped_file, sheet = xlsx_sheet_names[sheet_number]) %>%
      mutate(across(everything(), as.character))

  }

  for (i in seq_len(nrow(Data_info))) {

    data_xlsx <- unzip_and_read(Data_info$file_id[i],
                                Data_info$file_number[i],
                                Data_info$sheet_number[i])

      data_xlsx_long <- data_xlsx %>%
        pivot_longer(-(H01:Data_info$final_column[i]), names_to = "Date_original", values_to = "Value") %>%
        mutate(Link = str_replace(downloaded_files[grepl(Data_info$file_id[i], downloaded_files)],
                                  "data-raw/STATSSA/Downloads/", ""),
               Date = str_replace(Date_original, "-", ""),
               Date = str_replace(Date, "M2", "2"),
               Date = str_replace(Date, "MO", "")) %>%
        filter(!grepl("Online Price", Date)) %>%
        mutate(Date = if_else(str_sub(Date, 1, 1) == "4",
                              excel_numeric_to_date(as.numeric(Date)),
                              if_else(nchar(Date) == 7,
                                      as.Date(paste0("01", Date), format = '%d%b%Y'),
                                      if_else(nchar(Date) == 5,
                                              as.Date(paste0("01", Date), format = '%d%b%y'),
                                              if_else(str_sub(Date, 1, 1) == "2",
                                                      as.Date(paste0("01", Date), format = '%d%Y%m'),
                                                      as.Date(paste0("01", Date), format = '%d%m%Y'))))),
               Month_number = month(Date),
               Month = month(Date, label = TRUE, abbr = FALSE),
               Quarter = ifelse(!is.na(Month),
                                case_when(
                                  Month %in% c("January", "February", "March") ~ 1,
                                  Month %in% c("April", "May", "June") ~ 2,
                                  Month %in% c("July", "August", "September") ~ 3,
                                  Month %in% c("October", "November", "December") ~ 4
                                ), ifelse(grepl("Q", Date), as.numeric(str_sub(Date, 7, 7)), NA)),
               Year = as.numeric(str_sub(Date, 1, 4)),
               Fiscal_year = ifelse(!is.na(Month),
                                    ifelse(Month %in% c("January", "February", "March"), Year, Year + 1),
                                    ifelse(!is.na(Quarter), ifelse(Quarter == 1, Year, Year + 1), NA)))

      temp_name <- paste0("STATSSA_",Data_info$name[i])

      assign(temp_name, data_xlsx_long)

      do.call("use_data", list(as.name(temp_name), overwrite = TRUE))

  }

  # Remove all files that are there already
  unlink("data-raw/STATSSA/Downloads/*")
  unlink("data-raw/STATSSA/Unzipped/*")
  unlink("data-raw/STATSSA/Unzipped/Excel/*")

}


