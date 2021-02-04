######################################################################################
# Meta-analysis of survival models in DataSHIELD for the red meat project
#	
# Additional code in:
#   https://github.com/neelsoumya/dsBaseClient/tree/absolute_newbie_client
#   https://github.com/neelsoumya/dsBase/tree/absolute_newbie
#
# Usage:
#     R --no-save < redmeat_survival_ownVM.R > output_redmeat_surv.txt
#
######################################################################################

####################
# Load library
####################
library(survival)
library(metafor)
library(ggplot2)
#library(survminer)
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

builder$append(server = "study9",
                url = "http://192.168.56.100:8080",
                user = "administrator", password = "datashield_test&",
                table = "test.meat_country9_harmonized", driver = "OpalDriver")
# CAUTION
# DUMMY DATA
# builder$append(server = "study9",
#                 url = "http://192.168.56.100:8080",
#                 user = "administrator", password = "datashield_test&",
#                 table = "test.meat_DUMMY", driver = "OpalDriver")

# TODO: include meat9 study and modify all code to have study 10
# TODO: modofy next call to be study10
# TODO: metafor::forest.rma() modify to have country names

# WHI data
builder$append(server = "study10",
               url = "http://opal-dev.mrc-epid.cam.ac.uk:8080",
               user = "soumya", password = "interconnect2021",
               table = "MEAT.whi_pattern_harm", driver = "OpalDriver")

# CARDIA data
builder$append(server = "study11",
               url = "http://opal-dev.mrc-epid.cam.ac.uk:8080",
               user = "soumya", password = "interconnect2021",
               table = "MEAT.cardia_pattern_harm", driver = "OpalDriver")

# Golestan data
builder$append(server = "study12",
               url = "http://opal-dev.mrc-epid.cam.ac.uk:8080",
               user = "soumya", password = "interconnect2021",
               table = "MEAT.golestan_pattern_harm", driver = "OpalDriver")

logindata <- builder$build()

##############
# login
##############

# opals <- datashield.login(logins=logindata,assign=TRUE)
# Log onto the remote Opal training servers

# list of all variables to be loaded
list_all_var_load <- list("PREV_DIAB", "AGE_BASE", "SEX", "TYPE_DIAB", "E_INTAKE", "CASE_OBJ_SELF",
                          "CASE_OBJ", "FUP_OBJ", "FUP_OBJ_SELF", "NUTS_SEEDS", "BMI", "EDUCATION",
                          "SMOKING", "PA", "ALCOHOL", "BMI_CAT", "REDMEATTOTAL", "REDMEAT", 
                          "POULTRY", "OFFALS", "i_status_out_cohort")
# prototype is
#     https://github.com/datashield/DSI/blob/master/R/datashield.login.R
connections <- DSI::datashield.login(logins = logindata, assign = TRUE, 
                                     symbol = "D", variables = list_all_var_load) 

#############################################
# data filtering
# 	exclusion criterion
#		1. no previous diabetes
#		2. no type 1 diabetes
#	inclusion criterion
#		1. age >= 18 years
#############################################
dsBaseClient::ds.dataFrameSubset(df.name = 'D', 
                                 V1.name = 'D$PREV_DIAB', 
                                 V2.name = '0', 
                                 Boolean.operator = '==', 
                                 newobj = 'E_temp',
                                 datasources = connections)	

cat("Performing data munging .... \n")
cat("The number of patients that you start with .... \n")
dsBaseClient::ds.length(x = 'D$SEX', 
                        type = 'split',
                        datasources = connections)

dsBaseClient::ds.dataFrameSubset(df.name = 'E_temp', 
                                 V1.name = 'E_temp$AGE_BASE', 
                                 V2.name = '18', 
                                 Boolean.operator = '>=', 
                                 newobj = 'E_temp2',
                                 datasources = connections)	

cat("The number of patients after removing those with age >= 18 ...")
dsBaseClient::ds.length(x = 'E_temp2$SEX', 
                        type = 'split',
                        datasources = connections)

