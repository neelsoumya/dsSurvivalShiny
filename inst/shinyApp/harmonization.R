############################################
# Script to perform data harmonization
#
############################################

##################
# Load library
##################
# require('DSI')
# require('DSOpal')
# require('dsBaseClient')


#####################################
# Harmonize PA (physical activity)
#####################################

# get quantiles for PA for WHI
ds.quantileMean(x = 'D_curated$PA', datasources = connections[9]) # WHI

# assign these quantiles to a temp variable and make it a factor
ds.asFactor(input.var.name = 'D_curated$PA', newobj.name = 'PA_harmonized', forced.factor.levels = c(0, 3.5, 10, 41.5), datasources = connections[9])

# assign this temp variable (which is now a factor) to original data frame for WHI study
# ds.assign(toAssign = 'PA_harmonized', newobj = 'D_curated$PA', datasources = connections[9])

# ds.dataFrame(x = 'PA_harmonized', newobj = 'D_PA2', datasources = connections[9])

# ds.dataFrame(x = 'PA_harmonized', newobj = 'D_curated$PA2', datasources = connections[9])

ds.dataFrame(x = c("D_curated", "PA_harmonized"), newobj = 'D_curated', datasources = connections[9])

# use cbind
# https://rdrr.io/github/datashield/dsBaseClient/man/ds.cbind.html

# check if it is a factor
# ds.class(x = 'D_curated$PA', datasources = connections[9])
# ds.class(x = 'PA_harmonized', datasources = connections[9])
# ds.summary(x = 'D_curated$PA', datasources = connections[9])

# ds.class(x = 'D_PA2', datasources = connections[9])
# ds.summary(x = 'D_PA2', datasources = connections[9])
ds.summary(x = 'D_curated$PA_harmonized', datasources = connections[9])

# ds.class(x = 'D_curated$PA2', datasources = connections[9])
# ds.summary(x = 'D_curated$PA2', datasources = connections[9])

ds.ls()
