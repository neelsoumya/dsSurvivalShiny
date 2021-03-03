###########################################
# Script to perform data harmonization
#
###########################################

##################
# Load library
##################
# require('DSI')
# require('DSOpal')
# require('dsBaseClient')


#####################################
# Harmonize PA (physical activity)
#####################################

# count from studies 9 through 15
for (i_counter_study_temp in c(9))
{
            
            cat("Harmonizing data for study: ")
            cat(i_counter_study_temp)
            cat("\n")
            
            # get quantiles for PA for WHI
            ds.quantileMean(x = 'D_curated$PA', datasources = connections[i_counter_study_temp]) # WHI

            # assign these quantiles to a temp variable and make it a factor
            ds.asFactor(input.var.name = 'D_curated$PA', 
                        newobj.name = 'PA_harmonized', 
                        forced.factor.levels = c(0, 3.5, 10, 41.5), 
                        datasources = connections[i_counter_study_temp])

            # assign this temp variable (which is now a factor) to original data frame for WHI study
            # ds.assign(toAssign = 'PA_harmonized', newobj = 'D_curated$PA', datasources = connections[9])

            # ds.dataFrame(x = 'PA_harmonized', newobj = 'D_PA2', datasources = connections[9])

            # ds.dataFrame(x = 'PA_harmonized', newobj = 'D_curated$PA2', datasources = connections[9])

            ds.dataFrame(x = c("D_curated", "PA_harmonized"), 
                         newobj = 'D_curated', 
                         datasources = connections[i_counter_study_temp])


            # use cbind
            # https://rdrr.io/github/datashield/dsBaseClient/man/ds.cbind.html

}


# get quantiles for PA for WHI
ds.quantileMean(x = 'D_curated$PA', datasources = connections[10]) # WHI

# assign these quantiles to a temp variable and make it a factor
ds.asFactor(input.var.name = 'D_curated$PA', 
            newobj.name = 'PA_harmonized', 
            forced.factor.levels = c(2.0, 4.5, 9.0, 36.0), 
            datasources = connections[10])

ds.dataFrame(x = c("D_curated", "PA_harmonized"), 
             newobj = 'D_curated', 
             datasources = connections[10])



# get quantiles for PA for WHI
ds.quantileMean(x = 'D_curated$PA', datasources = connections[12]) # WHI

# assign these quantiles to a temp variable and make it a factor
ds.asFactor(input.var.name = 'D_curated$PA', 
            newobj.name = 'PA_harmonized', 
            forced.factor.levels = c(480.0, 870.0, 1470.0, 3780.0), 
            datasources = connections[12])

ds.dataFrame(x = c("D_curated", "PA_harmonized"), 
             newobj = 'D_curated', 
             datasources = connections[12])



# get quantiles for PA for WHI
ds.quantileMean(x = 'D_curated$PA', datasources = connections[13]) # WHI

# assign these quantiles to a temp variable and make it a factor
ds.asFactor(input.var.name = 'D_curated$PA', 
            newobj.name = 'PA_harmonized', 
            forced.factor.levels = c(0.0, 2.0, 4.0, 5.0), 
            datasources = connections[13])

ds.dataFrame(x = c("D_curated", "PA_harmonized"), 
             newobj = 'D_curated', 
             datasources = connections[13])



# get quantiles for PA for WHI
ds.quantileMean(x = 'D_curated$PA', datasources = connections[14]) # WHI

# assign these quantiles to a temp variable and make it a factor
ds.asFactor(input.var.name = 'D_curated$PA', 
            newobj.name = 'PA_harmonized', 
            forced.factor.levels = c(1.18, 1.43, 1.78, 1.94), 
            datasources = connections[14])

ds.dataFrame(x = c("D_curated", "PA_harmonized"), 
             newobj = 'D_curated', 
             datasources = connections[14])


# get quantiles for PA for WHI
ds.quantileMean(x = 'D_curated$PA', datasources = connections[15]) # WHI

# assign these quantiles to a temp variable and make it a factor
ds.asFactor(input.var.name = 'D_curated$PA', 
            newobj.name = 'PA_harmonized', 
            forced.factor.levels = c(1.0, 2.0, 3.0, 4.0), 
            datasources = connections[15])

ds.dataFrame(x = c("D_curated", "PA_harmonized"), 
             newobj = 'D_curated', 
             datasources = connections[15])



# check if it is a factor
# ds.class(x = 'D_curated$PA', datasources = connections[9])
# ds.class(x = 'PA_harmonized', datasources = connections[9])
# ds.summary(x = 'D_curated$PA', datasources = connections[9])

# ds.class(x = 'D_PA2', datasources = connections[9])
# ds.summary(x = 'D_PA2', datasources = connections[9])
ds.summary(x = 'D_curated$PA_harmonized', datasources = connections[9])
ds.summary(x = 'PA_harmonized', datasources = connections[9])

# ds.class(x = 'D_curated$PA2', datasources = connections[9])
# ds.summary(x = 'D_curated$PA2', datasources = connections[9])

# use ds.assign for studies 1 to 9 for PA_harmonized
#    these studies are already harmonized
ds.assign(toAssign = 'D_curated$PA',
          newobj = 'PA_harmonized',
          datasources = connections[1:8])
ds.assign(toAssign = 'D_curated$PA',
          newobj = 'PA_harmonized',
          datasources = connections[11])
# TODO: do for other studies MEC etc.
# TODO: in server.R change PA to PA_harmonized

ds.ls()
