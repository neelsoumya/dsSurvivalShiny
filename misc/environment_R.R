
############################
# Simple script to load 
#   survival data and show 
#   environments
############################

# 1. Information on environments
#     http://adv-r.had.co.nz/Environments.html
# 2. Python Lambda functions
#     removes all occurrences of 0
#     list( filter( lambda a: a!=0, list_numbers ) )
# 3. https://stackoverflow.com/questions/1157106/remove-all-occurrences-of-a-value-from-a-list
#     x = [1,2,3,2,2,2,3,4]
#     list(filter(lambda a: a != 2, x))
# 4. In R
#     https://lukesingham.com/anonymous-functions-in-r-python/
df <- data.frame(
                col1 = c("element1", "element2"),
                col2 = c("element1", "element2"), 
                stringsAsFactors = FALSE
                )

lapply(df, function(x) paste(x, "doing stuff"))


#################
# Load libraries
#################
library(survival)

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

##################################################
# more advanced options like subset, control
##################################################
cox_int <- survival::coxph(formula = s ~ AGE,
                           data = file,
                           subset = age.60 > 7,
                           control = survival::coxph.control(eps = 0.00001, iter.max = 1000)
                           )

# NOTE: default is
survival::coxph.control()

# ERROR
cox_int <- survival::coxph(formula = s ~ AGE,
                           data = file,
                           subset = age.60 > 7,
                           control = "survival::coxph.control(eps = 0.00001, iter.max = 1000)"
                          )

cox_int <- survival::coxph(formula = s ~ AGE,
                           data = file,
                           subset = age.60 > 7,
                           control = as.symbol("survival::coxph.control(eps = 0.00001, iter.max = 1000)")
                          )

cox_int <- survival::coxph(formula = s ~ AGE,
                           data = file,
                           subset = age.60 > 7,
                           control = quote("survival::coxph.control(eps = 0.00001, iter.max = 1000)")
                          )

cox_int <- survival::coxph(formula = s ~ AGE,
                           data = file,
                           subset = age.60 > 7,
                           control = `"survival::coxph.control(eps = 0.00001, iter.max = 1000)"`
                          )


cox_int <- survival::coxph(formula = s ~ AGE,
                           data = file,
                           subset = age.60 > 7,
                           control = "\survival::coxph.control(eps = 0.00001, iter.max = 1000)"
                          )


cox_int <- survival::coxph(formula = s ~ AGE,
                           data = file,
                           subset = age.60 > 7,
                           control = eval(parse(text = "survival::coxph.control(eps = 0.00001, iter.max = 1000)"))
                          )

cox_int <- survival::coxph(formula = s ~ AGE,
                           data = file,
                           subset = age.60 > 7,
                           control = eval(parse(text = "survival::coxph.control()"))
                          )

eval(parse(text = "survival::coxph.control(eps = 0.00001, iter.max = 1000)"))


eval(parse(text = "fn_ptr = survival::coxph.control(eps = 0.00001, iter.max = 1000)"))

cox_int <- survival::coxph(formula = s ~ AGE,
                           data = file,
                           subset = age.60 > 7,
                           control = fn_ptr
                          )
