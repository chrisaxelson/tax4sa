
# Creating historical database from auctions data -------------------------

library(tidyverse)
library(readxl)
library(tidyxl)
library(unpivotr)
library(lubridate)

# Fixed rate data ---------------------------------------------------------

folder_name <- "data-raw/NT/Auctions/Fixed_rate"

fixed_rate_files <- list.files(path = folder_name)

fixed_rate_files <- grep(fixed_rate_files, pattern = "2010|~", invert = TRUE, value = TRUE)

for (i in fixed_rate_files) {

  print(i)

  auction_file_name <- i

  auction_sheet_names <- excel_sheets(paste0(folder_name, "/", auction_file_name))

  for (k in auction_sheet_names) {

    cells <- xlsx_cells(paste0(folder_name, "/", auction_file_name),
                        sheet = k)

    if (nrow(cells) == 0) next

    if (i != '2013-14.xlsx') {

      tidied <- cells %>%
        filter(!is_blank) %>%
        behead("up-left", "Table_heading") %>%
        behead("up-left", "Auction_date_original") %>%
        behead("up-left", "Settlement_date_original") %>%
        behead("up-left", "Bond") %>%
        behead("up-left", "Bond_coupon_Redemption") %>%
        behead("left", "variable") %>%
        mutate(value = numeric,
               Bond_coupon_Redemption = str_replace(Bond_coupon_Redemption, ";", ","),
               Bond_coupon_Redemption = str_replace(Bond_coupon_Redemption, ":", ","),
               Bond_coupon_Redemption = str_replace(Bond_coupon_Redemption, " : ", ","),
               Bond_coupon_Redemption = str_replace_all(Bond_coupon_Redemption, "\\(|\\)", "")) %>%
        select(Table_heading, Auction_date_original, Settlement_date_original, Bond,
               Bond_coupon_Redemption, variable, value) %>%
        separate_wider_delim(Bond_coupon_Redemption,
                             delim = ",", names = c("Bond_coupon", "Redemption_year"))
    } else {

      if (k == "Sheet1") {

        tidied <- cells %>%
          filter(!is_blank) %>%
          behead("up-left", "Auction_date_original") %>%
          behead("up-left", "Settlement_date_original") %>%
          behead("up-left", "Bond") %>%
          behead("up-left", "Bond_coupon_Redemption") %>%
          behead("left", "variable") %>%
          mutate(value = numeric,
                 Bond_coupon_Redemption = str_replace(Bond_coupon_Redemption, ";", ",")) %>%
          select(Auction_date_original, Settlement_date_original, Bond,
                 Bond_coupon_Redemption, variable, value) %>%
          separate_wider_delim(Bond_coupon_Redemption,
                               delim = ",", names = c("Bond_coupon", "Redemption_year"))
      } else {
        next
      }
    }

    if (i == fixed_rate_files[1] & k == auction_sheet_names[1]) {
      NT_auctions_fixed <- tidied
    } else {
      NT_auctions_fixed <- NT_auctions_fixed %>%
        bind_rows(tidied)
    }

    print(k)
  }

}

NT_auctions_fixed <- NT_auctions_fixed %>%
  filter(Auction_date_original != "Auction date") %>%
  mutate(Bond = if_else(str_detect(Bond, "R"), Bond, paste0("R", Bond)),
         Bond = str_remove(Bond, "'"),
         Auction_date = if_else(nchar(Auction_date_original) > 10,
                                as.Date(Auction_date_original, format = "%d %B %Y"),
                                ymd(Auction_date_original)),
         Settlement_date = if_else(nchar(Settlement_date_original) > 10,
                                   as.Date(Settlement_date_original, format = "%d %B %Y"),
                                   ymd(Settlement_date_original)))

# Save data
save(NT_auctions_fixed, file = "data-raw/NT/NT_auctions_fixed.rda", version = 2)

usethis::use_data(NT_auctions_fixed, overwrite = TRUE)


# Inflation linked --------------------------------------------------------

folder_name <- "data-raw/NT/Auctions/Inflation_linked"

inflation_linked_files <- list.files(path = folder_name)

inflation_linked_files <- grep(inflation_linked_files, pattern = "2010|~", invert = TRUE, value = TRUE)

