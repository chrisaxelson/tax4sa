
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tax4sa

<!-- badges: start -->

<!-- badges: end -->

This is a minimal package to help with the compilation and analysis of
tax and economic data in South Africa. The package only contains four
main sets of data, three functions and the personal income tax tables
from 1995/96 to 2021/22.

The data includes:

  - Annual tax revenue collections from 1983/84, as published in the
    [Budget Reviews of the National
    Treasury](http://www.treasury.gov.za/documents/national%20budget/default.aspx)
  - Monthly tax revenue collections from April 2002, as published in the
    [monthly financing statements of the National
    Treasury](http://www.treasury.gov.za/comm_media/press/monthly/default.aspx)
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

## Example

The data can be accessed by directly entering either `SARS_annual`,
`SARS_monthly`, `STATSSA` or `SARB` and is in a tidy format to ease
analysis within R. The revenue data is split by three revenue
classifications in columns `T1`, `T2` and `T3` and all figures are in
ZAR 000’s. The dataframes `SARB_descriptions` and `STATSSA_descriptions`
are also available to help with the details of each variable in those
two sets of data.

``` r
library(tax4sa)
library(dplyr)
library(knitr)
#> Warning: package 'knitr' was built under R version 4.0.3
library(kableExtra)

# Check revenue data
SARS_annual %>% 
  filter(Fiscal_year == 2021) %>%  
  select(T1:T3, Year, Revenue) %>% 
  mutate(Revenue = round(Revenue,0)) %>% 
  head() %>% 
  kable(format.args = list(big.mark = ","), 
        caption = "SARS_annual (R'000s)")
```

<table>

<caption>

SARS\_annual (R’000s)

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

<tr>

<td style="text-align:left;">

Taxes on income and profits

</td>

<td style="text-align:left;">

Other

</td>

<td style="text-align:left;">

Small business tax amnesty

</td>

<td style="text-align:left;">

2020/21

</td>

<td style="text-align:right;">

72

</td>

</tr>

</tbody>

</table>

``` r

# And monthly
SARS_monthly %>% 
  filter(T3 == "Health promotion levy") %>% 
  select(Tax = T3, Month, Year, Revenue) %>% 
  mutate(Year = as.character(Year)) %>% 
  tail(5) %>% 
  kable(format.args = list(big.mark = ","),
        caption = "Health promotion levy in SARS_monthly (R'000s)") 
```

<table>

<caption>

Health promotion levy in SARS\_monthly (R’000s)

</caption>

<thead>

<tr>

<th style="text-align:left;">

Tax

</th>

<th style="text-align:left;">

Month

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

Health promotion levy

</td>

<td style="text-align:left;">

February

</td>

<td style="text-align:left;">

2021

</td>

<td style="text-align:right;">

188,848

</td>

</tr>

<tr>

<td style="text-align:left;">

Health promotion levy

</td>

<td style="text-align:left;">

March

</td>

<td style="text-align:left;">

2021

</td>

<td style="text-align:right;">

182,444

</td>

</tr>

<tr>

<td style="text-align:left;">

Health promotion levy

</td>

<td style="text-align:left;">

April

</td>

<td style="text-align:left;">

2021

</td>

<td style="text-align:right;">

217,617

</td>

</tr>

<tr>

<td style="text-align:left;">

Health promotion levy

</td>

<td style="text-align:left;">

May

</td>

<td style="text-align:left;">

2021

</td>

<td style="text-align:right;">

184,318

</td>

</tr>

<tr>

<td style="text-align:left;">

Health promotion levy

</td>

<td style="text-align:left;">

June

</td>

<td style="text-align:left;">

2021

</td>

<td style="text-align:right;">

152,891

</td>

</tr>

</tbody>

</table>

``` r

# Or you can download the annual and monthly data in one spreadsheet
# This saves it in your current working directory
# download.file("https://raw.githubusercontent.com/chrisaxelson/tax4sa/master/data-raw/SARS/Revenue.xlsx",
#               "Revenue.xlsx")

# Look for SARB economic data on GDP
SARB_descriptions %>% 
  filter(grepl("Gross domestic product at market prices", Description), Frequency == "K1") %>%
  kable()
```

<table>

<thead>

<tr>

<th style="text-align:left;">

Code

</th>

<th style="text-align:left;">

Description

</th>

<th style="text-align:left;">

Frequency

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

Gross domestic product at market prices

</td>

<td style="text-align:left;">

K1

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

Gross domestic product at market prices

</td>

<td style="text-align:left;">

K1

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

Gross domestic product at market prices

</td>

<td style="text-align:left;">

K1

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

Gross domestic product at market prices

</td>

<td style="text-align:left;">

K1

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

Gross domestic product at market prices

</td>

<td style="text-align:left;">

K1

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

Value

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

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

KBP6006K

</td>

<td style="text-align:right;">

20200100

</td>

<td style="text-align:left;">

K1

</td>

<td style="text-align:right;">

1281361

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

2020

</td>

<td style="text-align:right;">

2020

</td>

</tr>

<tr>

<td style="text-align:left;">

KBP6006K

</td>

<td style="text-align:right;">

20200200

</td>

<td style="text-align:left;">

K1

</td>

<td style="text-align:right;">

1073725

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

2020

</td>

<td style="text-align:right;">

2021

</td>

</tr>

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

1266238

</td>

<td style="text-align:left;">

NA

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

1351651

</td>

<td style="text-align:left;">

NA

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

1304065

</td>

<td style="text-align:left;">

NA

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

</tr>

</tbody>

</table>

``` r

# Look for STATSSA inflation data
STATSSA_descriptions %>% 
  filter(grepl("Consumer Price Index", H02), H04 == "All Items") %>%
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

CPA00000

</td>

<td style="text-align:left;">

All Items

</td>

<td style="text-align:left;">

Western Cape

</td>

</tr>

<tr>

<td style="text-align:left;">

P0141

</td>

<td style="text-align:left;">

Consumer Price Index

</td>

<td style="text-align:left;">

CPB00000

</td>

<td style="text-align:left;">

All Items

</td>

<td style="text-align:left;">

Eastern Cape

</td>

</tr>

<tr>

<td style="text-align:left;">

P0141

</td>

<td style="text-align:left;">

Consumer Price Index

</td>

<td style="text-align:left;">

CPC00000

</td>

<td style="text-align:left;">

All Items

</td>

<td style="text-align:left;">

Northern Cape

</td>

</tr>

<tr>

<td style="text-align:left;">

P0141

</td>

<td style="text-align:left;">

Consumer Price Index

</td>

<td style="text-align:left;">

CPD00000

</td>

<td style="text-align:left;">

All Items

</td>

<td style="text-align:left;">

Free State

</td>

</tr>

<tr>

<td style="text-align:left;">

P0141

</td>

<td style="text-align:left;">

Consumer Price Index

</td>

<td style="text-align:left;">

CPE00000

</td>

<td style="text-align:left;">

All Items

</td>

<td style="text-align:left;">

Kwazulu-Natal

</td>

</tr>

<tr>

<td style="text-align:left;">

P0141

</td>

<td style="text-align:left;">

Consumer Price Index

</td>

<td style="text-align:left;">

CPF00000

</td>

<td style="text-align:left;">

All Items

</td>

<td style="text-align:left;">

North-West

</td>

</tr>

<tr>

<td style="text-align:left;">

P0141

</td>

<td style="text-align:left;">

Consumer Price Index

</td>

<td style="text-align:left;">

CPG00000

</td>

<td style="text-align:left;">

All Items

</td>

<td style="text-align:left;">

Gauteng

</td>

</tr>

<tr>

<td style="text-align:left;">

P0141

</td>

<td style="text-align:left;">

Consumer Price Index

</td>

<td style="text-align:left;">

CPH00000

</td>

<td style="text-align:left;">

All Items

</td>

<td style="text-align:left;">

Mpumalanga

</td>

</tr>

<tr>

<td style="text-align:left;">

P0141

</td>

<td style="text-align:left;">

Consumer Price Index

</td>

<td style="text-align:left;">

CPJ00000

</td>

<td style="text-align:left;">

All Items

</td>

<td style="text-align:left;">

Limpopo

</td>

</tr>

<tr>

<td style="text-align:left;">

P0141

</td>

<td style="text-align:left;">

Consumer Price Index

</td>

<td style="text-align:left;">

CPR00000

</td>

<td style="text-align:left;">

All Items

</td>

<td style="text-align:left;">

Rural Areas

</td>

</tr>

<tr>

<td style="text-align:left;">

P0141

</td>

<td style="text-align:left;">

Consumer Price Index

</td>

<td style="text-align:left;">

CPT00000

</td>

<td style="text-align:left;">

All Items

</td>

<td style="text-align:left;">

Total country

</td>

</tr>

</tbody>

</table>

``` r

STATSSA %>% 
  filter(Code == "CPT00000") %>% 
  tail(5) %>% 
  kable()
```

<table>

<thead>

<tr>

<th style="text-align:left;">

</th>

<th style="text-align:left;">

Publication

</th>

<th style="text-align:left;">

Code

</th>

<th style="text-align:left;">

Date

</th>

<th style="text-align:left;">

Value

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

156

</td>

<td style="text-align:left;">

P0141

</td>

<td style="text-align:left;">

CPT00000

</td>

<td style="text-align:left;">

2020 12

</td>

<td style="text-align:left;">

117

</td>

</tr>

<tr>

<td style="text-align:left;">

157

</td>

<td style="text-align:left;">

P0141

</td>

<td style="text-align:left;">

CPT00000

</td>

<td style="text-align:left;">

2021 01

</td>

<td style="text-align:left;">

117.4

</td>

</tr>

<tr>

<td style="text-align:left;">

158

</td>

<td style="text-align:left;">

P0141

</td>

<td style="text-align:left;">

CPT00000

</td>

<td style="text-align:left;">

2021 02

</td>

<td style="text-align:left;">

118.2

</td>

</tr>

<tr>

<td style="text-align:left;">

159

</td>

<td style="text-align:left;">

P0141

</td>

<td style="text-align:left;">

CPT00000

</td>

<td style="text-align:left;">

2021 03

</td>

<td style="text-align:left;">

119

</td>

</tr>

<tr>

<td style="text-align:left;">

160

</td>

<td style="text-align:left;">

P0141

</td>

<td style="text-align:left;">

CPT00000

</td>

<td style="text-align:left;">

2021 04

</td>

<td style="text-align:left;">

119.8

</td>

</tr>

</tbody>

</table>

The data is probably most useful when combined, such as in the chart
below.

``` r
library(dplyr)
library(ggplot2)
library(scales)

# Create a tax to GDP chart - revenue per year first
Total_revenue <- SARS_annual %>% 
  group_by(Fiscal_year) %>% 
  summarise(Revenue = sum(Revenue))

# Get Nominal GDP across fiscal year by summing per quarter
GDP_fiscal <- SARB %>% 
  filter(Code == "KBP6006K") %>% 
  group_by(Fiscal_year) %>% 
  summarise(GDP = sum(Value)) %>% 
  filter(Fiscal_year < 2022)

# Join together and create tax to GDP
Tax_to_GDP <- GDP_fiscal %>% 
  inner_join(Total_revenue, by = "Fiscal_year") %>% 
  mutate(Revenue = Revenue / 1000,
         Tax_to_GDP = Revenue / GDP)

# Chart
ggplot(Tax_to_GDP, aes(x = Fiscal_year, y = Tax_to_GDP)) +
  geom_line(color = "darkblue") + 
  geom_point(color = "darkblue") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1L)) +
  theme_minimal() +
  theme(axis.title.x = element_blank()) +
  ylab("Tax to GDP") +
  ggtitle("Total tax revenue to GDP")
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
#>    0.41    0.03    0.43
```
