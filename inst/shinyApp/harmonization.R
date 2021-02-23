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
ds.quantileMean(x = 'D_curated$PA', datasources = connections[9]) # WHI

ds.asFactor(input.var.name = 'D_curated$PA', newobj.name = 'D_curated$PA', forced.factor.levels = c(0, 3.5, 10, 41.5), datasources = connections[9])

ds.class(x = 'D_curated$PA', datasources = connections[9])

ds.summary(x = 'D_curated$PA', datasources = connections[9])

ds.ls()
