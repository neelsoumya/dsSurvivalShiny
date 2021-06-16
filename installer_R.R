###############################################
# code to install all DataSHIELD R packages
#     and packages for GUI
###############################################

install.packages('devtools')
library(devtools)
devtools::install_github('https://github.com/datashield/dsBaseClient')

devtools::install_github('https://github.com/datashield/dsBase')
library(dsBase)

devtools::install_github('https://github.com/datashield/opal')
library(opal)

devtools::install_github('https://github.com/datashield/dsBaseClient', force = TRUE)
library(dsBaseClient)

devtools::install_github('https://github.com/datashield/dsStatsClient')#, force = TRUE)

library(dsStatsClient)

devtools::install_github('https://github.com/datashield/dsGraphicsClient')#, force = TRUE)

library(dsGraphicsClient)

devtools::install_github('https://github.com/datashield/dsModellingClient')#, force = TRUE)

#library(dsModellingClient)
#devtools::install_github('https://github.com/datashield/DSOpal')#, force = TRUE)

install.packages('shiny')
install.packages('rmarkdown')
install.packages('knitr')
install.packages('tinytex')
install.packages('metafor')
install.packages('shiny')
install.packages('shinyjs')

devtools::install_github(repo = 'https://github.com/lifecycle-project/ds-helper/', ref = 'completecases' )
library(dsHelper)

devtools::install_github('https://github.com/neelsoumya/dsSurvivalShiny')#, force = TRUE)
library(dsSurvivalShiny)
install.packages('simstudy')


url <- "https://cran.r-project.org/src/contrib/Archive/JohnsonDistribution/JohnsonDistribution_0.24.tar.gz"
pkgFile <- "JohnsonDistribution_0.24.tar.gz"
download.file(url = url, destfile = pkgFile)

install.packages(pkgs=pkgFile, type="source", repos=NULL)

unlink(pkgFile)

library(devtools)
install_github("bonorico/gcipdr")
