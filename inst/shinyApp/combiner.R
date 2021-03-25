##########################################
# Script to call all stage scripts
#     and combine results
#
##########################################

source('stage1.R')

load Rdata file

rename coxph model 

coxph_model_full_stage1 <- coxph_model_full


source('stage3.R')

load Rdata file

rename coxph model 

coxph_model_full_stage3 <- coxph_model_full


# then make changes in log_HR

# call forest plot




