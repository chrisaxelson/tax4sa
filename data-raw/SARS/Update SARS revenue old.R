
# Adding monthly s32 revenue data -----------------------------------------

# Packages
library(tidyverse)
library(pdftools)

load("data-raw/SARS/SARS_monthly.rda")
load("data-raw/SARS/SARS_annual.rda")

SARS_monthly <- SARS_monthly %>%
  select(-Category_number)

SARS_annual <- SARS_annual %>%
  select(-Category_number)

usethis::use_data(SARS_monthly, overwrite = TRUE)
usethis::use_data(SARS_annual, overwrite = TRUE)


# THIS NEEDS TO BE UPDATED FOR EACH NEW MONTH -----------------------------

Latest_month <- "2020_June"
Latest_link <- "http://www.treasury.gov.za/comm_media/press/monthly/2008/Table%201.pdf"

# This section should be the same each time -------------------------------

# Latest link
download.file(Latest_link,
              destfile = paste0("data-raw/SARS/FYE_", Latest_month, ".pdf"), mode = "wb")
# Updated table
table <- pdf_text(pdf = paste0("data-raw/SARS/FYE_", Latest_month, ".pdf"))

# Bring in data
load("data-raw/SARS/SARS_monthly.rda")

# Check latest month
tail(colnames(SARS_monthly))

table <- str_split(table, "\n", simplify = TRUE)
tax_year <- str_trim(str_replace(table[1,2], "\\r", ""))
s32_cols <- table[1,3]
s32_cols <- str_trim(s32_cols, side = "left")
s32_cols <- str_replace_all(s32_cols, "\\s{2,}", "#")
s32_cols <- str_replace_all(s32_cols, "\\r", "")
s32_cols <- str_split(s32_cols, pattern = "#", simplify = TRUE)

table_start <- stringr::str_which(table, "Taxes on income and profits")
table_end <- stringr::str_which(table, "Revenue collected according to Table 4")

table <- table[1, table_start:table_end]

table <- str_trim(table, side = "left")

# Need to remove footnotes
table <- str_replace(table, "\\s[0-9]\\)", "")
table <- str_replace(table, "\\s[0-9][0-9]\\)", "")
table <- str_replace(table, "\\r", "")
table <- str_replace_all(table, "\\s{2,}", "|")

table[(length(table) - 6):length(table)] <- str_replace(table[(length(table) - 6):length(table)], "\\|", "||")

table[(length(table) - 20):(length(table) - 9)] <- str_replace(table[(length(table) - 20):(length(table) - 9)], "\\|", "||")


text_con <- textConnection(table)
SARS_temp <- read.csv(text_con, sep = "|", header = FALSE)
colnames(SARS_temp) <- c("Revenue", s32_cols)

# Only keep next month
SARS_temp <- SARS_temp %>%
  select(1,3)
colnames(SARS_temp) <- c(colnames(SARS_temp)[1], paste0(colnames(SARS_temp)[2], "_2020"))

# Change to numeric
SARS_temp <- SARS_temp %>%
  mutate(across(c(-Revenue), ~ gsub(" ", "", .)))

SARS_temp <- SARS_temp %>%
  mutate(across(c(-Revenue), ~ gsub("\\(", "-", .)),
         across(c(-Revenue), ~ gsub("\\)", "", .)),
         across(c(-Revenue), as.numeric))

# Change NAs to 0s
SARS_temp[is.na(SARS_temp)] <- 0

SARS_temp <- SARS_temp %>%
  mutate(Revenue = str_squish(Revenue))

# Sum up rows which are empty
SARS_temp <- SARS_temp %>%
  mutate(across(c(-Revenue), ~ifelse(Revenue == "Other" & lead(Revenue) == "Interest on overdue income tax",
                                 lead(., 1) + lead(., 2), .)),
         across(c(-Revenue), ~ifelse(Revenue == "Estate, inheritance and gift taxes",
                                 lead(., 1) + lead(., 2), .)),
         across(c(-Revenue), ~ifelse(Revenue == "Taxes on financial and capital transactions",
                                 lead(., 1) + lead(., 2), .)),
         # across(c(-Revenue), ~ifelse(Revenue == "Specific excise duties",
         #                         lead(., 1) + lead(., 2) + lead(., 3) + lead(., 4) +
         #                           lead(., 5) + lead(., 6) + lead(., 7) + lead(., 8), .)),
         across(c(-Revenue), ~ifelse(Revenue == "Taxes on use of goods and on permission to use goods or perform activities",
                                 lead(., 1) + lead(., 2) + lead(., 3) + lead(., 4) +
                                   lead(., 5) + lead(., 6) + lead(., 7) + lead(., 8), .)),
         across(c(-Revenue), ~ifelse(Revenue == "Other" & lead(Revenue) == "Universal Service Fund",
                                 lead(., 1), .)),
         across(c(-Revenue), ~ifelse(Revenue == "Import duties",
                                 lead(., 1) + lead(., 2), .)),
         across(c(-Revenue), ~ifelse(Revenue == "Other" & lead(Revenue) == "Miscellaneous customs and excise receipts",
                                 lead(., 1) + lead(., 2), .)))

