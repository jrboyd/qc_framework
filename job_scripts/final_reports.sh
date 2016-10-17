#!/bin/bash
#$ -o final_report."$JOB_ID".out
#$ -e final_report."$JOB_ID".error

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
echo writing report for output in $(pwd)
RPT=finish_time.txt
if [ ! -f $RPT ]; then
	echo all jobs done > $RPT
	echo finished at $(date) >> $RPT
fi
echo reporting peaks...
LOOSE=loose_rep_peak_counts.txt
TIGHT=tight_rep_peak_counts.txt
POOLED=tight_pooled_peak_counts.txt
rm -f $LOOSE; rm -f $TIGHT; rm -f $POOLED
for f in */*peaks.narrowPeak
do if echo $f | grep -iq loose; then
	wc -l $f >> $LOOSE
else 
	if echo $f | grep -iq pool; then
		wc -l $f >> $POOLED
	else
		wc -l $f >> $TIGHT
	fi
fi; done
echo truncating pooled peaks by IDR
for f in */*_IDR.npeaks-aboveIDR.txt; do
	echo $f ...
	peaks=${f/_IDR.npeaks-aboveIDR.txt/_pooled_peaks.narrowPeak}
        trunc=${f/_IDR.npeaks-aboveIDR.txt/_pooled_peaks_passIDR.05.narrowPeak}
	if [ -f $trunc ]; then continue; fi
	thresh=$(cat $f | awk '{if (NR == 5) print $4}')
	echo npeaks passing is $thresh
	sort -nr -k 8,8 $peaks | head -n $thresh | sort -n -k 2 | sort -k 1,1V -k 2,2n > $trunc
done

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

#.cutadapt.tmp
#.tc.fastq
