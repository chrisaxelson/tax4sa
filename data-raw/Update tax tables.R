
# PIT_tables ------------------------------------------------------------

# Add data to the package to be available
Tax_tables <- list(PIT_brackets_2011 = matrix(c(0,140000,221000,305000,431000,552000,
                                            0.18,0.25,0.30,0.35,0.38,0.4), ncol =2),
                   PIT_rebates_2011 = matrix(c(0,65,75,
                                           10260,5675,0), ncol = 2),
                   PIT_brackets_2012 = matrix(c(0,150000,235000,325000,455000,580000,
                                            0.18,0.25,0.30,0.35,0.38,0.4), ncol =2),
                   PIT_rebates_2012 = matrix(c(0,65,75,
                                           10755,6012,2000), ncol = 2),
                   PIT_brackets_2013 = matrix(c(0,160000,250000,346000,484000,617000,
                                            0.18,0.25,0.30,0.35,0.38,0.4), ncol =2),
                   PIT_rebates_2013 = matrix(c(0,65,75,
                                           11440,6390,2130), ncol = 2),
                   PIT_brackets_2014 = matrix(c(0,165600,258750,358110,500940,638600,
                                            0.18,0.25,0.30,0.35,0.38,0.4), ncol =2),
                   PIT_rebates_2014 = matrix(c(0,65,75,
                                           12080,6750,2250), ncol = 2),
                   PIT_brackets_2015 = matrix(c(0,174550,272700,377450,528000,673100,
                                            0.18,0.25,0.30,0.35,0.38,0.4), ncol =2),
                   PIT_rebates_2015 = matrix(c(0,65,75,
                                           12726,7100,2367), ncol = 2),
                   PIT_brackets_2016 = matrix(c(0,181900,284100,393200,550100,701300,
                                            0.18,0.26,0.31,0.36,0.39,0.41), ncol =2),
                   PIT_rebates_2016 = matrix(c(0,65,75,
                                           13257,7407,2466), ncol = 2),
                   PIT_brackets_2017 = matrix(c(0,188000,293600,406400,550100,701300,
                                            0.18,0.26,0.31,0.36,0.39,0.41), ncol =2),
                   PIT_rebates_2017 =  matrix(c(0,65,75,
                                            13500,7407,2466), ncol = 2),
                   PIT_brackets_2018 = matrix(c(0,189880, 296540, 410460, 555600, 708310, 1500000,
                                            0.18, 0.26, 0.31, 0.36, 0.39, 0.41, 0.45), ncol =2),
                   PIT_rebates_2018 = matrix(c(0,65,75,
                                           13635,7479,2493), ncol = 2),
                   PIT_brackets_2019 = matrix(c(0,195850, 305850, 423300, 555600, 708310, 1500000,
                                            0.18, 0.26, 0.31, 0.36, 0.39, 0.41, 0.45), ncol =2),
                   PIT_rebates_2019 = matrix(c(0,65,75,
                                           14067,7713,2574), ncol = 2),
                   PIT_brackets_2020 = matrix(c(0,195850, 305850, 423300, 555600, 708310, 1500000,
                                            0.18, 0.26, 0.31, 0.36, 0.39, 0.41, 0.45), ncol =2),
                   PIT_rebates_2020 = matrix(c(0,65,75,
                                           14220,7794,2601), ncol = 2),
                   PIT_brackets_2021 = matrix(c(0,205900, 321600, 445100, 584200, 744800, 1577300,
                                            0.18, 0.26, 0.31, 0.36, 0.39, 0.41, 0.45), ncol =2),
                   PIT_rebates_2021 = matrix(c(0,65,75,
                                           14958, 8199, 2736), ncol = 2))

save(Tax_tables, file = "data-raw/SARS/Tax_tables.rda")

usethis::use_data(Tax_tables, overwrite = TRUE)

# Changing the data into a dataframe to make it easier to work with
# library(tidyverse)
#
# PIT_brackets <- data.frame(rbind(cbind(2011, PIT_tables$PIT_brackets_2011),
#                                  cbind(2012, PIT_tables$PIT_brackets_2012),
#                                  cbind(2013, PIT_tables$PIT_brackets_2013),
#                                  cbind(2014, PIT_tables$PIT_brackets_2014),
#                                  cbind(2015, PIT_tables$PIT_brackets_2015),
#                                  cbind(2016, PIT_tables$PIT_brackets_2016),
#                                  cbind(2017, PIT_tables$PIT_brackets_2017),
#                                  cbind(2018, PIT_tables$PIT_brackets_2018),
#                                  cbind(2019, PIT_tables$PIT_brackets_2019),
#                                  cbind(2020, PIT_tables$PIT_brackets_2020),
#                                  cbind(2021, PIT_tables$PIT_brackets_2021)))
#
# PIT_brackets <- PIT_brackets %>%
#   rename(Tax_year = X1, Bracket = X2, Tax_rate = X3)
#
# # Create cumulative tax paid column
# PIT_brackets <- PIT_brackets %>%
#   group_by(Tax_year) %>%
#   mutate(Cumulative_tax = if_else(Bracket == 0, 0, round((Bracket - lag(Bracket)) * lag(Tax_rate), 0)),
#          Cumulative_tax = cumsum(Cumulative_tax))
#
# PIT_brackets <- as.data.frame(PIT_brackets)
#
# PIT_rebates <- data.frame(rbind(cbind(2011, PIT_tables$PIT_rebates_2011),
#                                 cbind(2012, PIT_tables$PIT_rebates_2012),
#                                 cbind(2013, PIT_tables$PIT_rebates_2013),
#                                 cbind(2014, PIT_tables$PIT_rebates_2014),
#                                 cbind(2015, PIT_tables$PIT_rebates_2015),
#                                 cbind(2016, PIT_tables$PIT_rebates_2016),
#                                 cbind(2017, PIT_tables$PIT_rebates_2017),
#                                 cbind(2018, PIT_tables$PIT_rebates_2018),
#                                 cbind(2019, PIT_tables$PIT_rebates_2019),
#                                 cbind(2020, PIT_tables$PIT_rebates_2020),
#                                 cbind(2021, PIT_tables$PIT_rebates_2021)))
#
# PIT_rebates <- PIT_rebates %>%
#   rename(Tax_year = X1, Age = X2, Rebate = X3)
#
# # Cumulative rebate
# PIT_rebates <- PIT_rebates %>%
#   group_by(Tax_year) %>%
#   mutate(Cumulative_rebate = cumsum(Rebate),
#          Tax_free_threshold = round(Cumulative_rebate / 0.18,0))
#
# PIT_rebates <- as.data.frame(PIT_rebates)
#
#
# save(PIT_brackets, file = "data-raw/SARS/PIT_brackets.rda")
# save(PIT_rebates, file = "data-raw/SARS/PIT_rebates.rda")
#
# usethis::use_data(PIT_brackets, overwrite = TRUE)
# usethis::use_data(PIT_rebates, overwrite = TRUE)
