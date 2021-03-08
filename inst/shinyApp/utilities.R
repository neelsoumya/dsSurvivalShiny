###############################################
# File with utility and helper functions
#     for the survival model GUI
# 
###############################################

fn_recompute <- function(input_e_min, 
                         input_e_max)
{
  
             ####################################################################
             # function to recompute, load all data and perform data filtering   
             #################################################################### 
  
             ####################
             # Load libraries
             ####################
             require(dsBase)
             require(dsBaseClient)

             #############################################
             # data filtering
             # 	exclusion criterion
             #		1. no previous diabetes
             #		2. no type 1 diabetes
             #	inclusion criterion
             #		1. age >= 18 years
             ##############################################
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
                                             V1.name = 'D$AGE_BASE', 
                                             V2.name = '18', 
                                             Boolean.operator = '>=', 
                                             newobj = 'E_temp2',
                                             datasources = connections)	

            cat("The number of patients after removing those with age >= 18 ...")
            dsBaseClient::ds.length(x = 'E_temp2$SEX', 
                                    type = 'split',
                                    datasources = connections)

            dsBaseClient::ds.dataFrameSubset(df.name = 'E_temp2', 
                                             V1.name = 'D$TYPE_DIAB', 
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
                                             V2.name = as.character(input_e_max), # '4200' 
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
                                             V2.name = as.character(input_e_min), # '800' 
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
            #ds.assign(toAssign = "(i_status_out_cohort*0.00001) + ((1-i_status_out_cohort)*SURVTIME_SELF)",
            #          newobj = "PRENTICETIME_SELF",
            #          datasources = connections
            #          )




            #####################################################
            # create survival object and then call coxphSLMA()
            #####################################################
            # call coxph server side
            # client side function is here:
            # 	https://github.com/neelsoumya/dsBaseClient/blob/absolute_newbie_client/R/ds.coxph.SLMA.R
            # server side function is here:
            # 	https://github.com/neelsoumya/dsBase/blob/absolute_newbie/R/coxphSLMADS.R

            # 1. use constructed surv object in coxph
            # dsBaseClient::ds.Surv(time='SURVTIME', event = 'EVENT', objectname='surv_object')

            dsBaseClient::ds.Surv(time='PRENTICETIME', event = 'EVENT', objectname='surv_object_prentice') 

            # dsBaseClient::ds.Surv(time='PRENTICETIME_SELF', event = 'EVENT_SELF', objectname='surv_object_prentice_self') 

  
}


# fn_generate_report <- function()
# {
#    
#    # generate a pretty report
#    require(rmarkdown)
#    require(knitr)
#    require(tinytex)
#    rmarkdown::render('log_generate.rmd', 'pdf_document')
# }


generic_statistical_modelling <- function(str_outcome_variable,
                                          list_covariate,
                                          list_covariate_D,
                                          list_exposure,
                                          str_model_type
                                          )

