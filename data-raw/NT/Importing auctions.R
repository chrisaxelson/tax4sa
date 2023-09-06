
#  Importing all the auction data from NT ---------------------------------

library(tidyverse)

# Download and save data from this page
# https://investor.treasury.gov.za/Pages/Auctions.aspx?RootFolder=%2FHistorical%20Results%2FSwitch%20auctions&FolderCTID=0x0120000FC2FD67C4F46B45926B1F1A98F8918D&View={F2C81696-1FED-4C3C-AA4C-A66A57B6EB54}

# Fixed rate bonds

Years <- c(2010, 2012:2023)
url <- "https://investor.treasury.gov.za/Historical%20Results/Fixed-rate%20bonds/Fixed-rate%20bond%20auctions%20-%20"

for (i in Years) {
  file_ext <- ifelse(i < 2020, ".xls", ".xlsx")
  added_years <- ifelse(i == 2010, 3, 1)
  download.file(paste0(url, i, "-", i - 2000 + added_years, file_ext),
                paste0("data-raw/NT/Auctions/Fixed_rate/", i, "-", i - 2000 + added_years, file_ext), mode = "wb")
  print(i)
}

# Inflation linked

Years <- c(2010, 2012:2023)
url <- "https://investor.treasury.gov.za/Historical%20Results/Inflation-linked%20bonds/Inflation-linked%20%20bond%20auctions%20-%20"

for (i in Years) {
  file_ext <- ifelse(i < 2020, ".xls", ".xlsx")
  added_years <- ifelse(i == 2010, 3, 1)
  download.file(paste0(url, i, "-", i - 2000 + added_years, file_ext),
                paste0("data-raw/NT/Auctions/Inflation_linked/", i, "-", i - 2000 + added_years, file_ext), mode = "wb")
  print(i)
}


# Treasury bills

Years <- 2010:2023
url <- "https://investor.treasury.gov.za/Historical%20Results/Treasury%20bills/Treasury%20bill%20auctions%20-%20"

for (i in Years) {
  file_ext <- ".xls"
  download.file(paste0(url, i, "-", i - 2000 + added_years, file_ext),
                paste0("data-raw/NT/Auctions/Treasury_bills/", i, "-", i - 2000 + added_years, file_ext), mode = "wb")
  print(i)
}

# Switch auctions

Years <- 2014:2022
url <- "https://investor.treasury.gov.za/Historical%20Results/Switch%20auctions/Historical%20Switch%20Auction%20Results%20-%20"

for (i in Years) {
  file_ext <- ".xls"
  download.file(paste0(url, i, "-", i - 2000 + added_years, file_ext),
                paste0("data-raw/NT/Auctions/Switch_auctions/", i, "-", i - 2000 + added_years, file_ext), mode = "wb")
  print(i)
}

# Floating rate notes

Years <- 2022:2023
url <- "https://investor.treasury.gov.za/Historical%20Results/Floating-rate%20note%20auctions/Floating-rate%20note%20auctions%20-%20"

for (i in Years) {
  file_ext <- ".xls"
  download.file(paste0(url, i, "-", i - 2000 + added_years, file_ext),
                paste0("data-raw/NT/Auctions/Floating_rate_notes/", i, "-", i - 2000 + added_years, file_ext), mode = "wb")
  print(i)
}