# Change others
SARS_temp <- SARS_temp %>%
  mutate(Revenue = ifelse(Revenue == "Other" & lead(Revenue) == "Interest on overdue income tax", "Other: Taxes on income and profits", Revenue),
         Revenue = ifelse(Revenue == "Other" & lead(Revenue) == "Universal Service Fund", "Other: Taxes on goods and services", Revenue),
         Revenue = ifelse(Revenue == "Other" & lead(Revenue) == "Miscellaneous customs and excise receipts", "Other: Taxes on international trade and transactions", Revenue))


# Duplicate row
SARS_temp <- SARS_temp %>%
  distinct(Revenue, .keep_all = TRUE)

SARS_temp <- SARS_temp %>%
  filter(Revenue != "Of which:")

SARS_temp <- SARS_temp %>%
  mutate(Revenue = case_when(
    Revenue == "Taxes on income and profits" ~ "Taxes on income, profits and capital gains",
    Revenue == "Personal income tax" ~ "Income tax on persons and individuals",
    Revenue == "NRF receipts" ~ "National Revenue Fund receipts",
    Revenue == "Direct transfer from NRF to the RAF" ~
      "Direct transfer from National Revenue Fund to the Road Accident Fund",
    Revenue == "Direct transfer from NRF to the UIF" ~
      "Direct transfer from National Revenue Fund to the Unemployment Insurance Fund",
    Revenue == "Cash balance NRF" ~ "Cash balance National Revenue Fund",
    Revenue == "Provincial revenue collected by SARS and transferred by NRF" ~
      "Provincial revenue collected by SARS and transferred by National Treasury",
    Revenue == "CARA added as part of cash revenue in Table 4" ~
      "Recovery of criminal assets added as part of cash revenue in table 4",
    Revenue == "Revenue collected on behalf of the RAF" ~
      "Revenue collected on behalf of the Road Accident Fund",
    Revenue == "Revenue collected on behalf of the UIF" ~
      "Revenue collected on behalf of the Unemployment Insurance Fund",
    Revenue == "Value-added tax" ~ "Value added tax",
    Revenue == "Departmental revenue received but not yet paid to NRF" ~
      "Departmental revenue received but not yet paid to the National Revenue Fund",
    TRUE ~ Revenue
  ))


SARS_temp <- SARS_temp %>%
  mutate(Revenue = str_replace(Revenue, "Table 4", "table 4"),
         Revenue = str_squish(Revenue))

# Join with current data
SARS_monthly <- SARS_monthly %>%
  full_join(SARS_temp)

SARS_monthly <- SARS_monthly %>%
  mutate(Category_number = ifelse(Revenue == "Carbon tax", 53.1, Category_number)) %>%
  arrange(Category_number)

save(SARS_monthly, file = "data-raw/SARS/SARS_monthly.rda")

# Reshape
SARS_monthly <- SARS_monthly %>%
  select(-Category_number)

# # Reshape
# SARS_monthly <- SARS_monthly %>%
#   pivot_longer(c(-Revenue, -Category_number)) %>%
#   filter(!is.na(value)) %>%
#   separate(name, into = c("Month", "Year"), sep = "_") %>%
#   mutate(Year = as.numeric(Year),
#          Fiscal_year = if_else(Month %in% c("January", "February", "March"), Year, Year + 1)) %>%
#   select(Revenue, Year, Fiscal_year, Month, Revenue = value)


usethis::use_data(SARS_monthly, overwrite = TRUE)

# SARS_monthly_wide <- SARS_monthly %>%
#   select(-Fiscal_year) %>%
#   pivot_wider(names_from = c(Month, Year), values_from = Revenue)

