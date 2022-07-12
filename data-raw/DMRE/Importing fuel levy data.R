
# Scraping fuel prices and taxes ------------------------------------------

library(tidyverse)
library(rvest)
library(pdftools)
library(glue)
library(lubridate)
library(fuzzyjoin)

# Scraping from SAPIA -----------------------------------------------------

content <- read_html("https://www.sapia.org.za/Overview/Old-fuel-prices")

tables <- content %>% html_table(fill = TRUE)

for (i in 1:length(tables)) {

  table_i <- tables[[i]]

  # Last few tables have a shorter length - need variable to get correct rows
  table_i_rows <- nrow(table_i)

  # Ignore explanatory tables
  if (table_i_rows > 10) {

    # Only keep rows with data
    Coastal <- table_i[c(3:8),]
    colnames(Coastal) <- c("Fuel_type", table_i[1, 2:13])
    Coastal <- Coastal %>%
      mutate(Region = "Coastal") %>%
      pivot_longer(contains("-"), names_to = "Date", values_to = "Price")

    Gauteng <- table_i[c(10:table_i_rows), ]
    colnames(Gauteng) <- c("Fuel_type", table_i[1, 2:13])
    Gauteng <- Gauteng %>%
      mutate(Region = "Gauteng") %>%
      pivot_longer(contains("-"), names_to = "Date", values_to = "Price")

    Fuel_prices_i <- bind_rows(Coastal, Gauteng) %>%
      mutate(Date = dmy(Date)) %>%
      filter(Price != "")

    if (i == 1) {
      Fuel_prices <- Fuel_prices_i

    } else {
      Fuel_prices <- bind_rows(Fuel_prices, Fuel_prices_i)
    }

  }
  print(i)
}

Fuel_prices <- Fuel_prices %>%
  arrange(Date, Fuel_type, Region) %>%
  mutate(Price = str_replace_all(Price, ",", "."),
         Price = str_replace_all(Price, " ", ""),
         Price = as.numeric(Price),
         ULP = if_else(grepl("ULP|LRP", Fuel_type), 1, 0),
         Diesel_0.05 = if_else(grepl("Diesel 0.05", Fuel_type), 1, 0),
         Diesel_0.005 = if_else(grepl("Diesel 0.005", Fuel_type), 1, 0))

# Scraping petrol taxes from DMRE -----------------------------------------

#  https://www.brodrigues.co/blog/2018-06-10-scraping_pdfs/

# Create vectors for urls
year <- 2012:2022
month_name <- c("December", "Dec-", rep("December", 8), "June")
pdf_name <- c("Petrol_price_Margin", "Petrol-Price-Margin", "Petrol-price-Margin",
              rep("Petrol-Price-Margin", 2),
              rep("Petrol-margins", 4),
              "Erratum-Petrol-margins", "Petrol-margins")

# Base url for most years
urls <- glue("http://www.energy.gov.za/files/esources/petroleum/{month_name}{year}/{pdf_name}.pdf")

# Create names for pdfs to be saved as
pdf_files <- glue("DMRE_levies_{year}.pdf")

# Download and save as particular names
walk2(urls, pdf_files, download.file, mode = "wb")

# Actual pdf data
raw_text <- map(pdf_files, pdf_text)


