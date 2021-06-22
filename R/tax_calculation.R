#' @title
#' Calculate tax liability based on a tax table
#' @description
#' Function to calculate tax liability using custom tax tables
#' @param income any amount to apply to a tax table
#' @param tax_table a matrix representing any tax table
#' @details
#' \code{tax_calculation} takes a vector of income and a matrix representation of the income tax brackets to calculate the tax liability.
#' Allowing for custom tax tables make it easier to model policy changes.
#' @export

tax_calculation <- function(income, tax_table) {

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

  Bracket_i <- findInterval(income, Brackets[, "Bracket"])

  # And do the tax calculation
  Simulated_tax <- Brackets[Bracket_i, "Cumulative_tax"] +
    (income -  Brackets[Bracket_i, "Bracket"]) *
    Brackets[Bracket_i, "Tax_rate"]

  Simulated_tax
}
