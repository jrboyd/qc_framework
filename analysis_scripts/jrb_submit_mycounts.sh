#!/bin/bash
#counting mapped read is not needed in qc_framework
BAM_DIR=$1
#OUNTS_DIR=$2
BAM_DIR=$(readlink -f $BAM_DIR)
#OUNTS_DIR=$(readlink -f $COUNTS_DIR)
#WD=/slipstream/galaxy/uploads/working/prostate
SCRIPTS_DIR=/slipstream/galaxy/uploads/working/qc_framework/analysis_scripts
#lines=(MCF10A MCF7 MDA231)
#lines=(LN RW PC)
#lines=(ES H1 H7)
#mods=(input H3K4ME3 H3K27ME3) #H3K4AC H3K27AC H3K27ME3 H4K20ME3 H4K12AC)
#mods=(input H3K27ME3 K27 K4)
#MR_OUT=$COUNTS_DIR"/mapped_reads_Sep-30-2015.txt"
GTF_FILE=$2
if [ -z $GTF_FILE ]
then
GTF_FILE=/slipstream/home/joeboyd/ref/gencode.v21.annotation.gtf
echo using default gtf file $GTF_FILE
fi

#echo bam_file total_mapped_reads > $MR_OUT
#mkdir $WD/ref
#for l in ${lines[@]}
#do for m in ${mods[@]}
#do for BAM_FILE in $WD/$l*$m*.bam
for BAM_FILE in $BAM_DIR/*/*.bam
do
	if [ -e $BAM_FILE ]
	then
		echo $(basename $BAM_FILE) in $BAM_DIR
		qsub -v BAM_FILE=$BAM_FILE,GTF_FILE=$GTF_FILE $SCRIPTS_DIR/jrb_run_mycounts.sh
	fi
#done;done;done
done
