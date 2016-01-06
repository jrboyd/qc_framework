#!/usr/bin/bash
#$ -o bdg2bw."$JOB_ID".out
#$ -e bdg2bw."$JOB_ID".error


#required inputs:
if [ -z $inputBedGraph ]
then
	inputBedGraph=$1
	inputChromSizes=$2
	outputBigWig=$3
fi
echo input - $inputBedGraph
echo chrSizes - $inputChromSizes
echo output - $outputBigWig
bedGraphToBigWig $inputBedGraph $inputChromSizes $outputBigWig
