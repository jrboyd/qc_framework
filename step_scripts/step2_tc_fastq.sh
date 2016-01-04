#!/bin/bash
#arg1 is a raw fastq file
#arg2 is name of trimcut fastq file to be generated
input=$1
output=$2
job_depends=$3
if [ -z $input ]; then
log "arg1 should be input but was blank! stop"
exit 1
fi
#if [ ! -e $input ]; then
#echo arg1s $input does not exist! stop >> $LOG_FILE
#exit 1
#fi
if [ -z $output ]; then
log "arg2 should be output but was blank! stop"
exit 1
fi
if [ -z $job_depends ]; then
log "arg3 should be dependency job id! stop"
fi
#SRCDIR=$(pwd)
OUTDIR=$(dirname $output)
#cd $OUTDIR
log "--- starting step 2"
log "    input is $input"
log "    output is $output"
log "    will wait for $job_depends"
JOB1=$(qsub -wd $OUTDIR -v INPUT=$input,OUTPUT=$output -hold_jid $job_depends job_scripts/trimcut_fastq2bam.sh) #add file here
#returns whole line
JOBID=$(parse_jid "$JOB1") #returns JOBID
log "--- step 2 finished"
log "    JOBID for step 3 is $JOBID"
#cd $SRCDIR
echo $JOBID
