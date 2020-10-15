#!/bin/bash
#$ -o archive_report."$JOB_ID".out
#$ -e archive_report."$JOB_ID".error


#meant for qsub in SGE, take INPUT raw fastq and apply hardcoded trim and cut procedure and output to specififed OUTPUT
#RAW - raw fastq file to be trimmed then cut
#TC- name of final trimmed and cut file
#REPORT - name of file to output report to
#any tmp files will be named according to sge job_id
if [ -z $RAW ]; then
echo no RAW set! stop
exit 1
fi
if [ -z $TC ]; then
echo no TC set! stop
exit 1
fi
if [ -z $REPORT ]; then
echo no REPORT set! stop
exit 1
fi

if [ -f $RAW.gz ]; then
	echo archive $RAW.gz exists so skip archiving $RAW
else
	echo gzip file $RAW to $RAW.gz
	gzip -c $RAW > $RAW.gz
fi
if [ -f $REPORT ]; then
	echo skip reporting, $REPORT exists for $RAW, please check for completeness
else
	checksum=$(md5sum $RAW.gz | cut -d " " -f 1)
	function nreads ()
	{
		n=$(wc -l $1)
		n=$(echo $n | cut -d " " -f 1)
		echo $(( $n / 4))
	}
	raw_reads=$(nreads $RAW)
	tc_reads=$(nreads $TC)
	echo name $(basename $RAW) > $REPORT
	echo gz_filename $RAW.gz >> $REPORT
	echo gz_md5sum $checksum >> $REPORT
	echo raw_reads $raw_reads >> $REPORT
	echo tc_reads $tc_reads >> $REPORT

	echo archived $RAW and reported to $REPORT
fi

#copied from galaxy env.sh for fastqc
PATH=/slipstream/galaxy/production/dependencies/FastQC/0.11.2/devteam/package_fastqc_0_11_2/4b65f6e39cb0:$PATH; export PATH
FASTQC_JAR_PATH=/slipstream/galaxy/production/dependencies/FastQC/0.11.2/devteam/package_fastqc_0_11_2/4b65f6e39cb0; export FASTQC_JAR_PATH
#copied from galaxy command for joe's fastqc workflow
#fastqc_dir=$(dirname $TC)/fastqc_files
#fastqc_f="$TC".fastq_report
#mkdir $fastqc_dir
qc_out=${RAW/.fastq/_fastqc}
if [ -d $qc_out ]; then
        echo skip fastqc, $qc_out exists for $RAW, please check for completeness
else
        echo running fastqc, output to $qc_out
        fastqc --quiet --extract $RAW
fi


qc_out=${TC/.fastq/_fastqc}
if [ -d $qc_out ]; then 
	echo skip fastqc, $qc_out exists for $TC, please check for completeness
else
	echo running fastqc, output to $qc_out
	fastqc --quiet --extract $TC
fi
#python /slipstream/galaxy/uploads/working/qc_framework/job_scripts/rgFastQC.py -i "$TC" -o "$fastqc_f.html" -t "$fastqc_f.txt" -f "fastqsanger" -j "$TC" -e "$FASTQC_JAR_PATH/fastqc"
