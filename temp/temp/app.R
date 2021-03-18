############################################################
# Plot pretty forest plots 
# this is donwstream of stage1.R and stage2.R
#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Old Faithful Geyser Data"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput("bins",
                        "Number of bins:",
                        min = 1,
                        max = 50,
                        value = 30)
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("distPlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$distPlot <- renderPlot({
        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        
        # this is donwstream of stage1.R and stage2.R
        # load the Rdata file that is saved in stage2.R
        
        load(file = '../../inst/shinyApp/survival_meat_interact_mec_downstream_final.RData')
        metafor::forest.rma(x = meta_model,
                            digits = 4, # 6 decimal places round
                            # at = c(0.999, 1, 1.006),   # ticks for hazard ratio at these places
                            # at = c(0.996, 1, 1.004, 1.008),   # ticks for hazard ratio at these places
                            slab = c('France', 'Italy', 'Spain', 'UK', 'Netherlands', 'Germany', 'Sweden', 'Denmark', 'WHI', 'CARDIA', 'Golestan', 'MESA', 'PRHHP', 'MEC', 'ARIC')) #, 'ARIC'))  # , 'PRHHP' Denmark, WHI
        
        # hist(x, breaks = bins, col = 'darkgray', border = 'white')
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
