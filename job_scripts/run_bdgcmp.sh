#!/usr/bin/bash
#required inputs:
#TREATMENT
#CONTROL
#METHOD
WD=$WD
t=$TREATMENT
c=$CONTROL
met=$METHOD
if [ -z $t ]
	then t=$1
	c=$2
	met=$3
fi
echo treat file - $t
echo control file - $c
echo method - $met
OUT=$WD/$(basename $t)
OUT="${OUT/_treat_pileup.bdg/}"_"$met".bdg
macs2 bdgcmp -t $t -c $c -m $met -o $OUT
