##########################################
# Script to start shiny server
#   assumes library already installed
#
# Usage:
#   R --no-save < RUN.R
#
##########################################

library(dsSurvivalShiny)

dsSurvivalShiny::app()