{
    #####################################################################################################
    # function to take in a list of covariates, exposure and outcome
    #   model type (like survival models) and outcome variable
    #   and 
    #   1. dynamically construct a formula
    #   2. call the appropriate function e.g. coxphSLMA for survival models
    #   3. have additional logic to modify the formula and call for those studies
    #         which have some covariates missing.
    #
    # str_outcome_variable character string of outcome variable in model
    # list_covariate list of character strings in covariates
    # list_covariate_D list of character strings in covariates available in data frame D in same order 
    #   as list_covariate
    # str_model_type character string of model type. Currently takes 'survival'.
    #
    ######################################################################################################  
  
    require(dsBase)
    require(dsBaseClient)
    require(dsHelper)
    
    
    # modify formula to make sure that covariates exist in these studies
    #     construct modified formula for each study for as many covariates that exist
    #     call dh.anyData()
    #     https://github.com/lifecycle-project/ds-helper/blob/completecases/R/any-data.R
    dt_missingness <- dsHelper::dh.anyData(conns = connections,  
                                           df = 'D', 
                                           vars = list_covariate_D) 
    # c('BMI','AGE_BASE','SEX')
    
    
    # TODO: 1. remove later modify some elements to be false
    # dt_missingness$variable[1]
    # dt_missingness[1,2] <- FALSE
    
    # initialize a list to store all models
    list_models <- NULL
  
    # find out if any element of this data frame has a FALSE
    i_temp_missing = which(dt_missingness == FALSE)
    # if no FALSE, then all covariates exist on all studies
    # just construct formula and call coxph() in standard way
    if (length(i_temp_missing) == 0)
    {
          
              # Normal call functionality
              #########################################
              # construct call
              #########################################
              str_formula = paste0(str_outcome_variable, ' ~ ')
              str_formula = paste0(str_formula, list_exposure)
    
              # for each covariate do a for loop and append
              for (temp_covariate in list_covariate)
              {
                   str_formula = paste0(str_formula, ' + ')  
                   str_formula = paste0(str_formula, temp_covariate)
              }
  
              cat(str_formula, '\n')
  
              ########################################
              # call appropriate modeling function
              ########################################
              if (str_model_type == 'survival')
              {  
                     # call coxphSLMA() for survival models
                     model <- dsBaseClient::ds.coxph.SLMA(formula = str_formula, 
                                                          combine_with_metafor = TRUE,
                                                          datasources = connections)
                
                     # construct return parameter
                     list_models <- model
              }
           
      
              # return function call
              return(list_models)  
    } 
        
        
    ######################################################### 
    # otherwise go through each element of the data frame
    #########################################################
  
    # for loop each study
    # NOTE: will start from 2 since first column us variable
    for (i_temp_col in c(2:ncol(dt_missingness)))
    {
        # does this study have all covariates? flag for this now initialize
        b_temp_flag_all_covar_exist = TRUE
      
        # initalize a temporary variable to store connection to this study i.e. i_temp_col
        cn_temp_connection = connections[i_temp_col - 1]
        
        # go through each covariate
        for (i_temp_row in c(1:nrow(dt_missingness)))
        {
            # start constructing formula 
            str_formula = paste0(str_outcome_variable, ' ~ ')
            str_formula = paste0(str_formula, list_exposure)
          
            if (dt_missingness[i_temp_row, i_temp_col] == TRUE)
            {
                # if this element is true then add to formula
                # do this only if all columns for this row are TRUE
                str_formula = paste0(str_formula, ' + ')  
                # what is the covariate for this element?
                # this refers to the variable name in D, since dh.anyData()
                #   refers to D. However for survival models due to survival object
                #   we cannot refer to D. So we dereference to list_covariate
                #   which must have variables in same order as list_covariate_D
                # temp_covariate = dt_missingness$variable[i_temp_row]
                temp_covariate = list_covariate[i_temp_row]
                str_formula = paste0(str_formula, temp_covariate)
                cat(str_formula, "\n")
            }  
            else
            {
                # if FALSE, then skip for this study
                # set flag to FALSE since covariate missing
                b_temp_flag_all_covar_exist = FALSE
            }  
        }
      
        cat(str_formula, "\n")
        # return (str_formula)
        # have gone through all covariates for this study
        # do all covariates exist for this study?
        if (b_temp_flag_all_covar_exist == TRUE)
        {
              
              # Normal call functionality
              #########################################
              # construct call
              #########################################
              str_formula = paste0(str_outcome_variable, ' ~ ')
              str_formula = paste0(str_formula, list_exposure)
    
              # for each covariate do a for loop and append
              for (temp_covariate in list_covariate)
              {
                   str_formula = paste0(str_formula, ' + ')  
                   str_formula = paste0(str_formula, temp_covariate)
              }
  
              cat(str_formula, '\n')
  
              ########################################
              # call appropriate modeling function
              ########################################
              if (str_model_type == 'survival')
              {  
                     # call coxphSLMA() for survival models
                     # with connection to current connection for this study
                     model <- dsBaseClient::ds.coxph.SLMA(formula = str_formula, 
                                                          datasources = cn_temp_connection)
                
                     # append to list of all models
                     list_models <- list(list_models, model)
              }
 
          
        }
        else
        {
                # some covariates missing for this study
                # call model with those which do exist
                if (str_model_type == 'survival')
                {
                      # call coxphSLMA() for survival models
                      # with connection to current connection for this study
                      # TODO: fix dataName = 'D'
                      # get another list as parameter in D list_covariate_D
                      # in same order as list_covariate
                      # then whichever are missing in that whittle that down
                      # cat(str_formula, "new formula in D \n")
                      model <- dsBaseClient::ds.coxph.SLMA(formula = str_formula,
                                                           datasources = cn_temp_connection)#,
                                                           #dataName = 'D')
                  
                     # append to list of all models
                     list_models <- list(list_models, model)
                }  
        }  
      
      
    }  
  
    
    return(list_models)
  

}


