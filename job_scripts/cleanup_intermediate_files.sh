#!/bin/bash
#$ -o cleanup_intermediate_files."$JOB_ID".out
#$ -e cleanup_intermediate_files."$JOB_ID".error

if [ -z $OUT_DIR ]; then
        OUT_DIR=$1
fi
if [ -z $OUT_DIR ]; then
        echo "no OUT_DIR (arg 1) supplied, stop"
        exit 1
fi
if [ ! -d $OUT_DIR ]; then
        echo OUT_DIR $OUT_DIR does not exist, stop
        exit 1
fi
cd $OUT_DIR

echo cleaning up bdg files where bw have been made
#ls -lha */*bw
#ls -lha */*bdg
for bw in */*bw; do bdg=${bw/.bw/.bdg}; if [ -f $bdg ]; then echo rm $bdg; chmod u+w $(dirname $bdg); chmod u+w $bdg; rm $bdg ;fi; done
for bw in */*bw; do bdg=${bw/.bw/_treat_pileup.bdg}; if [ -f $bdg ]; then echo rm $bdg; chmod u+w $(dirname $bdg); chmod u+w $bdg; rm $bdg ;fi; done
for bw in */*bw; do bdg=${bw/.bw/_control_lambda.bdg}; if [ -f $bdg ]; then echo rm $bdg; chmod u+w $(dirname $bdg); chmod u+w $bdg; rm $bdg ;fi; done

echo cleaning up fastq files where bam have been made
for bam in */*gz; do for key in .fastq; do fastq=${bam/.gz/""}; if [ -f $fastq ]; then echo rm $fastq; rm $fastq; fi; done; done
for bam in */*bam; do for key in .tc.fastq .fastq.cutadapt.tmp; do fastq=${bam/.bam/$key}; if [ -f $fastq ]; then echo rm $fastq; rm $fastq; fi; done; done

echo making output read only
#chmod a-w -R $OUT_DIR/*
chmod a+w -R $OUT_DIR/tmp*
chmod a+w -R $OUT_DIR/samples.log


