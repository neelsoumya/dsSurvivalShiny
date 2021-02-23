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

# ds.asFactor(

ds.ls()
