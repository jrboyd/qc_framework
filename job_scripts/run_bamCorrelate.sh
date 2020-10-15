#!/bin/bash
#$ -o bamcorr."$JOB_ID".out
#$ -e bamcorr."$JOB_ID".error
#$ -pe threads 8

#pools to input semicolon delimited list of bam files into the output file
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
if [ -z $REF ]; then
REF=$3
fi
echo BAMS is $BAMS
echo OUTDIR is $OUTDIR
echo REF is $REF
bams=${BAMS//";"/" "}
bams_array=( $bams )
for b in ${bams_array[@]}; do
	if [ ! -f $b ]; then echo bam file $b not found! stop.; exit 1; fi
done
if [ ! -d $OUTDIR ]; then echo OUTDIR $OUTDIR not found! stop.; exit 1; fi

#rand=$(date +%N | sed -e 's/000$//' -e 's/^0//')
#bamCorrelate min args are "bamCorrelate bins ---bamfiles file1.bam file2.bam --corMethod spearman -o heatmap.png"
#cmd="bamCorrelate bins --bamfiles $bams --corMethod spearman -o $OUTDIR/bamCorrelate_heatmap_"$rand".pdf  --outFileCorMatrix $OUTDIR/bamCorrelate_values_"$rand".txt --plotFileFormat pdf"
outf=global
if [ ! -z $REF ]; then outf=$(basename $REF | awk 'BEGIN {FS="."} {print $1} '); fi
if [ -f $OUTDIR/bamCorrelate_"$outf"_values.txt ]; then
	echo bamCorrelate output exists already! 
	echo delete $OUTDIR/bamCorrelate_"$outf"_values.txt to rerun
	exit 1
fi
if [ -z $REF ]; then
	echo no REF set, running bamCorrelate globally
	cmd="bamCorrelate bins --bamfiles $bams --corMethod spearman -o $OUTDIR/bamCorrelate_"$outf"_heatmap.pdf  --outFileCorMatrix $OUTDIR/bamCorrelate_"$outf"_values.txt --plotFileFormat pdf"
else
	if [ ! -f $REF ]; then echo REF $REF not found, stop.; exit 1; fi
	cmd="bamCorrelate BED-file --BED $REF --bamfiles $bams --corMethod spearman -o $OUTDIR/bamCorrelate_"$outf"_heatmap.pdf  --outFileCorMatrix $OUTDIR/bamCorrelate_"$outf"_values.txt --plotFileFormat pdf"
fi
echo CMD is "$cmd"
$cmd

for b in ${bams_array[@]}; do
echo $b
done
echo bamCorrelate finished
#echo "$INPUT" > $pooled
