#include <Rcpp.h>
using namespace Rcpp;
//' Find the interval of a number in a sequence
//'
//' @param x A numeric value.
//' @param breaks A vector of numbers
// [[Rcpp::export]]
int find_interval(double x, NumericVector breaks) {
  NumericVector::iterator upper1;
  upper1 = std::upper_bound(breaks.begin(), breaks.end(), x);
  return std::distance(breaks.begin(), upper1);
}
