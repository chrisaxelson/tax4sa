library(tax4sa)
library(glue)

data("SARS_annual")
data("SARS_monthly")
data("SARB_descriptions")
data("SARB")
data("STATSSA_descriptions")
data("STATSSA")
data("DMRE_fuel")

force(SARS_annual)
force(SARS_monthly)
force(SARB_descriptions)
force(SARB)
force(STATSSA_descriptions)
force(STATSSA)
force(DMRE_fuel)

# Deleting and resaving trade data

library(piggyback)

pb_list(repo = "chrisaxelson/tax4sa",
        tag = "v0.0.1")

pb_delete(file = "SARS_exports_2010.rda",
          repo = "chrisaxelson/tax4sa",
          tag = "v0.0.1")

for (year in 2011:2021) {
  for (type in c("imports", "exports")) {
    pb_delete(file = glue("SARS_{type}_{year}.rda"),
              repo = "chrisaxelson/tax4sa",
              tag = "v0.0.1")
  }
}

for (year in 2010:2021) {
  for (type in c("imports", "exports")) {
    pb_upload(glue("SARS_{type}_{year}.parquet"),
              repo = "chrisaxelson/tax4sa",
              tag = "v0.0.1")
  }
}

# Downloading trade data in new folder

dir.create(file.path(getwd(), "SARS_trade_data"), showWarnings = FALSE)

for (year in 2010:2021) {
  for (type in c("imports", "exports")) {
    if (!file.exists(glue("SARS_trade_data/SARS_{type}_{year}.parquet"))) {
      download.file(glue("https://github.com/chrisaxelson/tax4sa/releases/download/v0.0.1/SARS_{type}_{year}.parquet"),
                    glue("SARS_trade_data/SARS_{type}_{year}.parquet"))
    }
  }
}

library(duckdb)
library(dplyr)


# Create connection to temporary database in memory
con <- dbConnect(duckdb())

setwd("SARS_trade_data")
# Create connection to parquet file

duckdb_register(con, "mtcars", "SARS_exports_2010.parquet")

SARS_trade <- tbl(con, "SARS_exports_2010.parquet")


SARS_trade %>%
  filter(TradeType == "Imports",
         YearMonth == 202012) %>%
  summarise(Total_imports = sum(CustomsValue))

SARS_trade_sample <- SARS_trade %>%
  head(1000) %>%
  collect()

library("DBI")
library("dplyr")
con <- dbConnect(duckdb::duckdb())
duckdb::duckdb_register(con, "mtcars", mtcars)

tbl(con, "mtcars") %>%
  group_by(dest) %>%
  summarise(delay = mean(dep_time))



for (year in 2010:2021) {
  for (type in c("imports", "exports")) {

    load(glue("SARS_{type}_{year}.rda"))

    if (year == 2010 & type == "imports") {
      SARS_trade <- SARS_imports_2010
      rm(SARS_imports_2010)
    } else {
      SARS_trade <- rbind(SARS_trade,
                          get(glue("SARS_{type}_{year}")))
      rm(get(glue("SARS_{type}_{year}")))
    }
  }
}

library(arrow)
library(glue)

year <- 2010
type <- "exports"

load("SARS_exports_2010.rda")
write_parquet(SARS_exports_2010, "SARS_exports_2010.parquet")

pb_delete(file = "SARS_exports_2010.parquet",
          repo = "chrisaxelson/tax4sa",
          tag = "v0.0.1")

pb_upload(glue("SARS_{type}_{year}.parquet"),
          repo = "chrisaxelson/tax4sa",
          tag = "v0.0.1")

pb_download(glue("SARS_{type}_{year}.parquet"),
            repo = "chrisaxelson/tax4sa",
            tag = "v0.0.1")





download.file(glue("https://api.github.com/repos/chrisaxelson/tax4sa/releases/assets/v0.0.1/SARS_{type}_{year}.parquet"),
              glue("SARS_{type}_{year}.parquet"))

sw <- read_parquet("SARS_exports_2010.parquet", as_data_frame = FALSE)

#### Add this to README ####

library(piggyback)
library(duckdb)
library(dplyr)

# Create a directory for the data if it isn't there
dir.create(file.path(getwd(), "SARS_trade_data"), showWarnings = FALSE)

# Download the trade data from Github - about 600MB
pb_download(repo = "chrisaxelson/tax4sa",
            dest = "SARS_trade_data")

# Create connection to temporary database in memory
con <- dbConnect(duckdb())

# Create a table that is made up of all the parquet files
SARS_trade <- tbl(con, "SARS_trade_data/SARS_*.parquet")

# Get the first 1000 lines into R to see the data - use "collect()"
SARS_trade_sample <- SARS_trade %>%
  head(1000) %>%
  collect()

# Generate the annual trade balance from the micro data
Trade_statistics <- SARS_trade %>%
  group_by(YearMonth) %>%
  summarise(Exports = sum(ifelse(TradeType == "Exports", CustomsValue, 0)),
            Imports = sum(ifelse(TradeType == "Imports", CustomsValue, 0))) %>%
  collect() %>%
  arrange(YearMonth) %>%
  mutate(Trade_Balance = Exports - Imports)

library(tax4sa)

SARS_monthly
