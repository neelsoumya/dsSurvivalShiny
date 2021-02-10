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

###########################
# load data in DataSHIELD
###########################
# source('~/soumya_mrc/mrc_cam_project/projects/meat_project/redmeat_survival_ownVM.R')
source('redmeat_survival_ownVM.R')
# load generic functions
source('utilities.R')
# TODO: comment line 24 and uncomment below have prentice scheme and correct name of Surv object
# calling script to make connections and load data and create Surv objects
# source('init.R')

###########################
# Global variables
###########################
global_state = 0 # variable to store state of compute button (on load)

################################################################
# Define server logic required to draw forest plots
################################################################
shinyServer(function(input, output) {
   
  output$distPlot <- renderPlot({
    
    
    # plot and show survival models
    # source('survival_model_meat_ownVM.R')
    #       add toggle since being incremented each time clicked
    #       https://cran.r-project.org/web/packages/shinyjs/vignettes/shinyjs-example.html 
    #       https://stackoverflow.com/questions/45880437/r-shiny-use-onclick-option-of-actionbutton-on-the-server-side 
  
    global_state_temp = input$compute
    if (global_state_temp > global_state)
    {
            # overwrite global with new value of button
            # TODO: use state or ds.assign() and instead of if use ds.Boole
            global_state = global_state_temp 
    }   
     
    #shinyjs::onclick("compute", cat("helloclikcbutton")) 
    
    # function to ack on click button for compute
    shinyjs::onclick("compute", fn_recompute(input_e_min = as.numeric(input$e_intake_min), 
                                             input_e_max = as.numeric(input$e_intake_max))
                    )
    
    # function to act on data report button 
    shinyjs::onclick("report", rmarkdown::render('log_data_summary.rmd', 'pdf_document')  
                    ) 
    # fn_generate_report()
     
    # function to act on model report button
    shinyjs::onclick("model_report", rmarkdown::render('log_model_summary.rmd', 'pdf_document')  
                    ) 
    
    # function for batch report
    shinyjs::onclick("batch_report", fn_generate_batch_report(param_bmi = input$checkbox_bmi,
                                                              param_age = input$checkbox_age,
                                                              param_gender = input$checkbox_gender,
                                                              param_exposure = input$exposure
                                                             )
                    )
    
    # function for mega batch log
    shinyjs::onclick("mega_batch_log", fn_big_batch()) 
     
    # generic_statistical_modelling(str_outcome_variable = 'surv_object_prentice',
    #                                                              list_covariate = c('BMI', 'AGEBASE', 'GENDER'),
    #                                                               list_covariate_D = c('BMI','AGE_BASE','SEX'),
    #                                                               list_exposure = 'POULTRY',
    #                                                               str_model_type = 'survival'
    #                                                              )
    #                 )
    
    ################################### 
    # all individual meat exposures
    ###################################

    # create formula based on checkboxes 
    str_temp_formula_dynamic = 'surv_object_prentice ~ ' 
    
    ################################################################## 
    # get exposures first
    #    NOTE: only one expposure at a time so no  + sign in front 
    ################################################################## 
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
        str_temp_formula_dynamic = paste0(str_temp_formula_dynamic, ' PA ')
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
     
    #if (input$exposure == 'redmeat')
    #{
    #        dsBaseClient::ds.coxph.SLMA(formula = 'surv_object_prentice ~ AGEBASE + GENDER + REDMEAT + PA + SMOKING + EDUCATION + E_INTAKE',
    #                            combine_with_metafor = TRUE)
    #}   
    
    #if (input$exposure == 'poultry')
    #{
    #  dsBaseClient::ds.coxph.SLMA(formula = 'surv_object_prentice ~ AGEBASE + GENDER + POULTRY + PA + SMOKING + EDUCATION + E_INTAKE',
    #                              combine_with_metafor = TRUE)
    #}   
    
    #if (input$exposure == 'redmeattotal')
    #{
    #  dsBaseClient::ds.coxph.SLMA(formula = 'surv_object_prentice ~ AGEBASE + GENDER + REDMEATTOTAL + PA + SMOKING + EDUCATION + E_INTAKE',
    #                              combine_with_metafor = TRUE)
    #}   
    
    #if (input$exposure == 'offals')
    #{
    #  dsBaseClient::ds.coxph.SLMA(formula = 'surv_object_prentice ~ AGEBASE + GENDER + OFFALS + PA + SMOKING + EDUCATION + E_INTAKE',
    #                              combine_with_metafor = TRUE)
    #}   
    
    
    
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
                    coxph_model_full$study13$coefficients[1,2]
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
                    coxph_model_full$study13$coefficients[1,3]
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
                        at = c(0.996, 1, 1.004, 1.008),   # ticks for hazard ratio at these places
                        slab = c('France', 'Italy', 'Spain', 'UK', 'Netherlands', 'Germany', 'Sweden', 'Denmark', 'WHI', 'CARDIA', 'Golestan', 'MESA'))  # Denmark, WHI
    
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
 
    
    
    # save workspace if checkbox is checked
    if (input$checkbox_model_save == TRUE)
    {
        DSI::dsSaveWorkspace(conn = connections, name = 'gui_survival_models')
    }
     
    # delete workspace
    if (input$checkbox_model_remove == TRUE)
    {
        DSI::dsRmWorkspace(conn = connections, name = 'gui_survival_models')
    }
     
    
  })
  
})
