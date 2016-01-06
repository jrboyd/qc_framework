#!/bin/bash
#$ -o macs2."$JOB_ID".out
#$ -e macs2."$JOB_ID".error


echo TREAT_BAM is $TREAT_BAM
echo INPUT_BAM is $INPUT_BAM
echo OUTDIR is $OUTDIR
echo PREFIX is $PREFIX
echo PVAL is $PVAL
echo macs2 on $(basename $TREAT_BAM):$(basename $INPUT_BAM)

if [ -z $TREAT_BAM ] || [ ! -e $TREAT_BAM ]
then
	echo TREAT_BAM $TREAT_BAM not found! stop
	exit 1
fi
if [ -z $INPUT_BAM ] || [ ! -e $INPUT_BAM ]
then
	echo INPUT_BAM $INPUT_BAM not found! stop
	exit 1
fi
if [ -z $OUTDIR ] || [ ! -d $OUTDIR ]
then
	echo OUTDIR $OUTDIR not found! stop
	exit 1
fi
if [ -z $PREFIX ]
then
	echo PREFIX $PREFIX missing! stop
	exit 1
fi
if [ -z $PVAL ]
then
	echo PVAL $PVAL missing! stop
	exit 1
fi

#model is disabled for testing on small files!
#macs2 callpeak -t $TREAT_BAM -c $INPUT_BAM -g hs --outdir $OUTDIR -n "$PREFIX" -s 101 --bw 375 -p $PVAL --bdg --to-large

macs2 callpeak -t $TREAT_BAM -c $INPUT_BAM -g hs --outdir $OUTDIR -n "$PREFIX" -s 101 --bw 375 -p $PVAL --bdg --to-large --nomodel --extsize 147

