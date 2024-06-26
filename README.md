<!--# dsDataDocumentation -->


## Introduction

This is a package with miscellaneous tools, a set of computational tools and a graphical user interface (GUI) for privacy preserving federated survival model meta-analysis using the DataSHIELD platform. The primary function is to enable data and model documentation.


* inst/shinyApp

    * folder with all R files
    

* installer_R.R and installer_unix.sh

    * installation scripts in R and UNIX
    
* RUN.R

    * script to start shiny server
    
    * R --no-save < RUN.R
    
* synthetic_data_generator.R

    * script to generate synthetic data
    
    * R --no-save < synthetic_data_generator.R

* build_man_test.R

    * script to build manuals and test code (testing script)
    
    * R --no-save < build_man_test.R  

* build_man_test_git_add.sh

    * shell script to build manuals, test code and commit to git all documentation

    * ./build_man_test_git_add.sh
   
   
* vignettes

   * tutorials and vignettes

* misc

   * miscellaneous scripts for basic scripts and tutorials
   
   
* NAMESPACE, DESCRIPTION

   * files for package
   
* Dockerfile, shiny-server.conf, shiny-server.sh

   * files for Docker and vagrant
   
   * adapted from
   
      * https://github.com/isglobal-brge/ShinyDataSHIELD
   
   * see the following for more on how to run and compile
   
      * https://blog.zenika.com/2014/10/07/setting-up-a-development-environment-using-docker-and-vagrant/
      
      * https://data2knowledge.atlassian.net/wiki/spaces/DSDEV/pages/367656962/Vagrant
      
      * https://data2knowledge.atlassian.net/wiki/spaces/DSDEV/pages/12943447/Build+your+own+DataSHIELD+VMs
      
      * https://docs.github.com/en/packages/guides/configuring-docker-for-use-with-github-packages
      
* Link to demo website 

     * Demo GUI shiny server
 
        * forthcoming
	
     * Demo VM running on Cambridge server
     
        * Forthcoming 	
     
     * Opal server
      
     	* https://opal-demo.obiba.org/ui/index.html#!admin 
	
    
     * Synthetic data
     
        * Forthcoming 

## Usage

Install ShinySurvivalDataSHIELD package, load package and run
	
```R
	
		install.packages('devtools')
		
		library(devtools)
		
		devtools::install_github('neelsoumya/dsSurvivalShiny')
			
		library(dsSurvivalShiny)
	
		dsSurvivalShiny::app()
		
		OR
		
		R --no-save < installer_R.R
		
		R --no-save < RUN.R
	
```

* Screenshot of graphical user interface

	![Screenshot of GUI](screenshot.png)
		


* Presentations

   * presentation folder

## Citation

   * Forthcoming

## Contact
 
   * Soumya Banerjee
     
   * https://github.com/neelsoumya/dsSurvivalShiny

   * sb2333@cam.ac.uk
   

* Acknowledgements

   * DataSHIELD technical team
   



### What is this repository for? ###

* Quick summary

    * GUI for data and model documentation and meta-analysis of federated survival models



### How do I get set up? ###

* Summary of installation

     
    
  ```R
	
		install.packages('devtools')
		
		library(devtools)
		
		devtools::install_github('neelsoumya/dsSurvivalShiny')
			
		library(dsSurvivalShiny)
	
		dsSurvivalShiny::app()
		
		OR
		
		R --no-save < installer_R.R
		
		R --no-save < RUN.R
	
  ```

* Configuration

* How to run tests

    * R --no-save < build_man_test.R

* Deployment instructions



### Usage ###


```R
R --no-save < RUN.R
```	


   
### Who do I talk to? ###

* Soumya Banerjee

* https://sites.google.com/site/neelsoumya/Home

* sb2333@cam.ac.uk

* DataSHIELD

    * DataSHIELD is a platform that enables the non-disclosive analysis of distributed sensitive data 

    * https://github.com/datashield



[![License](https://img.shields.io/badge/license-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.html)