fn_generate_batch_report <- function(param_bmi,
                                     param_age,
                                     param_gender,
                                     param_exposure)
{
    #######################################################
    # function to generate comprehensive batch report
    # Usage: 
    #  fn_generate_batch_report(param_bmi = TRUE, param_gender = TRUE, param_age = TRUE, param_exposure = 'poultry')
    #######################################################
  
    # take exposure from checkboxes
    if (param_exposure == 'redmeat')
    {
         str_exposure = 'REDMEAT'
    }   
    if (param_exposure == 'poultry')
    {
        str_exposure = 'POULTRY'
    }   
    if (param_exposure == 'redmeattotal')
    {
        str_exposure = 'REDMEATTOTAL'
    }   
    if (param_exposure == 'offals')
    {
        str_exposure = 'OFFALS'
    }   
    
    # initialize two lists to store covariates
    #   these will be filled based on checkboxes
    list_input_covariate   = NULL
    list_input_covariate_D = NULL
    
    # construct filename that is to be saved to disk
    str_temp_filename = 'batch_report_'
    if (param_bmi == TRUE)
    {  
        str_temp_filename = paste0(str_temp_filename, 'BMI')
        str_temp_filename = paste0(str_temp_filename, '_')
      
        # also construct list to be passed to modelling function
        list_input_covariate   = cbind(list_input_covariate, 'BMI')
        list_input_covariate_D = cbind(list_input_covariate_D, 'BMI')
    } 
    if (param_age == TRUE)
    {  
        str_temp_filename = paste0(str_temp_filename, 'AGE')
        str_temp_filename = paste0(str_temp_filename, '_')
      
        # also append to list to be passed to modelling function
        list_input_covariate   = cbind(list_input_covariate, 'AGEBASE')
        list_input_covariate_D = cbind(list_input_covariate_D, 'AGE_BASE')
    } 
    if (param_gender == TRUE)
    {  
        str_temp_filename = paste0(str_temp_filename, 'GENDER')
        str_temp_filename = paste0(str_temp_filename, '_')
      
        # also append to list to be passed to modelling function
        list_input_covariate   = cbind(list_input_covariate, 'GENDER')
        list_input_covariate_D = cbind(list_input_covariate_D, 'SEX')
    } 
  
    # add exposure to filename
    str_temp_filename = paste0(str_temp_filename, str_exposure)
    str_temp_filename = paste0(str_temp_filename, '_')
    # add current date
    str_temp_filename = paste0(str_temp_filename, as.character(Sys.Date()))
    str_temp_filename = paste0(str_temp_filename, '.txt')
  
  
    ############################ 
    # call modelling function
    ############################
    # if no covariates raise error and return
    # TODO: dialog using shinyalerts
    if (is.null(list_input_covariate))
    {
        cat("The model needs covariates. \n")
        return (NULL)
    }
    if (is.null(list_input_covariate_D))
    {
      cat("The model needs covariates. \n")
      return (NULL)
    }
    str_model_type = 'survival'
    list_models <- generic_statistical_modelling(str_outcome_variable = 'surv_object_prentice',
                                                 list_covariate = list_input_covariate,     # c('BMI', 'AGEBASE', 'GENDER')
                                                 list_covariate_D = list_input_covariate_D, # c('BMI','AGE_BASE','SEX'),
                                                 list_exposure = str_exposure,
                                                 str_model_type = str_model_type
                                                )
  
    ########################
    # save model to disk
    ########################
    fn_save_model_to_disk(str_file_name = str_temp_filename,
                          m_model = list_models)

}


fn_save_model_to_disk <- function(str_file_name,
                                  m_model)
{
    ##############################################################
    # A function to save a model to disk with a specified name
    ##############################################################
  
    sink(str_file_name)
    cat('********************************************************** \n \n')
    cat('BEGIN LOG \n')
    cat('BATCH REPORT AND LOG OF SURVIVAL ANALYSIS \n \n')
    cat('********************************************************** \n \n')
    #cat('Parameters: \n')
    #cat('Model : \n') 
    #cat(input$model, '\n') 
    #cat('Exposure \n')
    #cat(input$exposure, '\n\n') 
    cat("Model .... \n") 
    i_num_models = length(m_model)
    # for each model print separately
    for (i_temp_counter in c(1:i_num_models))
    {
         print(m_model[i_temp_counter])
    }  
    #print(m_model)
    cat('********************************************************** \n   ')
    cat('END LOG \n')
    cat('********************************************************** \n \n')
    sink() 
  
}  



