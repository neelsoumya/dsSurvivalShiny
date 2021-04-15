###################################
#
# Simple script to load 
# survival data and show 
# survival functionality
#
###################################

####################
# Load libraries
####################
library(survival)
library(RANN)

##############
# Load data
##############
file <- read.csv(file = "expand_no_missing_study1.csv", header = TRUE, stringsAsFactors = FALSE)

SURVTIME  <- as.numeric(file$survtime)
EVENT     <- as.numeric(file$cens)
STARTTIME <- as.numeric(file$starttime)
ENDTIME   <- as.numeric(file$endtime)

AGE <- as.numeric(file$age.60)

# build survival object
s <- survival::Surv(time=SURVTIME,event=EVENT)
# survival::coxph(formula = "survival::Surv(time=SURVTIME,event=EVENT) ~ file$age.60", data = file)



##################
# Plotting
##################
my_surv = Surv(SURVTIME, EVENT)
no_noise <- survfit(Surv(SURVTIME, EVENT) ~ 1)
survfit_model_variable <- survfit(Surv(SURVTIME, EVENT) ~ 1)

# original survival curve
plot(survfit_model_variable)

#noise = 0.0003 # 0.03 0.26
noise = 0.03
percentage <- noise



##########################################
# Approach 1: probabilistic anonymization
#     add noise before plotting
#
# add noise to:
# surv (i.e. proportion surviving)
# time (times at which events occur, ie when the proportion changes)
# this is for the y axis
# and for time on x axis
##########################################
for ( i_temp_counter_inner in c(2:length(survfit_model_variable$surv)) )
{
  # current value, upper, lower at this index
  value_temp <- survfit_model_variable$surv[i_temp_counter_inner]
  upper_temp <- survfit_model_variable$upper[i_temp_counter_inner]
  lower_temp <- survfit_model_variable$lower[i_temp_counter_inner]
  
  # previous value, upper, lower
  prev_value_temp <- survfit_model_variable$surv[i_temp_counter_inner - 1]
  prev_upper_temp <- survfit_model_variable$upper[i_temp_counter_inner - 1]
  prev_lower_temp <- survfit_model_variable$lower[i_temp_counter_inner - 1]
  
  # add some noise 
  # TODO: make noise a percentage of previous OR current value
  # delta_noise <- abs(stats::rnorm(n = 1, mean = value_temp, sd = percentage * value_temp))
  delta_noise <- stats::rnorm(n = 1, mean = 0, sd = percentage)
  
  # SUBTRACT this noise from the PREVIOUS VALUE if it does not cause problems with monotonicity
  
  value_noise = value_temp - delta_noise
  upper_noise = upper_temp - delta_noise
  lower_noise = lower_temp - delta_noise
  
  if (prev_value_temp >= value_noise)
  {
    survfit_model_variable$surv[i_temp_counter_inner] <- value_noise
    survfit_model_variable$upper[i_temp_counter_inner] <- upper_noise
    survfit_model_variable$lower[i_temp_counter_inner] <- lower_noise
  }
  else
  {
    survfit_model_variable$surv[i_temp_counter_inner] = prev_value_temp
    survfit_model_variable$upper[i_temp_counter_inner] = prev_upper_temp
    survfit_model_variable$lower[i_temp_counter_inner] = prev_lower_temp
  }
  
  survfit_model_variable$mono[i_temp_counter_inner] = prev_value_temp - survfit_model_variable$surv[i_temp_counter_inner]
  
  #new noise for x axis
  #needs more work, also monotonic
  delta_noise <- stats::rnorm(n = 1, mean = 0, sd = percentage)
  survfit_model_variable$time[i_temp_counter_inner] <- survfit_model_variable$time[i_temp_counter_inner] - delta_noise
  
}

# modified survival curve
plot(survfit_model_variable)





##########################################
# Approach 2: deterministic anonymization
#
##########################################

# TODO: Demetris code here
