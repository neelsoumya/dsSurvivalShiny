###########################################
# Script to prototype survival functions
#    by Tom Bishop 
#
#    Updates by Soumya Banerjee
#
###########################################

###################
# Load libraries
###################
library(survival)
library(tidyverse)

###################
# Load data
###################
data(lung)
expand_no = read_csv(file = "~/expand_no_missing.csv")

my_surv = Surv(lung$time, lung$status)
no_noise <- survfit(Surv(time, status) ~ 1, data = lung)
survfit_model_variable <- survfit(Surv(time, status) ~ 1, data = lung)

#noise = 0.0003 # 0.03 0.26
noise = 0.03
percentage <- noise

##########################################
# Approach 1: add noise before plotting
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

plot(survfit_model_variable)



bigger_percentage = 30

######################################
# Approach 2: add noise to raw data 
#  add noise to raw data
######################################

lung$time_noise = stats::rnorm(n = length(lung$time), mean = lung$time, sd = bigger_percentage)

survfit_model_early <- survfit(Surv(time_noise, status) ~ 1, data = lung)
plot(survfit_model_early)





###################################################################
# Approach 3: add noise to raw data + add noise before plotting
###################################################################
survfit_model_both = survfit_model_early

for ( i_temp_counter_inner in c(2:length(survfit_model_both$surv)) )
{
  # current value, upper, lower at this index
  value_temp <- survfit_model_both$surv[i_temp_counter_inner]
  upper_temp <- survfit_model_both$upper[i_temp_counter_inner]
  lower_temp <- survfit_model_both$lower[i_temp_counter_inner]
  
  # previous value, upper, lower
  prev_value_temp <- survfit_model_both$surv[i_temp_counter_inner - 1]
  prev_upper_temp <- survfit_model_both$upper[i_temp_counter_inner - 1]
  prev_lower_temp <- survfit_model_both$lower[i_temp_counter_inner - 1]
  
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
    survfit_model_both$surv[i_temp_counter_inner] <- value_noise
    survfit_model_both$upper[i_temp_counter_inner] <- upper_noise
    survfit_model_both$lower[i_temp_counter_inner] <- lower_noise
  }
  else
  {
    survfit_model_both$surv[i_temp_counter_inner] = prev_value_temp
    survfit_model_both$upper[i_temp_counter_inner] = prev_upper_temp
    survfit_model_both$lower[i_temp_counter_inner] = prev_lower_temp
  }
  
  survfit_model_both$mono[i_temp_counter_inner] = prev_value_temp - survfit_model_both$surv[i_temp_counter_inner]
  
  #new noise for x axis
  #needs more work, also monotonic
  delta_noise <- stats::rnorm(n = 1, mean = 0, sd = percentage)
  survfit_model_both$time[i_temp_counter_inner] <- survfit_model_both$time[i_temp_counter_inner] - delta_noise
  
}

plot(survfit_model_both)

# TODO: cloglog plots
plot(survfit_model_both, fun = 'cloglog')
graphics::plot(survfit_model_both, fun = 'cloglog')