for (i in 1:11) {

  year_i <- year[i]

  clean_table <- str_split(raw_text[[i]], "\n", simplify = TRUE)

  if (year_i %in% c(2016, 2017)) {
    table_start <- ceiling(stringr::str_which(clean_table, "Jan ")/2)
    table_end <- ceiling(stringr::str_which(clean_table, "Dec ")/2)
  } else if (year_i == 2022) {
    table_start <- stringr::str_which(clean_table, "Jan ")
    table_end <- stringr::str_which(clean_table, "Jun ")
  } else {
    table_start <- stringr::str_which(clean_table, "Jan ")
    table_end <- stringr::str_which(clean_table, "Dec ")
  }


  if (year_i < 2015) {
    table <- clean_table[1, table_start:table_end] %>%
      as_tibble() %>%
      mutate(value = str_squish(value)) %>%
      separate(value, sep = " ",
               into = c("Month",
                        "Basic_fuel_price",
                        "General_fuel_levy",
                        "Customs_and_excise_levy",
                        "Equalisation_fund_levy",
                        "Road_accident_fund_levy",
                        "Transport_cost",
                        "Petroleum_products_levy",
                        "Wholesale_margin",
                        "Retail_margin",
                        "Slate_levy",
                        "Delivery_cost",
                        "Demand_side_management_levy",
                        "Inland_transport_cost"))

    table <- table %>%
      mutate(across(Basic_fuel_price:Inland_transport_cost, as.numeric),
             Date_begin = dmy(paste0("01", Month, year_i)),
             Date_end = dmy(paste0("07", Month, year_i)))

  } else {
    table <- clean_table[1, table_start:table_end] %>%
      as_tibble() %>%
      mutate(value = str_squish(value)) %>%
      separate(value, sep = " ",
               into = c("Month",
                        "Basic_fuel_price",
                        "General_fuel_levy",
                        "Customs_and_excise_levy",
                        "Equalisation_fund_levy",
                        "Road_accident_fund_levy",
                        "Transport_cost",
                        "Petroleum_products_levy",
                        "Wholesale_margin",
                        "Secondary_storage",
                        "Secondary_distribution",
                        "Retail_margin",
                        "Slate_levy",
                        "Delivery_cost",
                        "Demand_side_management_levy"))

    table <- table %>%
      mutate(across(Basic_fuel_price:Demand_side_management_levy, as.numeric),
             Date_begin = dmy(paste0("01", Month, year_i)),
             Date_end = dmy(paste0("07", Month, year_i)))

  }

  Fuel_prices_i <- fuzzy_left_join(Fuel_prices %>% filter(ULP == 1),
                                   table,
                                       by = c("Date" = "Date_begin",
                                              "Date" = "Date_end"),
                                       match_fun = list(`>=`, `<=`)) %>%
    mutate(Demand_side_management_levy = if_else(grepl("LRP|ULP", Fuel_type) &
                                                   (grepl("93", Fuel_type) | Region == "Coastal"), 0,
                                                 Demand_side_management_levy))

  if (i == 1) {
    Fuel_prices_final <- Fuel_prices_i %>%
      filter(year(Date) == year_i)
  } else {
    Fuel_prices_final <- bind_rows(Fuel_prices_final,
                                   Fuel_prices_i %>%
                                     filter(year(Date) == year_i))
  }
  print(year_i)
}


# Scraping diesel taxes from DMRE  ----------------------------------------

# Create vectors for urls
year <- 2012:2022
month_name <- c("December", "Dec-", rep("December", 8), "June")
pdf_name <- c("Diesel_margins_guidelines",
              rep("Diesel-Price-Margins", 2),
              rep("Diesel-price-margins", 1),
              rep("Diesel-margins", 7))

# Base url for most years
urls <- glue("http://www.energy.gov.za/files/esources/petroleum/{month_name}{year}/{pdf_name}.pdf")

# Create names for pdfs to be saved as
diesel_pdf_files <- glue("DMRE_diesel_levies_{year}.pdf")

# Download and save as particular names
walk2(urls, diesel_pdf_files, download.file, mode = "wb")

# Actual pdf data
raw_text <- map(diesel_pdf_files, pdf_text)


