#-------------------------------------------------------------------------------
# Copyright (c) 2019-2020 University of Newcastle upon Tyne. All rights reserved.
#
# This program and the accompanying materials
# are made available under the terms of the GNU Public License v3.0.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#-------------------------------------------------------------------------------

#
# Set up
#

context("ds.retStr::smk::setup")

connect.studies.dataset.cnsim(list("LAB_TSC"))

test_that("setup", {
    ds_expect_variables(c("D"))
})

#
# Tests
#

context("ds.retStr::smk")
test_that("simple ds.retStr call", {
    dim.res <- ds.retStr('thisishello')
    
    expect_match(as.character(dim.res), 'hello', ignore.case = TRUE)

})

context("ds.retStr::smk")
test_that("simple call", {
    dim.res <- ds.retStr('1234')
    
    expect_match(as.character(dim.res), '123', ignore.case = TRUE)
})

context("ds.retStr::smk")
test_that("simple call with special character", {
    dim.res <- ds.retStr('$')
    
    expect_match(as.character(dim.res), '$', ignore.case = TRUE)
})

# testthat::expect_error( as.character(ds.retStr('1==1') ) )
              
context("ds.retStr::smk")
test_that("simple error, SQL injection", {
    
    expect_error( as.character(ds.retStr('1==1') ) )
})

context("ds.retStr::smk")
test_that("space in string error", {
    
    expect_error( as.character(ds.retStr('he llo') ) )
})


#
# Done
#

context("ds.dim::smk::shutdown")

test_that("shutdown", {
    ds_expect_variables(c("D"))
})

disconnect.studies.dataset.cnsim()

context("ds.dim::smk::done")
