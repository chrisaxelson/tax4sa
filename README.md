
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tax4sa

<!-- badges: start -->

<!-- badges: end -->

This is a minimal package to help with the compilation and analysis of
tax and economic data in South Africa. The package only contains six
main sets of data, three functions and the personal income tax tables
from 1995/96 to 2021/22.

The data includes:

  - Annual tax revenue collections from 1983/84, as published in the
    [Budget Reviews of the National
    Treasury](http://www.treasury.gov.za/documents/national%20budget/default.aspx)
  - Monthly tax revenue collections from April 2002, as published in the
    [monthly financing statements of the National
    Treasury](http://www.treasury.gov.za/comm_media/press/monthly/default.aspx)
  - Monthly trade data on imports and exports from January 2010 from the
    [South African Revenue
    Service](https://tools.sars.gov.za/tradestatsportal/data_download.aspx)
  - Forecasts of the main tax instruments and GDP from 2005, as
    published in the [Budget Reviews of the National
    Treasury](http://www.treasury.gov.za/documents/national%20budget/default.aspx)
  - Quarterly Bulletin data from the [South African Reserve
    Bank](https://www.resbank.co.za/en/home/publications/quarterly-bulletin1/download-information-from-xlsx-data-files)
  - Economic statistics from [Statistics South
    Africa](http://www.statssa.gov.za/?page_id=1847)

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

The data can be accessed by directly entering either `SARS_annual`,
`SARS_monthly`, `NT_forecasts`, `STATSSA` or `SARB` and is in a tidy
format to ease analysis within R.

### South African Revenue Service

The tax revenue data is split by three revenue classifications in
columns `T1`, `T2` and `T3` and all figures are in ZAR 000’s.

``` r
library(tax4sa)
library(dplyr)
library(knitr)
#> Warning: package 'knitr' was built under R version 4.0.5
library(kableExtra)

# Check revenue data
SARS_annual %>% 
  filter(Fiscal_year == 2021) %>%  
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

2020/21

</td>

<td style="text-align:right;">

487,006,278

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

2020/21

</td>

<td style="text-align:right;">

202,099,326

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

2020/21

</td>

<td style="text-align:right;">

24,845,362

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

2020/21

</td>

<td style="text-align:right;">

490,305

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

2020/21

</td>

<td style="text-align:right;">

3,739,157

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

Fiscal\_year

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

2021

</td>

<td style="text-align:left;">

2022

</td>

<td style="text-align:right;">

167,249

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

2021

</td>

<td style="text-align:left;">

2022

</td>

<td style="text-align:right;">

204,775

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

2021

</td>

<td style="text-align:left;">

2022

</td>

<td style="text-align:right;">

204,515

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

2021

</td>

<td style="text-align:left;">

2022

</td>

<td style="text-align:right;">

231,748

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

2022

</td>

<td style="text-align:left;">

2022

</td>

<td style="text-align:right;">

209,823

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

The line-by-line trade data from the South African Revenue Service is
too large to be included directly in the package, but can be downloaded
separately per year of data and type of trade (imports or exports). Each
file is around 20MB.

``` r
# Downloading 2021 imports
if (!file.exists("SARS_imports_2021.rda")) {
  download.file("https://github.com/chrisaxelson/tax4sa/releases/download/v0.0.1/SARS_imports_2021.rda",
              "SARS_imports_2021.rda")
} 
# Data is available from 2010 for both imports and exports. File name convention is "SARS_exports_2010.rda", etc. 

load("SARS_imports_2021.rda")

SARS_imports_2021 %>% 
  head(5) %>% 
  mutate(YearMonth = as.character(YearMonth)) %>% 
  select(District = DistrictOfficeName, Origin = CountryOfOriginName, Unit = StatisticalUnit,
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

Value\_ZAR

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Beit Bridge

</td>

<td style="text-align:left;">

China

</td>

<td style="text-align:left;">

KG

</td>

<td style="text-align:left;">

202102

</td>

<td style="text-align:left;">

90 - Medical and Photographic Equipment

</td>

<td style="text-align:right;">

5.00

</td>

<td style="text-align:right;">

18,870

</td>

</tr>

<tr>

<td style="text-align:left;">

Beit Bridge

</td>

<td style="text-align:left;">

Malawi

</td>

<td style="text-align:left;">

KG

</td>

<td style="text-align:left;">

202102

</td>

<td style="text-align:left;">

03 - Fish and crustaceans

</td>

<td style="text-align:right;">

10,544.00

</td>

<td style="text-align:right;">

62,266

</td>

</tr>

<tr>

<td style="text-align:left;">

Beit Bridge

</td>

<td style="text-align:left;">

Malawi

</td>

<td style="text-align:left;">

KG

</td>

<td style="text-align:left;">

202102

</td>

<td style="text-align:left;">

07 - Edible vegetables and certain roots and tubers

</td>

<td style="text-align:right;">

6,000.00

</td>

<td style="text-align:right;">

4,009

</td>

</tr>

<tr>

<td style="text-align:left;">

Beit Bridge

</td>

<td style="text-align:left;">

Malawi

</td>

<td style="text-align:left;">

KG

</td>

<td style="text-align:left;">

202102

</td>

<td style="text-align:left;">

07 - Edible vegetables and certain roots and tubers

</td>

<td style="text-align:right;">

90,000.00

</td>

<td style="text-align:right;">

1,278,398

</td>

</tr>

<tr>

<td style="text-align:left;">

Beit Bridge

</td>

<td style="text-align:left;">

Italy

</td>

<td style="text-align:left;">

KG

</td>

<td style="text-align:left;">

202102

</td>

<td style="text-align:left;">

40 - Rubber and articles thereof

</td>

<td style="text-align:right;">

0.04

</td>

<td style="text-align:right;">

34

</td>

</tr>

</tbody>

</table>

## National Treasury

``` r
# Check revenue data
NT_forecasts %>% 
  filter(Publication_year == 2021,
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

Publication\_year

</th>

<th style="text-align:left;">

Category

</th>

<th style="text-align:left;">

Forecast\_year

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

2021

</td>

<td style="text-align:left;">

Gross tax revenue

</td>

<td style="text-align:left;">

2020/21

</td>

<td style="text-align:right;">

1,212,206

</td>

</tr>

<tr>

<td style="text-align:left;">

Budget

</td>

<td style="text-align:left;">

2021

</td>

<td style="text-align:left;">

Gross tax revenue

</td>

<td style="text-align:left;">

2021/22

</td>

<td style="text-align:right;">

1,365,124

</td>

</tr>

<tr>

<td style="text-align:left;">

Budget

</td>

<td style="text-align:left;">

2021

</td>

<td style="text-align:left;">

Gross tax revenue

</td>

<td style="text-align:left;">

2022/23

</td>

<td style="text-align:right;">

1,457,653

</td>

</tr>

<tr>

<td style="text-align:left;">

Budget

</td>

<td style="text-align:left;">

2021

</td>

<td style="text-align:left;">

Gross tax revenue

</td>

<td style="text-align:left;">

2023/24

</td>

<td style="text-align:right;">

1,548,512

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

Frequency\_description

</th>

<th style="text-align:left;">

Unit\_of\_measure

</th>

<th style="text-align:left;">

Version\_description

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

Fiscal\_year

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

20200300

</td>

<td style="text-align:left;">

K1

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

2020

</td>

<td style="text-align:right;">

2021

</td>

<td style="text-align:right;">

1404540

</td>

</tr>

<tr>

<td style="text-align:left;">

KBP6006K

</td>

<td style="text-align:right;">

20200400

</td>

<td style="text-align:left;">

K1

</td>

<td style="text-align:right;">

4

</td>

<td style="text-align:right;">

2020

</td>

<td style="text-align:right;">

2021

</td>

<td style="text-align:right;">

1499180

</td>

</tr>

<tr>

<td style="text-align:left;">

KBP6006K

</td>

<td style="text-align:right;">

20210100

</td>

<td style="text-align:left;">

K1

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

2021

</td>

<td style="text-align:right;">

2021

</td>

<td style="text-align:right;">

1453958

</td>

</tr>

<tr>

<td style="text-align:left;">

KBP6006K

</td>

<td style="text-align:right;">

20210200

</td>

<td style="text-align:left;">

K1

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

2021

</td>

<td style="text-align:right;">

2022

</td>

<td style="text-align:right;">

1543106

</td>

</tr>

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

1565697

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

Fiscal\_year

</th>

<th style="text-align:right;">

Value

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

165

</td>

<td style="text-align:left;">

P0141

</td>

<td style="text-align:left;">

CPS00000

</td>

<td style="text-align:left;">

2021 09

</td>

<td style="text-align:left;">

September

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

98.7

</td>

</tr>

<tr>

<td style="text-align:left;">

166

</td>

<td style="text-align:left;">

P0141

</td>

<td style="text-align:left;">

CPS00000

</td>

<td style="text-align:left;">

2021 10

</td>

<td style="text-align:left;">

October

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

99.0

</td>

</tr>

<tr>

<td style="text-align:left;">

167

</td>

<td style="text-align:left;">

P0141

</td>

<td style="text-align:left;">

CPS00000

</td>

<td style="text-align:left;">

2021 11

</td>

<td style="text-align:left;">

November

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

99.4

</td>

</tr>

<tr>

<td style="text-align:left;">

168

</td>

<td style="text-align:left;">

P0141

</td>

<td style="text-align:left;">

CPS00000

</td>

<td style="text-align:left;">

2021 12

</td>

<td style="text-align:left;">

December

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

100.0

</td>

</tr>

<tr>

<td style="text-align:left;">

169

</td>

<td style="text-align:left;">

P0141

</td>

<td style="text-align:left;">

CPS00000

</td>

<td style="text-align:left;">

2022 01

</td>

<td style="text-align:left;">

January

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

100.2

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
#>    0.26    0.03    0.30
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

# Get Nominal GDP across fiscal year by summing per quarter
GDP_fiscal <- STATSSA %>% 
  filter(H03 == "QNU1000") %>% 
  group_by(Fiscal_year) %>% 
  summarise(GDP = sum(Value)) %>% 
  filter(Fiscal_year < 2022, Fiscal_year > 1993)

# Join together and create tax to GDP
Tax_to_GDP <- GDP_fiscal %>% 
  inner_join(Total_revenue, by = "Fiscal_year") %>% 
  mutate(Revenue = Revenue / 1000,
         Tax_to_GDP = Revenue / GDP)

# Chart
ggplot(Tax_to_GDP, aes(x = Fiscal_year, y = Tax_to_GDP)) +
  geom_line() + 
  geom_point() +
  geom_text(aes(label = ifelse(Fiscal_year == 2021, paste0(round(Tax_to_GDP,3) * 100, "%"),'')),
            hjust=0.5, vjust=1.8, show.legend = FALSE) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1L)) +
  theme_classic() +
  ylab("Tax to GDP") +
  xlab("Fiscal year") +
  ggtitle("Gross tax revenue to GDP")
```

<img src="man/figures/README-revenue-1.png" width="100%" />

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
