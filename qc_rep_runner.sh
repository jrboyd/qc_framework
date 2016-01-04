#!/bin/bash
#runner called by qc_framework.sh for each raw fastq file
#arg 1 is raw fastq file, presumed in WD
#returns job_id of bam file to be used by merge bam
#echo $LOG_FILE
#LOG=$1.runner.log
RAW_F=$1
TC_F=${RAW_F/.fastq/.tc.fastq}
tc_job=$(bash step_scripts/step1*.sh $RAW_F $TC_F)
echo step2 jobs will wait for $tc_job >> $LOG_FILE
BAM_F=${RAW_F/.fastq/.bam}
bam_job=$(bash step_scripts/step2*.sh $TC_F $BAM_F $tc_job)
echo $bam_job

if [ ! -z $2 ]; then
#if [ $2 = "dopeaks" ]; then
echo call peaks for $BAM_F >> $LOG_FILE
f=$(basename $BAM_F)
INPUT_F=$(dirname $BAM_F)/$2"_pooled.bam"
#mark=echo $f | awk -v index=$3 'BEGIN {FS="_"} {print $index}'
echo $INPUT_F is input for $BAM_F, waiting for $3,$bam_job >> $LOG_FILE
macs_job=$(bash step_scripts/step4*.sh $BAM_F $INPUT_F $3,$bam_job)
echo macs jobs is $macs_job >> $LOG_FILE
#fi
fi
