############################################
# Script to initialize and load data
############################################

# load and start all connections

####################
# Load library
####################
library(survival)
library(metafor)
library(ggplot2)
library(survminer)
require('DSI')
require('DSOpal')
require('dsBaseClient')

#################################################
# Load data
#   1. Data processed using meat_study.R
#   2. Uploaded to my own VM
#   3. See more steps in opal_instructions.txt
#################################################
builder <- DSI::newDSLoginBuilder()

builder$append(server = "study1", 
               url = "http://192.168.56.100:8080/", 
               user = "administrator", password = "datashield_test&", 
               table = "test.meat_country1_harmonized", driver = "OpalDriver")

builder$append(server = "study2", 
               url = "http://192.168.56.100:8080/", 
               user = "administrator", password = "datashield_test&", 
               table = "test.meat_country2_harmonized", driver = "OpalDriver")

builder$append(server = "study3",
               url = "http://192.168.56.100:8080/",
               user = "administrator", password = "datashield_test&",
               table = "test.meat_country3_harmonized", driver = "OpalDriver")

builder$append(server = "study4",
               url = "http://192.168.56.100:8080/",
               user = "administrator", password = "datashield_test&",
               table = "test.meat_country4_harmonized", driver = "OpalDriver")

builder$append(server = "study5",
               url = "http://192.168.56.100:8080/",
               user = "administrator", password = "datashield_test&",
               table = "test.meat_country5_harmonized", driver = "OpalDriver")

builder$append(server = "study7",
               url = "http://192.168.56.100:8080/",
               user = "administrator", password = "datashield_test&",
               table = "test.meat_country7_harmonized", driver = "OpalDriver")

builder$append(server = "study8",
               url = "http://192.168.56.100:8080/",
               user = "administrator", password = "datashield_test&",
               table = "test.meat_country8_harmonized", driver = "OpalDriver")



logindata <- builder$build()

##############
# login
##############

# opals <- datashield.login(logins=logindata,assign=TRUE)
# Log onto the remote Opal training servers
connections <- DSI::datashield.login(logins = logindata, assign = TRUE, symbol = "D") 

############################################
# do data filtering and quality control
#   and create Surv() objects
############################################
fn_recompute(input_e_min = 800, 
             input_e_max = 4200
             )
