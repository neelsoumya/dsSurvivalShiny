#######################################
# Script to test harmonization code
#
#######################################

###############
# load library
###############
library(ggplot2)

##############
# load data
##############
df_alswh <- read.csv('ALSWH_young_sample_diab_only_17_05.csv', 
                     sep = ',', header = TRUE, 
                     stringsAsFactors=FALSE)#, na.strings="..") # ,strip.white = TRUE)



# // $('y8q24b_age').value() - $('y3age').value()
# 
# // code and logic from MESA FUP_OBJ
# // temp logic: find first of CASE_OBJ which is positive, mid point of age between follow-up periods. 
# // e.g. if y6 then mid point of age between y5 and y6. then take away baseline age to get follow up time 
# 
# // null checks for y4q12c and other variables
# //  if null then set to 2, default values are 1 (case) or 0 (non-case)

# for all rows
for (i_temp_counter in c(1:nrow(df_alswh) ))
{
  
  y4q12c = df_alswh$y4q12c[i_temp_counter] #  $('y4q12c');
  
  if ( is.na(y4q12c) )
  {
    y4q12c = 2
  }
  
  #cat(y4q12c)
  #cat('\n')
  
  
  y5q12b = df_alswh$y5q12b[i_temp_counter] #  $('y4q12c');
  
  if ( is.na(y5q12b) )
  {
    y5q12b = 2
  }
  
  
  y6q12b = df_alswh$y6q12b[i_temp_counter] #  $('y4q12c');
  
  if ( is.na(y6q12b) )
  {
    y6q12b = 2
  }
  
  
  
  y7q24b = df_alswh$y7q24b[i_temp_counter] #  $('y4q12c');
  
  if ( is.na(y7q24b) )
  {
    y7q24b = 2
  }
  
  
  y8q24b = df_alswh$y8q24b[i_temp_counter] #  $('y4q12c');
  
  if ( is.na(y8q24b) )
  {
    y8q24b = 2
  }
  
  
  
#} # end for loop on last line

#y4q12c
#y5q12b
#y6q12b
#y7q24b
#y8q24b

# y5q12b = $('y5q12b');
# if ( y5q12b.isNull() )
# {
#   y5q12b = 2;
# }
# else
# {
#   y5q12b = $('y5q12b').value();
# }

# y6q12b = $('y6q12b');
# if ( y6q12b.isNull() )
# {
#   y6q12b = 2;
# }
# else
# {
#   y6q12b = $('y6q12b').value();
# }

# y7q24b = $('y7q24b');
# if ( y7q24b.isNull() )
# {
#   y7q24b = 2;
# }
# else
# {
#   y7q24b = $('y7q24b').value();
# }

# y8q24b = $('y8q24b');
# if ( y8q24b.isNull() )
# {
#   y8q24b = 2;
# }
# else
# {
#   y8q24b = $('y8q24b').value();
# }


# list of FUP_OBJ so it can be plotted
list_FUP_OBJ = NULL



# // set flag and dteremine yi_aage
# // if all null or missing exit and set FUP_OBJ = NULL
# // ensure R  script checks and removes FUP_OBJ  is Null
# // generate synthetic data, test R code and test Javascript code 

# // if all of these variables  are null then return FUP_OBJ is null
# if ( y4q12c == 2 && y5q12b == 2 &&  y6q12b == 2 && y7q24b == 2 && y8q24b == 2 )
if ( y4q12c == 2 & y5q12b == 2 &  y6q12b == 2 & y7q24b == 2 & y8q24b == 2 )
{
  FUP_OBJ = NULL # null;
}else
{
  
  # if ( $('y4q12c') == 1 || $('y5q12b') == 1 ||  $('y6q12b') == 1 || $('y7q24b') == 1 || $('y8q24b') == 1  )
  #  if ( y4q12c == 1 || y5q12b == 1 ||  y6q12b == 1 || y7q24b == 1 || y8q24b == 1  )
  if ( y4q12c == 1 || y5q12b == 1 ||  y6q12b == 1 || y7q24b == 1 || y8q24b == 1  )
  {
    CASE_OBJ = 1
  }else
  {
    CASE_OBJ = 0  
  }
  
  
  #// if any of (y4q12c, y5q12b, y6q12b, y7q24b, y8Q24b) = 1 ~ 1; else ~0
  
  #// "if any of (y1q15a, y2q12Ab, y2q12Bb, y3q12b, y4q12b, y5q12a, y6q12a, y7q24a, y8Q24a) = 1, type 1; 
  #// if any if (y2q12Ac, y2q12Bc, y3q12c, y4q12c, y5q12b, y6q12b, y7q24b, y8Q24b) = 1, type 2."
  
  
  #// "if CASE_OBJ = 1,
  #//    if y8q24b_age -  y3age > 0 ~ y8q24b_age -  y3age; 
  #//    else
  #//    find the earlist yi(i = 4,5,6,7 or 8), FUP_OBJ = yiage - 1.5 - y3age
  #//else
  #// find the last survy yk(k=4, 5, 6, or 7), FUP_OBJ = (age at mid point between yk and yk+1) - y3age; if k =8, FUP_OBJ = y8age - y3age"
  
  
  #// edge cases: all of the y4age, y5age, y6age, y7age and y8age need a check for null. 
  #// I also wonder if there could be a scenario: a participant didn't attend any of the follow-ups. 
  #// If so, all the y4age to y8age would be null, 
  #// then would be assigned to 0. In this case, ykage -y3age would return a negative value. So it would be better to check this
  
  ##################################
  # do null check for all variables
  ##################################
  
  y3age = df_alswh$y3age[i_temp_counter] # $('y3age');
  if (  is.null(y3age) | is.na(y3age) ) #  y3age.isNull() )
  {
    y3age = 0
  }
  #else
  #{
  #  y3age = y3age.value();
  #}
  
  y4age = df_alswh$y4age[i_temp_counter] # $('y3age');
  if (  is.null(y4age) | is.na(y4age) ) #  y3age.isNull() )
  {
    y4age = 0
  }
  
  y5age = df_alswh$y5age[i_temp_counter] # $('y3age');
  if (  is.null(y5age) | is.na(y5age) ) #  y3age.isNull() )
  {
    y5age = 0
  }
  
  y6age = df_alswh$y6age[i_temp_counter] # $('y3age');
  if (  is.null(y6age) | is.na(y6age) ) #  y3age.isNull() )
  {
    y6age = 0
  }
  
  y7age = df_alswh$y7age[i_temp_counter] # $('y3age');
  if (  is.null(y7age) | is.na(y7age) ) #  y3age.isNull() )
  {
    y7age = 0
  }
  
  y8age = df_alswh$y8age[i_temp_counter] # $('y3age');
  if (  is.null(y8age) | is.na(y8age) ) #  y3age.isNull() )
  {
    y8age = 0
  }
  
  y8q24b_age = df_alswh$y8q24b_age[i_temp_counter]
  if ( is.null(y8q24b_age) | is.na(y8q24b_age) )
  {
    y8q24b_age = 0
  }
  #else
  #{
  #  y8q24b_age = df_alswh$y8q24b_age[i_temp_counter]
  #}
  
  
  
  if (CASE_OBJ == 1)
  {
    #//if ( $('y8q24b_age').value() - $('y3age').value() > 0)
    if ( y8q24b_age - y3age > 0 )
    {
      FUP_OBJ = y8q24b_age - y3age# ; #// $('y3age').value();  
    
      # append to list so it can be plotted
      list_FUP_OBJ = cbind(list_FUP_OBJ, FUP_OBJ)
      
      cat(FUP_OBJ)
      
    }else
    {
      
      yiage = min(y4age, y5age, y6age, y7age, y8age)
      
      FUP_OBJ = yiage - 1.5 - y3age# ; //$('y3age').value();
      
      # FUP_OBJ = 1
      
      # append to list so it can be plotted
      list_FUP_OBJ = cbind(list_FUP_OBJ, FUP_OBJ)
      
      
    }
    
  }else
  {
    #// find the last survy yk(k=4, 5, 6, or 7)
    #// FUP_OBJ = (age at mid point between yk and yk+1) - y3age; if k =8, FUP_OBJ = y8age - y3age"
    #// edge cases: e.g. what happends if there ar enulls, y4 exists but no y5 or vice versa?
    
    #     yk_age = Math.max( y4age, y5age, y6age, y7age, y8age ); // $('y8age').value()
    
    yk_age = max(y4age, y5age, y6age, y7age, y8age )
    
    # //  find midpoint age
    #// y_midpoint_age = yk_age;
    
    #// y_midpoint_age = ( y7age + y4age )/2.0; 
    
    
    FUP_OBJ = yk_age - y3age# ; #//  $('y3age').value();  
    
    # FUP_OBJ = 1
    
    # append to list so it can be plotted
    list_FUP_OBJ = cbind(list_FUP_OBJ, FUP_OBJ)
    
    
    #//FUP_OBJ = y_midpoint_age - $('y3age').value();
    
    
    
  }
  
  
}

} # end for loop for all patients


########################
# plot distribution
########################
hist(as.numeric(list_FUP_OBJ))
# qplot(list_FUP_OBJ, geom = 'histogram') # data = df, 

gp2 <- ggplot(as.data.frame(as.numeric(list_FUP_OBJ)), aes(x=FUP_OBJ)) # ,fill=histology
gp2 <- gp2 + geom_histogram()#(alpha=0.5)
gp2 <- gp2 + xlab("Metagene score") + ylab("Number of patients")
gp2

