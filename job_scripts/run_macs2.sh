#!/bin/bash
#$ -o macs2."$JOB_ID".out
#$ -e macs2."$JOB_ID".error


echo TREAT_BAM is $TREAT_BAM
echo INPUT_BAM is $INPUT_BAM
echo OUTDIR is $OUTDIR
echo PREFIX is $PREFIX
echo macs2 on $(basename $TREAT_BAM):$(basename $INPUT_BAM) >> $OUTDIR/$PREFIX".tmp"
