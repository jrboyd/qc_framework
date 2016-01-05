#!/bin/bash
#$ -pe threads 8
#$ -o align."$JOB_ID".out
#$ -e align."$JOB_ID".error



#meant for qsub in SGE, take INPUT trimmed and cut fastq and apply hardcoded alignment procedure and output to specififed OUTPUT
#INPUT - trimmed and cut bam to be aligned
#OUTPUT- name of final alignment file
#any tmp files will be named according to sge job_id
if [ -z $INPUT ]; then
echo no INPUT set! stop
exit 1
fi
if [ -z $OUTPUT ]; then
echo no OUTPUT set! stop
exit 1
fi


echo aligning file $INPUT
/slipstream/galaxy/production/galaxy-dist/tools/star/STAR --genomeLoad NoSharedMemory --genomeDir /slipstream/galaxy/data/hg38/star_index --readFilesIn $INPUT --runThreadN 8 --alignIntronMax 1 --outSAMtype BAM SortedByCoordinate --outStd BAM_SortedByCoordinate > $OUTPUT
mv Log.final.out $OUTPUT".log"
#echo i am an alignment of $INPUT > $OUTPUT
#echo trimming file $INPUT

echo aligned file is written to $OUTPUT