for (i in 1:11) {

  year_i <- year[i]

  clean_table <- str_split(raw_text[[i]], "\n")

  if (year_i < 2016) {
    table_start <- str_which(clean_table[[1]], "Jan ")
    table_end <- str_which(clean_table[[1]], "Dec ")
  } else if (year_i >= 2016 & year_i < 2022) {
    table_start <- c(str_which(clean_table[[1]], "Jan "), str_which(clean_table[[2]], "Jan "))
    table_end <- c(str_which(clean_table[[1]], "Dec "), str_which(clean_table[[2]], "Dec "))
  } else {
    table_start <- c(str_which(clean_table[[1]], "Jan "), str_which(clean_table[[2]], "Jan "))
    table_end <- c(str_which(clean_table[[1]], "Jun "), str_which(clean_table[[2]], "Jun "))

    # Problem with DMRE table
    clean_table[[1]][19] <- paste0("May", clean_table[[1]][19])
  }

  if (year_i == 2021) {
    # DNRE table is incorrect for Dec 2021, manually correct values
    clean_table[[2]][19] <- paste0("Dec 961.030 379 4 0.1 0.33 218 64.9 ",
                                   str_sub(clean_table[[2]][19], start = 30))
  }

  # Do 0.05 first, then 0.005

  if (year_i == 2012) {

    table <- clean_table[[1]][table_start[1]:table_end[1]] %>%
      as_tibble() %>%
      mutate(value = str_squish(value)) %>%
      separate(value, sep = " ",
               into = c("Month",
                        "Basic_fuel_price",
                        "General_fuel_levy",
                        "Customs_and_excise_levy",
                        "IP_tracer_dye_levy",
                        "Pipeline_levy",
                        "Road_accident_fund_levy",
                        "Transport_cost",
                        "Wholesale_margin",
                        "Delivery_cost",
                        "Slate_levy",
                        "Inland_transport_cost"))

    table <- table %>%
      mutate(across(Basic_fuel_price:Inland_transport_cost, as.numeric),
             Date_begin = dmy(paste0("01", Month, year_i)),
             Date_end = dmy(paste0("07", Month, year_i)))

    table2 <- clean_table[[1]][table_start[2]:table_end[2]] %>%
      as_tibble() %>%
      mutate(value = str_squish(value)) %>%
      separate(value, sep = " ",
               into = c("Month",
                        "Basic_fuel_price",
                        "General_fuel_levy",
                        "Customs_and_excise_levy",
                        "IP_tracer_dye_levy",
                        "Pipeline_levy",
                        "Road_accident_fund_levy",
                        "Transport_cost",
                        "Wholesale_margin",
                        "Delivery_cost",
                        "Slate_levy",
                        "Inland_transport_cost"))

    table2 <- table2 %>%
      mutate(across(Basic_fuel_price:Inland_transport_cost, as.numeric),
             Date_begin = dmy(paste0("01", Month, year_i)),
             Date_end = dmy(paste0("07", Month, year_i)))

  } else if (year_i %in% c(2013, 2014)) {

    table <- clean_table[[1]][table_start[1]:table_end[1]] %>%
      as_tibble() %>%
      mutate(value = str_squish(value)) %>%
      separate(value, sep = " ",
               into = c("Month",
                        "Basic_fuel_price",
                        "General_fuel_levy",
                        "Customs_and_excise_levy",
                        "IP_tracer_dye_levy",
                        "Pipeline_levy",
                        "Road_accident_fund_levy",
                        "Transport_cost",
                        "Wholesale_margin",
                        "Secondary_storage",
                        "Secondary_distribution",
                        "Slate_levy",
                        "Inland_transport_cost"))

    table <- table %>%
      mutate(across(Basic_fuel_price:Inland_transport_cost, as.numeric),
             Date_begin = dmy(paste0("01", Month, year_i)),
             Date_end = dmy(paste0("07", Month, year_i)))

    table2 <- clean_table[[1]][table_start[2]:table_end[2]] %>%
      as_tibble() %>%
      mutate(value = str_squish(value)) %>%
      separate(value, sep = " ",
               into = c("Month",
                        "Basic_fuel_price",
                        "General_fuel_levy",
                        "Customs_and_excise_levy",
                        "IP_tracer_dye_levy",
                        "Pipeline_levy",
                        "Road_accident_fund_levy",
                        "Transport_cost",
                        "Wholesale_margin",
                        "Secondary_storage",
                        "Secondary_distribution",
                        "Slate_levy",
                        "Inland_transport_cost"))

    table2 <- table2 %>%
      mutate(across(Basic_fuel_price:Inland_transport_cost, as.numeric),
             Date_begin = dmy(paste0("01", Month, year_i)),
             Date_end = dmy(paste0("07", Month, year_i)))

  } else if (year_i == 2015) {

    table <- clean_table[[1]][table_start[1]:table_end[1]] %>%
      as_tibble() %>%
      mutate(value = str_squish(value)) %>%
      separate(value, sep = " ",
               into = c("Month",
                        "Basic_fuel_price",
                        "General_fuel_levy",
                        "Customs_and_excise_levy",
                        "IP_tracer_dye_levy",
                        "Pipeline_levy",
                        "Road_accident_fund_levy",
                        "Transport_cost",
                        "Wholesale_margin",
                        "Secondary_storage",
                        "Secondary_distribution",
                        "Slate_levy"))

    table <- table %>%
      mutate(across(Basic_fuel_price:Slate_levy, as.numeric),
             Date_begin = dmy(paste0("01", Month, year_i)),
             Date_end = dmy(paste0("07", Month, year_i)))

    table2 <- clean_table[[1]][table_start[2]:table_end[2]] %>%
      as_tibble() %>%
      mutate(value = str_squish(value)) %>%
      separate(value, sep = " ",
               into = c("Month",
                        "Basic_fuel_price",
                        "General_fuel_levy",
                        "Customs_and_excise_levy",
                        "IP_tracer_dye_levy",
                        "Pipeline_levy",
                        "Road_accident_fund_levy",
                        "Transport_cost",
                        "Wholesale_margin",
                        "Secondary_storage",
                        "Secondary_distribution",
                        "Slate_levy"))

    table2 <- table2 %>%
      mutate(across(Basic_fuel_price:Slate_levy, as.numeric),
             Date_begin = dmy(paste0("01", Month, year_i)),
             Date_end = dmy(paste0("07", Month, year_i)))

  } else {

    table <- clean_table[[1]][table_start[1]:table_end[1]] %>%
      as_tibble() %>%
      mutate(value = str_squish(value)) %>%
      separate(value, sep = " ",
               into = c("Month",
                        "Basic_fuel_price",
                        "General_fuel_levy",
                        "Customs_and_excise_levy",
                        "IP_tracer_dye_levy",
                        "Pipeline_levy",
                        "Road_accident_fund_levy",
                        "Transport_cost",
                        "Wholesale_margin",
                        "Secondary_storage",
                        "Secondary_distribution",
                        "Slate_levy")) %>%
      filter(!is.na(Basic_fuel_price))

    table <- table %>%
      mutate(across(Basic_fuel_price:Slate_levy, as.numeric),
             Date_begin = dmy(paste0("01", Month, year_i)),
             Date_end = dmy(paste0("07", Month, year_i)))

    table2 <- clean_table[[2]][table_start[2]:table_end[2]]%>%
      as_tibble() %>%
      mutate(value = str_squish(value)) %>%
      separate(value, sep = " ",
               into = c("Month",
                        "Basic_fuel_price",
                        "General_fuel_levy",
                        "Customs_and_excise_levy",
                        "IP_tracer_dye_levy",
                        "Pipeline_levy",
                        "Road_accident_fund_levy",
                        "Transport_cost",
                        "Wholesale_margin",
                        "Secondary_storage",
                        "Secondary_distribution",
                        "Slate_levy"))

    table2 <- table2 %>%
      mutate(across(Basic_fuel_price:Slate_levy, as.numeric),
             Date_begin = dmy(paste0("01", Month, year_i)),
             Date_end = dmy(paste0("07", Month, year_i)))

  }

  Fuel_prices_i_005 <- fuzzy_left_join(Fuel_prices %>%
                                         filter(Diesel_0.05 == 1), table,
                                   by = c("Date" = "Date_begin",
                                          "Date" = "Date_end"),
                                   match_fun = list(`>=`, `<=`))

  Fuel_prices_i_0005 <- fuzzy_left_join(Fuel_prices %>%
                                         filter(Diesel_0.005 == 1), table2,
                                       by = c("Date" = "Date_begin",
                                              "Date" = "Date_end"),
                                       match_fun = list(`>=`, `<=`))

  Fuel_prices_diesel_i <- bind_rows(Fuel_prices_i_005, Fuel_prices_i_0005)

  if (i == 1) {
    Fuel_prices_diesel <- Fuel_prices_diesel_i %>%
      filter(year(Date) == year_i)
  } else {
    Fuel_prices_diesel <- bind_rows(Fuel_prices_diesel,
                                   Fuel_prices_diesel_i %>%
                                     filter(year(Date) == year_i))
  }
  print(year_i)
}


