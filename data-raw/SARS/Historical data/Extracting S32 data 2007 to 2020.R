#### Downloading and extracting historical SARS revenue data from PDF ####

# Packages
library(pdftools)
library(glue)
library(tidyverse)

# Good example
# http://www.brodrigues.co/blog/2018-06-10-scraping_pdfs/

# # ONLY RUN FIRST TIME
#
# # Create years vector
# year <- c("04", "05", "06", "07", "08", "09", "10", "11", "12", "14", "15", "16")
# # Base url for most years
# urls <- glue("http://www.treasury.gov.za/comm_media/press/monthly/{year}05/04-03/schedule_1.pdf")
# # Create names for files
# pdf_names <- glue("data-raw/SARS/Historical data/FYE_20{year}.pdf")
# # Download and save reports
# walk2(urls, pdf_names, download.file, mode = "wb")
#
# # Manually download urls that don't match
# # 2003
# download.file("http://www.treasury.gov.za/comm_media/press/monthly/0405/04-03-03/schedule_1.pdf",
#               destfile = "data-raw/SARS/Historical data/FYE_2003.pdf", mode = "wb")
# # 2013
# download.file("http://www.treasury.gov.za/comm_media/press/monthly/1305/04-05/statement_1.pdf",
#               destfile = "data-raw/SARS/Historical data/FYE_2013.pdf", mode = "wb")
# # 2017
# download.file( "http://www.treasury.gov.za/comm_media/press/monthly/1705/04-15/Table%201.pdf",
#               destfile = "data-raw/SARS/Historical data/FYE_2017.pdf", mode = "wb")
# # 2018
# download.file("http://www.treasury.gov.za/comm_media/press/monthly/1805/07-01/Table%201.pdf",
#               destfile = "data-raw/SARS/Historical data/FYE_2018.pdf", mode = "wb")
# # 2019
# download.file("http://www.treasury.gov.za/comm_media/press/monthly/1905/04-03/Table%201%20April%202018%20to%20March%202019.pdf",
#               destfile = "data-raw/SARS/Historical data/FYE_2019.pdf", mode = "wb")
# # 2020
# download.file("http://www.treasury.gov.za/comm_media/press/monthly/2005/04-03/Table%201.pdf",
#               destfile = "data-raw/SARS/Historical data/FYE_2020.pdf", mode = "wb")


# Run from here to extract pdf data ---------------------------------------

# Recreate pdf names with all years
year <- 2003:2020
# Create names for files
pdf_names <- glue("data-raw/SARS/Historical data/FYE_{year}.pdf")

# Extract the text from all the pdfs
raw_text <- map(pdf_names, pdf_text)

# Try a loop

# i <- 2008

