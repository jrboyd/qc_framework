#!/bin/bash
#arg1 is a raw fastq file
#arg2 is name of trimcut fastq file to be generated
input=$1
output=$2
if [ -z $input ]; then
echo arg1 should be input but was blank! stop >> $LOG_FILE
exit 1
fi
if [ ! -e $input ]; then
echo arg1s $input does not exist! stop >> $LOG_FILE
exit 1
fi
if [ -z $output ]; then
echo arg2 should be output but was blank! stop >> $LOG_FILE
exit 1
fi

echo --- starting step 1 >> $LOG_FILE
echo input is $input >> $LOG_FILE
echo output is $output >> $LOG_FILE
JOB1=$(qsub -v INPUT=$input,OUTPUT=$output job_scripts/fastq2trimcut_fastq.sh) #add file here
#returns whole line
JOBID=$(awk -v RS=[0-9]+ '{print RT+0;exit}' <<< "$JOB1") #returns JOBID
echo --- step 1 finished >> $LOG_FILE
echo JOBID for step 2 is $JOBID >> $LOG_FILE
echo $JOBID
