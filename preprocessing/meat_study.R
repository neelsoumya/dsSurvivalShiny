################################################
# Script to do data munging 
# for InterAct meat project
# for uploading to Opal server
# 
# installation
# install.packages('tidyverse')
# install.packages('haven')
# install.packages('sqldf')
################################################


######################
# load libraries
######################
library(haven)
library(tidyverse)
library(data.table)
library(sqldf)
library(dplyr)

stata_data <- haven::read_dta(file='V:/Studies/InterConnect/Internal/Meat exemplar/Data/InterAct/PHIA0000072020.dta')

# split by country
dt_stata_data <- data.table::data.table(stata_data, stringsAsFactors = FALSE)

# set key
data.table::setkey(dt_stata_data, MRCid_IAp_134)

# number of unique countries
data.table::uniqueN(dt_stata_data$country)

############################################
# one data table for each country
############################################
dt_stata_data_country1 = dt_stata_data[country == 1]

dt_stata_data_country2 = dt_stata_data[country == 2]

dt_stata_data_country3 = dt_stata_data[country == 3]

dt_stata_data_country4 = dt_stata_data[country == 4]

dt_stata_data_country5 = dt_stata_data[country == 5]

dt_stata_data_country7 = dt_stata_data[country == 7]

dt_stata_data_country8 = dt_stata_data[country == 8]

dt_stata_data_country9 = dt_stata_data[country == 9]

# create a dummy country totest formissing covariates
dt_stata_data_DUMMY    = dt_stata_data_country9
# remove one covariate
dt_stata_data_DUMMY$bmi_adj <- NULL

############################################
# save file in stata format
############################################
haven::write_dta(data = dt_stata_data_country1,
                 path ='C:/Users/sb2333/Downloads/data_interact_country1.dta')

haven::write_dta(data = dt_stata_data_country2,
                 path ='C:/Users/sb2333/Downloads/data_interact_country2.dta')

haven::write_dta(data = dt_stata_data_country3,
                 path ='C:/Users/sb2333/Downloads/data_interact_country3.dta')

haven::write_dta(data = dt_stata_data_country4,
                 path ='C:/Users/sb2333/Downloads/data_interact_country4.dta')

haven::write_dta(data = dt_stata_data_country5,
                 path ='C:/Users/sb2333/Downloads/data_interact_country5.dta')

haven::write_dta(data = dt_stata_data_country7,
                 path ='C:/Users/sb2333/Downloads/data_interact_country7.dta')

haven::write_dta(data = dt_stata_data_country8,
                 path ='C:/Users/sb2333/Downloads/data_interact_country8.dta')

haven::write_dta(data = dt_stata_data_country9,
                 path = 'C:/Users/sb2333/Downloads/data_interact_country9.dta')

haven::write_dta(data = dt_stata_data_DUMMY,
                 path = 'C:/Users/sb2333/Downloads/data_interact_DUMMY.dta')


############################################
# save file in csv format
############################################
write.table(x = dt_stata_data_country1,
            file = 'data_interact_country1.csv',
            row.names = FALSE,
            quote = FALSE,
            append = FALSE,
            sep = ','
            )

write.table(x = dt_stata_data_country2,
            file = 'data_interact_country2.csv',
            row.names = FALSE,
            quote = FALSE,
            append = FALSE,
            sep = ','
            )

# df_stata_data <- as.data.frame(stata_data)
# df_data <- sqldf::sqldf('select *
#                         from df_stata_data')

# use group_by in data.table dplyr etc
