#!/bin/bash
#step5 args
#arg 1 bam files delimited by ;
#arg 2 output directory
#arg 3 job ids passed to hold_jid to wait for

#called by step5_o=$(bash step_scripts/step5*.sh $samp_bams $OUT_DIR $samp_jobs)

if [ -z $BAMS ]; then
BAMS=$1
fi
if [ -z $OUTDIR]; then
OUTDIR=$2
fi
if [ -z $DEP_JIDS ]; then
DEP_JIDS=$3
fi
log "---- start step5"
log "     bulk analysis with:"
#log "logtest"
BAM_LIST=( ${BAMS//";"/" "} )
log $BAMS
log "     BAMS are:"
for bam in ${BAM_LIST[@]}; do
log "         $bam"
done
log "     OUTDIR is $OUTDIR"
log "     DEP_JIDS are $DEP_JIDS"

qsub_out=$(qsub -v BAMS="$BAMS",OUTDIR="$OUTDIR",DESC=global -wd $OUTDIR -hold_jid "$DEP_JIDS" job_scripts/run_bamCorrelate.sh)
jid=$(parse_jid "$qsub_out")

log "     QSUB_OUT is $qsub_out"
log "     JID is $jid"
log "---- end step5"
#log "     step4 continues"