dsBaseClient::ds.dataFrameSubset(df.name = 'E_temp2', 
                                 V1.name = 'E_temp2$TYPE_DIAB', 
                                 V2.name = '1', 
                                 Boolean.operator = '!=', 
                                 newobj = 'E_temp3',
                                 datasources = connections)	

cat("The number of patients that remain after removing those with Type 1 diabetes  ..\n")
dsBaseClient::ds.length(x = 'E_temp3$SEX', 
                        type = 'split',
                        datasources = connections)

# filter and remove outliers for energy intake
dsBaseClient::ds.asNumeric("E_temp3$SEX", newobj = "sexNumbers", connections)

dsBaseClient::ds.assign(toAssign = "(sexNumbers*300)+E_temp3$E_INTAKE", 
                        newobj = "adjustedLowerBound",
                        connections)

dsBaseClient::ds.assign(toAssign = "(sexNumbers*700)+E_temp3$E_INTAKE", 
                        newobj = "adjustedUpperBound",
                        connections)

dsBaseClient::ds.cbind(x=c("E_temp3","adjustedLowerBound"),
                       newobj = "L1",
                       #DataSHIELD.checks = FALSE,
                       datasources = connections)

dsBaseClient::ds.cbind(x=c("L1", "adjustedUpperBound"),
                       newobj = "L2",
                       #DataSHIELD.checks = FALSE,
                       datasources = connections)

# remove participants with very high or very low energy intake
dsBaseClient::ds.dataFrameSubset(df.name = 'L2', 
                                 V1.name = 'L2$adjustedUpperBound', 
                                 V2.name = '4200', 
                                 Boolean.operator = '<=', 
                                 newobj = 'E3',
                                 datasources = connections)	

# how many have been removed
dsBaseClient::ds.length(x = 'L2$SEX', 
                        type = 'split',
                        datasources = connections)

dsBaseClient::ds.length(x = 'E3$SEX',
                        type = 'split',
                        datasources = connections)

dsBaseClient::ds.dataFrameSubset(df.name = 'E3', 
                                 V1.name = 'E3$adjustedLowerBound', 
                                 V2.name = '800', 
                                 Boolean.operator = '>=', 
                                 newobj = 'D_curated', 
                                 datasources = connections)

cat("The number of patients removed due to lower bound on energy intake are: \n")
dsBaseClient::ds.length(x = 'D_curated$SEX',
                        type = 'split',
                        datasources = connections)
 
# TODO: make sure no data missing for the covariates across all studies

###############################################################
# add in Prentice weights
#	1. https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4074158/
#	2. pseudocode
# To apply Prentice weighting, all we actually do is set the weight of 
#   Cases outside subcohort before failure to 0.
#   In practical terms, what this means is changing the
#   start times of cases outside the subcohort to (end time – 0.0001).
#   So they only ‘appear’ just before their event.
#   This means some code like this:
# 
# og_data$age_recr_prentice <- og_data$age_recr_max
# for (i in 1:length(og_data$age_recr_max))
# {
#   if(og_data$dmstatus_ver_outc[i] == 2)
#   {
#       og_data$age_recr_prentice[i] = og_data$ageEnd[i] - 0.00001
#   }
# }
#   Because dmstatus_ver_outc value of 2 is case outside subcohort, 
#   age_recr_max is age at start. 
#   We have 2 ways of doing this for DataSHIELD – 
#   either as part of harmonisation (so when we generate the follow up time 
#                                 variable in opal, we do the logic above),
#   or we can use ds.Boole to apply the rule above
#########################################################

# make sure no data missing
# all the variables in the analysis
myvars = c(
  'AGE_BASE', 'TYPE_DIAB', 'PREV_DIAB', 'CASE_OBJ_SELF', 'CASE_OBJ', 'FUP_OBJ', 'FUP_OBJ_SELF', 'PBCL',
  'SOY', 'NUTS_SEEDS', 'ISOFLAVONES', 'TOTAL', 'SEX', 'BMI', 'EDUCATION', 'SMOKING', 'PA', 'ALCOHOL',
  'FAM_DIAB', 'COMORBIDITY', 'E_INTAKE', 'COV_FRUIT', 'COV_VEG', 'COV_FIBER', 'COV_MEAT', 'COV_SUG_BEVS', 'WAIST',
  'REGION_CH', 'BMI_CAT', 'CONSUMER', 'COV_DAIRY', 'COV_FISH'
)

