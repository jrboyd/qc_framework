#!/bin/bash
#$ -o idr."$JOB_ID".out
#$ -e idr."$JOB_ID".error


#REQUIRED INPUTS
#PEAKS1
#PEAKS2 - 2 rep files
#PREFIX - prefix of output file (name without extension)
if [ -z $PEAKS1 ] || [ ! -f $PEAKS1 ]; then
	echo PEAKS1 $PEAKS1 not found! stop
	exit 1
fi
if [ -z $PEAKS2 ] || [ ! -f $PEAKS2 ]; then
        echo PEAKS1 $PEAKS2 not found! stop
        exit 1
fi
OUTDIR=$(dirname $PREFIX)
if [ -z $PREFIX ] || [ ! -d $OUTDIR ]; then
        echo PREFIX $PREFIX either not given or not in valid directory! stop
        exit 1
fi

#rand=$(date +%N | sed -e 's/000$//' -e 's/^0//')
#PREFIX="$PREFIX"_"$rand"
if [ -f $PREFIX.npeaks-aboveIDR.txt ]; then
	echo file $PREFIX.npeaks-aboveIDR.txt exists so skip IDR.  deleted this file to run.
	exit 0
fi

isBroad=F
SCRIPT_DIR=/slipstream/galaxy/production/toolshed-repositories/toolshed.g2.bx.psu.edu/repos/modencode-dcc/idr_package/6f6a9fbe264e/idr_package
gen=hg38
gen=/slipstream/galaxy/production/galaxy-dist/tool-data/bigbedwig/$gen.chrom.sizes

#num of peaks is capped at 250k, sort by pval, head 250k, resort by chrm position
#cat output/MCF10A_H3K4AC_R1/MCF10A_H3K4AC_R1_loose_peaks.narrowPeak | sort -n -r -k 8 | head
#sort -nr -k 8,8 $peaks | head -n $thresh | sort -n -k 2 | sort -k 1,1V -k 2,2n > $trunc
MAX=250000
np1=$(wc -l $PEAKS1 | cut -d " " -f 1)
np2=$(wc -l $PEAKS2 | cut -d " " -f 1)
IDR_IN1=$PEAKS1
IDR_IN2=$PEAKS2
if [ $np1 -gt $MAX ]; then #if > MAX peaks, sort by pval and cut then resort by chrm
	IDR_IN1="$PEAKS1".idr_in
	echo $(basename $PEAKS1) too many peaks. $np1.  filter top $MAX to $(basename $IDR_IN1).
	cat $PEAKS1 | sort -nr -k 8,8 | head -n $MAX | sort -n -k 2 | sort -k 1,1V -k 2,2n > $IDR_IN1
fi
if [ $np2 -gt $MAX ]; then #if > MAX peaks, sort by pval and cut then resort by chrm
	IDR_IN2="$PEAKS2".idr_in
	echo $(basename $PEAKS2) too many peaks. $np2.  filter top $MAX to $(basename $IDR_IN2).
	cat $PEAKS2 | sort -nr -k 8,8 | head -n $MAX | sort -n -k 2 | sort -k 1,1V -k 2,2n > $IDR_IN2
fi




Rscript $SCRIPT_DIR/batch-consistency-analysis.r $SCRIPT_DIR $IDR_IN1 $IDR_IN2 -1 0 $isBroad p.value $gen $PREFIX.Rout.txt $PREFIX.overlapped-peaks.txt $PREFIX.npeaks-aboveIDR.txt $PREFIX.em.sav $PREFIX.uri.sav
#>batch-consistency-analysis.r \$SCRIPT_PATH $input1 $input2 $halfwidth $overlap $option $sigvalue $gtable $rout $aboveIDR $ratio $emSav $uriSav
#    <data format="txt" name="rout" label="IDR.Rout.txt"/>
#    <data format="txt" name="aboveIDR" label="IDR.npeaks-aboveIDR.txt"/>
#    <data format="txt" name="ratio" label="IDR.overlapped-peaks.txt"/>
#    <data format="txt" name="emSav" label="IDR.em.sav"/>
#    <data format="txt" name="uriSav" label="IDR.uri.sav"/>

