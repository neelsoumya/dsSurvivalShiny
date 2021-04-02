###########################################
# Script to build manuals and test
#
# Usage:
#   R --no-save < build_man_test.R
#
###########################################

###################
# load libraries
###################
library(devtools)
library(testthat)

##################
# build manuals
##################
devtools::build_manual()

##################
# Testing
##################
devtools::test()

gc()

