#ifndef PIT_FUNCTION_H
#define PIT_FUNCTION_H

#include <Rcpp.h>
double pit_function(double income, double age, double mtc, Rcpp::NumericMatrix brackets, Rcpp::NumericMatrix rebates);
#endif
