
# Downloading SARB monthly data ----------------------------------------------

library(RSelenium)
library(tidyverse)
library(tidyxl)
library(unpivotr)
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
remDr$navigate("https://www.resbank.co.za/en/home/what-we-do/statistics/releases/selected-statistics")

Data_info <- tribble(
  ~name, ~abbr,
  "Money_and_banking", "MRDMA",
  "Banks_and_mutual_banks", "MRDBM",
  "International_economic_data", "MRDIE",
  "Capital_market", "MRDCM",
  "National_government_finance","MRDFG",
  "Economic_indicators", "MRDEI",
  "Credit_detail", "CDACSM",
  "Credit_aggregates", "CDASA",
  "Deposit_detail", "CDADS",
  "Securitisation", "CDACA",
  "Counterparts_of_M3", "CDACM3"
)

# Click on link to download
for (i in seq_len(nrow(Data_info))) {
  print(paste0("Trying to download ", Data_info$name[i]))
  webElem <- remDr$findElement("xpath", paste0("//*/div[@class='mb-5']//*/div/a[@value='",Data_info$abbr[i],"']"))
  webElem$clickElement()
  Sys.sleep(1)
  webElem <- remDr$findElement("xpath", "//*/i[@class='icon-download']")
  webElem$clickElement()
  # Need to wait a long time for it to download
  Sys.sleep(30)
  system(paste0("docker cp ",container_id,":/home/seluser/Downloads/MonthlyRelease.xlsx data-raw/SARB/Monthly/", Data_info$name[i], ".xlsx"))
  Sys.sleep(2)
  system(paste0("docker exec ",container_id," rm -rf /home/seluser/Downloads/MonthlyRelease.xlsx"))
  webElem <- remDr$findElement("xpath", "//*/div[@class='monthlyReleaseSelection__button']/a")
  webElem$clickElement()
  cat(" - done.")
}

# Import each data set
for (i in seq_len(nrow(Data_info))) {

  # Load data
  Monthly_data <- xlsx_cells(paste0("data-raw/SARB/Monthly/", Data_info$name[i], ".xlsx")) %>%
    behead("up-left", H1) %>%
    behead("up", H2) %>%
    behead("left", Date_original) %>%
    mutate(Value = if_else(data_type == "character",
                           as.numeric(str_replace_all(character, ",", "")),
                           numeric)) %>%
    filter(!is.na(Value)) %>%
    select(H1, H2, Date_original, Value) %>%
    mutate(Date = as.Date(paste0("01", Date_original), format = '%d%b, %Y'),
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
                                ifelse(!is.na(Quarter), ifelse(Quarter == 1, Year, Year + 1), NA))) %>%
    arrange(factor(H1, as.character(unique(H1))), H2, Date)

  temp_name <- paste0("SARB_monthly_",Data_info$name[i])

  assign(temp_name, Monthly_data)

  do.call("use_data", list(as.name(temp_name), overwrite = TRUE))

}





