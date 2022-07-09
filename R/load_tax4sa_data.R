
#' @title
#' Loading data
#' @description
#' Loading data
#' @details
#' Convenience function to get data into environment
#' @export

load_tax4sa_data <- function() {
  data("SARS_annual")
  data("SARS_monthly")
  data("SARB_descriptions")
  data("SARB")
  data("STATSSA_descriptions")
  data("STATSSA")
  data("DMRE_fuel")

  invisible(force(SARS_annual))
  invisible(force(SARS_monthly))
  invisible(force(SARB_descriptions))
  invisible(force(SARB))
  invisible(force(STATSSA_descriptions))
  invisible(force(STATSSA))
  invisible(force(DMRE_fuel))
}
