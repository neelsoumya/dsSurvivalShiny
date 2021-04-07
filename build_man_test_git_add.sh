#!/bin/bash

R --no-save < build_man_test.R


cp ../dsSurvivalShiny_1.0.pdf  man/


git add man/dsSurvivalShiny_10.0.pdf

git commit -m "adding documentation" 

git push