# TODO: additional logic
# variables not to be used in complete cases
# stops loss of missing for these variables during complete cases, when they are not used in most models

none_cc_vars = c('tid.f','CENSOR', "WAIST", "FAM_DIAB")
#none_cc_vars = c('tid.f','CENSOR')

# Other functions in github repository
#	https://github.com/interconnectDiabetes/exemplar_analyses/blob/master/variable_functions.R
# also see legume_exemplar.R
#	https://github.com/interconnectDiabetes/exemplar_analyses/blob/master/legume_exemplar/legume_analysis.R




#################################################
# Create server side variables
#   make sure that the outcome is numeric, etc. 
##################################################

# REDMEATTOTAL is the exposure and CASE_OBJ is the event. 
# The time element is FUP_OBJ

dsBaseClient::ds.asNumeric(x.name = "D_curated$CASE_OBJ",
             newobj = "EVENT",
             datasources = connections)

# time to event variable
dsBaseClient::ds.asNumeric(x.name = "D_curated$FUP_OBJ",
             newobj = "SURVTIME",
             datasources = connections)

# add secondary event and survtime variables
dsBaseClient::ds.asNumeric(x.name = "D_curated$CASE_OBJ_SELF",
                           newobj = "EVENT_SELF",
                           datasources = connections)

# time to event variable
dsBaseClient::ds.asNumeric(x.name = "D_curated$FUP_OBJ_SELF",
                           newobj = "SURVTIME_SELF",
                           datasources = connections)

# get age at baseline
dsBaseClient::ds.asNumeric(x.name = 'D_curated$AGE_BASE',
             newobj = 'AGEBASE',
             datasources = connections)

# get exposure variables
dsBaseClient::ds.asNumeric(x.name = 'D_curated$NUTS_SEEDS',
             newobj = 'NUTSSEEDS',
             datasources = connections
              )

# get exposure variables
dsBaseClient::ds.asNumeric(x.name = 'D_curated$REDMEATTOTAL',
             newobj = 'REDMEATTOTAL',
             datasources = connections
              )

# get red meat only
dsBaseClient::ds.asNumeric(x.name = 'D_curated$REDMEAT', 
                           newobj = 'REDMEAT', 
                           datasources = connections)

# get poultry
dsBaseClient::ds.asNumeric(x.name = 'D_curated$POULTRY', 
                           newobj = 'POULTRY', 
                           datasources = connections)
# get offals
dsBaseClient::ds.asNumeric(x.name = 'D_curated$OFFALS', 
                           newobj = 'OFFALS', 
                           datasources = connections)


# get gender
dsBaseClient::ds.asFactor(input.var.name = 'D_curated$SEX',
            newobj.name = 'GENDER',
            datasources = connections
            )

# get BMI
dsBaseClient::ds.asNumeric(x.name = 'D_curated$BMI',
                           newobj = 'BMI',
                           datasources = connections
                          )

# Get physical activity
dsBaseClient::ds.asFactor(input.var.name = 'D_curated$PA', 
                          newobj.name = 'PA', 
                          datasources = connections)

# get smoking
dsBaseClient::ds.asFactor(input.var.name = 'D_curated$SMOKING', 
                          newobj.name = 'SMOKING', 
                          datasources = connections)
# get alcohol
dsBaseClient::ds.asNumeric(x.name = 'D_curated$ALCOHOL', 
                           newobj = 'ALCOHOL', 
                           datasources = connections)

# get energy intake
dsBaseClient::ds.asNumeric(x.name = 'D_curated$E_INTAKE', 
                           newobj = 'E_INTAKE', 
                           datasources = connections)