j <- 1
for (i in 2020:2007) {

  # Try for latest year
  table <- raw_text[[-(2002-i)]]
  table <- str_split(table, "\n", simplify = TRUE)
  tax_year <- str_trim(str_replace(table[1,2], "\\r", ""))
  s32_cols <- table[1,3]
  s32_cols <- str_trim(s32_cols, side = "left")
  s32_cols <- str_replace_all(s32_cols, "\\s{2,}", "#")
  s32_cols <- str_replace_all(s32_cols, "\\r", "")
  s32_cols <- str_split(s32_cols, pattern = "#", simplify = TRUE)

  if (i <= 2008) {
    s32_cols <- s32_cols[-1]
  }

  if (i >= 2018) {
    table_start <- stringr::str_which(table, "Taxes on income and profits")
    table_end <- stringr::str_which(table, "Revenue collected according to Table 4")
  } else if (i %in% c(2017:2015)) {
    table_start <- stringr::str_which(table, "Taxes on income, profits and capital gains")
    table_end <- stringr::str_which(table, "Revenue collected according to table 4")
  } else if (i %in% c(2014:2010)) {
    table_start <- stringr::str_which(table, "Taxes on income, profits and capital gains")
    table_end <- stringr::str_which(table, "Revenue collected according to table 5")
  } else if (i %in% c(2009:2003)) {
    table_start <- stringr::str_which(table, "Taxes on income and profits")
    table_end <- stringr::str_which(table, "Revenue collected according to table 5")
  }

  table <- table[1, table_start:table_end]

  # Record which row is which type of category
  table <- str_trim(table, side = "left")

  # Need to remove footnotes
  table <- str_replace(table, "\\s[0-9]\\)", "")
  table <- str_replace(table, "\\s[0-9][0-9]\\)", "")
  table <- str_replace(table, "\\r", "")
  table <- str_replace_all(table, "\\s{2,}", "|")

  if (i == 2008) {
    table[46] <- str_replace(table[46], ", 4\\)\\|", "")
    table <- str_replace(table, " \\(RAF\\)", "")
    table <- str_replace(table, " \\(UIF\\)", "")
  }
  if (i == 2007) {
    table[48] <- str_replace(table[46], ", 4\\)\\|", "")
  }


  if (i >= 2017) {
    # Last 7 rows have no values in first column
    table[(length(table) - 6):length(table)] <- str_replace(table[(length(table) - 6):length(table)], "\\|", "||")
  } else if (i <= 2016) {
    table[(length(table) - 11):length(table)] <- str_replace(table[(length(table) - 11):length(table)], "\\|", "||")
  } else if (i <= 2009) {

  }

  # And some more blank spaces
  if (i == 2020) {
    table[(length(table) - 25):(length(table) - 9)] <- str_replace(table[(length(table) - 25):(length(table) - 9)], "\\|", "||")
    # Also add for refunds
    table[29] <- str_replace_all(table[29], "\\) ", "\\)|")
  }

  # And some more blank spaces
  if (i == 2019) {
    table[(length(table) - 22):(length(table) - 9)] <- str_replace(table[(length(table) - 22):(length(table) - 9)], "\\|", "||")
    table[29] <- str_replace_all(table[29], "\\) ", "\\)|")
  }

  if (i == 2012) {
    table[82] <- str_replace_all(table[82], "\\) ", "\\)|")
    table[83] <- str_replace_all(table[83], "\\) ", "\\)|")
  }

  if (i %in% c(2010, 2008)) {
    table <- str_replace_all(table, "(?<=[0-9]) ", "|")
    table <- str_replace_all(table, "\\) ", "\\)|")
  }

  text_con <- textConnection(table)
  SARS_temp <- read.csv(text_con, sep = "|", header = FALSE)
  colnames(SARS_temp) <- c("Tax", s32_cols)

  if (i == 2013) {
    SARS_temp <- SARS_temp %>%
      select(-16, -17, -18)
  }

  colnames(SARS_temp) <- paste0(colnames(SARS_temp), c("", "", rep(paste0("_", i-1), 9), rep(paste0("_", i), 3)))

  # Category <- Category[1:nrow(SARS_temp)]

  # Make all columns numeric
  if (i %in% c(2020, 2015)) {
    SARS_temp <- SARS_temp %>%
      mutate(across(c(-Tax), ~ gsub(" ", "", .)))
  } else if (c(2019:2016)) {
    SARS_temp <- SARS_temp %>%
      mutate(across(c(-Tax), ~ gsub(",", "", .)))
  }

  SARS_temp <- SARS_temp %>%
    mutate(across(c(-Tax), ~ gsub("\\(", "-", .)),
           across(c(-Tax), ~ gsub("\\)", "", .)),
           across(c(-Tax), as.numeric))

  # Change NAs to 0s
  SARS_temp[is.na(SARS_temp)] <- 0

  SARS_temp <- SARS_temp %>%
    mutate(Tax = str_squish(Tax))

  # Sum up rows which are empty
  SARS_temp <- SARS_temp %>%
    mutate(across(c(-Tax), ~ifelse(Tax == "Tax on corporate income",
                                   lead(., 1) + lead(., 2) + lead(., 3) + lead(., 4), .)),
           across(c(-Tax), ~ifelse(Tax == "Other" & lead(Tax) == "Interest on overdue income tax",
                                   lead(., 1) + lead(., 2), .)),
           across(c(-Tax), ~ifelse(Tax == "Estate, inheritance and gift taxes",
                                   lead(., 1) + lead(., 2), .)),
           across(c(-Tax), ~ifelse(Tax == "Taxes on financial and capital transactions",
                                   lead(., 1) + lead(., 2), .)),
           across(c(-Tax), ~ifelse(Tax == "Specific excise duties",
                                   lead(., 1) + lead(., 2) + lead(., 3) + lead(., 4) +
                                     lead(., 5) + lead(., 6) + lead(., 7) + lead(., 8), .)),
           across(c(-Tax), ~ifelse(Tax == "Other" & lead(Tax) == "Universal Service Fund",
                                   lead(., 1), .)),
           across(c(-Tax), ~ifelse(Tax == "Import duties",
                                   lead(., 1) + lead(., 2), .)),
           across(c(-Tax), ~ifelse(Tax == "Other" & lead(Tax) == "Miscellaneous customs and excise receipts",
                                   lead(., 1) + lead(., 2), .)))


  if (i <= 2008) {
    SARS_temp <- SARS_temp %>%
      mutate(across(c(-Tax), ~ifelse(Tax == "Mining leases and ownership", lead(., 1), .))) %>%
      filter(Tax != "Other mines",
             Tax != "use goods or to perform activities") %>%
      mutate(Tax = str_replace(Tax, "Mining leases and ownership", "Mineral and petroleum royalties"),
             Tax = str_replace(Tax, "Marketable securities tax", "Securities transfer tax"),
             Tax = str_replace(Tax, "Taxes on use of goods or permission to", "Taxes on use of goods and on permission to use goods or perform activities"),
             Tax = str_replace(Tax, "Revenue collected on behalf of the Road Accident Fund \\(RAF\\) for February",
                               "Revenue collected on behalf of the Road Accident Fund"))
  }

  if (i >= 2016) {
    SARS_temp <- SARS_temp %>%
      mutate(across(c(-Tax), ~ifelse(Tax == "Tax on corporate income",
                                     lead(., 1) + lead(., 2) + lead(., 3) + lead(., 4), .)),
             across(c(-Tax), ~ifelse(Tax == "Taxes on use of goods and on permission to use goods or perform activities",
                                     lead(., 1) + lead(., 2) + lead(., 3) + lead(., 4) +
                                       lead(., 5) + lead(., 6) + lead(., 7), .)))
  }

  if (i <= 2016) {
    SARS_temp <- SARS_temp %>%
      mutate(across(c(-Tax), ~ifelse(Tax == "Taxes on use of goods and on permission to use goods or perform activities",
                                     lead(., 1) + lead(., 2) + lead(., 3) + lead(., 4) + lead(., 5), .)))
  }

  if (i <= 2010) {
    SARS_temp <- SARS_temp %>%
      mutate(across(c(-Tax), ~ifelse(Tax == "Taxes on use of goods and on permission to use goods or perform activities",
                                     lead(., 1) + lead(., 2) + lead(., 3) + lead(., 4), .)))
  }
  if (i <= 2009) {
    SARS_temp <- SARS_temp %>%
      mutate(across(c(-Tax), ~ifelse(Tax == "Taxes on use of goods and on permission to use goods or perform activities",
                                     lead(., 1) + lead(., 2), .)))
  }

  if (i %in% c(2015, 2012)) {
    SARS_temp <- SARS_temp %>%
      mutate(across(c(-Tax), ~ifelse(Tax == "Tax on corporate income",
                                     lead(., 1) + lead(., 2) + lead(., 3), .)))
  }

  if (i <= 2014) {
    SARS_temp <- SARS_temp %>%
      mutate(across(c(-Tax), ~ifelse(Tax == "Tax on corporate income",
                                     lead(., 1) + lead(., 2) + lead(., 3) + lead(., 4), .)))
  }

  if (i <= 2012) {
    SARS_temp <- SARS_temp %>%
      mutate(across(c(-Tax), ~ifelse(Tax == "Import duties", lead(., 1), .)))
  }

  # Change others
  SARS_temp <- SARS_temp %>%
    mutate(Tax = ifelse(Tax == "Other" & lead(Tax) == "Interest on overdue income tax", "Other: Taxes on income and profits", Tax),
           Tax = ifelse(Tax == "Other" & lead(Tax) == "Universal Service Fund", "Other: Taxes on goods and services", Tax),
           Tax = ifelse(Tax == "Other" & lead(Tax) == "Miscellaneous customs and excise receipts", "Other: Taxes on international trade and transactions", Tax))

  # Duplicate row
  SARS_temp <- SARS_temp %>%
    distinct(Tax, .keep_all = TRUE)

  SARS_temp <- SARS_temp %>%
    filter(Tax != "Of which:")

  if (i %in% c(2020:2018)) {
    SARS_temp <- SARS_temp %>%
      mutate(Tax = case_when(
        Tax == "Taxes on income and profits" ~ "Taxes on income, profits and capital gains",
        Tax == "Value-added tax" ~ "Value added tax",
        Tax == "Departmental revenue received but not yet paid to NRF" ~
          "Departmental revenue received but not yet paid to the National Revenue Fund",
        TRUE ~ Tax
      ))
  }

  if (i %in% c(2020, 2019)) {
    SARS_temp <- SARS_temp %>%
      mutate(Tax = case_when(
        Tax == "Personal income tax" ~ "Income tax on persons and individuals",
        Tax == "NRF receipts" ~ "National Revenue Fund receipts",
        Tax == "Direct transfer from NRF to the RAF" ~
          "Direct transfer from National Revenue Fund to the Road Accident Fund",
        Tax == "Direct transfer from NRF to the UIF" ~
          "Direct transfer from National Revenue Fund to the Unemployment Insurance Fund",
        Tax == "Cash balance NRF" ~ "Cash balance National Revenue Fund",
        Tax == "Provincial revenue collected by SARS and transferred by NRF" ~
          "Provincial revenue collected by SARS and transferred by National Treasury",
        Tax == "CARA added as part of cash revenue in Table 4" ~
          "Recovery of criminal assets added as part of cash revenue in table 4",
        Tax == "Revenue collected on behalf of the RAF" ~
          "Revenue collected on behalf of the Road Accident Fund",
        Tax == "Revenue collected on behalf of the UIF" ~
          "Revenue collected on behalf of the Unemployment Insurance Fund",
        TRUE ~ Tax
      ))
  }

  if (i %in% c(2019, 2018)) {
    SARS_temp <- SARS_temp %>%
      mutate(Tax = str_replace(Tax, "ETI credit - Refunds", "ETI credit - refunds"),
             Tax = str_replace(Tax, "PIT Refunds", "PIT refunds"),
             Tax = str_replace(Tax, "Imports on health promotion levy", "Health promotion levy on imports"))
  }

  if (i == 2019) {
    SARS_temp <- SARS_temp %>%
      mutate(Tax = str_replace(Tax, "Fines, penalties and forfeits", "Fines penalties and forfeits"))
  }

  if (i == 2018) {
      SARS_temp <- SARS_temp %>%
        mutate(Tax = case_when(
          Tax == "Tax on Persons and Individuals" ~ "Income tax on persons and individuals",
          Tax == "National Revenue Fund Receipts" ~ "National Revenue Fund receipts",
          Tax == "Direct transfer from National Revenue Fund to the RAF" ~
            "Direct transfer from National Revenue Fund to the Road Accident Fund",
          Tax == "Direct transfer from National Revenue Fund to the UIF" ~
            "Direct transfer from National Revenue Fund to the Unemployment Insurance Fund",
          TRUE ~ Tax
        ))
  }

  if (i >= 2018) {
  SARS_temp <- SARS_temp %>%
    mutate(Tax = str_replace(Tax, "Table 4", "table 4"),
           Tax = str_squish(Tax))
  }

  if (i <= 2018) {
    SARS_temp <- SARS_temp %>%
      mutate(Tax = case_when(
        Tax == "Companies" ~ "Corporate income tax",
        Tax == "Unallocated tax revenue" ~ "State miscellaneous revenue",
        Tax == "Non- tax receipts" ~ "Non-tax receipts",
        Tax == "Revenue collected on behalf of the Road Accident Fund (RAF)" ~
          "Revenue collected on behalf of the Road Accident Fund",
        Tax == "Revenue collected on behalf of the Unemployment Insurance Fund (UIF)" ~
          "Revenue collected on behalf of the Unemployment Insurance Fund",
        TRUE ~ Tax
      ))
  }

  if (i <= 2015) {
    SARS_temp <- SARS_temp %>%
      mutate(Tax = case_when(
        Tax == "Traditional beer and traditional beer powder" ~ "Sorghum beer and sorghum flour",
        TRUE ~ Tax
      ))
  }

  if (i <= 2014) {
    SARS_temp <- SARS_temp %>%
      mutate(Tax = str_replace(Tax, "table 5", "table 4"),
             Tax = str_replace(Tax, "statement 5", "table 4"))
  }

  if (i <= 2013) {
    SARS_temp <- SARS_temp %>%
      mutate(Tax = str_replace(Tax, "Provincial revenue collected by SARS and transferred by National Treasury for February",
                               "Provincial revenue collected by SARS and transferred by National Treasury"))
  }

  if (i <= 2012) {
    SARS_temp <- SARS_temp %>%
      mutate(Tax = str_replace(Tax, "Levies on fuel", "General fuel levy"))
  }

  if (i <= 2011) {
    SARS_temp <- SARS_temp %>%
      mutate(Tax = str_replace(Tax, "Of which actual collections for Mineral and petroleum royalties are", "Mineral and petroleum royalties"),
             Tax = str_replace(Tax, "Provincial revenue collected by SARS and transferred by National Treasury for Feb",
                               "Provincial revenue collected by SARS and transferred by National Treasury"))
  }

  if (i <= 2009) {
    SARS_temp <- SARS_temp %>%
      mutate(Tax = case_when(
        Tax == "Taxes on income and profits" ~ "Taxes on income, profits and capital gains",
        Tax == "Domestic taxes on goods and services" ~ "Taxes on goods and services",
        Tax == "Taxes on use of goods or permission to use goods or to perform activities" ~
          "Taxes on use of goods and on permission to use goods or perform activities",
        Tax == "Of which: Mining leases and ownership" ~ "Mineral and petroleum royalties",
        TRUE ~ Tax
      ))
  }

  if (i == 2008) {
    SARS_temp <- SARS_temp %>%
      mutate(Tax = case_when(
        Tax == "Companies" ~ "Corporate income tax",
        Tax == "Unallocated tax revenue" ~ "State miscellaneous revenue",
        Tax == "Non- tax receipts" ~ "Non-tax receipts",
        Tax == "Revenue collected on behalf of the Road Accident Fund for February" ~
          "Revenue collected on behalf of the Road Accident Fund",
        TRUE ~ Tax
      ))
  }

  if (i == 2007) {
    SARS_temp <- SARS_temp %>%
      filter(Tax != "Levy on financial services",
             Tax != "Taxes on specific services",
             Tax != "Other Receipts")
  }


  # Clean up, reshape and add Calendar year
  SARS_annual_temp <- SARS_temp %>%
    select(Tax, `Year to date`) %>%
    rename_at("Year to date", list( ~paste0(i-1, "/", i)))

  SARS_temp <- SARS_temp %>%
    select(-Revised, -`Year to date`)

  if (j == 1) {
    SARS_temp <- SARS_temp %>%
      mutate(Category_number = row_number())

    SARS_annual_temp <- SARS_annual_temp %>%
      mutate(Category_number = row_number())
  }

  assign(paste0("SARS_monthly_", i), SARS_temp)
  assign(paste0("SARS_annual_", i), SARS_annual_temp)

  if (j == 1) {
    # Merge years of data
    SARS_monthly <- mget(paste0("SARS_monthly_", i))[[1]]
    SARS_annual <- mget(paste0("SARS_annual_", i))[[1]]
  } else {
    SARS_monthly <- mget(c(paste0("SARS_monthly_", i), "SARS_monthly")) %>%
      reduce(full_join) %>%
      arrange(Category_number)
    SARS_annual <- mget(c(paste0("SARS_annual_", i), "SARS_annual")) %>%
      reduce(full_join) %>%
      arrange(Category_number)
  }

  # Rearrange for extra line items
  if (i == 2014) {
    SARS_monthly <- SARS_monthly %>%
      mutate(Category_number = ifelse(Tax == "Tax on retirement funds", 12.1, Category_number)) %>%
      arrange(Category_number)
  }

  j <- j + 1
}

