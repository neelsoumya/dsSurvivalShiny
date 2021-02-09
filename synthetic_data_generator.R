###########################################
# Script to generate synthetic data
#
#     https://cran.r-project.org/web/packages/simstudy/vignettes/simstudy.html
#
###########################################

##################### 
# load library
#####################
library(simstudy)

# generate definition
def <- defData(varname = "age", dist = "normal", 
               formula = 10, variance = 2)
def <- defData(def, varname = "female", dist = "binary", 
    formula = "-2 + age * 0.1", link = "logit")
def <- defData(def, varname = "visits", dist = "poisson", 
    formula = "1.5 - 0.2 * age + 0.5 * female", link = "log")
def <- defData(def, varname = "REDMEAT", dist = "normal", 
               formula = 100, variance = 10)
def <- defData(def, varname = "REDMEATTOTAL", dist = "normal", 
               formula = 150, variance = 11)


# generate data
dd <- genData(1000, def)
dd

# 1. save as csv
filename_synthetic_data = "df_synthetic_data.csv"
write.table(dd, file=filename_synthetic_data,
            row.names = FALSE, quote=FALSE, append = FALSE, sep = ",")  #, col.names = NA)
# 2. upload to VM dev v2
# 3. Save VM and make it available


# TODO: use dsData
#       https://github.com/datashield/DSData
