#!/bin/bash
#$ -o final_report."$JOB_ID".out
#$ -e final_report."$JOB_ID".error


echo writing report for output in $(pwd)
RPT=final_report.txt
echo all jobs done > $RPT
echo finished at $(date) >> $RPT
echo reporting peaks...
LOOSE=loose_rep_peak_counts.txt
TIGHT=tight_rep_peak_counts.txt
POOLED=tight_pooled_peak_counts.txt
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
	thresh=$(cat $f | awk '{if (NR == 5) print $4}')
	echo npeaks passing is $thresh
	peaks=${f/_IDR.npeaks-aboveIDR.txt/_pooled_peaks.narrowPeak}
	trunc=${f/_IDR.npeaks-aboveIDR.txt/_pooled_peaks_passIDR.05.narrowPeak}
	sort -nr -k 8,8 $peaks | head -n $thresh | sort -n -k 2 | sort -k 1,1V -k 2,2n > $trunc
done

	