DMRE_fuel <- bind_rows(Fuel_prices_final,
                                  Fuel_prices_diesel,
                                  Fuel_prices %>%
                                    filter(ULP == 0, Diesel_0.005 == 0, Diesel_0.05 == 0)) %>%
  arrange(Date, Fuel_type, Region) %>%
  select(-ULP, -Diesel_0.05, -Diesel_0.005, -Month, -Date_begin, -Date_end)

DMRE_fuel <- DMRE_fuel %>%
  mutate(Fuel_type = str_replace_all(Fuel_type, "\\*", ""),
         Fuel_type = str_replace(Fuel_type, " \\s*\\([^\\)]+\\)", ""),
         Fuel_type = str_replace(Fuel_type, "%", ""),
         Fuel_type = str_squish(Fuel_type),
         Fuel_type = str_replace_all(Fuel_type, " ", "_"))

DMRE_fuel <- DMRE_fuel %>%
  mutate(Fuel_type = str_replace_all(Fuel_type, "_", " "))

DMRE_fuel <- DMRE_fuel %>%
  mutate(Demand_side_management_levy = if_else(Date == "2019-12-04" & Fuel_type == "95_ULP" & Region == "Gauteng",
                                               10, Demand_side_management_levy))

save(DMRE_fuel,  file = "data-raw/DMRE/DMRE_fuel.rda", version = 2)
load("data-raw/DMRE/DMRE_fuel.rda")
usethis::use_data(DMRE_fuel, overwrite = TRUE)
