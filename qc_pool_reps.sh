#!/bin/bash
after_jids=$1
input_bams=$2
output_bam=$3
log "----pooling"
log "    will pool $input_bams after $after_jids jobs complete into $output_bam"
JOB1=$(qsub -v INPUT="$input_bams" -v OUTPUT=$output_bam -wd $(dirname $output_bam) -hold_jid $after_jids job_scripts/pool_bams.sh) #add file here
#returns whole line
JOBID=$(parse_jid "$JOB1") #returns JOBID
log "    pooled bam is $JOBID"
log "----done pooling"
echo $JOBID
