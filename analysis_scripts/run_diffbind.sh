#!/bin/bash
#$ -pe threads 8

if [ -z $SCRIPT ]; then echo SCRIPT missing! quit; exit 1; fi
echo SCRIPT is $SCRIPT
Rscript $SCRIPT
