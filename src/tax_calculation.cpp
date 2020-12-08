#include <Rcpp.h>
#include "find_interval.h"
#include "tax_function.h"
using namespace Rcpp;
//' @title
//' Calculate tax liability based on a tax table
//' @description
//' Function to calculate tax liability using custom tax tables
//' @param income any amount to apply to a tax table
//' @param table a matrix representing any tax table
//' @details
//' \code{pit_manual} takes a vector of income and age and a matrix representation of the income tax brackets and
//' the rebate available per age to calculate the tax liability.
//' Allowing for custom tax tables make it easier to model policy changes.
//' Since it is implemented in C++ it should be relatively quick and well-suited to large datasets.
//' @export
// [[Rcpp::export]]
NumericVector tax_calculation(NumericVector income, NumericMatrix brackets) {

  // Initialise output
  int n = income.size();
  NumericVector out(n);

  // Loop through tax calculations
  for(int i=0; i<n; i++) {
    out[i] = tax_function(income[i], brackets);
  }

  return out;
}
