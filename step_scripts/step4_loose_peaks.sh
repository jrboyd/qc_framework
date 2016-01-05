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
log "---- start step4"
log "     calling peaks with:"
#log "logtest"
log "     TREAT_BAM is $TREAT_BAM"
log "     INPUT_BAM is $INPUT_BAM"
PREFIX=$(basename $TREAT_BAM)
PREFIX=${PREFIX/.bam/""}
OUTDIR=$(dirname $TREAT_BAM)
#if [ -d $OUTDIR ]; then
#rm -r $OUTDIR
#fi
#mkdir $OUTDIR
#echo AAA >> $LOG_FILE
qsub_out=$(qsub -v TREAT_BAM=$TREAT_BAM,INPUT_BAM=$INPUT_BAM,PREFIX=$PREFIX,OUTDIR=$OUTDIR -wd $OUTDIR -hold_jid $DEP_JIDS job_scripts/run_macs2.sh)
#echo BBB >> $LOG_FILE

jid=$(parse_jid "$qsub_out")
log "     QSUB_OUT is $qsub_out"
log "     JID is $jid"
log "---- end step4"
log "     step4 continues"

inputBedGraph=$OUTDIR/*treat_pileup.bdg
inputChromSizes=/slipstream/galaxy/uploads/working/hg38.chrom.sizes
outputBigWig=$OUTDIR/$PREFIX.bw
qsub_out1=$(qsub -v inputBedGraph=$inputBedGraph,inputChromSizes=$inputChromSizes,outputBigWig=$outputBigWig -wd $OUTDIR -hold_jid $jid job_scripts/run_bdg2bw.sh)

WD=$OUTDIR
TREATMENT=$OUTDIR/*treat_pileup.bdg
CONTROL=$OUTDIR/*control_lambda.bdg
METHOD=logFE
qsub_out2=$(qsub -v WD=$WD,TREATMENT=$TREATMENT,CONTROL=$CONTROL,METHOD=$METHOD -wd $OUTDIR -hold_jid $jid job_scripts/run_bdgcmp.sh)
jid_cmp=$(parse_jid "$qsub_out2")

inputBedGraph=$OUTDIR/*logFE.bdg
inputChromSizes=/slipstream/galaxy/uploads/working/hg38.chrom.sizes
outputBigWig=$OUTDIR/"$PREFIX"_logFE.bw
qsub_out3=$(qsub -v inputBedGraph=$inputBedGraph,inputChromSizes=$inputChromSizes,outputBigWig=$outputBigWig  -wd $OUTDIR -hold_jid $jid_cmp job_scripts/run_bdg2bw.sh)
echo "$jid"

