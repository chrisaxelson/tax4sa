
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tax4sa

<!-- badges: start -->

<!-- badges: end -->

This is a minimal package to help with the compilation and analysis of
tax data in South Africa. The package only contains three main sets of
data, three functions and the personal income tax tables from 2001 to
2021.

The data includes monthly tax revenue collections of the South African
Revenue Service (SARS) as published by the [National Treasury of South
Africa](http://www.treasury.gov.za/comm_media/press/monthly/default.aspx)
in a dataframe named `SARS`, data from the Quarterly Bulletin published
by the [South African Reserve
Bank](https://www.resbank.co.za/en/home/publications/quarterly-bulletin1/download-information-from-xlsx-data-files)
in a dataframe named `SARB` and regularly updated statistics from
[Statistics South Africa](http://www.statssa.gov.za/?page_id=1847) in a
dataframe named `STATSSA`.

The three functions and the personal income tax tables are intended to
help with calculating tax liabilities, particularly when used with the
[administrative data from
SARS](https://sa-tied.wider.unu.edu/sites/default/files/pdf/SATIED_WP36_Ebrahim_Axelson_March_2019.pdf).

## Installation

You can install the package from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("chrisaxelson/tax4sa")
```

## Example

The data can be accessed by directly entering either `SARS` or `STATSSA`
and is in a tidy format to ease analysis within R. `SARB_descriptions`
and `STATSSA_descriptions` are also available to help with the details
of each variable in those two sets of data.

``` r
library(tax4sa)
library(dplyr)
library(knitr)

# Check revenue data
SARS %>% 
  filter(Tax == "Total tax revenue (gross)") %>% 
  tail(5) %>% 
  kable()
```

| Tax                       | Year | Fiscal\_year | Month    |   Revenue |
| :------------------------ | ---: | -----------: | :------- | --------: |
| Total tax revenue (gross) | 2020 |         2021 | November |  97377290 |
| Total tax revenue (gross) | 2020 |         2021 | December | 163683330 |
| Total tax revenue (gross) | 2021 |         2021 | January  | 101388476 |
| Total tax revenue (gross) | 2021 |         2021 | February | 130843297 |
| Total tax revenue (gross) | 2021 |         2021 | March    | 141965716 |

``` r

# Look for SARB economic data on GDP
SARB_descriptions %>% 
  filter(grepl("Gross domestic product at market prices", Description), Frequency == "K1") %>%
  kable()
```

| Code     | Description                             | Frequency | Frequency\_description | Unit\_of\_measure | Version\_description                                     |
| :------- | :-------------------------------------- | :-------- | :--------------------- | :---------------- | :------------------------------------------------------- |
| KBP6006C | Gross domestic product at market prices | K1        | Quarterly              | RMILL             | Constant 2010 prices                                     |
| KBP6006D | Gross domestic product at market prices | K1        | Quarterly              | RMILL             | Constant 2010 prices. Seasonally adjusted at annual rate |
| KBP6006K | Gross domestic product at market prices | K1        | Quarterly              | RMILL             | Current prices                                           |
| KBP6006L | Gross domestic product at market prices | K1        | Quarterly              | RMILL             | Current prices. Seasonally adjusted at annual rate       |
| KBP6006S | Gross domestic product at market prices | K1        | Quarterly              | PERC              | 1-Term % change                                          |

``` r

SARB %>% 
  filter(Code == "KBP6006K") %>% 
  tail(5) %>% 
  kable()
```

| Code     |     Date | Frequency |   Value |
| :------- | -------: | :-------- | ------: |
| KBP6006K | 20190400 | K1        | 1313452 |
| KBP6006K | 20200100 | K1        | 1281361 |
| KBP6006K | 20200200 | K1        | 1073725 |
| KBP6006K | 20200300 | K1        | 1266238 |
| KBP6006K | 20200400 | K1        | 1352651 |

``` r

# Look for STATSSA inflation data
STATSSA_descriptions %>% 
  filter(grepl("Consumer Price Index", H02), H04 == "All Items") %>%
  select(H01, H02, H03, H04, H13) %>% 
  kable()
```

| H01   | H02                  | H03      | H04       | H13           |
| :---- | :------------------- | :------- | :-------- | :------------ |
| P0141 | Consumer Price Index | CPA00000 | All Items | Western Cape  |
| P0141 | Consumer Price Index | CPB00000 | All Items | Eastern Cape  |
| P0141 | Consumer Price Index | CPC00000 | All Items | Northern Cape |
| P0141 | Consumer Price Index | CPD00000 | All Items | Free State    |
| P0141 | Consumer Price Index | CPE00000 | All Items | Kwazulu-Natal |
| P0141 | Consumer Price Index | CPF00000 | All Items | North-West    |
| P0141 | Consumer Price Index | CPG00000 | All Items | Gauteng       |
| P0141 | Consumer Price Index | CPH00000 | All Items | Mpumalanga    |
| P0141 | Consumer Price Index | CPJ00000 | All Items | Limpopo       |
| P0141 | Consumer Price Index | CPR00000 | All Items | Rural Areas   |
| P0141 | Consumer Price Index | CPT00000 | All Items | Total country |

``` r

STATSSA %>% 
  filter(Code == "CPT00000") %>% 
  tail(5) %>% 
  kable()
```

| Publication | Code     | Date    | Value |
| :---------- | :------- | :------ | :---- |
| P0141       | CPT00000 | 2020 12 | 117   |
| P0141       | CPT00000 | 2021 01 | 117.4 |
| P0141       | CPT00000 | 2021 02 | 118.2 |
| P0141       | CPT00000 | 2021 03 | 119   |
| P0141       | CPT00000 | 2021 04 | 119.8 |

The aim is to update the data monthly and the data structure should
hopefully stay the same to allow for automated updates.

``` r
library(dplyr)
library(tsibble)
library(ggplot2)
library(scales)

Total_revenue <- SARS %>% 
  filter(Tax == "Total tax revenue (gross)") %>% 
  mutate(Year_month = yearmonth(paste(Year, Month)))

ggplot(Total_revenue, aes(x = Year_month, y = Revenue)) +
  geom_line(color = "darkblue") + 
  scale_y_continuous(labels = comma) +
  theme_minimal() +
  theme(axis.title.x = element_blank())
```

<img src="man/figures/README-revenue-1.png" width="100%" />

The three functions are `tax_calculation`, `pit` and `pit_manual`. The
first is a generic function to apply a tax table to a value, while the
latter two specifically calculate the personal income tax liability in
South Africa. `pit_manual` allows for a custom tax table to be applied
to cater for modelling the impacts of changes in the personal income tax
tables. The package includes a list of historical tax tables to be used
in the calculations.

``` r
# Accessing tax tables
tax_calculation(100000, Tax_tables$PIT_brackets_2021)
#> [1] 18000

# Calculate personal income tax
pit(income = 1000000, age = 53, mtc = 2550, tax_year = 2021)
#> [1] 305263

# Same calculation in a relatively large dataframe with differing variables
individuals <- 1e6
df <- data.frame(Taxable_income = round(runif(individuals, 0, 3000000),0),
                 Age = round(runif(individuals, 18, 80),0),
                 MTC = round(runif(individuals, 0, 6000), 0),
                 Tax_year = round(runif(individuals, 2014, 2020), 0))

system.time({
  df <- df %>% 
    mutate(Simulated_tax = pit(Taxable_income, Age, MTC, Tax_year))
})
#>    user  system elapsed 
#>   0.534   0.111   0.691
```
