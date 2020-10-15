#!/bin/bash
#runner called by qc_framework.sh for each raw fastq file
#arg 1 is raw fastq file, presumed in WD
#returns job_id of bam file to be used by merge bam
gen=$1
LOG=$LOG_FILE
dep_jids=$2
treat_bam=$(echo $3 | awk 'BEGIN {FS=";"} {print $1}')
input_bam=$(echo $3 | awk 'BEGIN {FS=";"} {print $2}')
log "--start pool runner"
log "  pool runner on $treat_bam and $input_bam waiting for $dep_jids"
#echo running step 1

if [ -z $input_bam ]; then
log "  not input bam for pooled "$treat_bam"! stop"
exit 1
fi
#if [ ! -e $input_bam ]; then
#echo input bam $input_bam does not exist! stop >> $LOG_FILE
#exit 1
#fi
#if [ ! -e $treat_bam ]; then
#echo treat bam "$treat_bam" does not exist! stop >> $LOG_FILE
#exit 1
#fi


#if [ $2 = "dopeaks" ]; then
log "  call peaks for $treat_bam"
#f=$(basename $treat_bam)
#INPUT_F=$(dirname $BAM_F)/$2"_pooled.bam"
#mark=echo $f | awk -v index=$3 'BEGIN {FS="_"} {print $index}'
#echo $INPUT_F is input for $BAM_F, waiting for $dep_jids >> $LOG_FILE
macs_job=$(bash step_scripts/step4*.sh "$treat_bam" "$input_bam" "$dep_jids" $gen)
#fi
log "  macs job is $macs_job"
log "--finish pool runner"

