#' Launch the application dsSurvivalShiny
#' @export

app <- function()
{
      # app for shiny server
      
      #####################
      # load libraries
      #####################
      library(shiny)
      library(metafor)
      library(rmarkdown)
      library(shinyjs)
      library(shinyBS)
      library(dsHelper)
      library(tinytex)
      library(knitr)
      
      #####################################################################
      # run
      #     https://shiny.rstudio.com/reference/shiny/1.4.0/runApp.html
      #####################################################################
      shiny::runApp(system.file('shinyApp', package = 'dsSurvivalShiny'))

}

# TODO: shiny extensions
#      https://shiny.rstudio.com/articles/progress.html
