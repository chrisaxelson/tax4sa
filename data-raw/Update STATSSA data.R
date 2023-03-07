# Updating STATSSA data ---------------------------------------------------

# Packages
library(data.table)
library(tidyr)
library(dplyr)
library(stringr)
library(tsibble)
library(lubridate)
library(rvest)
library(httr)
library(readxl)

# STATSSA time series website
STATSSA_url <- "http://www.statssa.gov.za/?page_id=1847"


# Extract links from that page that contain the data
STATSSA_links <- read_html(STATSSA_url) %>%
  html_nodes(xpath = "//*/table[@id = 'mine']//a") %>%
  html_attr("href")
STATSSA_links <- STATSSA_links[grepl("Ascii", STATSSA_links)]
STATSSA_links <- str_replace(STATSSA_links, " https://www.statssa.gov.za/../", "")

# Only keep updated data
Data_to_include <- c(
  "P0141", "P6410", "P5041.1", "P0041", "P0151.1", "P4141", "P0142.7",
  # "P9119.4",
  "P9102", "P9103.1", "P9119.3", "P9121", "P6420", "P0441",
  "P7162", "P0043", "P3043", "P3041.2", "P2041", "P6343.2",
  # "P0142.1",
  "P6242.1", "P6141.2"
  )
STATSSA_links <- STATSSA_links[grepl(paste(Data_to_include, collapse = "|"), STATSSA_links)]

Available_files_on_website <- STATSSA_links

# Check with file names that have been downloaded already
Imported_files <- readRDS("data-raw/STATSSA/Imported_files.rds")

# Only keep names that are new
Files_to_import <- Available_files_on_website[!(Available_files_on_website %in% Imported_files)]

Files_to_import <- Files_to_import[!(grepl("BK", Files_to_import))]

Links_to_import <- str_replace_all(Files_to_import, " ", "%20")

# Loop through all links to get the data
for (j in seq_along(Links_to_import)) {

  # Create temporary files to download, unzip and save files
  tmp_file <- tempfile()
  link_error <- FALSE
  tryCatch(
    expr = {download.file(url = paste0("https://www.statssa.gov.za/", Links_to_import[j]),
                          destfile = tmp_file)},
    error = function(e) {
      cat(paste0("\n", Files_to_import[j], " link not found. Moving to next link.\n"))
      link_error <<- TRUE}
  )
  if(link_error) next

  unzipped_file_name <- unzip(tmp_file, list=TRUE)$Name

  tmp_file2 <- tempfile()

  # # Some zipped files have two underlying txt files
  # if (grepl("Mining Production and Sales annual", unzipped_file_name)) {
  #   tmp_file2 <- unzip(zipfile=tmp_file, files = unzipped_file_name[1], exdir=tempdir())
  # } else {
    tmp_file2 <- unzip(zipfile=tmp_file, files = unzipped_file_name[1], exdir=tempdir())
  # }


  info <- read.delim(tmp_file2, header = FALSE)

  setDT(info)
  test <- info

  test[str_sub(V1, 1, 3) == "H01", Group_number := sequence(.N)]
  setnafill(test, "locf", cols = "Group_number")
  test[str_sub(V1, 1, 1) == "H", Headers := TRUE]

  print(Files_to_import[j])

  for (i in seq_len(max(test$Group_number))) {

    just_values <- test[is.na(Headers) & Group_number == i, .(Group_number, Value = V1)]

    time_period <- test[Group_number == i & str_sub(V1, 1, 3) == "H25", V1]
    time_period <- tolower(str_trim(gsub(".*:","",time_period)))
    # Misspelling in the data
    if (time_period == "quartely") {
      time_period <- "quarterly"
    }
    if (time_period == "annual") {
      time_period <- "annually"
    }

    start_date <- test[Group_number == i & str_sub(V1, 1, 3) == "H24", V1]
    start_date <- str_trim(gsub(".*:","",start_date))

    end_date <- test[Group_number == i & str_sub(V1, 1, 3) == "H23", V1]
    end_date <- str_trim(gsub(".*:","",end_date))

    if (time_period == "monthly") {

      dates_for_values <- as.character(
        format(
          yearmonth(
            seq(ymd(paste0(start_date, " 01")),
                ymd(paste0(end_date, " 01")), by = "month")),
          format = "%Y %m"))

      if (length(dates_for_values) != nrow(just_values)) {
        cat(paste("\nEntries did not match time period for",
                  test[Group_number == i & str_sub(V1, 1, 4) == "H03:", V1], "\n"))
        next
      }

    } else if (time_period == "annually") {

      dates_for_values <- as.numeric(start_date):as.numeric(end_date)

      if (length(dates_for_values) != nrow(just_values)) {
        cat(paste("\nEntries did not match time period for",
                  test[Group_number == i & str_sub(V1, 1, 4) == "H03:", V1], "\n"))
        next
      }

    } else if (time_period == "quarterly") {

      start_month_ind <- as.numeric(str_sub(start_date, start = -2))
      start_month_ind <- case_when(
        start_month_ind == 1 ~ "0101",
        start_month_ind == 2 ~ "0401",
        start_month_ind == 3 ~ "0701",
        start_month_ind == 4 ~ "1001",
      )

      end_month_ind <- as.numeric(str_sub(end_date, start = -2))
      end_month_ind <- case_when(
        end_month_ind == 1 ~ "0101",
        end_month_ind == 2 ~ "0401",
        end_month_ind == 3 ~ "0701",
        end_month_ind == 4 ~ "1001",
      )

      dates_for_values <- as.character(
          yearquarter(
            seq(ymd(paste0(str_sub(start_date, 1, 4), start_month_ind)),
                ymd(paste0(str_sub(end_date, 1, 4), end_month_ind)), by = "quarter")))

      if (length(dates_for_values) != nrow(just_values)) {
        cat(paste("\nEntries did not match time period for",
                  test[Group_number == i & str_sub(V1, 1, 3) == "H03", V1], "\n"))
        next
      }
    }

    just_values[, Date := dates_for_values]

    save_for_col_names <- str_sub(test[Headers & Group_number == i, V1], 1, 3)
    test[Headers & Group_number == i, V1 := str_sub(V1, 6, -1)]

    just_headers <- transpose(test[Headers & Group_number == i, .(V1)])
    setnames(just_headers, new = save_for_col_names)

    just_headers[ , Group_number := i]

    result <- just_headers[just_values, on = c("Group_number")]
    result[, Group_number := NULL]

    result$Link <- str_replace(Files_to_import[j], "timeseriesdata/Ascii/", "")

    if (!exists("STATSSA_new")) {
      STATSSA_new <- result
    } else {
      STATSSA_new <- rbind(STATSSA_new, result, fill = TRUE)
    }
    cat(i, " ")
  }
}

