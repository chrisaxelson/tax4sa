#include <Rcpp.h>
#include "find_interval.h"
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
// [[Rcpp::export]]
double tax_function(double income, NumericMatrix brackets) {

  // Create cumulative tax and cumulative rebates
  int nbrackets = brackets.nrow();

  NumericMatrix brackets_new(nbrackets, 3);
  for (int i = 0; i < nbrackets; ++i) {brackets_new(i,0) = brackets(i,0);}
  for (int i = 0; i < nbrackets; ++i) {brackets_new(i,1) = brackets(i,1);}
  brackets_new(0,2) = 0;
  brackets_new(1,2) = brackets_new(1,0) * brackets_new(0,1);
  for (int i = 2; i < nbrackets; ++i) {brackets_new(i,2) = brackets_new(i-1,2) + brackets_new(i-1,1) * (brackets_new(i,0)-brackets_new(i-1,0));}

  // Find bracket row related to that income
  int bracketrow = find_interval(income, brackets_new( _, 0)) - 1;

  // Calculate tax liability, including rebate and medical tax credits
  double tax = brackets_new(bracketrow, 2) + (income - brackets_new(bracketrow, 0)) * brackets_new(bracketrow, 1);
  if (tax < 0) {
    return 0;
  } else {
    return tax;
  }
}
