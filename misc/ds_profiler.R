# Script for profiling DataSHIELD
# https://bookdown.org/rdpeng/rprogdatascience/profiling-r-code.html#the-r-profiler
# https://support.rstudio.com/hc/en-us/articles/218221837-Profiling-with-RStudio 


####################
# load libraries
####################
Rprof()
library(profvis)


profvis({
  
builder <- DSI::newDSLoginBuilder()
#builder$append(server = "study1", url = "https://opal-demo.obiba.org/",
#               user = "administrator", password = "password",
#               table = "CNSIM.CNSIM2", driver = "OpalDriver")
builder$append(server = "study2", url = "http://192.168.56.100:8080/",
               user = "administrator", password = "datashield_test&",
               table = "CNSIM.CNSIM2", driver = "OpalDriver")

logindata <- builder$build()
connections <- DSI::datashield.login(logins = logindata, assign = TRUE, symbol = "D")

ds.ls()

# disconnect from server
DSI::datashield.logout(conns = connections)
  
  })


# ds.profiler()

# profilerDS()

# return that print like ds.ls()

# do security checks

# log with logger
# https://rdocumentation.org/packages/logger/versions/0.2.0
# https://daroczig.github.io/logger/articles/Intro.html

# more comments by Yannick
# As the server side environment can disappear (R server crash due to memory shortage), any profiling (or logging) information should have been sent outside of the R server session workspace for latter retrieval. Apparently for logging, logger is the recommended package. It supports custom log appenders, i.e. the log message can be sent to an app instead of being simply printed on the stdout.

# Then one option would be to define an API for logging info in the DataSHIELD context (obviously in the DS middleware, Opal) and for making this log available to end user (if not disclosive!).
