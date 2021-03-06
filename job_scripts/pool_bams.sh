#!/bin/bash
#$ -o poolbam."$JOB_ID".out
#$ -e poolbam."$JOB_ID".error


#pools to input semi colon delimited list of bam files into the output file
#arg 1 is semi colon separated list of bam files
#arg 2 is name of output pooled bam file
if [ -z $INPUT ]; then
INPUT=$1
fi
if [ -z $OUTPUT ]; then
OUTPUT=$2
fi
bams=$INPUT
pooled=$OUTPUT
echo pooling $bams to $pooled
bams=${bams//";"/" "}
topool=( $bams )
cmd="no command set"
if [ -f $pooled ]; then
	#echo pooled file already present, please verify $pooled is complete.
	cmd="echo $pooled already exists, check for completeness"
elif [ ${#topool[@]} -eq 1 ]; then
        echo pooling not necessary, just link for $bams to $pooled
	cmd="ln $bams $pooled"
else
        echo gonna pool $bams into $pooled
	cmd="samtools merge $pooled $bams"
fi
echo CMD is "$cmd"
$cmd
for tp in ${topool[@]}; do
	echo $tp
done
echo pooling finished into $pooled
if [ -f "$pooled".bai ]; then
	echo indexing not necessary, already done
else
	echo indexing $pooled
	samtools index $pooled
fi
ls -lha $pooled*
echo done
#echo "$INPUT" > $pooled
