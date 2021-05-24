
# PIT_tables ------------------------------------------------------------

# Add data to the package to be available
Tax_tables <- list(PIT_brackets_2000 = matrix(c(0,33000,50000,60000,70000,120000,
                                                0.19,0.3,0.35,0.4,0.44,0.45), ncol =2),
                   PIT_rebates_2000 = matrix(c(0,65,75,
                                               3710,2775,0), ncol = 2),
                   PIT_brackets_2001 = matrix(c(0,35000,45000,60000,70000,200000,
                                                0.18,0.26,0.32,0.37,0.4,0.42), ncol =2),
                   PIT_rebates_2001 = matrix(c(0,65,75,
                                               3800,2900,0), ncol = 2),
                   PIT_brackets_2002 = matrix(c(0,38000,55000,80000,100000,215000,
                                                0.18,0.26,0.32,0.37,0.4,0.42), ncol =2),
                   PIT_rebates_2002 = matrix(c(0,65,75,
                                               4140,3000,0), ncol = 2),
                   PIT_brackets_2003 = matrix(c(0,40000,80000,110000,170000,240000,
                                                0.18,0.25,0.3,0.35,0.38,0.4), ncol =2),
                   PIT_rebates_2003 = matrix(c(0,65,75,
                                               4860,3000,0), ncol = 2),
                   PIT_brackets_2004 = matrix(c(0,70000,110000,140000,180000,255000,
                                                0.18,0.25,0.3,0.35,0.38,0.4), ncol =2),
                   PIT_rebates_2004 = matrix(c(0,65,75,
                                               5400,3100,0), ncol = 2),
                   PIT_brackets_2005 = matrix(c(0,74000,115000,155000,195000,270000,
                                                0.18,0.25,0.3,0.35,0.38,0.4), ncol =2),
                   PIT_rebates_2005 = matrix(c(0,65,75,
                                               5800,3200,0), ncol = 2),
                   PIT_brackets_2006 = matrix(c(0,80000,130000,180000,230000,300000,
                                                0.18,0.25,0.3,0.35,0.38,0.4), ncol =2),
                   PIT_rebates_2006 = matrix(c(0,65,75,
                                               6300,4500,0), ncol = 2),
                   PIT_brackets_2007 = matrix(c(0,100000,160000,220000,300000,400000,
                                                0.18,0.25,0.3,0.35,0.38,0.4), ncol =2),
                   PIT_rebates_2007 = matrix(c(0,65,75,
                                               7200,4500,0), ncol = 2),
                   PIT_brackets_2008 = matrix(c(0,112500,180000,250000,350000,450000,
                                                0.18,0.25,0.3,0.35,0.38,0.4), ncol =2),
                   PIT_rebates_2008 = matrix(c(0,65,75,
                                               7740,4680,0), ncol = 2),
                   PIT_brackets_2009 = matrix(c(0,122000,195000,270000,380000,490000,
                                                0.18,0.25,0.3,0.35,0.38,0.4), ncol =2),
                   PIT_rebates_2009 = matrix(c(0,65,75,
                                               8280,5040,0), ncol = 2),
                   PIT_brackets_2010 = matrix(c(0,132000,210000,290000,410000,525000,
                                                0.18,0.25,0.3,0.35,0.38,0.4), ncol =2),
                   PIT_rebates_2010 = matrix(c(0,65,75,
                                               9756,5400,0), ncol = 2),
                   PIT_brackets_2011 = matrix(c(0,140000,221000,305000,431000,552000,
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

save(Tax_tables, file = "data-raw/SARS/Tax_tables.rda", version = 2)

usethis::use_data(Tax_tables, overwrite = TRUE)

# Changing the data into a dataframe to make it easier to work with
library(data.table)
#
PIT_brackets <- data.table(rbind(cbind(2001, Tax_tables$PIT_brackets_2001),
                                 cbind(2002, Tax_tables$PIT_brackets_2002),
                                 cbind(2003, Tax_tables$PIT_brackets_2003),
                                 cbind(2004, Tax_tables$PIT_brackets_2004),
                                 cbind(2005, Tax_tables$PIT_brackets_2005),
                                 cbind(2006, Tax_tables$PIT_brackets_2006),
                                 cbind(2007, Tax_tables$PIT_brackets_2007),
                                 cbind(2008, Tax_tables$PIT_brackets_2008),
                                 cbind(2009, Tax_tables$PIT_brackets_2009),
                                 cbind(2010, Tax_tables$PIT_brackets_2010),
                                 cbind(2011, Tax_tables$PIT_brackets_2011),
                                 cbind(2012, Tax_tables$PIT_brackets_2012),
                                 cbind(2013, Tax_tables$PIT_brackets_2013),
                                 cbind(2014, Tax_tables$PIT_brackets_2014),
                                 cbind(2015, Tax_tables$PIT_brackets_2015),
                                 cbind(2016, Tax_tables$PIT_brackets_2016),
                                 cbind(2017, Tax_tables$PIT_brackets_2017),
                                 cbind(2018, Tax_tables$PIT_brackets_2018),
                                 cbind(2019, Tax_tables$PIT_brackets_2019),
                                 cbind(2020, Tax_tables$PIT_brackets_2020),
                                 cbind(2021, Tax_tables$PIT_brackets_2021)))

PIT_brackets <- setnames(PIT_brackets,
                         new = c("Tax_year", "Bracket", "Tax_rate"))

# Create cumulative tax paid column
PIT_brackets[, Cumulative_tax := data.table::fifelse(Bracket == 0, 0,
                                                 round((Bracket - data.table::shift(Bracket)) *
                                                         data.table::shift(Tax_rate), 0)),
             by = Tax_year][, Cumulative_tax := cumsum(Cumulative_tax), by = Tax_year]

PIT_rebates <- data.table(rbind(cbind(2001, Tax_tables$PIT_rebates_2001),
                                cbind(2002, Tax_tables$PIT_rebates_2002),
                                cbind(2003, Tax_tables$PIT_rebates_2003),
                                cbind(2004, Tax_tables$PIT_rebates_2004),
                                cbind(2005, Tax_tables$PIT_rebates_2005),
                                cbind(2006, Tax_tables$PIT_rebates_2006),
                                cbind(2007, Tax_tables$PIT_rebates_2007),
                                cbind(2008, Tax_tables$PIT_rebates_2008),
                                cbind(2009, Tax_tables$PIT_rebates_2009),
                                cbind(2010, Tax_tables$PIT_rebates_2010),
                                cbind(2011, Tax_tables$PIT_rebates_2011),
                                cbind(2012, Tax_tables$PIT_rebates_2012),
                                cbind(2013, Tax_tables$PIT_rebates_2013),
                                cbind(2014, Tax_tables$PIT_rebates_2014),
                                cbind(2015, Tax_tables$PIT_rebates_2015),
                                cbind(2016, Tax_tables$PIT_rebates_2016),
                                cbind(2017, Tax_tables$PIT_rebates_2017),
                                cbind(2018, Tax_tables$PIT_rebates_2018),
                                cbind(2019, Tax_tables$PIT_rebates_2019),
                                cbind(2020, Tax_tables$PIT_rebates_2020),
                                cbind(2021, Tax_tables$PIT_rebates_2021)))

PIT_rebates <- setnames(PIT_rebates,
                        new = c("Tax_year", "Age", "Rebate"))

# Cumulative rebate
Rebates[, Cumulative_rebate := cumsum(Rebate)]

save(PIT_brackets, file = "data-raw/SARS/PIT_brackets.rda")
save(PIT_rebates, file = "data-raw/SARS/PIT_rebates.rda")

usethis::use_data(PIT_brackets, overwrite = TRUE)
usethis::use_data(PIT_rebates, overwrite = TRUE)
