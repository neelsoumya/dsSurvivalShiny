###############################################################################
# Script to generate synthetic data using the simstudy package.
#     Also generate synthetic outlier data.
#
#     https://cran.r-project.org/web/packages/simstudy/vignettes/simstudy.html
#
################################################################################

##################### 
# Load library
#####################
library(simstudy)
library(haven)
library(ggplot2)
# library(tidyverse)
# library(data.table)
# library(sqldf)
# library(dplyr)


# TODO: do simstudy on survey data y3beef, y3poultry, generate the synthetic RAW data
#           connect to RAW data and mean and SD and feedinto simstudy
#           get synthetic RAW data  
#        make binary and/or bionomial use case status as a function of current BMI and previous status
#    synth_coeff = 0.01 * dd$BMI + 0.01 * dd$AGE_BASE #+ 0.001 * dd$AGE_INTAKE
# calculate the log-odds
#    synth_log_odds = exp(synth_coeff)/( 1 + exp(synth_coeff) )
# pass this log-odds to link function (for logistic regression it is the binomial)
#     rbinom( n = length(dd$BMI), size = 1, p = synth_log_odds)
# assign this to dichotomous variable 
#     dd$CASE_OBJ = rbinom(n = length(dd$BMI), size = 1, p = synth_log_odds )

# TODO: make function


# TODO: pick std from ds.var  and pick parameters from datashield
# TODO: have explicit formula and relationship for DIAB ~ AGE + BMI etc.
#   issue #4


# TODO: more complex formukla/expressions
#     see
#     https://cran.r-project.org/web/packages/simstudy/vignettes/simstudy.html
# TODO: FUP_OBJ time depend on complex formula


########################
# generate definition
########################

def <- defData(varname = "age", dist = "normal", 
               formula = 32, variance = 2)
def <- defData(def, varname = "female", dist = "binary", 
               formula = "-2 + age * 0.1", link = "logit")
def <- defData(def, varname = "SEX", dist = "binary", 
               formula = "-2 + age * 0.1", link = "logit")
def <- defData(def, varname = "visits", dist = "poisson", 
               formula = "1.5 - 0.2 * age + 0.5 * female", link = "log")

def <- defData(varname = "AGE_BASE", dist = "normal", 
               formula = 10, variance = 2)

def <- defData(def, varname = "REDMEAT", dist = "normal", 
               formula = 100, variance = 10)

# def <- defData(def, varname = "FUP_OBJ", dist = "poisson", 
#                formula = "1.5 + REDMEAT", link = "log")
def <- defData(def, varname = "FUP_OBJ", dist = "poisson", 
               formula = "1.5 + REDMEAT", link = "identity")
def <- defData(def, varname = "FUP_OBJ_SELF", dist = "poisson", 
               formula = "1.5 + REDMEAT", link = "identity")

def <- defData(def, varname = "REDMEATTOTAL", dist = "normal", 
               formula = 150, variance = 11)
def <- defData(def, varname = "OFFALS", dist = "normal", 
               formula = 50, variance = 5)
def <- defData(def, varname = "POULTRY", dist = "normal", 
               formula = 100, variance = 8)
def <- defData(def, varname = "NUTS_SEEDS", dist = "normal", 
               formula = 100, variance = 10)
# TODO: see Avraam 2017 Wellcome Open Research data Notes for fomrula to simulate BMI
def <- defData(def, varname = "BMI", dist = "normal", 
               formula = 23, variance = 1)
def <- defData(def, varname = "BMI_CAT", dist = "normal",
               formula = 23, variance = 1)
def <- defData(def, varname = "ALCOHOL", dist = "normal",
               formula = 42, variance = 5)
def <- defData(def, varname = "E_INTAKE", dist = "normal",
               formula = 200, variance = 20)

# choose dichotmous target variables
def <- defData(def, varname = "CASE_OBJ", dist = "binary", 
               formula = "0.1 + REDMEAT", link = "logit")
def <- defData(def, varname = "CASE_OBJ_SELF", dist = "binary", 
               formula = "0.1 + 0.1*REDMEAT + 0.1*BMI - 0.1*AGE_BASE", link = "logit")

# TODO: PA EDUCATION SMOKING factor  
# TODO: FUP_OBJ time normal and depend on something simple OR just use rpois()

# "PREV_DIAB", "AGE_BASE", "SEX", "TYPE_DIAB", "E_INTAKE", "CASE_OBJ_SELF",
#                          "CASE_OBJ", "FUP_OBJ", "FUP_OBJ_SELF", "NUTS_SEEDS", "BMI", "EDUCATION",
#                          "SMOKING", "PA", "ALCOHOL", "BMI_CAT", "REDMEATTOTAL", "REDMEAT", 
#                          "POULTRY", "OFFALS", "i_status_out_cohort")

