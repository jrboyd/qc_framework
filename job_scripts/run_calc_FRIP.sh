#!/bin/bash
#$ -o calcFRIP."$JOB_ID".out
#$ -e calcFRIP."$JOB_ID".error

##expected inputs
#key
#bam_file
#peak_file
if [ -z $bam_file ]; then
	bam_file=$1
	echo 2nd arg bam_file=$bam_file
fi
bam_file=$(readlink -f $bam_file)
if [ ! -e $bam_file ]; then
	echo $bam_file not found! stop
	exit 1
fi
if [ -z $peak_file ]; then
peak_file=$2
echo 3rd arg peak_file=$peak_file
fi
peak_file=$(readlink -f $peak_file)
if [ ! -e $peak_file ]; then
        echo $peak_file not found! stop
        exit 1
fi
if [ -z $key ]; then
        key=$(basename $bam_file .bam)
        echo 1st arg key=$key
fi

if [ -z $OUT_FILE ]; then
OUT_FILE=${bam_file/.bam/""}"_FRIP.txt"
echo output will be in $OUT_FILE
fi
echo bam_file is $bam_file
echo peak_file is $peak_file
echo calculating FRIP for $(basename $bam_file) and $(basename $peak_file)
in_peak=$(bedtools intersect -abam -bed -wa -u -f 1 -a $bam_file -b $peak_file | wc -l)
total=0
cmd="echo no cmd set"
if [ -f ${bam_file/.bam/.bam.bai} ]; then
	echo bam is indexed, doing this the smart way
	total=$(samtools idxstats $bam_file | cut -f 3 | awk 'BEGIN {sum=0} { sum = sum + $1} END {print sum}')
else
	echo bam is not indexed, doing this the dumb way
	total=$(samtools view -c $bam_file)
fi
#echo "cmd is->"$cmd
#total=$( $cmd )
echo total is $total
frip=$(echo "$in_peak $total" | awk '{printf "%.4f \n", $1/$2}')
echo $key $in_peak $total $frip
echo $key $in_peak $total $frip >> $OUT_FILE
