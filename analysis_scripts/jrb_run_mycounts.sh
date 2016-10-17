#!/bin/bash
if [ -z $BAM_FILE ]
then
	echo "parsing inputs"
	BAM_FILE=$1
	GTF_FILE=$2
fi
SCRIPT_PATH="/slipstream/home/joeboyd/scripts"

echo "bam file is $BAM_FILE"
echo "gtf file is $GTF_FILE"
echo "script path is $SCRIPT_PATH"

PROM_EXT=2000
F_TYPE="transcript"

#echo 'counting ensg only'
#python $SCRIPT_PATH/chipseq_count_ensg.py $BAM_FILE $GTF_FILE
#exit 0
echo 'counting in promoters'
python $SCRIPT_PATH/chipseq_count_promoters_v3.py $BAM_FILE $GTF_FILE $PROM_EXT $F_TYPE
echo 'counting in genebodies minus promoters'
python $SCRIPT_PATH/chipseq_count_genebodies_no_promoters_v3.py $BAM_FILE $GTF_FILE $PROM_EXT $F_TYPE

#python $SCRIPT_PATH/chipseq_count_promoters_v2.py $BAM_FILE $GTF_FILE $PROM_EXT $F_TYPE
#echo 'counting in tes'
#python $SCRIPT_PATH/chipseq_count_tes.py $BAM_FILE $GTF_FILE
#echo 'counting in genebodies'
#python $SCRIPT_PATH/chipseq_count_genebodies.py $BAM_FILE $GTF_FILE
#echo 'counting in exons'
#python $SCRIPT_PATH/chipseq_count_exons.py $BAM_FILE $GTF_FILE

