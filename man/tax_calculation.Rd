% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RcppExports.R
\name{tax_calculation}
\alias{tax_calculation}
\title{Calculate tax liability based on a tax table}
\usage{
tax_calculation(income, brackets)
}
\arguments{
\item{income}{any amount to apply to a tax table}

\item{table}{a matrix representing any tax table}
}
\description{
Function to calculate tax liability using custom tax tables
}
\details{
\code{pit_manual} takes a vector of income and age and a matrix representation of the income tax brackets and
the rebate available per age to calculate the tax liability.
Allowing for custom tax tables make it easier to model policy changes.
Since it is implemented in C++ it should be relatively quick and well-suited to large datasets.
}
