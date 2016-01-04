#!/bin/bash
#arg1 is a raw fastq file
#arg2 is name of trimcut fastq file to be generated
input=$1
output=$2
job_depends=$3
if [ -z $input ]; then
echo arg1 should be input but was blank! stop >> $LOG_FILE
exit 1
fi
#if [ ! -e $input ]; then
#echo arg1s $input does not exist! stop >> $LOG_FILE
#exit 1
#fi
if [ -z $output ]; then
echo arg2 should be output but was blank! stop >> $LOG_FILE
exit 1
fi
if [ -z $job_depends ]; then
echo arg3 should be dependency job id! stop >> $LOG_FILE
fi

echo --- starting step 2 >> $LOG_FILE
echo input is $input >> $LOG_FILE
echo output is $output >> $LOG_FILE
echo will wait for $job_depends >> $LOG_FILE
JOB1=$(qsub -v INPUT=$input,OUTPUT=$output -hold_jid $job_depends job_scripts/trimcut_fastq2bam.sh) #add file here
#returns whole line
JOBID=$(awk -v RS=[0-9]+ '{print RT+0;exit}' <<< "$JOB1") #returns JOBID
echo --- step 2 finished >> $LOG_FILE
echo JOBID for step 3 is $JOBID >> $LOG_FILE
echo $JOBID
