#!/bin/sh

# Installation steps for R and dependencies for devtools on Unix

sudo apt-get install r-base

sudo apt install  libssl-dev
sudo apt install  libgit2-dev
sudo apt install  libxml2-utils
sudo apt install  libxml2-dev
sudo apt-get install libcurl4-openssl-dev

sudo apt-get install git


# optionally update R to latest version later
#   https://askubuntu.com/questions/1237102/problem-installing-r-4-0-on-ubuntu-18-04
# sudo apt remove r-base
# sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
# sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran40/'
# sudo apt update
# sudo apt install r-base

# Install R Studio
sudo apt-get install gdebi-core
wget https://download2.rstudio.org/server/xenial/amd64/rstudio-server-1.3.1093-amd64.deb
sudo gdebi rstudio-server-1.3.1093-amd64.deb



