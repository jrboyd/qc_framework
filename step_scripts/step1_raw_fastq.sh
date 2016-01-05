#!/bin/bash
#arg1 is a raw fastq file
#arg2 is name of trimcut fastq file to be generated
input=$1
output=$2
if [ -z $input ]; then
log "arg1 should be input but was blank! stop"
exit 1
fi
if [ ! -e $input ]; then
log "arg1s $input does not exist! stop"
exit 1
fi
if [ -z $output ]; then
log "arg2 should be output but was blank! stop"
exit 1
fi



#SRCDIR=$(pwd)
OUTDIR=$(dirname $output)
#cd $OUTDIR
log "--- starting step 1"
log "    input is $input"
log "    output is $output"
JOB1=$(qsub -v INPUT=$input,OUTPUT=$output -wd $OUTDIR job_scripts/fastq2trimcut_fastq.sh) #add file here
#returns whole line
#JOBID=$(awk -v RS=[0-9]+ '{print RT+0;exit}' <<< "$JOB1") #returns JOBID
JOBID=$(parse_jid "$JOB1")
#echo --- step 1 finished >> $LOG_FILE
#echo JOBID for step 2 is $JOBID >> $LOG_FILE
log "--- step 1 finished"
log "    wait JOBID for step 2 is $JOBID"
log "--- step 1 start non-dependent"
report=$(echo $input | cut -d "." -f 1)".report_fastq"

JOB2=$(qsub -v RAW=$input,TC=$output,REPORT=$report -wd $OUTDIR -hold_jid $JOBID job_scripts/fastq_archive_and_report.sh) 
echo $JOBID
