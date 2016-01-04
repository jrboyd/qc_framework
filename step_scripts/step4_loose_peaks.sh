#!/bin/bash

if [ -z $TREAT_BAM ]; then
TREAT_BAM=$1
fi
if [ -z $INPUT_BAM ]; then
INPUT_BAM=$2
fi
if [ -z $DEP_JIDS ]; then
DEP_JIDS=$3
fi
echo calling peaks with: >> $LOG_FILE
#log "logtest"
echo TREAT_BAM is $TREAT_BAM >> $LOG_FILE
echo INPUT_BAM is $INPUT_BAM >> $LOG_FILE
PREFIX=$(basename $TREAT_BAM)
PREFIX=${PREFIX/.bam/""}
OUTDIR=$(dirname $TREAT_BAM)/$PREFIX
if [ -d $OUTDIR ]; then
rm -r $OUTDIR
fi
mkdir $OUTDIR
#echo AAA >> $LOG_FILE
qsub_out=$(qsub -v TREAT_BAM=$TREAT_BAM,INPUT_BAM=$INPUT_BAM,PREFIX=$PREFIX,OUTDIR=$OUTDIR -hold_jid $DEP_JIDS job_scripts/run_macs2.sh)
#echo BBB >> $LOG_FILE

jid=$(parse_jid "$qsub_out")
echo QSUB_OUT is $qsub_out >> $LOG_FILE
echo JID is $jid >> $LOG_FILE
echo "$jid"

