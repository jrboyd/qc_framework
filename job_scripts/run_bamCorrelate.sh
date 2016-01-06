#!/bin/bash
#$ -o bamcorr."$JOB_ID".out
#$ -e bamcorr."$JOB_ID".error


#pools to input comma delimited list of bam files into the output file
#arg 1 is semicolon separated list of bam files
#arg 2 is output dir
#arg 3 is short descriptor appended to outputs


#called with qsub_out=$(qsub -v BAMS=$BAMS,OUTDIR=$OUTDIR,DESC=global -wd $OUTDIR -hold_jid $DEP_JIDS job_scripts/run_bamCorrelate.sh)

if [ -z $BAMS ]; then
BAMS=$1
fi
if [ -z $OUTDIR ]; then
OUTDIR=$2
fi
if [ -z $DESC ]; then
DESC=$3
fi

bams=${BAMS//";"/" "}
bams_array=( $bams )
#bamCorrelate min args are "bamCorrelate bins ---bamfiles file1.bam file2.bam --corMethod spearman -o heatmap.png"
cmd="bamCorrelate bins --bamfiles $bams --corMethod spearman -o $OUTDIR/bamCorrelate_heatmap.png  --outFileCorMatrix $OUTDIR/bamCorrelate_values.txt --plotFileFormat pdf"
echo CMD is "$cmd"
$cmd
for b in ${bams_array[@]}; do
echo $b
done
echo bamCorrelate finished
#echo "$INPUT" > $pooled
