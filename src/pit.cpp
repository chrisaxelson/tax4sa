#include <Rcpp.h>
#include "pit_function.h"
using namespace Rcpp;
//' @title
//' Calculate personal income tax liability in South Africa
//' @description
//' Function to calculate personal income tax liability
//' @param income a numeric vector of incomes
//' @param age a numeric vector of ages, which is the age of each individual at the end of the tax year
//' @param mtc a numeric vector of medical tax credits available in the tax year
//' @param taxyear a numeric vector of the tax year for each record, where the number represents the year in which
//'  the tax year ends. For example, 2021 refers to the 2020/21 tax year.
//' @details
//' \code{pit} takes inputs of income (in Rands), age, medical tax credit and the tax year to
//' calculate the tax liability in South Africa.
//' Available for tax years 2010/11 to 2020/21.
//' @export
//' @useDynLib tax4sa
//' @examples
//' # Calculate personal income tax
//' pit(income = 1000000, age = 53, mtc = 2550, taxyear = 2021)
//'
//' # Same calculation in a relatively large dataframe with differing variables
//' individuals <- 1e6
//' df <- data.frame(Taxable_income = round(runif(individuals, 0, 3000000),0),
//'                  Age = round(runif(individuals, 18, 80),0),
//'                  MTC = round(runif(individuals, 0, 6000), 0),
//'                  Tax_year = round(runif(individuals, 2014, 2020), 0))
//'
//' df$Simulated_tax <- pit(df$Taxable_income, df$Age, df$MTC, df$Tax_year)
//'
//' # Or tidyverse way
//' library(dplyr)
//' df <- df %>%
//'   mutate(Simulated_tax = pit(Taxable_income, Age, MTC, Tax_year))
//'
//' # Check pit_manual function for simulations with custom tax tables
//'
//' @export
// [[Rcpp::export]]
NumericVector pit(NumericVector income, NumericVector age, NumericVector mtc, NumericVector taxyear) {

  // Tax tables

  // 2021
  NumericMatrix table_2021(7,3);
  table_2021( _, 0) = NumericVector::create(0, 205900, 321600, 445100, 584200, 744800, 1577300);
  table_2021( _, 1) = NumericVector::create(0.18, 0.26, 0.31, 0.36, 0.39, 0.41, 0.45);
  NumericMatrix rebate_2021(3,3);
  rebate_2021( _, 0) = NumericVector::create(0, 65, 75);
  rebate_2021( _, 1) = NumericVector::create(14958, 8199, 2736);
  // 2020
  NumericMatrix table_2020(7,3);
  table_2020( _, 0) = NumericVector::create(0, 195850, 305850, 423300, 555600, 708310, 1500000);
  table_2020( _, 1) = NumericVector::create(0.18, 0.26, 0.31, 0.36, 0.39, 0.41, 0.45);
  NumericMatrix rebate_2020(3,3);
  rebate_2020( _, 0) = NumericVector::create(0, 65, 75);
  rebate_2020( _, 1) = NumericVector::create(14220, 7794, 2601);
  // 2019
  NumericMatrix table_2019(7,3);
  table_2019( _, 0) = NumericVector::create(0, 195850, 305850, 423300, 555600, 708310, 1500000);
  table_2019( _, 1) = NumericVector::create(0.18, 0.26, 0.31, 0.36, 0.39, 0.41, 0.45);
  NumericMatrix rebate_2019(3,3);
  rebate_2019( _, 0) = NumericVector::create(0, 65, 75);
  rebate_2019( _, 1) = NumericVector::create(14067, 7713, 2574);
  // 2018
  NumericMatrix table_2018(7,3);
  table_2018( _, 0) = NumericVector::create(0, 189880, 296540, 410460, 555600, 708310, 1500000);
  table_2018( _, 1) = NumericVector::create(0.18, 0.26, 0.31, 0.36, 0.39, 0.41, 0.45);
  NumericMatrix rebate_2018(3,3);
  rebate_2018( _, 0) = NumericVector::create(0, 65, 75);
  rebate_2018( _, 1) = NumericVector::create(13635, 7479, 2493);
  // 2017
  NumericMatrix table_2017(6,3);
  table_2017( _, 0) = NumericVector::create(0, 188000, 293600, 406400, 550100, 701300);
  table_2017( _, 1) = NumericVector::create(0.18, 0.26, 0.31, 0.36, 0.39, 0.41);
  NumericMatrix rebate_2017(3,3);
  rebate_2017( _, 0) = NumericVector::create(0, 65, 75);
  rebate_2017( _, 1) = NumericVector::create(13500, 7407, 2466);
  // 2016
  NumericMatrix table_2016(6,3);
  table_2016( _, 0) = NumericVector::create(0, 181900, 284100, 393200, 550100, 701300);
  table_2016( _, 1) = NumericVector::create(0.18, 0.26, 0.31, 0.36, 0.39, 0.41);
  NumericMatrix rebate_2016(3,3);
  rebate_2016( _, 0) = NumericVector::create(0, 65, 75);
  rebate_2016( _, 1) = NumericVector::create(13257,7407,2466);
  // 2015
  NumericMatrix table_2015(6,3);
  table_2015( _, 0) = NumericVector::create(0,174550,272700,377450,528000,673100);
  table_2015( _, 1) = NumericVector::create(0.18,0.25,0.30,0.35,0.38,0.4);
  NumericMatrix rebate_2015(3,3);
  rebate_2015( _, 0) = NumericVector::create(0, 65, 75);
  rebate_2015( _, 1) = NumericVector::create(12726,7100,2367);
  // 2014
  NumericMatrix table_2014(6,3);
  table_2014( _, 0) = NumericVector::create(0,165600,258750,358110,500940,638600);
  table_2014( _, 1) = NumericVector::create(0.18,0.25,0.30,0.35,0.38,0.4);
  NumericMatrix rebate_2014(3,3);
  rebate_2014( _, 0) = NumericVector::create(0, 65, 75);
  rebate_2014( _, 1) = NumericVector::create(12080,6750,2250);
  // 2013
  NumericMatrix table_2013(6,3);
  table_2013( _, 0) = NumericVector::create(0,160000,250000,346000,484000,617000);
  table_2013( _, 1) = NumericVector::create(0.18,0.25,0.30,0.35,0.38,0.4);
  NumericMatrix rebate_2013(3,3);
  rebate_2013( _, 0) = NumericVector::create(0, 65, 75);
  rebate_2013( _, 1) = NumericVector::create(11440,6390,2130);
  // 2012
  NumericMatrix table_2012(6,3);
  table_2012( _, 0) = NumericVector::create(0,150000,235000,325000,455000,580000);
  table_2012( _, 1) = NumericVector::create(0.18,0.25,0.30,0.35,0.38,0.4);
  NumericMatrix rebate_2012(3,3);
  rebate_2012( _, 0) = NumericVector::create(0, 65, 75);
  rebate_2012( _, 1) = NumericVector::create(10755,6012,2000);
  // 2011
  NumericMatrix table_2011(6,3);
  table_2011( _, 0) = NumericVector::create(0,140000,221000,305000,431000,552000);
  table_2011( _, 1) = NumericVector::create(0.18,0.25,0.30,0.35,0.38,0.4);
  NumericMatrix rebate_2011(3,3);
  rebate_2011( _, 0) = NumericVector::create(0, 65, 75);
  rebate_2011( _, 1) = NumericVector::create(10260, 5675, 0);

  // Initialise matrices and output vector
  NumericMatrix brackets(Rcpp::clone(table_2021));
  NumericMatrix rebates(Rcpp::clone(rebate_2021));
  int n = income.size();
  NumericVector out(n);

  // Loop through tax calculations
  for(int i=0; i<n; i++) {

    if (taxyear[i] == 2021) {
      brackets = table_2021;
      rebates = rebate_2021;
    } else if (taxyear[i] == 2020) {
      brackets = table_2020;
      rebates = rebate_2020;
    } else if (taxyear[i] == 2019) {
      brackets = table_2019;
      rebates = rebate_2019;
    } else if (taxyear[i] == 2018) {
      brackets = table_2018;
      rebates = rebate_2018;
    } else if (taxyear[i] == 2017) {
      brackets = table_2017;
      rebates = rebate_2017;
    } else if (taxyear[i] == 2016) {
      brackets = table_2016;
      rebates = rebate_2016;
    } else if (taxyear[i] == 2015) {
      brackets = table_2015;
      rebates = rebate_2015;
    } else if (taxyear[i] == 2014) {
      brackets = table_2014;
      rebates = rebate_2014;
    } else if (taxyear[i] == 2013) {
      brackets = table_2013;
      rebates = rebate_2013;
    } else if (taxyear[i] == 2012) {
      brackets = table_2012;
      rebates = rebate_2012;
    } else if (taxyear[i] == 2011) {
      brackets = table_2011;
      rebates = rebate_2011;
    }
    out[i] = pit_function(income[i], age[i], mtc[i], brackets, rebates);
  }
  return out;
}
