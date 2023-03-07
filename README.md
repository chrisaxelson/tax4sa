
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tax4sa

<!-- badges: start -->
<!-- badges: end -->

This is a minimal package to help with the compilation and analysis of
tax and economic data in South Africa. The package only contains seven
main sets of data, three functions and the personal income tax tables
from 1995/96 to 2023/24.

The data includes:

-   Annual tax revenue collections from 1983/84, as published in the
    [Budget Reviews of the National
    Treasury](http://www.treasury.gov.za/documents/national%20budget/default.aspx)
-   Monthly tax revenue collections from April 2002, as published in the
    [monthly financing statements of the National
    Treasury](http://www.treasury.gov.za/comm_media/press/monthly/default.aspx)
-   Monthly trade data on imports and exports from January 2010 from the
    [South African Revenue
    Service](https://tools.sars.gov.za/tradestatsportal/data_download.aspx)
-   Forecasts of the main tax instruments and GDP from 2005, as
    published in the [Budget Reviews of the National
    Treasury](http://www.treasury.gov.za/documents/national%20budget/default.aspx)
-   Quarterly Bulletin data from the [South African Reserve
    Bank](https://www.resbank.co.za/en/home/publications/quarterly-bulletin1/download-information-from-xlsx-data-files)
-   Economic statistics from [Statistics South
    Africa](http://www.statssa.gov.za/?page_id=1847)
-   Fuel pricing and levies from the [Department of Mineral Resources
    and
    Energy](http://www.energy.gov.za/files/esources/petroleum/petroleum_arch.html)

The three functions and the personal income tax tables are intended to
help with calculating tax liabilities, particularly when used with the
[administrative data from
SARS](https://sa-tied.wider.unu.edu/sites/default/files/pdf/SATIED_WP36_Ebrahim_Axelson_March_2019.pdf).

## Installation

You can install the package from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("chrisaxelson/tax4sa")
```

## Data

The data can be accessed by entering either `SARS_annual`,
`SARS_monthly`, `NT_forecasts`, `STATSSA`, `SARB` or `DMRE_fuel` and is
in a tidy format to ease analysis within R. The package needs to be
reinstalled to update the data. If you would like to load all the data
into your environment, you can run:

``` r
library(tax4sa)
load_tax4sa_data()
```

### South African Revenue Service

#### Revenue

The tax revenue data is split by three revenue classifications in
columns `T1`, `T2` and `T3` and all figures are in ZAR 000’s.

``` r
library(dplyr)
library(knitr)
library(kableExtra)

# Check revenue data
SARS_annual %>% 
  filter(Fiscal_year == 2022) %>%  
  select(T1:T3, Year, Revenue) %>% 
  mutate(Revenue = round(Revenue,0)) %>% 
  head(5) %>% 
  kable(format.args = list(big.mark = ","), 
        caption = "Annual tax revenue (R'000s)")
```

<table>
<caption>
Annual tax revenue (R’000s)
</caption>
<thead>
<tr>
<th style="text-align:left;">
T1
</th>
<th style="text-align:left;">
T2
</th>
<th style="text-align:left;">
T3
</th>
<th style="text-align:left;">
Year
</th>
<th style="text-align:right;">
Revenue
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Taxes on income and profits
</td>
<td style="text-align:left;">
Personal income tax
</td>
<td style="text-align:left;">
Personal income tax
</td>
<td style="text-align:left;">
2021/22
</td>
<td style="text-align:right;">
553,951,488
</td>
</tr>
<tr>
<td style="text-align:left;">
Taxes on income and profits
</td>
<td style="text-align:left;">
Tax on corporate income
</td>
<td style="text-align:left;">
Corporate income tax
</td>
<td style="text-align:left;">
2021/22
</td>
<td style="text-align:right;">
320,446,871
</td>
</tr>
<tr>
<td style="text-align:left;">
Taxes on income and profits
</td>
<td style="text-align:left;">
Tax on corporate income
</td>
<td style="text-align:left;">
Secondary tax on companies/dividend withholding tax
</td>
<td style="text-align:left;">
2021/22
</td>
<td style="text-align:right;">
33,429,472
</td>
</tr>
<tr>
<td style="text-align:left;">
Taxes on income and profits
</td>
<td style="text-align:left;">
Tax on corporate income
</td>
<td style="text-align:left;">
Interest withholding tax
</td>
<td style="text-align:left;">
2021/22
</td>
<td style="text-align:right;">
468,752
</td>
</tr>
<tr>
<td style="text-align:left;">
Taxes on income and profits
</td>
<td style="text-align:left;">
Other
</td>
<td style="text-align:left;">
Interest on overdue income tax
</td>
<td style="text-align:left;">
2021/22
</td>
<td style="text-align:right;">
4,573,663
</td>
</tr>
</tbody>
</table>

``` r
# And monthly
SARS_monthly %>% 
  filter(T3 == "Health promotion levy") %>% 
  select(Tax = T3, Month, Quarter, Year, Fiscal_year, Revenue) %>% 
  mutate(Year = as.character(Year),
         Fiscal_year = as.character(Fiscal_year)) %>% 
  tail(5) %>% 
  kable(format.args = list(big.mark = ","),
        caption = "Monthly health promotion levy revenue (R'000s)") 
```

<table>
<caption>
Monthly health promotion levy revenue (R’000s)
</caption>
<thead>
<tr>
<th style="text-align:left;">
Tax
</th>
<th style="text-align:left;">
Month
</th>
<th style="text-align:right;">
Quarter
</th>
<th style="text-align:left;">
Year
</th>
<th style="text-align:left;">
Fiscal_year
</th>
<th style="text-align:right;">
Revenue
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Health promotion levy
</td>
<td style="text-align:left;">
September
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:left;">
2022
</td>
<td style="text-align:left;">
2023
</td>
<td style="text-align:right;">
175,700.0
</td>
</tr>
<tr>
<td style="text-align:left;">
Health promotion levy
</td>
<td style="text-align:left;">
October
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:left;">
2022
</td>
<td style="text-align:left;">
2023
</td>
<td style="text-align:right;">
184,407.0
</td>
</tr>
<tr>
<td style="text-align:left;">
Health promotion levy
</td>
<td style="text-align:left;">
November
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:left;">
2022
</td>
<td style="text-align:left;">
2023
</td>
<td style="text-align:right;">
232,587.7
</td>
</tr>
<tr>
<td style="text-align:left;">
Health promotion levy
</td>
<td style="text-align:left;">
December
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:left;">
2022
</td>
<td style="text-align:left;">
2023
</td>
<td style="text-align:right;">
209,198.2
</td>
</tr>
<tr>
<td style="text-align:left;">
Health promotion levy
</td>
<td style="text-align:left;">
January
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:left;">
2023
</td>
<td style="text-align:left;">
2023
</td>
<td style="text-align:right;">
220,373.0
</td>
</tr>
</tbody>
</table>

Or you can download the annual and monthly data in one spreadsheet.

``` r
# This saves it in your current working directory
# download.file("https://raw.githubusercontent.com/chrisaxelson/tax4sa/master/data-raw/SARS/Revenue.xlsx",
#               "Revenue.xlsx")
```

#### Trade data

The line-by-line trade data from the South African Revenue Service is
too large to be included directly in the package, but can be downloaded
separately per year of data and type of trade (imports or exports). Each
file is around 20MB.

The following code downloads the data into your working directory using
the
[piggyback](https://cran.r-project.org/web/packages/piggyback/vignettes/intro.html)
package. The data is likely to be too large to be loaded onto most
computers, so it is saved as individual
[parquet](https://www.upsolver.com/blog/apache-parquet-why-use) files
where you can use [duckdb](https://duckdb.org/) to query all the data
without moving it into RAM. Any subsequent runs of the code will only
download updated data files.

``` r
library(piggyback)

# Download individual files - can adjust imports to exports and the year
pb_download("SARS_imports_2022.parquet", 
            repo = "chrisaxelson/tax4sa")

# # Or download ALL the trade data from Github - about 600MB
# # If run again, will only download updated data
# pb_download(repo = "chrisaxelson/tax4sa")

# Quick example of how to access the data
library(duckdb)

# Create connection to temporary database in memory
con <- dbConnect(duckdb())

# Reference from all the parquet files in that folder
tbl(con, "SARS_*.parquet") %>% 
  head(5) %>% 
  mutate(YearMonth = as.character(YearMonth)) %>% 
  select(TradeType, District = DistrictOfficeName, Origin = CountryOfOriginName, Unit = StatisticalUnit,
         YearMonth, ChapterAndDescription, Quantity = StatisticalQuantity, Value_ZAR = CustomsValue) %>% 
  kable(format.args = list(big.mark = ","),
        caption = "Monthly trade data")
```

<table>
<caption>
Monthly trade data
</caption>
<thead>
<tr>
<th style="text-align:left;">
TradeType
</th>
<th style="text-align:left;">
District
</th>
<th style="text-align:left;">
Origin
</th>
<th style="text-align:left;">
Unit
</th>
<th style="text-align:left;">
YearMonth
</th>
<th style="text-align:left;">
ChapterAndDescription
</th>
<th style="text-align:right;">
Quantity
</th>
<th style="text-align:right;">
Value_ZAR
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Exports
</td>
<td style="text-align:left;">
Alexanderbay
</td>
<td style="text-align:left;">
China
</td>
<td style="text-align:left;">
KG
</td>
<td style="text-align:left;">
201001
</td>
<td style="text-align:left;">
61 - Clothing and accessories, knitted or crocheted
</td>
<td style="text-align:right;">
57
</td>
<td style="text-align:right;">
930
</td>
</tr>
<tr>
<td style="text-align:left;">
Exports
</td>
<td style="text-align:left;">
Alexanderbay
</td>
<td style="text-align:left;">
China
</td>
<td style="text-align:left;">
NO
</td>
<td style="text-align:left;">
201001
</td>
<td style="text-align:left;">
61 - Clothing and accessories, knitted or crocheted
</td>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
634
</td>
</tr>
<tr>
<td style="text-align:left;">
Exports
</td>
<td style="text-align:left;">
Alexanderbay
</td>
<td style="text-align:left;">
Bangladesh
</td>
<td style="text-align:left;">
NO
</td>
<td style="text-align:left;">
201001
</td>
<td style="text-align:left;">
61 - Clothing and accessories, knitted or crocheted
</td>
<td style="text-align:right;">
8
</td>
<td style="text-align:right;">
288
</td>
</tr>
<tr>
<td style="text-align:left;">
Exports
</td>
<td style="text-align:left;">
Alexanderbay
</td>
<td style="text-align:left;">
China
</td>
<td style="text-align:left;">
NO
</td>
<td style="text-align:left;">
201001
</td>
<td style="text-align:left;">
62 - Clothing and accessories, not knitted or crocheted
</td>
<td style="text-align:right;">
51
</td>
<td style="text-align:right;">
7,979
</td>
</tr>
<tr>
<td style="text-align:left;">
Exports
</td>
<td style="text-align:left;">
Alexanderbay
</td>
<td style="text-align:left;">
China
</td>
<td style="text-align:left;">
NO
</td>
<td style="text-align:left;">
201001
</td>
<td style="text-align:left;">
62 - Clothing and accessories, not knitted or crocheted
</td>
<td style="text-align:right;">
96
</td>
<td style="text-align:right;">
7,930
</td>
</tr>
</tbody>
</table>

## National Treasury

``` r
# Check revenue data
NT_forecasts %>% 
  filter(Publication_year == 2023,
         Category == "Gross tax revenue") %>% 
   mutate(Publication_year = as.character(Publication_year)) %>% 
  kable(format.args = list(big.mark = ","), 
        caption = "Tax revenue forecasts (R million)")
```

<table>
<caption>
Tax revenue forecasts (R million)
</caption>
<thead>
<tr>
<th style="text-align:left;">
Source
</th>
<th style="text-align:left;">
Publication_year
</th>
<th style="text-align:left;">
Category
</th>
<th style="text-align:left;">
Forecast_year
</th>
<th style="text-align:right;">
Forecast
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Budget
</td>
<td style="text-align:left;">
2023
</td>
<td style="text-align:left;">
Gross tax revenue
</td>
<td style="text-align:left;">
2022/23
</td>
<td style="text-align:right;">
1,692,177
</td>
</tr>
<tr>
<td style="text-align:left;">
Budget
</td>
<td style="text-align:left;">
2023
</td>
<td style="text-align:left;">
Gross tax revenue
</td>
<td style="text-align:left;">
2023/24
</td>
<td style="text-align:right;">
1,787,456
</td>
</tr>
<tr>
<td style="text-align:left;">
Budget
</td>
<td style="text-align:left;">
2023
</td>
<td style="text-align:left;">
Gross tax revenue
</td>
<td style="text-align:left;">
2024/25
</td>
<td style="text-align:right;">
1,907,727
</td>
</tr>
<tr>
<td style="text-align:left;">
Budget
</td>
<td style="text-align:left;">
2023
</td>
<td style="text-align:left;">
Gross tax revenue
</td>
<td style="text-align:left;">
2025/26
</td>
<td style="text-align:right;">
2,043,456
</td>
</tr>
</tbody>
</table>

Or you can download the forecasts in one spreadsheet.

``` r
# This saves it in your current working directory
# download.file("https://raw.githubusercontent.com/chrisaxelson/tax4sa/master/data-raw/NT/Forecasts.xlsx",
#               "Forecasts.xlsx")
```

## South African Reserve Bank

``` r
# Look for SARB economic data on GDP
SARB_descriptions %>% 
  filter(grepl("Gross domestic product at market prices", Description), Frequency == "K1") %>%
  select(-Description, -Frequency) %>% 
  kable()
```

<table>
<thead>
<tr>
<th style="text-align:left;">
Code
</th>
<th style="text-align:left;">
Frequency_description
</th>
<th style="text-align:left;">
Unit_of_measure
</th>
<th style="text-align:left;">
Version_description
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
KBP6006C
</td>
<td style="text-align:left;">
Quarterly
</td>
<td style="text-align:left;">
RMILL
</td>
<td style="text-align:left;">
Constant 2010 prices
</td>
</tr>
<tr>
<td style="text-align:left;">
KBP6006D
</td>
<td style="text-align:left;">
Quarterly
</td>
<td style="text-align:left;">
RMILL
</td>
<td style="text-align:left;">
Constant 2010 prices. Seasonally adjusted at annual rate
</td>
</tr>
<tr>
<td style="text-align:left;">
KBP6006K
</td>
<td style="text-align:left;">
Quarterly
</td>
<td style="text-align:left;">
RMILL
</td>
<td style="text-align:left;">
Current prices
</td>
</tr>
<tr>
<td style="text-align:left;">
KBP6006L
</td>
<td style="text-align:left;">
Quarterly
</td>
<td style="text-align:left;">
RMILL
</td>
<td style="text-align:left;">
Current prices. Seasonally adjusted at annual rate
</td>
</tr>
<tr>
<td style="text-align:left;">
KBP6006S
</td>
<td style="text-align:left;">
Quarterly
</td>
<td style="text-align:left;">
PERC
</td>
<td style="text-align:left;">
1-Term % change
</td>
</tr>
</tbody>
</table>

``` r
SARB %>% 
  filter(Code == "KBP6006K") %>% 
  select(-Month) %>% 
  tail(5) %>% 
  kable()
```

<table>
<thead>
<tr>
<th style="text-align:left;">
Code
</th>
<th style="text-align:right;">
Date
</th>
<th style="text-align:left;">
Frequency
</th>
<th style="text-align:right;">
Quarter
</th>
<th style="text-align:right;">
Year
</th>
<th style="text-align:right;">
Fiscal_year
</th>
<th style="text-align:right;">
Value
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
KBP6006K
</td>
<td style="text-align:right;">
20210300
</td>
<td style="text-align:left;">
K1
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
2021
</td>
<td style="text-align:right;">
2022
</td>
<td style="text-align:right;">
1551077
</td>
</tr>
<tr>
<td style="text-align:left;">
KBP6006K
</td>
<td style="text-align:right;">
20210400
</td>
<td style="text-align:left;">
K1
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
2021
</td>
<td style="text-align:right;">
2022
</td>
<td style="text-align:right;">
1596999
</td>
</tr>
<tr>
<td style="text-align:left;">
KBP6006K
</td>
<td style="text-align:right;">
20220100
</td>
<td style="text-align:left;">
K1
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
2022
</td>
<td style="text-align:right;">
2022
</td>
<td style="text-align:right;">
1560424
</td>
</tr>
<tr>
<td style="text-align:left;">
KBP6006K
</td>
<td style="text-align:right;">
20220200
</td>
<td style="text-align:left;">
K1
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
2022
</td>
<td style="text-align:right;">
2023
</td>
<td style="text-align:right;">
1667225
</td>
</tr>
<tr>
<td style="text-align:left;">
KBP6006K
</td>
<td style="text-align:right;">
20220300
</td>
<td style="text-align:left;">
K1
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
2022
</td>
<td style="text-align:right;">
2023
</td>
<td style="text-align:right;">
1693232
</td>
</tr>
</tbody>
</table>

## Statistics South Africa

``` r
# Look for STATSSA inflation data
STATSSA_descriptions %>% 
  filter(H04 == "CPI Headline") %>%
  select(H01, H02, H03, H04, H13) %>% 
  kable()
```

<table>
<thead>
<tr>
<th style="text-align:left;">
H01
</th>
<th style="text-align:left;">
H02
</th>
<th style="text-align:left;">
H03
</th>
<th style="text-align:left;">
H04
</th>
<th style="text-align:left;">
H13
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
P0141
</td>
<td style="text-align:left;">
Consumer Price Index
</td>
<td style="text-align:left;">
CPS00000
</td>
<td style="text-align:left;">
CPI Headline
</td>
<td style="text-align:left;">
All urban areas
</td>
</tr>
</tbody>
</table>

``` r
STATSSA %>% 
  filter(H03 == "CPS00000") %>% 
  tail(5) %>% 
  kable()
```

<table>
<thead>
<tr>
<th style="text-align:left;">
</th>
<th style="text-align:left;">
H01
</th>
<th style="text-align:left;">
H03
</th>
<th style="text-align:left;">
Date
</th>
<th style="text-align:left;">
Month
</th>
<th style="text-align:right;">
Quarter
</th>
<th style="text-align:right;">
Year
</th>
<th style="text-align:right;">
Fiscal_year
</th>
<th style="text-align:right;">
Value
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
177
</td>
<td style="text-align:left;">
P0141
</td>
<td style="text-align:left;">
CPS00000
</td>
<td style="text-align:left;">
2022 09
</td>
<td style="text-align:left;">
September
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
2022
</td>
<td style="text-align:right;">
2023
</td>
<td style="text-align:right;">
106.1
</td>
</tr>
<tr>
<td style="text-align:left;">
178
</td>
<td style="text-align:left;">
P0141
</td>
<td style="text-align:left;">
CPS00000
</td>
<td style="text-align:left;">
2022 10
</td>
<td style="text-align:left;">
October
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
2022
</td>
<td style="text-align:right;">
2023
</td>
<td style="text-align:right;">
106.5
</td>
</tr>
<tr>
<td style="text-align:left;">
179
</td>
<td style="text-align:left;">
P0141
</td>
<td style="text-align:left;">
CPS00000
</td>
<td style="text-align:left;">
2022 11
</td>
<td style="text-align:left;">
November
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
2022
</td>
<td style="text-align:right;">
2023
</td>
<td style="text-align:right;">
106.8
</td>
</tr>
<tr>
<td style="text-align:left;">
180
</td>
<td style="text-align:left;">
P0141
</td>
<td style="text-align:left;">
CPS00000
</td>
<td style="text-align:left;">
2022 12
</td>
<td style="text-align:left;">
December
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
2022
</td>
<td style="text-align:right;">
2023
</td>
<td style="text-align:right;">
107.2
</td>
</tr>
<tr>
<td style="text-align:left;">
181
</td>
<td style="text-align:left;">
P0141
</td>
<td style="text-align:left;">
CPS00000
</td>
<td style="text-align:left;">
2023 01
</td>
<td style="text-align:left;">
January
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
2023
</td>
<td style="text-align:right;">
2023
</td>
<td style="text-align:right;">
107.1
</td>
</tr>
</tbody>
</table>

## Department of Mineral Resources and Energy

Note that the `Price` column reflects retail prices for unleaded petrol,
wholesale list prices for diesel and illuminating paraffin and maximum
retail price for liquified petroleum gas.

``` r
# Look for STATSSA inflation data
DMRE_fuel %>% 
  select(Fuel_type:General_fuel_levy) %>% 
  tail(10) %>% 
  kable()
```

<table>
<thead>
<tr>
<th style="text-align:left;">
Fuel_type
</th>
<th style="text-align:left;">
Region
</th>
<th style="text-align:left;">
Date
</th>
<th style="text-align:right;">
Price
</th>
<th style="text-align:right;">
Basic_fuel_price
</th>
<th style="text-align:right;">
General_fuel_levy
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
95_ULP
</td>
<td style="text-align:left;">
Coastal
</td>
<td style="text-align:left;">
2023-03-01
</td>
<td style="text-align:right;">
2230.000
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
244.85
</td>
</tr>
<tr>
<td style="text-align:left;">
95_ULP
</td>
<td style="text-align:left;">
Gauteng
</td>
<td style="text-align:left;">
2023-03-01
</td>
<td style="text-align:right;">
2295.000
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
244.85
</td>
</tr>
<tr>
<td style="text-align:left;">
Diesel_0.005
</td>
<td style="text-align:left;">
Coastal
</td>
<td style="text-align:left;">
2023-03-01
</td>
<td style="text-align:right;">
2106.610
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
350.03
</td>
</tr>
<tr>
<td style="text-align:left;">
Diesel_0.005
</td>
<td style="text-align:left;">
Gauteng
</td>
<td style="text-align:left;">
2023-03-01
</td>
<td style="text-align:right;">
2171.810
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
350.03
</td>
</tr>
<tr>
<td style="text-align:left;">
Diesel_0.05
</td>
<td style="text-align:left;">
Coastal
</td>
<td style="text-align:left;">
2023-03-01
</td>
<td style="text-align:right;">
2097.210
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
340.63
</td>
</tr>
<tr>
<td style="text-align:left;">
Diesel_0.05
</td>
<td style="text-align:left;">
Gauteng
</td>
<td style="text-align:left;">
2023-03-01
</td>
<td style="text-align:right;">
2162.410
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
340.63
</td>
</tr>
<tr>
<td style="text-align:left;">
Illuminating_Paraffin
</td>
<td style="text-align:left;">
Coastal
</td>
<td style="text-align:left;">
2023-03-01
</td>
<td style="text-align:right;">
1517.758
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
Illuminating_Paraffin
</td>
<td style="text-align:left;">
Gauteng
</td>
<td style="text-align:left;">
2023-03-01
</td>
<td style="text-align:right;">
1596.958
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
Liquefied_Petroleum_Gas
</td>
<td style="text-align:left;">
Coastal
</td>
<td style="text-align:left;">
2023-03-01
</td>
<td style="text-align:right;">
3610.000
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
Liquefied_Petroleum_Gas
</td>
<td style="text-align:left;">
Gauteng
</td>
<td style="text-align:left;">
2023-03-01
</td>
<td style="text-align:right;">
3868.000
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
</tr>
</tbody>
</table>

## Functions

The three functions are `tax_calculation`, `pit` and `pit_manual`. The
first is a generic function to apply a tax table to a value, while the
latter two specifically calculate the personal income tax liability in
South Africa. `pit_manual` allows for a custom tax table to be applied
to cater for modelling the impacts of changes in the personal income tax
tables. The package includes a list of historical tax tables to be used
in the calculations.

``` r
# Accessing tax tables
tax_calculation(100000, Tax_tables$PIT_brackets_2024)
#> [1] 18000

# Calculate personal income tax
pit(income = 1000000, age = 53, mtc = 2550, tax_year = 2024)
#> [1] 289734

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
#>    0.31    0.09    0.42
```

## Examples

``` r
library(tax4sa)
library(dplyr)
library(ggplot2)
library(scales)

# Create a tax to GDP chart - revenue per year first
Total_revenue <- SARS_annual %>% 
  group_by(Fiscal_year) %>% 
  summarise(Revenue = sum(Revenue))

# Get nominal GDP across fiscal year by summing per quarter
GDP_fiscal <- STATSSA %>% 
  filter(H03 == "QNU1000") %>% 
  group_by(Fiscal_year) %>% 
  summarise(GDP = sum(Value)) %>% 
  filter(Fiscal_year < 2023, Fiscal_year > 1993)

# Join together and create tax to GDP
Tax_to_GDP <- GDP_fiscal %>% 
  inner_join(Total_revenue, by = "Fiscal_year") %>% 
  mutate(Revenue = Revenue / 1000,
         Tax_to_GDP = Revenue / GDP)

# Chart
ggplot(Tax_to_GDP, aes(x = Fiscal_year, y = Tax_to_GDP)) +
  geom_line() + 
  geom_point() +
  geom_text(aes(label = ifelse(Fiscal_year == 2022, paste0(round(Tax_to_GDP,3) * 100, "%"),'')),
            hjust=1.2, vjust=0.5, show.legend = FALSE) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1L)) +
  theme_classic() +
  ylab("Tax to GDP") +
  xlab("Fiscal year") +
  ggtitle("Gross tax revenue to GDP")
```

<img src="man/figures/README-revenue-1.png" width="100%" />

``` r
library(lubridate)

DMRE_fuel %>% 
  filter(Fuel_type == "95_ULP",
         Region == "Gauteng",
         Date > dmy("01012016")) %>% 
  ggplot(aes(x = Date, y = Price/100)) + 
  geom_line() +
  geom_point() +
  theme_classic() +
  ylab("Retail price (R/litre)") +
  ggtitle("Retail price of 95 unleaded petrol in Gauteng") +
  geom_text(aes(label = ifelse(Date == "2022-07-06", 
                               paste0("R", Price/100),'')),
            hjust=1.2, vjust=0.5, show.legend = FALSE)
```

<img src="man/figures/README-fuel-1.png" width="100%" />

``` r
DMRE_fuel %>% 
  filter(Fuel_type == "95_ULP",
         Region == "Gauteng",
         Date > dmy("01012016")) %>% 
  mutate(Tax = General_fuel_levy + 
           Road_accident_fund_levy + 
           Customs_and_excise_levy + 
           Demand_side_management_levy,
         Tax_percentage = Tax / Price) %>% 
  ggplot(aes(x = Date, y = Tax_percentage)) + 
  geom_line() +
  geom_point() +
  theme_classic() +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1L)) +
  ylab("Percentage of retail price") +
  ggtitle("Levies as a percentage of retail price",
          subtitle = c("Includes the general fuel levy, the Road Accident Fund levy, customs levy and DSML")) +
    geom_text(aes(label = ifelse(Date == "2022-07-06", 
                               paste0(round(Tax_percentage*100 , 1), "%"),'')),
            hjust=0.25, vjust=-1, show.legend = FALSE)
```

<img src="man/figures/README-fuel-2.png" width="100%" />

``` r
# Quick example of how to access the data
library(duckdb)

# Create connection to temporary database in memory
con <- dbConnect(duckdb())

# Generate the annual trade balance from the micro data
system.time(
  Trade_statistics <- tbl(con, "SARS_*.parquet") %>%
  group_by(CalendarYear) %>%
  summarise(Exports = sum(ifelse(TradeType == "Exports", CustomsValue, 0)),
            Imports = sum(ifelse(TradeType == "Imports", CustomsValue, 0))) %>%
  collect() %>%
  arrange(CalendarYear) %>%
  mutate(CalendarYear = as.character(CalendarYear),
         Trade_Balance = Exports - Imports)
)
#>    user  system elapsed 
#>    3.43    0.52    1.72

ggplot(Trade_statistics, aes(x = CalendarYear, y = Trade_Balance/1e9)) +
  geom_bar(stat = "identity") +
  theme_classic() +
  xlab("Year") +
  ylab("Trade balance (R billions)") +
  ggtitle("Trade balance (exports - imports) in nominal terms") +
      geom_text(aes(label = ifelse(CalendarYear == "2021", 
                               paste0("R", round(Trade_Balance/1e9, 1), "bn"),'')),
            vjust = -0.5, show.legend = FALSE)
```

<img src="man/figures/README-trade_plot-1.png" width="100%" />

<!-- ```{r cpi, message = FALSE} -->
<!-- # Get headline CPI index and check growth -->
<!-- CPI <- STATSSA %>%  -->
<!--   filter(Code == "CPS00000") %>%  -->
<!--   mutate(Value = as.numeric(Value),  -->
<!--          Change = Value / lag(Value, n = 12) - 1) -->
<!-- # Chart -->
<!-- ggplot(CPI, aes(x = Fiscal_year, y = Tax_to_GDP)) + -->
<!--   geom_line(color = "darkblue") +  -->
<!--   geom_point(color = "darkblue") + -->
<!--   scale_y_continuous(labels = scales::percent_format(accuracy = 1L)) + -->
<!--   theme_minimal() + -->
<!--   theme(axis.title.x = element_blank()) + -->
<!--   ylab("Tax to GDP") + -->
<!--   ggtitle("Total tax revenue to GDP") -->
<!-- ``` -->