# Remove duplicates
STATSSA_new <- STATSSA_new %>%
  distinct() %>%
  mutate(Value = as.numeric(Value))

# Create STATSSA_descriptions
STATSSA_descriptions_new <- STATSSA_new %>%
  select(-Value, -Date) %>%
  distinct() %>%
  mutate_all(na_if," ") %>%
  select_if(colSums(!is.na(.)) > 0) %>%
  select(sort(tidyselect::peek_vars())) %>%
  arrange(H01, H03)

STATSSA_new <- STATSSA_new %>%
  select(H01, H03, Date, Value) %>%
  arrange(H01, H03)

# Create month, quarter, year, fiscal year
STATSSA_new <- STATSSA_new %>%
  mutate(Month = ifelse(length(Date) > 4 & !grepl("Q", Date),
                        month.name[as.numeric(str_sub(Date,5, 7))],
                        NA),
         Quarter = ifelse(!is.na(Month),
                          case_when(
                            Month %in% c("January", "February", "March") ~ 1,
                            Month %in% c("April", "May", "June") ~ 2,
                            Month %in% c("July", "August", "September") ~ 3,
                            Month %in% c("October", "November", "December") ~ 4
                          ), ifelse(grepl("Q", Date), as.numeric(str_sub(Date, 7, 7)), NA))                        ,
         Year = as.numeric(str_sub(Date, 1, 4)),
         Fiscal_year = ifelse(!is.na(Month),
                              ifelse(Month %in% c("January", "February", "March"), Year, Year + 1),
                              ifelse(!is.na(Quarter), ifelse(Quarter == 1, Year, Year + 1), NA)))


# NB - STATSSA not including GDP data on time series page
# Need to do it separately

GDP_url <- "https://www.statssa.gov.za/publications/P0441/GDP%20P0441%20-%20GDP%20Time%20series%202022Q4.xlsx"

GET(GDP_url, write_disk(tf <- tempfile(fileext = ".xlsx")))
GDP_annual <- read_excel(tf, sheet = "Annual")
GDP_annual_p <- read_excel(tf, sheet = "AnnualP")
GDP_quarterly <- read_excel(tf, sheet = "Quarterly")
GDP_quarterly_p <- read_excel(tf, sheet = "QuarterlyP")

