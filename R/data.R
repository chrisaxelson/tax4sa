
#' Monthly tax revenue data from the South African Revenue Service
#'
#' A dataset containing tax revenue by tax instrument
#' per month that is collected by the South African Revenue Service (SARS) and
#' published by the National Treasury of South Africa.
#'
#' @format A data frame with 14,764 rows and 5 variables:
#' \describe{
#'   \item{Tax}{Type of tax instrument}
#'   \item{Year}{Calendar year}
#'   \item{Fiscal_year}{Year running from April 1 to March 31}
#'   \item{Month}{}
#'   \item{Revenue}{Tax revenue in R thousands}
#' }
#' @source \url{http://www.treasury.gov.za/comm_media/press/monthly/default.aspx}
"SARS"


#' South African Reserve Bank (SARB) Quarterly Bulletin data
#'
#' A dataset containing time series information published by the SARB in their
#' Quarterly Bulletin.
#'
#' @format A data frame with 599,026 rows and 4 variables:
#' \describe{
#'   \item{Date}{Date in 8 digits, e.g. 19980101}
#'   \item{Frequency}{Time period of data series, e.g. J1, which is Annually - 1 January to 31 December}
#'   \item{Code}{Time series indicator, e.g. KBP6006J, which is Gross Domestic Product at market prices}
#'   \item{Value}{...}
#' }
#' @source \url{https://www.resbank.co.za/Publications/QuarterlyBulletins/Pages/DownloadInformationFromXLSXDataFiles.aspx}
"SARB"


#' Descriptions of South African Reserve Bank (SARB) Quarterly Bulletin variables
#'
#' A dataset containing information on the variables that are published by the SARB in their
#' Quarterly Bulletin.
#'
#' @format A data frame with 4,047 rows and 6 variables:
#' \describe{
#'   \item{Code}{Code for specific time series, e.g. KBP6006J1}
#'   \item{Description}{Description of time series, e.g. Gross domestic product at market prices}
#'   \item{Frequency}{Time period of data series, e.g. J1 }
#'   \item{Frequency_description}{Description of time period, e.g. Annually - 1 January to 31 December}
#'   \item{Unit_of_measure}{Characteristic of the value, e.g. RMILL (R millions)}
#'   \item{Version_Description}{Additional information on value}
#' }
#' @source \url{https://www.resbank.co.za/Publications/QuarterlyBulletins/Pages/ListOfDesciptionsOfAllQuarterlyBulletinTimeSeries.aspx}
"SARB_descriptions"


#' South African tax tables from 2010/11 to 2020/21
#'
#' A list containing the tax brackets and tax rebates to calculate the personal income tax liability in a given year.
#'
#' @format A list with 22 matrices:
#' \describe{
#'   \item{PIT_brackets_year}{The tax brackets and marginal tax rates}
#'   \item{PIT_rebates_year}{The primary, secondary and tertiary rebates}
#' }
"Tax_tables"

