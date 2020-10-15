#!/bin/bash
#FORCE=$true
QC_DIR=$1
QC_DIR=$(readlink -f $QC_DIR)
MARK=$2
peak_files=$(ls $QC_DIR/*$MARK*/*R[0-9]_peaks.narrowPeak | awk 'BEGIN {ORS=" "} {print $0}')
consensus_file="$MARK"_consensus_narrowPeak.bed
consensus_file=$(readlink -f $consensus_file)
echo writing consensus of $peak_files to $consensus_file
Rscript job_scripts/cmd_narrowPeak_consensus.R -wd $(pwd) -out $consensus_file $peak_files
bam_files=$(ls $QC_DIR/*$MARK*/*R[0-9].bam | awk 'BEGIN {ORS=";"} {print $0}')
#if [ $FORCE ]; then echo removing previous output; rm bamCorrelate_"$MARK"*; fi 
echo correlating reads in consensus $(wc -l $consensus_file) peaks for bam files: $bam_files
bash job_scripts/run_bamCorrelate.sh $bam_files $QC_DIR $consensus_file
