#!/bin/bash

if [ -z $TREAT_BAM ]; then
TREAT_BAM=$2
fi
if [ -z $INPUT_BAM ]; then
INPUT_BAM=$3
fi
if [ -z $DEP_JIDS ]; then
DEP_JIDS=$4
fi
if [ -z $GEN ]; then
GEN=$1
fi

log "---- start step6"
log "     calling peaks with:"
#log "logtest"
log "     TREAT_BAM is $TREAT_BAM"
log "     INPUT_BAM is $INPUT_BAM"
log "     DEP_JIDS is $DEP_JIDS"
PREFIX=$(basename $TREAT_BAM)
PREFIX=${PREFIX/.bam/""}
OUTDIR=$(dirname $TREAT_BAM)

qsub_out_loose=$(qsub -v TREAT_BAM=$TREAT_BAM,INPUT_BAM=$INPUT_BAM,PREFIX=$PREFIX"_loose",OUTDIR=$OUTDIR,PVAL="1e-2",GEN=$GEN -wd $OUTDIR -hold_jid $DEP_JIDS job_scripts/run_macs2.sh)
qsub -v TREAT_BAM=$TREAT_BAM,INPUT_BAM=$INPUT_BAM,PREFIX=$PREFIX"_loose",OUTDIR=$OUTDIR,PVAL="1e-2",GEN=$GEN -wd $OUTDIR -hold_jid $DEP_JIDS job_scripts/run_macs2.broad.sh
jid=$(parse_jid "$qsub_out_loose")

log "     QSUB_OUT is $qsub_out_loose"
log "     JID is $jid"
log "---- end step6"
log "     step6 continues"

echo "$jid"

