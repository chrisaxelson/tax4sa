
#' @title
#' Calculate personal income tax liability in South Africa
#' @description
#' Function to calculate personal income tax liability
#' @param income a numeric vector of incomes
#' @param age a numeric vector of ages, which is the age of each individual at the end of the tax year
#' @param mtc a numeric vector of medical tax credits available in the tax year
#' @param tax_year a numeric vector of the tax year for each record, where the number represents the year in which
#'  the tax year ends. For example, 2021 refers to the 2020/21 tax year.
#' @details
#' \code{pit} takes inputs of income (in Rands), age, medical tax credit and the tax year to
#' calculate the tax liability in South Africa.
#' Available for tax years 2010/11 to 2020/21.
#' @export
#' @examples
#' # Calculate personal income tax
#' pit(income = 1000000, age = 53, mtc = 2550, tax_year = 2021)
#'
#' # Same calculation in a relatively large dataframe with differing variables
#' individuals <- 1e6
#' df <- data.frame(Taxable_income = round(runif(individuals, 0, 3000000),0),
#'                  Age = round(runif(individuals, 18, 80),0),
#'                  MTC = round(runif(individuals, 0, 6000), 0),
#'                  Tax_year = round(runif(individuals, 2014, 2020), 0))
#'
#' df$Simulated_tax <- pit(df$Taxable_income, df$Age, df$MTC, df$Tax_year)
#'
#' # Or tidyverse way
#' library(dplyr)
#' df <- df %>%
#'   mutate(Simulated_tax = pit(Taxable_income, Age, MTC, Tax_year))
#'
#' # Check pit_manual function for simulations with custom tax tables

pit <- function(income, age, mtc, tax_year) {

  # Negative values don't pay tax
  income <- pmax(income, 0)

  # Get unique years
  Years_in_data <- unique(tax_year)

  # Don't create output vector if only one year (slightly faster)
  if (length(Years_in_data) == 1) {

    # Get tax tables for that year - use data from package
    Brackets <- PIT_brackets[PIT_brackets$Tax_year == Years_in_data, c("Bracket", "Tax_rate")]
    Rebates <- PIT_rebates[PIT_rebates$Tax_year == Years_in_data, c("Age", "Rebate")]

    # Easier to create lagged columns for the cumulative calculation
    Brackets$Lagged_bracket <- c(NA, head(Brackets$Bracket, -1))
    Brackets$Lagged_rate <- c(NA, head(Brackets$Tax_rate, -1))
    # Calculate cumulative tax
    Brackets$Cumulative_tax <- ifelse(Brackets$Bracket == 0, 0,
                                      round((Brackets$Bracket - Brackets$Lagged_bracket) *
                                              Brackets$Lagged_rate, 0))
    Brackets$Cumulative_tax <- cumsum(Brackets$Cumulative_tax)

    Rebates$Cumulative_rebate <- cumsum(Rebates$Rebate)

    # Find rebate for each entry
    Rebate_i <- findInterval(age, Rebates[, "Age"])
    Rebate <- Rebates[Rebate_i, "Cumulative_rebate"]

    # Find bracket for each entry
    Bracket_i <- findInterval(income, Brackets[, "Bracket"])

    # And do the tax calculation
    Simulated_tax <- Brackets[Bracket_i, "Cumulative_tax"] +
      (income -  Brackets[Bracket_i, "Bracket"]) *
      Brackets[Bracket_i, "Tax_rate"] - Rebate - mtc

    Simulated_tax[Simulated_tax < 0] <- 0

    return(Simulated_tax)

  } else {

    # If there are multiple years, assign an output vector to fill for each year
    out <- rep(NA, length(income))

    # Go through each year to calculate tax liability
    for (i in Years_in_data) {

      # Get the position of each record for the year we are calculating
      out_index <- tax_year == i

      # Get tax tables for that year - use data from package
      Brackets <- PIT_brackets[PIT_brackets$Tax_year == i, c("Bracket", "Tax_rate")]
      Rebates <- PIT_rebates[PIT_rebates$Tax_year == i, c("Age", "Rebate")]

      # Easier to create lagged columns for the cumulative calculation
      Brackets$Lagged_bracket <- c(NA, head(Brackets$Bracket, -1))
      Brackets$Lagged_rate <- c(NA, head(Brackets$Tax_rate, -1))
      # Calculate cumulative tax
      Brackets$Cumulative_tax <- ifelse(Brackets$Bracket == 0, 0,
                                        round((Brackets$Bracket - Brackets$Lagged_bracket) *
                                                Brackets$Lagged_rate, 0))
      Brackets$Cumulative_tax <- cumsum(Brackets$Cumulative_tax)

      Rebates$Cumulative_rebate <- cumsum(Rebates$Rebate)

      # Find rebate for each record
      Rebate_i <- findInterval(age[out_index], Rebates[, "Age"])
      Rebate <- Rebates[Rebate_i, "Cumulative_rebate"]

      # Find bracket for each record
      Bracket_i <- findInterval(income[out_index], Brackets[, "Bracket"])

      # And do the tax calculation
      Simulated_tax <- Brackets[Bracket_i, "Cumulative_tax"] +
        (income[out_index] -  Brackets[Bracket_i, "Bracket"]) *
        Brackets[Bracket_i, "Tax_rate"] - Rebate - mtc[out_index]

      # Put the result back into the original vector at each position
      out[out_index] <- Simulated_tax
    }

    # Make sure there are no negative entries (no tax credits)
    out[out < 0] <- 0

    return(out)
  }
}
