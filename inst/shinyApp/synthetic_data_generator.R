###############################################################################
# Script to generate synthetic data
#
#     https://cran.r-project.org/web/packages/simstudy/vignettes/simstudy.html
#
################################################################################

##################### 
# Load library
#####################
library(simstudy)
library(haven)
#library(tidyverse)
#library(data.table)
#library(sqldf)
#library(dplyr)

########################
# generate definition
########################

# TODO: pick std from ds.var  and pick parameters from datashield
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
def <- defData(def, varname = "BMI", dist = "normal", 
               formula = 23, variance = 1)
def <- defData(def, varname = "BMI_CAT", dist = "normal",
               formula = 23, variance = 1)
def <- defData(def, varname = "ALCOHOL", dist = "normal",
               formula = 42, variance = 5)
def <- defData(def, varname = "E_INTAKE", dist = "normal",
               formula = 200, variance = 20)
def <- defData(def, varname = "CASE_OBJ", dist = "binary", 
               formula = "0.1 + REDMEAT", link = "logit")
def <- defData(def, varname = "CASE_OBJ_SELF", dist = "binary", 
               formula = "0.1 + REDMEAT", link = "logit")

# TODO: PA EDUCATION SMOKING factor  
# TODO: FUP_OBJ time normal and depend on something simple OR just use rpois()

# "PREV_DIAB", "AGE_BASE", "SEX", "TYPE_DIAB", "E_INTAKE", "CASE_OBJ_SELF",
#                          "CASE_OBJ", "FUP_OBJ", "FUP_OBJ_SELF", "NUTS_SEEDS", "BMI", "EDUCATION",
#                          "SMOKING", "PA", "ALCOHOL", "BMI_CAT", "REDMEATTOTAL", "REDMEAT", 
#                          "POULTRY", "OFFALS", "i_status_out_cohort")

###################
# generate data
###################
dd <- genData(1000, def)
dd
dd$TYPE_DIAB <- 2
dd$i_status_out_cohort <- 1

# TODO: use data_gen.R moms data frame adn mean, skew etc to 
# geenrate dtaa from simstudy

#######################
# save to disk
#######################
# 1. save as csv
filename_synthetic_data = "df_synthetic_data.csv"
write.table(dd, file=filename_synthetic_data,
            row.names = FALSE, quote=FALSE, append = FALSE, sep = ",")  #, col.names = NA)

# 2. convert to dta format for uploading to VM
haven::write_dta(data = dd,
                 path ='C:/Users/sb2333/Downloads/data_synthetic_country1.dta')

#############################################################
# 3. upload to VM dev v2
# 4. Save VM and make it available
#    OR
#    use datashield.table.assign datashield.assign.table
#############################################################

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