for (i in inflation_linked_files) {

  print(i)

  auction_file_name <- i

  auction_sheet_names <- excel_sheets(paste0(folder_name, "/", auction_file_name))

  for (k in auction_sheet_names) {

    cells <- xlsx_cells(paste0(folder_name, "/", auction_file_name),
                        sheet = k)

    if (nrow(cells) == 0) next

    # Need to fill out merged cells with total amount on offer
    Row_of_amount_offer <- cells %>%
      filter(grepl("Amount on offer", character)) %>%
      pull(row)

    cells <- cells %>%
      mutate(numeric = if_else(row == Row_of_amount_offer & !is.na(lag(numeric)),
                               lag(numeric), numeric),
             numeric = if_else(row == Row_of_amount_offer & !is.na(lag(numeric)),
                               lag(numeric), numeric),
             is_blank = if_else(row == Row_of_amount_offer & !is.na(numeric),
                                FALSE, is_blank))

      tidied <- cells %>%
        filter(!is_blank) %>%
        behead("up-left", "Table_heading") %>%
        behead("up-left", "Auction_date_original") %>%
        behead("up-left", "Settlement_date_original") %>%
        behead("up-left", "Bond") %>%
        behead("up-left", "Bond_coupon_Redemption") %>%
        behead("left", "variable") %>%
        mutate(value = numeric,
               Bond_coupon_Redemption = str_replace(Bond_coupon_Redemption, ";", ","),
               Bond_coupon_Redemption = str_replace(Bond_coupon_Redemption, ":", ","),
               Bond_coupon_Redemption = str_replace(Bond_coupon_Redemption, " : ", ","),
               Bond_coupon_Redemption = str_replace_all(Bond_coupon_Redemption, "\\(|\\)", "")) %>%
        select(Table_heading, Auction_date_original, Settlement_date_original, Bond,
               Bond_coupon_Redemption, variable, value) %>%
        separate_wider_delim(Bond_coupon_Redemption,
                             delim = ",", names = c("Bond_coupon", "Redemption_year"))

    if (i == inflation_linked_files[1] & k == auction_sheet_names[1]) {
      NT_auctions_inflation_linked <- tidied
    } else {
      NT_auctions_inflation_linked <- NT_auctions_inflation_linked %>%
        bind_rows(tidied)
    }

    print(k)
  }

}

NT_auctions_inflation_linked <- NT_auctions_inflation_linked %>%
  mutate(Auction_date_original = str_replace(Auction_date_original, "spet", "September"),
         Auction_date = if_else(nchar(Auction_date_original) > 10,
                                as.Date(Auction_date_original, format = "%d %B %Y"),
                                ymd(Auction_date_original)),
         Settlement_date = if_else(nchar(Settlement_date_original) > 10,
                                as.Date(Settlement_date_original, format = "%d %B %Y"),
                                ymd(Settlement_date_original)))

# Save data
save(NT_auctions_inflation_linked, file = "data-raw/NT/NT_auctions_inflation_linked.rda", version = 2)

usethis::use_data(NT_auctions_inflation_linked, overwrite = TRUE)


# Treasury bills ----------------------------------------------------------

folder_name <- "data-raw/NT/Auctions/Treasury_bills"

tbills_files <- list.files(path = folder_name)

tbills_files <- grep(tbills_files, pattern = "~", invert = TRUE, value = TRUE)

for (i in tbills_files) {

  print(i)

  auction_file_name <- i

  auction_sheet_names <- excel_sheets(paste0(folder_name, "/", auction_file_name))

  for (k in auction_sheet_names) {

    cells <- xlsx_cells(paste0(folder_name, "/", auction_file_name),
                        sheet = k)

    if (nrow(cells) == 0) next

    # Need to fill out merged cells with total amount on offer
    tidied <- cells %>%
      filter(!is_blank) %>%
      behead("up-left", "Table_heading") %>%
      behead("up-left", "Bond") %>%
      behead("up-left", "Auction_date_original") %>%
      behead("up-left", "Settlement_date_original") %>%
      behead("up-left", "Maturity_date_original") %>%
      behead("left", "variable") %>%
      mutate(value = numeric) %>%
      select(Table_heading, Bond, Auction_date_original, Settlement_date_original,
             Maturity_date_original, variable, value)

    if (i == tbills_files[1] & k == auction_sheet_names[1]) {
      NT_auctions_tbills <- tidied
    } else {
      NT_auctions_tbills <- NT_auctions_tbills %>%
        bind_rows(tidied)
    }

    print(k)
  }

}

NT_auctions_tbills <- NT_auctions_tbills %>%
  mutate(Auction_date = if_else(nchar(Auction_date_original) > 10,
                                as.Date(Auction_date_original, format = "%d %B %Y"),
                                ymd(Auction_date_original)),
         Settlement_date = if_else(nchar(Settlement_date_original) > 10,
                                   as.Date(Settlement_date_original, format = "%d %B %Y"),
                                   ymd(Settlement_date_original)),
         Maturity_date = if_else(nchar(Maturity_date_original) > 10,
                                   as.Date(Maturity_date_original, format = "%d %B %Y"),
                                   ymd(Maturity_date_original)))