# get education
dsBaseClient::ds.asFactor(input.var.name = 'D_curated$EDUCATION', 
                          newobj.name = 'EDUCATION', 
                          datasources = connections)


##############################################################
# create a dummy variable for Prentice weighted survival time
##############################################################
ds.assign(toAssign = "SURVTIME",
          newobj = "PRENTICETIME",
          datasources = connections
         )

# let us now assume that all of study 2 is case outside sub-cohort
#	hence call ds.assign for connections[2]
# TODO: fix later using ds.Boole()
#ds.assign(toAssign = "PRENTICETIME-0.00001",
#          newobj = "PRENTICETIME",
#          datasources = connections[2]
#         )

# create a variable for out of cohort indicator
# TODO: this will be replaced with actual data
#	now this is set to 0	
#ds.assign(toAssign = "0",
#          newobj = "i_status_out_cohort",
#          datasources = connections
#         )

# javascript logic in data dictionary like so:
# i_status_out_cohort = $('dmstatus_ver_outc').value()
# if (i_status_out_cohort == 2)
# {
#    i_status_out_cohort = 1
# }
# else
# {
#    i_status_out_cohort = 0
# }
dsBaseClient::ds.asNumeric(x.name = 'D_curated$i_status_out_cohort', 
                           newobj = 'i_status_out_cohort', 
                           datasources = connections)

# cbind it to main data frame D
# ds.cbind(x=c("i_status_out_cohort","D"),
#         newobj = "D",
#         datasources = connections
#        )             


# 2. Prentice weight logic
#	if i_status_out_cohort is 1 then 0.00001
#	else if 0 then SURVTIME
ds.assign(toAssign = "(i_status_out_cohort*0.00001) + ((1-i_status_out_cohort)*SURVTIME)",
          newobj = "PRENTICETIME",
          datasources = connections
         )

# repeat for secondary objective
ds.assign(toAssign = "(i_status_out_cohort*0.00001) + ((1-i_status_out_cohort)*SURVTIME_SELF)",
          newobj = "PRENTICETIME_SELF",
          datasources = connections
          )


# check which variables exist
dsBaseClient::ds.ls()


#####################################################
# create survival object and then call coxphSLMA()
#####################################################
# call coxph server side
# client side function is here:
# 	https://github.com/neelsoumya/dsBaseClient/blob/absolute_newbie_client/R/ds.coxph.SLMA.R
# server side function is here:
# 	https://github.com/neelsoumya/dsBase/blob/absolute_newbie/R/coxphSLMADS.R

# 1. use constructed surv object in coxph
dsBaseClient::ds.Surv(time='SURVTIME', event = 'EVENT', objectname='surv_object')

dsBaseClient::ds.Surv(time='PRENTICETIME', event = 'EVENT', objectname='surv_object_prentice') 

dsBaseClient::ds.Surv(time='PRENTICETIME_SELF', event = 'EVENT_SELF', objectname='surv_object_prentice_self') 

#############################################
# Model 1
# 	from the analysis plan: 
#	surv_object ~ AGEBASE + GENDER + 
#	REDMEATTOTAL + ALCOHOL + PA + SMOKING
#	 + EDUCATION + E_INTAKE
#############################################
#dsBaseClient::ds.Surv(time='STARTTIME', time2='ENDTIME', event = 'EVENT', objectname='surv_object2', type='counting')
# coxph_model_full <- dsBaseClient::ds.coxph.SLMA(formula = 'surv_object_prentice ~ AGEBASE + GENDER + REDMEATTOTAL + ALCOHOL + PA + SMOKING + EDUCATION + E_INTAKE')

# dsBaseClient::ds.coxph.SLMA(formula = 'surv_object ~ AGEBASE + GENDER + REDMEATTOTAL + ALCOHOL + PA + SMOKING + EDUCATION + E_INTAKE',
#                            combine_with_metafor = TRUE)

