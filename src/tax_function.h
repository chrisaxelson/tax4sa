#ifndef TAX_FUNCTION_H
#define TAX_FUNCTION_H

#include <Rcpp.h>
double tax_function(double income, Rcpp::NumericMatrix brackets);
#endif
