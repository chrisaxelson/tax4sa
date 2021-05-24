# Updating STATSSA data ---------------------------------------------------

# Packages
library(data.table)
library(tidyr)
library(dplyr)
library(stringr)
library(tsibble)
library(lubridate)
library(rvest)

# STATSSA time series website
STATSSA_url <- "http://www.statssa.gov.za/?page_id=1847"

# Extract links from that page that contain the data
STATSSA_links <- read_html(STATSSA_url) %>%
  html_nodes(xpath = "//*/table[@id = 'mine']//a") %>%
  html_attr("href")
STATSSA_links <- STATSSA_links[grepl("Ascii", STATSSA_links)]
STATSSA_links <- str_replace(STATSSA_links, " http://www.statssa.gov.za/wp-content/../", "")

# Only keep updated data
Data_to_include <- c(
  "P0141", "P6410", "P5041.1", "P0041", "P0151.1", "P4141", "P0142.7",
  "P9119.4", "P9102", "P9103.1", "P9119.3", "P9121", "P6420", "P0441",
  "P7162", "P0043", "P3043", "P3041.2", "P2041", "P6343.2", "P0142.1",
  "P6242.1", "P6141.2"
  )
STATSSA_links <- STATSSA_links[grepl(paste(Data_to_include, collapse = "|"), STATSSA_links)]
STATSSA_links <- str_replace_all(STATSSA_links, " ", "%20")

for (j in seq_along(STATSSA_links)) {

  # Create temporary files to download, unzip and save files
  tmp_file <- tempfile()
  link_error <- FALSE
  tryCatch(
    expr = {download.file(url = paste0("http://www.statssa.gov.za/", STATSSA_links[j]),
                          destfile = tmp_file)},
    error = function(e) {
      cat(paste0("\n", STATSSA_links[j], " link not found. Moving to next link.\n"))
      link_error <<- TRUE}
  )
  if(link_error) next

  unzipped_file_name <- unzip(tmp_file, list=TRUE)$Name

  tmp_file2 <- tempfile()
  tmp_file2 <- unzip(zipfile=tmp_file, files = unzipped_file_name[1], exdir=tempdir())

  info <- read.delim(tmp_file2, header = FALSE)

  setDT(info)
  test <- info

  test[str_sub(V1, 1, 3) == "H01", Group_number := sequence(.N)]
  setnafill(test, "locf", cols = "Group_number")
  test[str_sub(V1, 1, 1) == "H", Headers := TRUE]

  print(STATSSA_links[j])

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

    if (!exists("STATSSA")) {
      STATSSA <- result
    } else {
      STATSSA <- rbind(STATSSA, result, fill = TRUE)
    }
    cat(i, " ")
  }
}

# Remove duplicates
STATSSA <- STATSSA %>%
  distinct()

# Create STATSSA_descriptions
STATSSA_descriptions <- STATSSA %>%
  select(-Value, -Date) %>%
  distinct() %>%
  mutate_all(na_if," ") %>%
  select_if(colSums(!is.na(.)) > 0) %>%
  select(sort(tidyselect::peek_vars())) %>%
  arrange(H01, H03)

STATSSA <- STATSSA %>%
  select(Publication = H01, Code = H03, Date, Value) %>%
  arrange(Publication, Code)

save(STATSSA, file = "data-raw/STATSSA/STATSSA.rda", version = 2)
save(STATSSA_descriptions, file = "data-raw/STATSSA/STATSSA_descriptions.rda", version = 2)

usethis::use_data(STATSSA, overwrite = TRUE)
usethis::use_data(STATSSA_descriptions, overwrite = TRUE)
