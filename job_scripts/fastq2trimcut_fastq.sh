#!/bin/bash
#$ -o trimcut."$JOB_ID".out
#$ -e trimcut."$JOB_ID".error


#meant for qsub in SGE, take INPUT raw fastq and apply hardcoded trim and cut procedure and output to specififed OUTPUT
#INPUT - raw fastq file to be trimmed then cut
#OUTPUT- name of final trimmed and cut file
#any tmp files will be named according to sge job_id
if [ -z $INPUT ]; then
echo no INPUT set! stop
exit 1
fi
if [ -z $OUTPUT ]; then
echo no OUTPUT set! stop
exit 1
fi
if [ -z $BAM ]; then
echo no BAM set to check for! job will run
fi

echo INPUT raw fastq is $INPUT
echo intermeidate cutadapt is "$INPUT".cutadapt.tmp
echo OUTPUT tc fastq is $OUTPUT
if [ -f $OUTPUT ]; then
	echo $OUTPUT exists already, skipping trim cut for $INPUT
elif [ ! -z $BAM ]; then
	if [ -f $BAM ]; then
		echo $BAM bam file exists, skipping trim cut for $INPUT
	
	else
		echo trimming file $INPUT
		PYTHONPATH=/slipstream/galaxy/production/dependencies/galaxy_sequence_utils/1.0.0/devteam/package_galaxy_utils_1_0/0643676ad5f7/lib/python:$PYTHONPATH; export PYTHONPATH
		cutadapt --format=fastq --anywhere="TruSeq Adapter Index Prefix"='GATCGGAAGAGCACACGTCTGAACTCCAGTCAC' --error-rate=0.0 --times=1 --overlap=20 --discard --output="$INPUT".cutadapt.tmp "$INPUT" > "$INPUT".cutadapt.log.tmp
		python /slipstream/galaxy/production/shed_tools/toolshed.g2.bx.psu.edu/repos/devteam/fastq_trimmer_by_quality/1cdcaf5fc1da/fastq_trimmer_by_quality/fastq_trimmer_by_quality.py "$INPUT".cutadapt.tmp "$OUTPUT" -f 'sanger' -s '10' -t '1' -e '53' -a 'min' -x '0' -c '>=' -q '20.0'
	
#		echo trimming file $INPUT
#	        PYTHONPATH=/slipstream/galaxy/production/dependencies/galaxy_sequence_utils/1.0.0/devteam/package_galaxy_utils_1_0/0643676ad5f7/lib/python:$PYTHONPATH; export PYTHONPATH
#       	cutadapt --format=fastq --anywhere="TruSeq Adapter Index Prefix"='GATCGGAAGAGCACACGTCTGAACTCCAGTCAC' --error-rate=0.0 --times=1 --overlap=20 --discard --output="$INPUT".cutadapt.tmp "$INPUT" > "$INPUT".cutadapt.log.tmp
#	        python /slipstream/galaxy/production/shed_tools/toolshed.g2.bx.psu.edu/repos/devteam/fastq_trimmer_by_quality/1cdcaf5fc1da/fastq_trimmer_by_quality/fastq_trimmer_by_quality.py "$INPUT".cutadapt.tmp "$OUTPUT" -f 'sanger' -s '10' -t '1' -e '53' -a 'min' -x '0' -c '>=' -q '20.0'
	fi
fi
#cp $INPUT $OUTPUT #placeholder 
#echo trimming file $INPUT
if [ -f $OUTPUT ]; then
	echo trimcut file is written to $OUTPUT
elif [ -f $BAM ]; then
	echo no trimcut file created.  $BAM bam file exists.
else
	echo something went wrong with $INPUT, no output detected.
fi