colnames(SARS_monthly)[1] <- "Revenue"
colnames(SARS_annual)[1] <- "Revenue"

save(SARS_monthly, file = "data-raw/SARS/SARS_monthly.rda")
save(SARS_annual, file = "data-raw/SARS/SARS_annual.rda")

# Can manually check whether it is all lined up alright

load("data-raw/SARS/SARS_monthly.rda")
load("data-raw/SARS/SARS_annual.rda")

# Reshape
SARS_monthly <- SARS_monthly %>%
  select(-Category_number)

# SARS_monthly <- SARS_monthly %>%
#   pivot_longer(c(-Tax)) %>%
#   filter(!is.na(value)) %>%
#   separate(name, into = c("Month", "Year"), sep = "_") %>%
#   mutate(Year = as.numeric(Year),
#          Fiscal_year = if_else(Month %in% c("January", "February", "March"), Year, Year + 1)) %>%
#   select(Tax, Year, Fiscal_year, Month, Revenue = value)

SARS_annual <- SARS_annual %>%
  select(-Category_number)

# SARS_annual <- SARS_annual %>%
#   pivot_longer(-Tax, names_to = "Fiscal_year", values_to = "Revenue")

usethis::use_data(SARS_monthly, overwrite = TRUE)
usethis::use_data(SARS_annual, overwrite = TRUE)