###################
# generate data
###################
# TODO: make 1000 a parameter in fuunction wtih @param
n_samples = 1000
dd <- genData(n_samples, def)
dd
dd$TYPE_DIAB <- 2
dd$i_status_out_cohort <- 1

##########################################
# generate dependent variable
##########################################
# dd$FUP_OBJ = stats::dlogis( dd$BMI + dd$AGE_BASE + dd$E_INTAKE )
# https://github.com/neelsoumya/R_Codes-Simulating_Synthetic_Data/blob/master/Simulating_1958_HOP_Data.R
#  # Do logistic regression for each discrete variable
# s1 <- glm(D1$DIS_DIAB ~ D1$LAB_TSC + D1$LAB_TRIG + D1$LAB_HDL + D1$LAB_GLUC_ADJUSTED  + D1$PM_BMI_CONTINUOUS + D1$GENDER, family=binomial)
# v1 <- s1$coefficients[1] + s1$coefficients[2]*IndepVar$LAB_TSC + s1$coefficients[3]*IndepVar$LAB_TRIG + s1$coefficients[4]*IndepVar$LAB_HDL + s1$coefficients[5]*IndepVar$LAB_GLUC_ADJUSTED  + s1$coefficients[6]*IndepVar$PM_BMI_CONTINUOUS + s1$coefficients[7]*IndepVar$GENDER
# fp1 <- exp(v1)/(1+exp(v1))  # calculate the log odds 
# DIS_DIAB <- rbinom(n,1,fp1)

# set coefficient
synth_coeff = 0.01 * dd$BMI + 0.01 * dd$AGE_BASE #+ 0.001 * dd$AGE_INTAKE
# calculate the log-odds
synth_log_odds = exp(synth_coeff)/( 1 + exp(synth_coeff) )
# pass this log-odds to link function (for logistic regression it is the binomial)
rbinom( n = length(dd$BMI), size = 1, p = synth_log_odds)
# assign this to dichotomous variable 
dd$CASE_OBJ = rbinom(n = length(dd$BMI), size = 1, p = synth_log_odds )

# TODO: make nice oducmentation and use case like
#   denaonymization tool
#   https://github.com/theodi/synthetic-data-tutorial 


#############################
# visualize synthetic data
#############################
head(dd)
qplot(dd$CASE_OBJ, xlab = 'Diabetic status (synthetic data)', ylab = 'Frequency')
qplot(dd$BMI, ylab = 'Frequency', xlab = 'BMI (synthetic data)')


####################################
# generate synthetic outlier data
####################################
def <- defData(varname = "age", dist = "normal", 
               formula = 10, variance = 2)
def <- defData(def, varname = "female", dist = "binary", 
               formula = "-2 + age * 0.1", link = "logit")
def <- defData(def, varname = "SEX", dist = "binary", 
               formula = "-2 + age * 0.1", link = "logit")
def <- defData(def, varname = "visits", dist = "poisson", 
               formula = "1.5 - 0.2 * age + 0.5 * female", link = "log")

def <- defData(varname = "AGE_BASE", dist = "normal", 
               formula = 10, variance = 2)

def <- defData(def, varname = "REDMEAT", dist = "normal", 
               formula = 100, variance = 10)
def <- defData(def, varname = "FUP_OBJ", dist = "poisson", 
               formula = "1.5 + REDMEAT", link = "identity")
def <- defData(def, varname = "FUP_OBJ_SELF", dist = "poisson", 
               formula = "1.5 + REDMEAT", link = "identity")

def <- defData(def, varname = "REDMEATTOTAL", dist = "normal", 
               formula = 150, variance = 11)
def <- defData(def, varname = "OFFALS", dist = "normal", 
               formula = 50, variance = 5)
def <- defData(def, varname = "POULTRY", dist = "normal", 
               formula = 100, variance = 8)
def <- defData(def, varname = "NUTS_SEEDS", dist = "normal", 
               formula = 100, variance = 10)

# TODO: see Avraam 2017 Wellcome Open Research data Notes for fomrula to simulate BMI
# this particular value of BMI is high
# TODO: make parameter?
high_value_BMI = 35
def <- defData(def, varname = "BMI", dist = "normal", 
               formula = high_value_BMI, variance = 1)
def <- defData(def, varname = "BMI_CAT", dist = "normal",
               formula = 23, variance = 1)
def <- defData(def, varname = "ALCOHOL", dist = "normal",
               formula = 42, variance = 5)
def <- defData(def, varname = "E_INTAKE", dist = "normal",
               formula = 200, variance = 20)

# choose dichotmous target variables
def <- defData(def, varname = "CASE_OBJ", dist = "binary", 
               formula = "0.1 + REDMEAT", link = "logit")
