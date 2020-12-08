#include <Rcpp.h>
#include "pit_function.h"
using namespace Rcpp;
//' @title
//' Calculate personal income tax liability based on a tax table, rebate table and medical tax credits
//' @description
//' Function to calculate tax liability using custom tax tables
//' @param income taxable income for the tax year
//' @param age age of each individual at the end of the tax year
//' @param mtc medical tax credits available in the tax year
//' @param table a matrix representing any tax table, specifically the marginal tax rates and brackets
//' @param rebate a matrix representing the rebates available for each age group
//' @details
//' \code{pit_manual} takes a vector of income and age and a matrix representation of the income tax brackets and
//' the rebate available per age to calculate the tax liability.
//' Allowing for custom tax tables make it easier to model policy changes.
//' Since it is implemented in C++ it should be relatively quick and well-suited to large datasets.
//' @export
//' @examples
//' # Calculate personal income tax using custom tax tables
//' pit_manual(income = 1000000, age = 53, mtc = 2550,
//'            brackets = Tax_tables$PIT_brackets_2021, rebates = Tax_tables$PIT_rebates_2021)
// [[Rcpp::export]]
NumericVector pit_manual(NumericVector income, NumericVector age, NumericVector mtc, NumericMatrix brackets, NumericMatrix rebates) {

  // Initialise output
  int n = income.size();
  NumericVector out(n);

  // Loop through tax calculations
  for(int i=0; i<n; i++) {
    out[i] = pit_function(income[i], age[i], mtc[i], brackets, rebates);
  }

  return out;

}