# all individual ed meat exposures
# dsBaseClient::ds.coxph.SLMA(formula = 'surv_object_prentice ~ AGEBASE + GENDER + REDMEAT + POULTRY + OFFALS + ALCOHOL + PA + SMOKING + EDUCATION + E_INTAKE',
#                            combine_with_metafor = TRUE)

# Prentice weighted Cox proportional hazards model
# dsBaseClient::ds.coxph.SLMA(formula = 'surv_object_prentice ~ AGEBASE + GENDER + REDMEATTOTAL + ALCOHOL + PA + SMOKING + EDUCATION + E_INTAKE',
#                            combine_with_metafor = TRUE)

# for secondary outcome measure
#dsBaseClient::ds.coxph.SLMA(formula = 'surv_object_prentice_self ~ AGEBASE + GENDER + REDMEATTOTAL + ALCOHOL + PA + SMOKING + EDUCATION + E_INTAKE',
#                            combine_with_metafor = TRUE)

#################################
# summary of Survival object
#################################
# dsBaseClient::ds.summary(x = 'surv_object')

#################################
# TODO: Plot survival curves
#################################
# fit <- survival::survfit(formula = 'surv_object~D$age+D$female', data = 'D')
# need ds.survfit() and survfitDS()
# fit_model <- ds.survfit(coxph_model[1])
# plot(fit_model)
# TODO:
# plot(survfit_km, fun="cloglog")
# TODO: 
# ggplot like functionality see other functions
# In dsBaseClient::
# ds.survfit()
#         datashield.aggregate("survfitDS", ....)
#          return (the fit model)
# In dsBase::
# survfitDS(coxph_model)  
#               fit_model <- survival::survfit(coxph_model, newdata = 'D')
#               return (fit_model)

# dsBaseClient::ds.survfit(formula='surv_object~1', objectname='survfit_object')


####################################
# Diagnostics
#   check assumptions of Cox model
####################################
# cat("Checking diagnostics and validity of Cox proportional hazards assumptions ... \n")
# dsBaseClient::ds.coxphSLMAassign(formula = 'surv_object_prentice ~ AGEBASE + GENDER + REDMEATTOTAL + ALCOHOL + PA + SMOKING + EDUCATION + E_INTAKE', 
#                                 objectname = 'coxph_model_server_side')

# dsBaseClient::ds.coxphSummary(x = 'coxph_model_server_side')

# dsBaseClient::ds.cox.zphSLMA(fit = 'coxph_model_server_side', 
#                             transform = "identity")


################################
# meta-analyze hazard ratios
################################

# TODO: for each study
#for (i_temp_counter in c(1:length(coxph_model_full)))
#{
#  
#}

# list of hazard ratios for first parameter over 2 studies 
#input_logHR = c(coxph_model_full$study1$coefficients[3,2], 
#                coxph_model_full$study2$coefficients[3,2], 
#                coxph_model_full$study3$coefficients[3,2],
#                coxph_model_full$study4$coefficients[3,2],
#                coxph_model_full$study5$coefficients[3,2],
#                coxph_model_full$study7$coefficients[3,2],
#                coxph_model_full$study8$coefficients[3,2]
#                )

#input_se    = c(coxph_model_full$study1$coefficients[3,3], 
#                coxph_model_full$study2$coefficients[3,3], 
#                coxph_model_full$study3$coefficients[3,3],
#                coxph_model_full$study4$coefficients[3,3],
#                coxph_model_full$study5$coefficients[3,3],
#                coxph_model_full$study7$coefficients[3,3],
#                coxph_model_full$study8$coefficients[3,3]
#              )


#meta_model <- metafor::rma(input_logHR, sei = input_se, method = 'REML')

#######################################################
# forest plots of final meta-analyzed hazard ratios
#######################################################
#metafor::forest.rma(x = meta_model)

#######################################################
# save model output and logging information to disk
#######################################################
save.image(file = 'survival_meat_interact.RData')

#############################################
# disconnect
#############################################
#DSI::datashield.logout(conns = connections)

cat("Completed ........\n")

