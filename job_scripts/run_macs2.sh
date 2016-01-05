#!/bin/bash
#$ -o macs2."$JOB_ID".out
#$ -e macs2."$JOB_ID".error


echo TREAT_BAM is $TREAT_BAM
echo INPUT_BAM is $INPUT_BAM
echo OUTDIR is $OUTDIR
echo PREFIX is $PREFIX
echo macs2 on $(basename $TREAT_BAM):$(basename $INPUT_BAM)

if [ -z $TREAT_BAM ]
then
	TREAT_BAM=$1
fi
if [ -z $INPUT_BAM ]
then
	INPUT_BAM=$2
fi
if [ -z $OUTDIR ]
then
	OUTDIR=$3
fi
if [ -z $PREFIX ]
then
	PREFIX=$4
fi

#model is disabled for testing on small files!
#macs2 callpeak -t $TREAT_BAM -c $INPUT_BAM -g hs --outdir $OUTDIR -n "$PREFIX"_narrow -s 101 --bw 375 -p 1e-2 --bdg --to-large

macs2 callpeak -t $TREAT_BAM -c $INPUT_BAM -g hs --outdir $OUTDIR -n "$PREFIX"_narrow_nomodel -s 101 --bw 375 -p 1e-2 --bdg --to-large --nomodel --extsize 147

