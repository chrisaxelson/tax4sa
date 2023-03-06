
# Updating DMRE data -----------------------------------------------------

library(tidyverse)
library(rvest)
library(pdftools)
library(glue)
library(lubridate)
library(fuzzyjoin)

# Scraping from SAPIA -----------------------------------------------------

content <- read_html("https://www.sapia.org.za/fuel-prices")

tables <- content %>% html_table(fill = TRUE)

table_i <- tables[[1]]

# Last few tables have a shorter length - need variable to get correct rows
table_i_rows <- nrow(table_i)

table_year <- colnames(table_i)[1]

# Only keep rows with data
Coastal <- table_i[c(3:7),]
colnames(Coastal) <- c("Fuel_type", colnames(Coastal)[-1])
Coastal <- Coastal %>%
  mutate(Region = "Coastal") %>%
  pivot_longer(contains(" "), names_to = "Date", values_to = "Price") %>%
  mutate(Date = paste(Date, table_year))

Gauteng <- table_i[c(9:15), ]
colnames(Gauteng) <- c("Fuel_type", colnames(Gauteng)[-1])
Gauteng <- Gauteng %>%
  mutate(Region = "Gauteng") %>%
  pivot_longer(contains(" "), names_to = "Date", values_to = "Price") %>%
  mutate(Date = paste(Date, table_year))

Fuel_prices <- bind_rows(Coastal, Gauteng) %>%
  mutate(Date = dmy(Date)) %>%
  filter(Price != "")

Fuel_prices <- Fuel_prices %>%
  arrange(Date, Fuel_type, Region) %>%
  mutate(Price = str_replace_all(Price, ",", "."),
         Price = str_replace_all(Price, " ", ""),
         Price = as.numeric(Price),
         ULP = if_else(grepl("ULP|LRP", Fuel_type), 1, 0),
         Diesel_0.05 = if_else(grepl("Diesel 0.05", Fuel_type), 1, 0),
         Diesel_0.005 = if_else(grepl("Diesel 0.005", Fuel_type), 1, 0))

# Scraping petrol taxes from DMRE -----------------------------------------

Month_latest <- "Mar "
year_i <- 2023

download.file("https://www.energy.gov.za/files/esources/petroleum/March2023/Petrol-margins.pdf",
              "data-raw/DMRE/DMRE_levies_2023.pdf", mode = "wb")

# Actual pdf data
raw_text <- pdf_text("data-raw/DMRE/DMRE_levies_2023.pdf")

clean_table <- str_split(raw_text[[1]], "\n", simplify = TRUE)

table_start <- stringr::str_which(clean_table, "Jan ")
table_end <- stringr::str_which(clean_table, Month_latest)

# Problem with DMRE table
# clean_table[20] <- paste0("Sep", clean_table[20])

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
                    "Demand_side_management_levy")) %>%
  filter(!is.na(Basic_fuel_price))

table <- table %>%
  mutate(across(Basic_fuel_price:Demand_side_management_levy, as.numeric),
         Date_begin = dmy(paste0("01", Month, year_i)),
         Date_end = dmy(paste0("07", Month, year_i)))

Fuel_prices_petrol <- fuzzy_left_join(Fuel_prices %>%
                                   filter(ULP == 1),
                                 table,
                                 by = c("Date" = "Date_begin",
                                        "Date" = "Date_end"),
                                 match_fun = list(`>=`, `<=`)) %>%
  mutate(Demand_side_management_levy = if_else(grepl("LRP|ULP", Fuel_type) &
                                                 (grepl("93", Fuel_type) | Region == "Coastal"), 0,
                                               Demand_side_management_levy))

# Scraping diesel taxes from DMRE  ----------------------------------------

download.file("https://www.energy.gov.za/files/esources/petroleum/March2023/Diesel-margins.pdf",
              "data-raw/DMRE/DMRE_diesel_levies_2023.pdf", mode = "wb")

# Actual pdf data
raw_text <- pdf_text("data-raw/DMRE/DMRE_diesel_levies_2023.pdf")

clean_table <- str_split(raw_text, "\n")

table_start <- c(str_which(clean_table[[1]], "Jan "), str_which(clean_table[[2]], "Jan "))
table_end <- c(str_which(clean_table[[1]], Month_latest), str_which(clean_table[[2]], Month_latest))

# # Problem with DMRE table
# clean_table[[1]][19] <- paste0("May", clean_table[[1]][19])
# clean_table[[1]][26] <- paste0("Sep", clean_table[[1]][26])

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
      mutate(Slate_levy = str_replace_all(Slate_levy, ",", "."),
             across(Basic_fuel_price:Slate_levy, as.numeric),
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
      mutate(Slate_levy = str_replace_all(Slate_levy, ",", "."),
             across(Basic_fuel_price:Slate_levy, as.numeric),
             Date_begin = dmy(paste0("01", Month, year_i)),
             Date_end = dmy(paste0("07", Month, year_i)))



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

  Fuel_prices_diesel <- bind_rows(Fuel_prices_i_005, Fuel_prices_i_0005)



# Combine all the data

DMRE_fuel_update <- bind_rows(Fuel_prices_petrol,
                       Fuel_prices_diesel,
                       Fuel_prices %>%
                         filter(ULP == 0, Diesel_0.005 == 0, Diesel_0.05 == 0)) %>%
  arrange(Date, Fuel_type, Region) %>%
  select(-ULP, -Diesel_0.05, -Diesel_0.005, -Month, -Date_begin, -Date_end)

DMRE_fuel_update <- DMRE_fuel_update %>%
  mutate(Fuel_type = str_replace_all(Fuel_type, "\\*", ""),
         Fuel_type = str_replace(Fuel_type, " \\s*\\([^\\)]+\\)", ""),
         Fuel_type = str_replace(Fuel_type, "%", ""),
         Fuel_type = str_squish(Fuel_type),
         Fuel_type = str_replace_all(Fuel_type, " ", "_"))

DMRE_fuel_update <- DMRE_fuel_update %>%
  mutate(Demand_side_management_levy = if_else(Date == "2019-12-04" & Fuel_type == "95_ULP" & Region == "Gauteng",
                                               10, Demand_side_management_levy),
         Inland_transport_cost = NA)

load("data/DMRE_fuel.rda")

DMRE_fuel_data_to_add <- DMRE_fuel_update %>%
  anti_join(DMRE_fuel, by = "Date")

DMRE_fuel <- bind_rows(DMRE_fuel, DMRE_fuel_data_to_add)

# Save data
save(DMRE_fuel, file = "data-raw/DMRE/DMRE_fuel.rda", version = 2)
load(file = "data-raw/DMRE/DMRE_fuel.rda")

usethis::use_data(DMRE_fuel, overwrite = TRUE)

