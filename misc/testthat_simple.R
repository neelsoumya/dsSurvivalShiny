# very simple example using testthat

library(testthat)
library(devtools)

string <- "Testing is fun! hellooooo..."
expect_match(string, "Testing") 
expect_match(string, 'hello', ignore.case = TRUE)
# expect_output(as.character(string), 'hello')
