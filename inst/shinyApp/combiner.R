##########################################
# Script to call all stage scripts
#     and combine results
#
##########################################

# TODO: make a shiny app server later for better plots

#######################
# load library
#######################
library(metafor)

#######################
# call stage 1
#######################
source('stage_generic.R')

stage_generic(c_study_index = c(1:2), str_filename_save = 'survival_meat_interact_mec_downstream_stage3.RData')


# source('stage1.R')

# load Rdata file
load(file = 'survival_meat_interact_stage1.RData')

# rename coxph model 

coxph_model_full_stage1 <- coxph_model_full

# call stage 2
source('stage3.R')

# load Rdata file
load(file = 'survival_meat_interact_stage3.RData')

# rename coxph model 
coxph_model_full_stage3 <- coxph_model_full


# then make changes in log_HR

    
    
   # list of hazard ratios for FIRST parameter over all 7 studies 
    input_logHR = c(coxph_model_full_bkup$study1$coefficients[1,2], 
                    coxph_model_full_bkup$study2$coefficients[1,2], 
                    coxph_model_full_bkup$study3$coefficients[1,2],
                    coxph_model_full_bkup$study4$coefficients[1,2],
                    coxph_model_full_bkup$study5$coefficients[1,2],
                    coxph_model_full_bkup$study7$coefficients[1,2],
                    coxph_model_full_bkup$study8$coefficients[1,2],
                    coxph_model_full_bkup$study9$coefficients[1,2],
                    coxph_model_full$study10$coefficients[1,2],
                    coxph_model_full_bkup$study11$coefficients[1,2],
                    coxph_model_full_bkup$study12$coefficients[1,2],
                    coxph_model_full_bkup$study13$coefficients[1,2],
                    coxph_model_full_bkup$study14$coefficients[1,2],
                    coxph_model_full_bkup$study15$coefficients[1,2],
                    coxph_model_full_bkup$study16$coefficients[1,2]
    )
    
    # list of standard errors for third parameter over all 7 studies 
    input_se    = c(coxph_model_full_bkup$study1$coefficients[1,3], 
                    coxph_model_full_bkup$study2$coefficients[1,3], 
                    coxph_model_full_bkup$study3$coefficients[1,3],
                    coxph_model_full_bkup$study4$coefficients[1,3],
                    coxph_model_full_bkup$study5$coefficients[1,3],
                    coxph_model_full_bkup$study7$coefficients[1,3],
                    coxph_model_full_bkup$study8$coefficients[1,3],
                    coxph_model_full_bkup$study9$coefficients[1,3],
                    coxph_model_full$study10$coefficients[1,3],
                    coxph_model_full_bkup$study11$coefficients[1,3],
                    coxph_model_full_bkup$study12$coefficients[1,3],
                    coxph_model_full_bkup$study13$coefficients[1,3],
                    coxph_model_full_bkup$study14$coefficients[1,3],
                    coxph_model_full_bkup$study15$coefficients[1,3],
                    coxph_model_full_bkup$study16$coefficients[1,3]
    )
    
    
    meta_model <- metafor::rma(input_logHR, sei = input_se, method = 'REML')
    # summary(meta_model)
    
    
# call forest plot

# TODO: add bigger font for HR for studies
    #       https://www.metafor-project.org/doku.php/plots 
    #       https://www.rdocumentation.org/packages/metafor/versions/2.4-0/topics/forest.rma
    #      use slab vector of labels
    #       https://www.metafor-project.org/doku.php/plots:forest_plot 
    #   https://www.rdocumentation.org/packages/metafor/versions/2.4-0/topics/forest.rma 
    metafor::forest.rma(x = meta_model,
                        digits = 4, # 6 decimal places round
                        at = c(0.992, 0.996, 1, 1.004, 1.008),   # ticks for hazard ratio at these places
                        # at = c(0.996, 1, 1.004, 1.008),   # ticks for hazard ratio at these places
                        slab = c('France', 'Italy', 'Spain', 'UK', 'Netherlands', 'Germany', 'Sweden', 'Denmark', 'WHI', 'CARDIA', 'Golestan', 'MESA', 'PRHHP', 'MEC', 'ARIC')) #, 'ARIC'))  # , 'PRHHP' Denmark, WHI
    


