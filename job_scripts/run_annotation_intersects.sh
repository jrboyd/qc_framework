#!/bin/bash
#$ -o annot_intersect."$JOB_ID".out
#$ -e annot_intersect."$JOB_ID".error
 

#PEAKS=$1
#ANNOT_DIR
#PEAKS=$1
if [ -z $PEAKS ] || [ ! -f $PEAKS ]; then
	echo PEAKS file $PEAKS not found! stop
	exit 1
fi
#ANNOT_DIR=$2
if [ -z $ANNOT_DIR ] || [ ! -d $ANNOT_DIR ]; then
        echo ANNOT_DIR $ANNOT_DIR not found! stop
        exit 1
fi

PR_ANNOT=$ANNOT_DIR/annot_promoters.gtf
EX1_ANNOT=$ANNOT_DIR/annot_1st_exons.gtf
EXall_ANNOT=$ANNOT_DIR/annot_all_exons.gtf
GB_ANNOT=$ANNOT_DIR/annot_genes.gtf
UP_ANNOT=$ANNOT_DIR/annot_upstream.gtf

dos2unix $PEAKS
#wc -l *.bed >> $OUT_F

echo PEAKS is $PEAKS
echo ANNOT_DIR is $ANNOT_DIR
echo annotation files are:
ls -lha $ANNOT_DIR/*

PT=$(echo $PEAKS | awk 'BEGIN {FS="[_.]"} {print $NF}')

if [ ! -e $PEAKS ]; then
	echo $PEAKS does not exist! quit
	exit 1
fi
f=$PEAKS

outdir=$(dirname $f)/peaks_by_location
if [ -d $outdir ]; then
	echo $outdir exists so assuming job does not need to be run.
	echo please check for completeness and delete $outdir to rerun.
	exit 0
fi
mkdir $outdir
f=$outdir/$(basename $f) #all outputs appear in subdirectory
in_f=$PEAKS
pos_f=${f/.$PT/.promoters.out.$PT}
neg_f=${f/.$PT/.not_promoters.tmp.$PT} #intermediate file, complements output
bedtools intersect -u -f 0.5 -wa -a $in_f -b $PR_ANNOT > $pos_f 
bedtools intersect -v -f 0.5 -a $in_f -b $PR_ANNOT > $neg_f
in_f=$neg_f
pos_f=${f/.$PT/.first_exons.out.$PT}
neg_f=${f/.$PT/.not_first_exons.tmp.$PT} #intermediate file, complements output
bedtools intersect -u -f 0.5 -wa -a $in_f -b $EX1_ANNOT > $pos_f
bedtools intersect -v -f 0.5 -a $in_f -b $EX1_ANNOT > $neg_f
in_f=$neg_f
pos_f=${f/.$PT/.secondplus_exons.out.$PT}
neg_f=${f/.$PT/.not_any_exons.tmp.$PT} #intermediate file, complements output
bedtools intersect -u -f 0.5 -wa -a $in_f -b $EXall_ANNOT > $pos_f
bedtools intersect -v -f 0.5 -a $in_f -b $EXall_ANNOT > $neg_f
in_f=$neg_f
pos_f=${f/.$PT/.gene_body.out.$PT}
neg_f=${f/.$PT/.not_gene.tmp.$PT} #intermediate file, complements output
bedtools intersect -u -f 0.5 -wa -a $in_f -b $GB_ANNOT > $pos_f
bedtools intersect -v -f 0.5 -a $in_f -b $GB_ANNOT > $neg_f
in_f=$neg_f
pos_f=${f/.$PT/.upstream.out.$PT}
neg_f=${f/.$PT/.intergenic.out.$PT} #intermediate file, complements output
bedtools intersect -u -f 0.5 -wa -a $in_f -b $UP_ANNOT > $pos_f
bedtools intersect -v -f 0.5 -a $in_f -b $UP_ANNOT > $neg_f
wc -l "${f/.$PT/}"* > "${f/.$PT/}".feature_distribution.txt