names(GDP_quarterly)[names(GDP_quarterly) == '201803...113'] <- '201803'
names(GDP_quarterly)[names(GDP_quarterly) == '201803...114'] <- '201804'

names(GDP_quarterly_p)[names(GDP_quarterly_p) == '201803...113'] <- '201803'
names(GDP_quarterly_p)[names(GDP_quarterly_p) == '201803...114'] <- '201804'

# Reshape
GDP <- GDP_annual %>%
  pivot_longer(-(H01:H25), names_to = "Date", values_to = "Value") %>%
  bind_rows(GDP_annual_p %>%
              pivot_longer(-(H01:H25), names_to = "Date", values_to = "Value")) %>%
  bind_rows(GDP_quarterly %>%
              pivot_longer(-(H01:H25), names_to = "Date", values_to = "Value")) %>%
  bind_rows(GDP_quarterly_p %>%
              pivot_longer(-(H01:H25), names_to = "Date", values_to = "Value"))

GDP <- GDP %>%
  mutate(Month = NA,
         Quarter = ifelse(nchar(Date) > 5, as.numeric(str_sub(Date, 6, 6)), NA),
         Year = ifelse(str_sub(Date, 1, 1) == "Y", as.numeric(str_sub(Date, 2, 5)),
                        as.numeric(str_sub(Date, 1, 4))),
         Fiscal_year = ifelse(!is.na(Quarter), ifelse(Quarter == 1, Year, Year + 1), NA))

# Remove duplicates
STATSSA_new <- STATSSA_new %>%
  bind_rows(GDP %>%
              select(H01, H03, Date, Value, Month, Quarter, Year, Fiscal_year) %>%
              arrange(H01, H03))

STATSSA_new <- GDP %>%
              select(H01, H03, Date, Value, Month, Quarter, Year, Fiscal_year) %>%
              arrange(H01, H03)


# Create STATSSA_descriptions
STATSSA_descriptions_new <- STATSSA_descriptions_new %>%
  bind_rows(GDP %>%
              select(-(Date:Fiscal_year)) %>%
              distinct() %>%
              mutate_all(na_if," ") %>%
              select_if(colSums(!is.na(.)) > 0) %>%
              select(sort(tidyselect::peek_vars())) %>%
              arrange(H01, H03))

# # First time
# STATSSA <- STATSSA_new
# STATSSA_descriptions <- STATSSA_descriptions_new
# save(STATSSA, file = "data-raw/STATSSA/STATSSA.rda", version = 2)
# save(STATSSA_descriptions, file = "data-raw/STATSSA/STATSSA_descriptions.rda", version = 2)

# Now replace current data with new data
load("data-raw/STATSSA/STATSSA.rda")
load("data-raw/STATSSA/STATSSA_descriptions.rda")

# Remove new data from saved data
STATSSA <- STATSSA %>%
  anti_join(STATSSA_new,
            by = c("H01", "H03"))

# Add on new data and arrange
STATSSA <- STATSSA %>%
  bind_rows(STATSSA_new) %>%
  arrange(H01, H03)

STATSSA <- STATSSA %>%
  distinct()

# Remove new data from saved data
STATSSA_descriptions <- STATSSA_descriptions %>%
  anti_join(STATSSA_descriptions_new,
            by = c("H01", "H03"))

# Add on new data and arrange
STATSSA_descriptions <- STATSSA_descriptions %>%
  bind_rows(STATSSA_descriptions_new) %>%
  arrange(H01, H03)

STATSSA_descriptions <- STATSSA_descriptions %>%
  distinct()

STATSSA <- STATSSA %>%
  mutate_if(is.character, str_trim)

STATSSA_descriptions <- STATSSA_descriptions %>%
  mutate_if(is.character, str_trim)

save(STATSSA, file = "data-raw/STATSSA/STATSSA.rda", version = 2)
save(STATSSA_descriptions, file = "data-raw/STATSSA/STATSSA_descriptions.rda", version = 2)

usethis::use_data(STATSSA, overwrite = TRUE)
usethis::use_data(STATSSA_descriptions, overwrite = TRUE)

# Check STATSSA descriptions for links
Imported_files <- STATSSA_descriptions %>%
  pull(Link) %>%
  unique()

Imported_files <- paste0("timeseriesdata/Ascii/", Imported_files)

# Save file names so don't need to redownload next time
saveRDS(Imported_files, file = "data-raw/STATSSA/Imported_files.rds")
devtools::document()
