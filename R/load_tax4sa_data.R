
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

  data("STATSSA_P0141_CPI_urban")
  data("STATSSA_P0141_CPI_province")
  data("STATSSA_P0141_CPI_digit")
  data("STATSSA_P0141_CPI_COICOP")
  data("STATSSA_P6410_tourists")
  data("STATSSA_P5041.1_building")
  data("STATSSA_P0151.1_construction")
  data("STATSSA_P4141_electricity")
  data("STATSSA_P0142.7_trade")
  data("STATSSA_P6420_food")

  invisible(force(SARS_annual))
  invisible(force(SARS_monthly))
  invisible(force(SARB_descriptions))
  invisible(force(SARB))
  invisible(force(STATSSA_descriptions))
  invisible(force(STATSSA))
  invisible(force(DMRE_fuel))

  invisible(force(STATSSA_P0141_CPI_urban))
  invisible(force(STATSSA_P0141_CPI_province))
  invisible(force(STATSSA_P0141_CPI_digit))
  invisible(force(STATSSA_P0141_CPI_COICOP))
  invisible(force(STATSSA_P6410_tourists))
  invisible(force(STATSSA_P5041.1_building))
  invisible(force(STATSSA_P0151.1_construction))
  invisible(force(STATSSA_P4141_electricity))
  invisible(force(STATSSA_P0142.7_trade))
  invisible(force(STATSSA_P6420_food))

}