# Save data
save(NT_auctions_tbills, file = "data-raw/NT/NT_auctions_tbills.rda", version = 2)

usethis::use_data(NT_auctions_tbills, overwrite = TRUE)

# Switches ----------------------------------------------------------

folder_name <- "data-raw/NT/Auctions/Switch_auctions"

switches_files <- list.files(path = folder_name)

switches_files <- grep(switches_files, pattern = "~", invert = TRUE, value = TRUE)

for (i in switches_files) {

  print(i)

  auction_file_name <- i

  auction_sheet_names <- excel_sheets(paste0(folder_name, "/", auction_file_name))

  for (k in auction_sheet_names) {

    cells <- xlsx_cells(paste0(folder_name, "/", auction_file_name),
                        sheet = k)

    if (nrow(cells) == 0) next

    # Need to fill out merged cells with total amount on offer
    tidied <- cells %>%
      filter(!is_blank) %>%
      behead("up-left", "Source_bond") %>%
      behead("up-left", "Auction_date_original") %>%
      behead("up-left", "Settlement_date_original") %>%
      behead("up-left", "Destination_bond") %>%
      behead("left", "variable") %>%
      mutate(value = numeric,
             value2 = str_replace(character, ",", ""),
             value = if_else(is.na(numeric), as.numeric(value2), numeric)) %>%
      select(Source_bond, Auction_date_original, Settlement_date_original,
             Destination_bond, variable, value) %>%
      mutate(Source_bond = str_replace_all(Source_bond, "\\(", ":"),
             Source_bond = str_replace_all(Source_bond, "\\)", "")) %>%
      separate_wider_delim(Source_bond,
                           delim = ":",
                           names = c("Source_bond", "Source_bond_coupon",
                                     "Source_bond_redemption_year")) %>%
      mutate(Source_bond = str_trim(Source_bond),
             Source_bond_coupon = str_trim(Source_bond_coupon),
             Source_bond_redemption_year = str_trim(Source_bond_redemption_year),
             Sheet_name = k)

    if (i == switches_files[1] & k == auction_sheet_names[1]) {
      NT_auctions_switches <- tidied
    } else {
      NT_auctions_switches <- NT_auctions_switches %>%
        bind_rows(tidied)
    }

    print(k)
  }

}

NT_auctions_switches <- NT_auctions_switches %>%
  mutate(Auction_date = if_else(grepl("/", Auction_date_original),
                                mdy(Auction_date_original), ymd(Auction_date_original)),
         Settlement_date = if_else(grepl("/", Settlement_date_original),
                                mdy(Settlement_date_original), ymd(Settlement_date_original)),
         Auction_date = if_else(is.na(Auction_date), dmy(Auction_date_original), Auction_date),
         Settlement_date = if_else(is.na(Settlement_date), dmy(Settlement_date_original), Settlement_date),)

# Save data
save(NT_auctions_switches, file = "data-raw/NT/NT_auctions_switches.rda", version = 2)

usethis::use_data(NT_auctions_switches, overwrite = TRUE)


# Floating rate notes -----------------------------------------------------

folder_name <- "data-raw/NT/Auctions/Floating_rate_notes"

floating_files <- list.files(path = folder_name)

floating_files <- grep(floating_files, pattern = "~", invert = TRUE, value = TRUE)

for (i in floating_files) {

  print(i)

  auction_file_name <- i

  auction_sheet_names <- excel_sheets(paste0(folder_name, "/", auction_file_name))

  for (k in auction_sheet_names) {

    cells <- xlsx_cells(paste0(folder_name, "/", auction_file_name),
                        sheet = k)

    if (nrow(cells) == 0) next

    # Need to fill out merged cells with total amount on offer
    tidied <- cells %>%
      filter(!is_blank) %>%
      behead("up-left", "Bond") %>%
      behead("up-left", "Auction_date_original") %>%
      behead("up-left", "Settlement_date_original") %>%
      behead("left", "variable") %>%
      mutate(value = numeric,
             value2 = str_replace(character, ",", ""),
             value = if_else(is.na(numeric), as.numeric(value2), numeric)) %>%
      select(Bond, Auction_date_original, Settlement_date_original,
            variable, value) %>%
      mutate(Bond = str_replace_all(Bond, "\\(", ":"),
             Bond = str_replace_all(Bond, "\\)", "")) %>%
      separate_wider_delim(Bond,
                           delim = ":",
                           names = c("Bond", "Bond_coupon",
                                     "Bond_redemption_year")) %>%
      mutate(Bond = str_trim(Bond),
             Bond_coupon = str_trim(Bond_coupon),
             Bond_redemption_year = str_trim(Bond_redemption_year),
             Sheet_name = k)

    if (i == floating_files[1] & k == auction_sheet_names[1]) {
      NT_auctions_floating <- tidied
    } else {
      NT_auctions_floating <- NT_auctions_floating %>%
        bind_rows(tidied)
    }

    print(k)
  }

}

