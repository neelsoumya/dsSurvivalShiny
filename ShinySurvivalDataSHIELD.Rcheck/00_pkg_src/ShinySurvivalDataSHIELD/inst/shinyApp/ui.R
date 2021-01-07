###########################################################################
# This is the user-interface definition of a Shiny web application. 
#     You can run the application by clicking 'Run App' above.
#
# GUI for survival models
#
############################################################################

##################
# Load libraries
##################
library(shiny)
library(shinyjs)
library(shinyBS)

##############################################################
# Define UI for application
##############################################################

shinyUI(fluidPage(
  
  # Application title
  titlePanel("Survival Model Meta-analysis Graphical User Interface"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
       sliderInput("e_intake_min",
                   "Energy intake minimum:",
                   min = 100,
                   max = 5000,
                   value = 800)
       ,
       
       sliderInput("e_intake_max",
                   "Energy intake maximum:",
                   min = 100,
                   max = 5000,
                   value = 4200)
       ,
       
       shinyjs::useShinyjs()
       ,
       actionButton("compute", "Recompute")
       ,
      
       selectInput("target",
                   label = "Choose target or response variable",
                   choices = list("CASE_OBJ", "CASE_OBJ_SELF"),
                   selected = "CASE_OBJ"
                  )
       ,
       
       selectInput("exposure",
                   label = "Choose exposure",
                   choices = list("redmeat", "poultry", "offals", "redmeattotal"),
                   selected = "redmeat"
                   )
       ,
       
       # selectInput("model",
       #             label = "Choose model",
       #             choices = list("Model1", "Model2"),
       #             selected = "Model1"
       #            )
       # ,
       
       checkboxInput("checkbox_model_save",
                      label = "Save model on server?",
                      value = FALSE
                    )
        ,
      
       checkboxInput("checkbox_model_remove",
                      label = "Delete model on server?",
                      value = FALSE
                    )
        ,
      
        shinyjs::useShinyjs()
        ,
        actionButton("report", "Generate data summary report")
        ,
      
      
        checkboxInput("checkbox_bmi",
                      label = "BMI",
                      value = FALSE
                    )
        ,
       
        checkboxInput("checkbox_age",
                      label = "AGE",
                      value = TRUE
                    )
        ,
       
        checkboxInput("checkbox_gender",
                      label = "GENDER",
                      value = TRUE
                    )
        ,      
        checkboxInput("checkbox_physical_activity",
                      label = "PHYSICAL ACTIVITY",
                      value = FALSE
                      )
        ,
        checkboxInput("checkbox_smoking",
                      label = "SMOKING",
                      value = FALSE
                      )
        ,
        checkboxInput("checkbox_energy_intake",
                     label = "ENERGY INTAKE",
                     value = FALSE
                    )
        ,
      
        shinyjs::useShinyjs()
        ,
        actionButton("batch_report", "Log model statistics")
        ,         
        shinyjs::useShinyjs()
        ,
        actionButton("model_report", "Generate model report")
        ,
      
        shinyjs::useShinyjs()
        ,
        actionButton("mega_batch_log", "Generate batch log")
        ,
        # add popover with alert that is going to take a long time
        #      https://stackoverflow.com/questions/46648471/popover-tooltip-for-a-text-in-shiny-app-using-shinybs
        #      https://www.rdocumentation.org/packages/shinyBS/versions/0.61/topics/bsPopover
        shinyBS::bsPopover(id = "mega_batch_log", 
                           title = "Please note that this operation can take a long time.",
                           placement = "bottom",
                           trigger = "hover"
                          )
       
    ),
    
    
    
    # Show a plot of the generated distribution
    mainPanel(
       plotOutput("distPlot")
    )
    
  )
  
))