fn_big_batch <- function()
{
      ########################################################
      # function for
      # big batch report with all combinations of covariates
      ########################################################
  
      list_str_exposure = c('OFFALS', 'REDMEAT', 'REDMEATTOTAL', 'POULTRY')
      str_model_type = 'survival'
      list_input_covariate     = c('BMI', 'AGEBASE', 'GENDER', 'E_INTAKE', 'ALCOHOL', 'PA', 'SMOKING')
      list_input_covariate_D   = c('BMI', 'AGE_BASE', 'SEX',   'E_INTAKE', 'ALCOHOL', 'PA', 'SMOKING')
      
      # TODO: exposure (if missing) also account for in main funtion
      # TODO: filename generate for each combination
  
  
  
      # initialize a temporary loop counter
      i_temp_save_counter = 1
        
  
      ###########################################
      # all 7 combinations also
      ###########################################
  
      # list each combination using combn()
      temp_list_covar   = combn(list_input_covariate,   7)
      temp_list_covar_D = combn(list_input_covariate_D, 7)

      # DO NOT initialize the temporary loop counter let it carry forward from previous value
      
      # for each exposure
      for (str_temp_exposure in list_str_exposure)
      {  

              # for all columns in temp_list_covar i.e. all combinations
              for ( i_temp_counter in c(1:dim(temp_list_covar)[2]) )
              {  
                  list_models <- generic_statistical_modelling(str_outcome_variable = 'surv_object_prentice',
                                                               list_covariate   = temp_list_covar[,i_temp_counter], #list_input_covariate,
                                                               list_covariate_D = temp_list_covar_D[,i_temp_counter], # list_input_covariate_D,
                                                               list_exposure = str_temp_exposure, # str_exposure, 
                                                               str_model_type = str_model_type
                                                              )

                  #####################################
                  # save to disk for each combination
                  #####################################
                  # generate unique filename
                  temp_file_name = 'log_' # i_temp_save_counter)
                  # get strings for each exposure and covariate
                  for (temp_str_x in temp_list_covar[,i_temp_counter])
                  {
                        temp_file_name = paste0(temp_file_name, temp_str_x)
                        temp_file_name = paste0(temp_file_name, '_')
                  }  
                  # add string for exposure
                  temp_file_name = paste0(temp_file_name, str_temp_exposure)
                  temp_file_name = paste0(temp_file_name, '_')
                  # add current date
                  temp_file_name = paste0(temp_file_name, as.character(Sys.Date()))
                  temp_file_name = paste0(temp_file_name, '.txt')

                  # save log to disk
                  fn_save_model_to_disk(str_file_name = temp_file_name,
                                        m_model = list_models
                                       )
                
                  # increment loop counter
                  i_temp_save_counter = i_temp_save_counter + 1

              } 
        
      }   
  
  
  
      ###########################################
      # all 6 combinations also
      ###########################################
  
      # list each combination using combn()
      temp_list_covar   = combn(list_input_covariate,   6)
      temp_list_covar_D = combn(list_input_covariate_D, 6)

      # DO NOT initialize the temporary loop counter let it carry forward from previous value
      
      # for each exposure
      for (str_temp_exposure in list_str_exposure)
      {  

              # for all columns in temp_list_covar i.e. all combinations
              for ( i_temp_counter in c(1:dim(temp_list_covar)[2]) )
              {  
                  list_models <- generic_statistical_modelling(str_outcome_variable = 'surv_object_prentice',
                                                               list_covariate   = temp_list_covar[,i_temp_counter], #list_input_covariate,
                                                               list_covariate_D = temp_list_covar_D[,i_temp_counter], # list_input_covariate_D,
                                                               list_exposure = str_temp_exposure, # str_exposure, 
                                                               str_model_type = str_model_type
                                                              )

                  #####################################
                  # save to disk for each combination
                  #####################################
                  # generate unique filename
                  temp_file_name = 'log_' # i_temp_save_counter)
                  # get strings for each exposure and covariate
                  for (temp_str_x in temp_list_covar[,i_temp_counter])
                  {
                        temp_file_name = paste0(temp_file_name, temp_str_x)
                        temp_file_name = paste0(temp_file_name, '_')
                  }  
                  # add string for exposure
                  temp_file_name = paste0(temp_file_name, str_temp_exposure)
                  temp_file_name = paste0(temp_file_name, '_')
                  # add current date
                  temp_file_name = paste0(temp_file_name, as.character(Sys.Date()))
                  temp_file_name = paste0(temp_file_name, '.txt')

                  # save log to disk
                  fn_save_model_to_disk(str_file_name = temp_file_name,
                                        m_model = list_models
                                       )
                
                  # increment loop counter
                  i_temp_save_counter = i_temp_save_counter + 1

              } 
        
      }   



  
  
  
      ###########################################
      # all 5 combinations also
      ###########################################
  
      # list each combination using combn()
      temp_list_covar   = combn(list_input_covariate,   5)
      temp_list_covar_D = combn(list_input_covariate_D, 5)

      # DO NOT initialize the temporary loop counter let it carry forward from previous value
      
      # for each exposure
      for (str_temp_exposure in list_str_exposure)
      {  

              # for all columns in temp_list_covar i.e. all combinations
              for ( i_temp_counter in c(1:dim(temp_list_covar)[2]) )
              {  
                  list_models <- generic_statistical_modelling(str_outcome_variable = 'surv_object_prentice',
                                                               list_covariate   = temp_list_covar[,i_temp_counter], #list_input_covariate,
                                                               list_covariate_D = temp_list_covar_D[,i_temp_counter], # list_input_covariate_D,
                                                               list_exposure = str_temp_exposure, # str_exposure, 
                                                               str_model_type = str_model_type
                                                              )

                  #####################################
                  # save to disk for each combination
                  #####################################
                  # generate unique filename
                  temp_file_name = 'log_' # i_temp_save_counter)
                  # get strings for each exposure and covariate
                  for (temp_str_x in temp_list_covar[,i_temp_counter])
                  {
                        temp_file_name = paste0(temp_file_name, temp_str_x)
                        temp_file_name = paste0(temp_file_name, '_')
                  }  
                  # add string for exposure
                  temp_file_name = paste0(temp_file_name, str_temp_exposure)
                  temp_file_name = paste0(temp_file_name, '_')
                  # add current date
                  temp_file_name = paste0(temp_file_name, as.character(Sys.Date()))
                  temp_file_name = paste0(temp_file_name, '.txt')
                
                  # save log to disk
                  fn_save_model_to_disk(str_file_name = temp_file_name,
                                        m_model = list_models
                                       )
                
                  # increment loop counter
                  i_temp_save_counter = i_temp_save_counter + 1

              } 
        
      }   


  
  
      ###########################################
      # all 4 combinations also
      ###########################################
  
      # list each combination using combn()
      temp_list_covar   = combn(list_input_covariate,   4)
      temp_list_covar_D = combn(list_input_covariate_D, 4)

      # DO NOT initialize the temporary loop counter let it carry forward from previous value
      
      # for each exposure
      for (str_temp_exposure in list_str_exposure)
      {  

              # for all columns in temp_list_covar i.e. all combinations
              for ( i_temp_counter in c(1:dim(temp_list_covar)[2]) )
              {  
                  list_models <- generic_statistical_modelling(str_outcome_variable = 'surv_object_prentice',
                                                               list_covariate   = temp_list_covar[,i_temp_counter], #list_input_covariate,
                                                               list_covariate_D = temp_list_covar_D[,i_temp_counter], # list_input_covariate_D,
                                                               list_exposure = str_temp_exposure, # str_exposure, 
                                                               str_model_type = str_model_type
                                                              )

                  #####################################
                  # save to disk for each combination
                  #####################################
                  # generate unique filename
                  temp_file_name = 'log_' # i_temp_save_counter)
                  # get strings for each exposure and covariate
                  for (temp_str_x in temp_list_covar[,i_temp_counter])
                  {
                        temp_file_name = paste0(temp_file_name, temp_str_x)
                        temp_file_name = paste0(temp_file_name, '_')
                  }  
                  # add string for exposure
                  temp_file_name = paste0(temp_file_name, str_temp_exposure)
                  temp_file_name = paste0(temp_file_name, '_')
                  # add current date
                  temp_file_name = paste0(temp_file_name, as.character(Sys.Date()))
                  temp_file_name = paste0(temp_file_name, '.txt')
                
                  # save log to disk
                  fn_save_model_to_disk(str_file_name = temp_file_name,
                                        m_model = list_models
                                       )
                
                  # increment loop counter
                  i_temp_save_counter = i_temp_save_counter + 1

              } 
        
      }   


  
  
      
      ###########################################
      # all 3 combinations also
      ###########################################
  
      # list each combination using combn()
      temp_list_covar   = combn(list_input_covariate,   3)
      temp_list_covar_D = combn(list_input_covariate_D, 3)

      # DO NOT initialize the temporary loop counter let it carry forward from previous value
      
      # for each exposure
      for (str_temp_exposure in list_str_exposure)
      {  

              # for all columns in temp_list_covar i.e. all combinations
              for ( i_temp_counter in c(1:dim(temp_list_covar)[2]) )
              {  
                  list_models <- generic_statistical_modelling(str_outcome_variable = 'surv_object_prentice',
                                                               list_covariate   = temp_list_covar[,i_temp_counter], #list_input_covariate,
                                                               list_covariate_D = temp_list_covar_D[,i_temp_counter], # list_input_covariate_D,
                                                               list_exposure = str_temp_exposure, # str_exposure, 
                                                               str_model_type = str_model_type
                                                              )

                  #####################################
                  # save to disk for each combination
                  #####################################
                  # generate unique filename
                  temp_file_name = 'log_' # i_temp_save_counter)
                  # get strings for each exposure and covariate
                  for (temp_str_x in temp_list_covar[,i_temp_counter])
                  {
                        temp_file_name = paste0(temp_file_name, temp_str_x)
                        temp_file_name = paste0(temp_file_name, '_')
                  }  
                  # add string for exposure
                  temp_file_name = paste0(temp_file_name, str_temp_exposure)
                  temp_file_name = paste0(temp_file_name, '_')
                  # add current date
                  temp_file_name = paste0(temp_file_name, as.character(Sys.Date()))
                  temp_file_name = paste0(temp_file_name, '.txt')
                
                  # save log to disk
                  fn_save_model_to_disk(str_file_name = temp_file_name,
                                        m_model = list_models
                                       )
                
                  # increment loop counter
                  i_temp_save_counter = i_temp_save_counter + 1

              } 
        
      }   

  
  
      #############################################
      # list each 2 combination using combn()
      #############################################
      temp_list_covar   = combn(list_input_covariate,   2)
      temp_list_covar_D = combn(list_input_covariate_D, 2)

      # DO NOT renitialize loop counter i_temp_save_counter
  
      # for each exposure
      for (str_temp_exposure in list_str_exposure)
      {  

              # for all columns in temp_list_covar i.e. all combinations
              for ( i_temp_counter in c(1:dim(temp_list_covar)[2]) )
              {  
                  list_models <- generic_statistical_modelling(str_outcome_variable = 'surv_object_prentice',
                                                               list_covariate   = temp_list_covar[,i_temp_counter], #list_input_covariate,
                                                               list_covariate_D = temp_list_covar_D[,i_temp_counter], # list_input_covariate_D,
                                                               list_exposure = str_temp_exposure, # str_exposure, 
                                                               str_model_type = str_model_type
                                                              )

                  #####################################
                  # save to disk for each combination
                  #####################################
                  # temp_file_name = paste('log_', i_temp_save_counter)
                  # temp_file_name = paste0(temp_file_name, '.txt')
                  
                  # generate unique filename
                  temp_file_name = 'log_' # i_temp_save_counter)
                  # get strings for each exposure and covariate
                  for (temp_str_x in temp_list_covar[,i_temp_counter])
                  {
                        temp_file_name = paste0(temp_file_name, temp_str_x)
                        temp_file_name = paste0(temp_file_name, '_')
                  }  
                  # add string for exposure
                  temp_file_name = paste0(temp_file_name, str_temp_exposure)
                  temp_file_name = paste0(temp_file_name, '_')
                  # add current date
                  temp_file_name = paste0(temp_file_name, as.character(Sys.Date()))
                  temp_file_name = paste0(temp_file_name, '.txt')
                
                  # save log to disk
                  fn_save_model_to_disk(str_file_name = temp_file_name,
                                        m_model = list_models
                                       )
                
                  # increment loop counter
                  i_temp_save_counter = i_temp_save_counter + 1

              } 
        
      }  
  

  
      # return some value
      return (TRUE)
  
}  
  
