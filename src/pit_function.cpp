#include <Rcpp.h>
#include "find_interval.h"
#include "tax_function.h"
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
// [[Rcpp::export]]
double pit_function(double income, double age, double mtc, NumericMatrix brackets,  NumericMatrix rebates) {

  // Create cumulative tax and cumulative rebates
  int nrebates = rebates.nrow();

  /* Create a modified rebate table to help with the loop (tax free thresholds, etc) */
  NumericVector x = cumsum(rebates( _, 1));
  NumericMatrix rebates_new(nrebates, 3);
  for (int i = 0; i < nrebates; ++i) {rebates_new(i,0) = rebates(i,0);}
  for (int i = 0; i < nrebates; ++i) {rebates_new(i,1) = rebates(i,1);}
  rebates_new( _,2) = x;

  // Find rebate row associated with age
  int agerow = find_interval(age, rebates_new( _, 0)) - 1;
  // Get rebate based on age row
  double rebate = rebates_new(agerow, 2);

  // Calculate tax liability, including rebate and medical tax credits
  double tax = tax_function(income, brackets) - rebate - mtc;
  if (tax < 0) {
    return 0;
  } else {
    return tax;
  }
}