def <- defData(def, varname = "CASE_OBJ_SELF", dist = "binary", 
               formula = "0.1 + 0.1*REDMEAT + 0.1*BMI - 0.1*AGE_BASE", link = "logit")

# TODO: PA EDUCATION SMOKING factor  
# TODO: FUP_OBJ time normal and depend on something simple OR just use rpois()

# "PREV_DIAB", "AGE_BASE", "SEX", "TYPE_DIAB", "E_INTAKE", "CASE_OBJ_SELF",
#                          "CASE_OBJ", "FUP_OBJ", "FUP_OBJ_SELF", "NUTS_SEEDS", "BMI", "EDUCATION",
#                          "SMOKING", "PA", "ALCOHOL", "BMI_CAT", "REDMEATTOTAL", "REDMEAT", 
#                          "POULTRY", "OFFALS", "i_status_out_cohort")

###################
# generate data
###################
dd <- genData(n_samples, def)
dd
dd$TYPE_DIAB <- 2
dd$i_status_out_cohort <- 1

# dd$FUP_OBJ = stats::dlogis( dd$BMI + dd$AGE_BASE + dd$E_INTAKE )
# https://github.com/neelsoumya/R_Codes-Simulating_Synthetic_Data/blob/master/Simulating_1958_HOP_Data.R
#  # Do logistic regression for each discrete variable
# s1 <- glm(D1$DIS_DIAB ~ D1$LAB_TSC + D1$LAB_TRIG + D1$LAB_HDL + D1$LAB_GLUC_ADJUSTED  + D1$PM_BMI_CONTINUOUS + D1$GENDER, family=binomial)
# v1 <- s1$coefficients[1] + s1$coefficients[2]*IndepVar$LAB_TSC + s1$coefficients[3]*IndepVar$LAB_TRIG + s1$coefficients[4]*IndepVar$LAB_HDL + s1$coefficients[5]*IndepVar$LAB_GLUC_ADJUSTED  + s1$coefficients[6]*IndepVar$PM_BMI_CONTINUOUS + s1$coefficients[7]*IndepVar$GENDER
# fp1 <- exp(v1)/(1+exp(v1))  # calculate the log odds 
# DIS_DIAB <- rbinom(n,1,fp1)

# set coefficient
synth_coeff = 0.01 * dd$BMI + 0.01 * dd$AGE_BASE #+ 0.001 * dd$AGE_INTAKE
# calculate the log-odds
synth_log_odds = exp(synth_coeff)/( 1 + exp(synth_coeff) )
# pass this log-odds to link function (for logistic regression it is the binomial)
rbinom( n = length(dd$BMI), size = 1, p = synth_log_odds)
# assign this to dichotomous variable 
dd$CASE_OBJ = rbinom(n = length(dd$BMI), size = 1, p = synth_log_odds )


#####################################
# plot this synthetic outlier data
#####################################
value_bmi_range_outlier = 35
idx <- which(dd$BMI > value_bmi_range_outlier)
dd_outlier_synthetic <- dd[idx,]
qplot(dd_outlier_synthetic$BMI, xlab = 'BMI (synthetic outlier data)', ylab = 'Frequency')


###################
# save to disk
###################
# 1. save as csv
filename_synthetic_data = "df_synthetic_data.csv"
write.table(dd, file=filename_synthetic_data,
            row.names = FALSE, quote=FALSE, append = FALSE, sep = ",")  #, col.names = NA)

#################################################
# 2. convert to dta format for uploading to VM
#################################################
haven::write_dta(data = dd,
                 path ='C:/Users/sb2333/Downloads/data_synthetic_country1.dta')

# 3. upload to VM dev v2
# 4. Save VM and make it available
#    OR
#    use datashield.table.assign datashield.assign.table

setwd('/Users/mibber/Work/Projects/SOPHIA/WP2/dsSwissKnife/dsSwissKnife-example-main-new')

# 2) Load the example data into local memory. 
#### The local CNSIM data frame (in this session) contains the concatenated data of the 2 remote ones and will be used to compare the results of various operations
load('CNSIM.rda')


# 3) Login to the federated nodes
logindata <- read.delim('logindata.txt') # read the login information
logindata

# log into the 2 remote servers:
opals <- datashield.login(logindata)

# load the CNSIM table from the 2 respective databases:
datashield.assign(opals, 'cnsim', 'test.CNSIM')

##########################################################################
# TODO: use ds.upload
#   https://github.com/lifecycle-project/ds-upload/blob/master/R/upload.R
#
# TODO: use datashield.login to upload this table
#   https://github.com/datashield/opal/blob/master/R/datashield.login.r
#   or dsloginbuilder
#   https://github.com/datashield/DSI/blob/master/R/DSLoginBuilder.R
#########################################################################
