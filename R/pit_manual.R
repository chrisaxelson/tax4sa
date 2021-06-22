#' @title
#' Calculate personal income tax liability based on a tax table, rebate table and medical tax credits
#' @description
#' Function to calculate tax liability using custom tax tables
#' @param income taxable income for the tax year
#' @param age age of each individual at the end of the tax year
#' @param mtc medical tax credits available in the tax year
#' @param tax_table a matrix representing any tax table, specifically the marginal tax rates and brackets
#' @param rebate_table a matrix representing the rebates available for each age group
#' @details
#' \code{pit_manual} takes a vector of income and age and a matrix representation of the income tax brackets and
#' the rebate available per age to calculate the tax liability.
#' Allowing for custom tax tables make it easier to model policy changes.
#' Since it is implemented in C++ it should be relatively quick and well-suited to large datasets.
#' @export
#' @examples
#' # Calculate personal income tax using custom tax tables
#' pit_manual(income = 1000000, age = 53, mtc = 2550,
#'            tax-table = Tax_tables$PIT_brackets_2021, rebate_table = Tax_tables$PIT_rebates_2021)

pit_manual <- function(income, age, mtc, tax_table, rebate_table) {

  # Adjust tax and rebate tables for cumulative amounts
  Brackets <- as.data.frame(tax_table)
  colnames(Brackets) <- c("Bracket", "Tax_rate")
  # Easier to create lagged columns for the calculation
  Brackets$Lagged_bracket <- c(NA, head(Brackets$Bracket, -1))
  Brackets$Lagged_rate <- c(NA, head(Brackets$Tax_rate, -1))
  # Calculate cumulative tax
  Brackets$Cumulative_tax <- ifelse(Brackets$Bracket == 0, 0,
                                    round((Brackets$Bracket - Brackets$Lagged_bracket) *
                                            Brackets$Lagged_rate, 0))
  Brackets$Cumulative_tax <- cumsum(Brackets$Cumulative_tax)

  # Also do cumulative amount for rebates
  Rebates <- as.data.frame(rebate_table)
  colnames(Rebates) <- c("Age", "Rebate")
  Rebates$Cumulative_rebate <- cumsum(Rebates$Rebate)

  # Now get the rebates and bracket per person
  Rebate_i <- findInterval(age, Rebates[, "Age"])
  Rebate <- Rebates[Rebate_i, "Cumulative_rebate"]
  Bracket_i <- findInterval(income, Brackets[, "Bracket"])

  # And do the tax calculation
  Simulated_tax <- Brackets[Bracket_i, "Cumulative_tax"] +
    (income -  Brackets[Bracket_i, "Bracket"]) *
    Brackets[Bracket_i, "Tax_rate"] - Rebate - mtc

  Simulated_tax[Simulated_tax < 0] <- 0

  Simulated_tax
}
