#####################################################################
# This is the server logic of a Shiny web application. 
#     You can run the 
#     application by clicking 'Run App' above.
#
# GUI for survival models
# 
#####################################################################

#########################
# Load libraries
#########################
library(shiny)
library(metafor)
library(dsHelper)
library(knitr)
library(rmarkdown)
library(tinytex)
library(dsBase)
library(dsBaseClient)
require('DSI')
require('DSOpal')

    ################################### 
    # all individual meat exposures
    ###################################

    # create formula based on checkboxes 
    str_temp_formula_dynamic = 'surv_object_prentice ~ ' 
    
    ################################################################## 
    # get exposures first
    #    NOTE: only one expposure at a time so no  + sign in front 
    ################################################################## 
    
    input <- NULL
    input$exposure = 'redmeat'
    input$checkbox_age = TRUE
    input$checkbox_gender = TRUE
    input$checkbox_bmi = TRUE
    input$checkbox_physical_activity = FALSE
    input$checkbox_smoking = TRUE
    input$checkbox_energy_intake = TRUE
    
    
    if (input$exposure == 'redmeat')
    {
        str_temp_formula_dynamic = paste0(str_temp_formula_dynamic, ' REDMEAT ')
    }   
    
    if (input$exposure == 'poultry')
    {
        str_temp_formula_dynamic = paste0(str_temp_formula_dynamic, ' POULTRY ')
    }   
     
    if (input$exposure == 'redmeattotal')
    {
        str_temp_formula_dynamic = paste0(str_temp_formula_dynamic, ' REDMEATTOTAL ')
    }   
     
    if (input$exposure == 'offals')
    {
        str_temp_formula_dynamic = paste0(str_temp_formula_dynamic, ' OFFALS ')
    }   
     
    #################### 
    # get covariates 
    #################### 
    if (input$checkbox_age == TRUE)
    {
        str_temp_formula_dynamic = paste0(str_temp_formula_dynamic, ' + ')
        str_temp_formula_dynamic = paste0(str_temp_formula_dynamic, 'AGEBASE ')   
    }
     
    if (input$checkbox_gender == TRUE)
    {
        str_temp_formula_dynamic = paste0(str_temp_formula_dynamic, ' + ')
        str_temp_formula_dynamic = paste0(str_temp_formula_dynamic, ' GENDER ') 
    }  
                                          
    if (input$checkbox_bmi == TRUE)
    {
        str_temp_formula_dynamic = paste0(str_temp_formula_dynamic, ' + ')
        str_temp_formula_dynamic = paste0(str_temp_formula_dynamic, ' BMI ')
    }   
     
    if (input$checkbox_physical_activity == TRUE)
    {
        str_temp_formula_dynamic = paste0(str_temp_formula_dynamic, ' + ')
        str_temp_formula_dynamic = paste0(str_temp_formula_dynamic, ' PA ')   # changed from PA to PA_harmonized
    }
     
    if (input$checkbox_smoking == TRUE)
    {
        str_temp_formula_dynamic = paste0(str_temp_formula_dynamic, ' + ')
        str_temp_formula_dynamic = paste0(str_temp_formula_dynamic, ' SMOKING ')
    }
     
    if (input$checkbox_energy_intake == TRUE)
    {
        str_temp_formula_dynamic = paste0(str_temp_formula_dynamic, ' + ')
        str_temp_formula_dynamic = paste0(str_temp_formula_dynamic, ' E_INTAKE ')
    }   
     
    cat(str_temp_formula_dynamic) 
     
    # call coxphSLMA()
    coxph_model_full <- dsBaseClient::ds.coxph.SLMA(formula = str_temp_formula_dynamic,
                                                    combine_with_metafor = FALSE)
     
    
    summary(coxph_model_full)
    
    load(file = 'survival_meat_interact_mec.RData')
    
    
   # list of hazard ratios for FIRST parameter over all 7 studies 
    input_logHR = c(coxph_model_full$study1$coefficients[1,2], 
                    coxph_model_full$study2$coefficients[1,2], 
                    coxph_model_full$study3$coefficients[1,2],
                    coxph_model_full$study4$coefficients[1,2],
                    coxph_model_full$study5$coefficients[1,2],
                    coxph_model_full$study7$coefficients[1,2],
                    coxph_model_full$study8$coefficients[1,2],
                    coxph_model_full$study9$coefficients[1,2],
                    coxph_model_full$study10$coefficients[1,2],
                    coxph_model_full$study11$coefficients[1,2],
                    coxph_model_full$study12$coefficients[1,2],
                    coxph_model_full$study13$coefficients[1,2],
                    coxph_model_full$study14$coefficients[1,2],
                    coxph_model_full$study15$coefficients[1,2],
                    coxph_model_full$study16$coefficients[1,2]
    )
    
    # list of standard errors for third parameter over all 7 studies 
    input_se    = c(coxph_model_full$study1$coefficients[1,3], 
                    coxph_model_full$study2$coefficients[1,3], 
                    coxph_model_full$study3$coefficients[1,3],
                    coxph_model_full$study4$coefficients[1,3],
                    coxph_model_full$study5$coefficients[1,3],
                    coxph_model_full$study7$coefficients[1,3],
                    coxph_model_full$study8$coefficients[1,3],
                    coxph_model_full$study9$coefficients[1,3],
                    coxph_model_full$study10$coefficients[1,3],
                    coxph_model_full$study11$coefficients[1,3],
                    coxph_model_full$study12$coefficients[1,3],
                    coxph_model_full$study13$coefficients[1,3],
                    coxph_model_full$study14$coefficients[1,3],
                    coxph_model_full$study15$coefficients[1,3],
                    coxph_model_full$study16$coefficients[1,3]
    )
    
    
    meta_model <- metafor::rma(input_logHR, sei = input_se, method = 'REML')
    summary(meta_model)
    
    # TODO: add bigger font for HR for studies
    #       https://www.metafor-project.org/doku.php/plots 
    #       https://www.rdocumentation.org/packages/metafor/versions/2.4-0/topics/forest.rma
    #      use slab vector of labels
    #       https://www.metafor-project.org/doku.php/plots:forest_plot 
    #   https://www.rdocumentation.org/packages/metafor/versions/2.4-0/topics/forest.rma 
    metafor::forest.rma(x = meta_model,
                        digits = 6, # 6 decimal places round
                        at = c(0.992, 0.996, 1, 1.004, 1.008),   # ticks for hazard ratio at these places
                        # at = c(0.996, 1, 1.004, 1.008),   # ticks for hazard ratio at these places
                        slab = c('France', 'Italy', 'Spain', 'UK', 'Netherlands', 'Germany', 'Sweden', 'Denmark', 'WHI', 'CARDIA', 'Golestan', 'MESA', 'PRHHP', 'MEC', 'ARIC')) #, 'ARIC'))  # , 'PRHHP' Denmark, WHI
    
    ############################################# 
    # TODO: save plot
    ############################################# 
    # pdf(file = 'forest_plot_survival.pdf') 
     
    # metafor::forest.rma(x = meta_model)
    
    # save forest plot
    # dev.off()
     
     
    ######################################################################################################
    # Logging functionality
    #    1. summary statistics
    #    2. convergence issues
    #    3. missingness of data
    #    4. table view using ds.helper
    #           https://github.com/lifecycle-project/ds-helper/blob/completecases/R/get-stats.R
    #    5. which studies have what covariates missing
    #           https://github.com/lifecycle-project/ds-helper/blob/completecases/R/class-discrepancy.R 
    ###################################################################################################### 
     
    # save model summary
    # inspired by: 
    # https://stackoverflow.com/questions/30371516/how-to-save-summarylm-to-a-file/30371944
    # str_log_filename = paste0('log_', '') 
    ## str_log_filename = paste0(str_log_filename, '_')  
    # str_log_filename = paste0(str_log_filename, input$exposure)
    # str_log_filename = paste0(str_log_filename, '.csv') 
    # sink(str_log_filename)
    # cat('BEGIN LOG \n')
    # cat('Parameters: \n')
    # cat('Model : \n') 
    # cat('Survival model ', '\n') 
    # cat('Exposure \n')
    # cat(input$exposure, '\n\n') 
    # cat("Summary of meta-analyzed model .... \n") 
    # print(meta_model)
    # sink() 
    
    # now print Cox model
    # sink(str_log_filename, append = TRUE)
    # cat("Summary of Cox model ..... \n") 
    # print(coxph_model_full) 
    # sink() 
    
    # now print summary of data for all covariates
    #sink(str_log_filename, append = TRUE)
    #cat("Summary of covariates and missingness ..... \n") 
    #cat("Redmeat covariate  \n") 
    #print(dsBaseClient::ds.summary(x = 'D$REDMEAT'))
    #cat("Summary statistics .... \n") 
    #print(dsHelper::dh.getStats(conns = connections, df = 'D', vars = c('REDMEAT','OFFALS','POULTRY','REDMEATTOTAL') ) ) 
    #cat("Degree of missingness in various studies ..... \n") 
    #print(dsHelper::dh.anyData(conns = connections,  df = 'D', vars = c('REDMEAT','OFFALS','POULTRY','REDMEATTOTAL') ) )
    #print('END LOG \n')
    #sink()      
     
    # generate a pretty report
    # rmarkdown::render('log_generate.rmd', 'pdf_document') 
     
    #write.table(df_model_summary_log, file = str_log_filename, 
    #            row.names = FALSE, quote = FALSE, 
    #            append = FALSE, sep = ',')
     

   
    
    
    # TODO: create another tab(s) for
    #          plots, save plots, diagnostics, heatmap, 
    #          correlation with parameters, survival curves, load and save workspace
    #          https://github.com/isglobal-brge/ShinyDataSHIELD 
    # TODO: save forest plot 
    # save report
    #       https://shiny.gerinberg.com/async/ 
    # TODO: show log file with summary in a different tab along with diagnostics 
    # https://www.rdocumentation.org/packages/base/versions/3.6.2/topics/sink 
    # dialog box 
    # file.show(str_log_filename)
 
    
    
#######################################################
# save model output and logging information to disk
#######################################################
save.image(file = 'survival_meat_interact_mec_downstream.RData')
    
