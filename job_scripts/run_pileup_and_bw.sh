#!/bin/bash
#$ -o pileup_and_bw."$JOB_ID".out
#$ -e pileup_and_bw."$JOB_ID".error

#BAM is bam file to be converted to bw
#CHRM_SIZES is appropriate chrom sizes file for genome

echo BAM is $BAM
echo CHRM_SIZES is $CHRM_SIZES

if [ -z $BAM ]
then
	echo no BAM arg
	exit 1
fi
if [ -z $CHRM_SIZES ]
then
	echo no CHRM_SIZES
	exit 1
fi

BDG=${BAM/.bam/.bdg}
BW=${BAM/.bam/.bw}
if [ -f $BW ]; then
	echo pileup file $BW exists, skipping pileup and bw conversion for $BAM
else
	macs2 pileup -i $BAM -o $BDG
	bedGraphToBigWig $BDG $CHRM_SIZES $BW
fi