NT_auctions_floating <- NT_auctions_floating %>%
  mutate(Auction_date = dmy(Auction_date_original),
         Settlement_date = dmy(Settlement_date_original))

# Save data
save(NT_auctions_floating, file = "data-raw/NT/NT_auctions_floating.rda", version = 2)

usethis::use_data(NT_auctions_floating, overwrite = TRUE)


# Combine all auction data ------------------------------------------------

load("data-raw/NT/NT_auctions_fixed.rda")
load("data-raw/NT/NT_auctions_inflation_linked.rda")
load("data-raw/NT/NT_auctions_tbills.rda")
load("data-raw/NT/NT_auctions_floating.rda")

NT_auctions_fixed <- NT_auctions_fixed %>%
  mutate(Auction_type = "Fixed_rate") %>%
  rename(Bond_redemption_year = Redemption_year)

NT_auctions_inflation_linked <- NT_auctions_inflation_linked %>%
  mutate(Auction_type = "Inflation_linked")  %>%
  rename(Bond_redemption_year = Redemption_year)

NT_auctions_tbills <- NT_auctions_tbills %>%
  mutate(Auction_type = "Treasury_bills")

NT_auctions_floating <- NT_auctions_floating %>%
  mutate(Auction_type = "Floating")


NT_auctions <- NT_auctions_fixed %>%
  bind_rows(NT_auctions_inflation_linked) %>%
  bind_rows(NT_auctions_tbills) %>%
  bind_rows(NT_auctions_floating) %>%
  mutate(Table_heading = coalesce(Table_heading, Sheet_name)) %>%
  select(-Sheet_name) %>%
  mutate(variable = str_to_sentence(variable),
         value = if_else(grepl("Amount on offer", variable) & value > 10000, value/1e6, value),
         value = if_else(grepl("Non comps", variable) & value > 10000, value/1e6, value),
         value = if_else(grepl("Total amount allocated", variable) & value > 100000, value/1e6, value),
         value = if_else(grepl("Total amount of bids received", variable) & value > 100000, value/1e6, value),
         variable = if_else(grepl("Amount on offer", str_trim(variable)), "Amount on offer (R million)", variable),
         variable = if_else(grepl("Non comps", str_trim(variable)), "Non comps (R million)", variable),
         variable = if_else(grepl("Total amount allocated", str_trim(variable)), "Total amount allocated (R million)", variable),
         variable = if_else(grepl("Total amount of bids received", str_trim(variable)), "Total amount of bids received (R million)", variable),
         variable = if_else(grepl("Total number of successful bids", str_trim(variable)), "Total number of bids successful", variable),
         variable = if_else(grepl("Bid to ", str_trim(variable)), "Bid to cover ratio", variable),
         Month_number = month(Auction_date),
         Month = month(Auction_date, label = TRUE, abbr = FALSE),
         Quarter = ifelse(!is.na(Month),
                          case_when(
                            Month %in% c("January", "February", "March") ~ 1,
                            Month %in% c("April", "May", "June") ~ 2,
                            Month %in% c("July", "August", "September") ~ 3,
                            Month %in% c("October", "November", "December") ~ 4
                          ), ifelse(grepl("Q", Auction_date), as.numeric(str_sub(Auction_date, 7, 7)), NA)),
         Year = as.numeric(str_sub(Auction_date, 1, 4)),
         Fiscal_year = ifelse(!is.na(Month),
                              ifelse(Month %in% c("January", "February", "March"), Year, Year + 1),
                              ifelse(!is.na(Quarter), ifelse(Quarter == 1, Year, Year + 1), NA)))

# # Check variable names
# Auction_variables <- NT_auctions %>%
#   mutate(variable = str_trim(variable)) %>%
#   distinct(variable)

# Save data
save(NT_auctions, file = "data-raw/NT/NT_auctions.rda", version = 2)

usethis::use_data(NT_auctions, overwrite = TRUE)


