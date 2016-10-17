#!/bin/bash
#$ -pe threads 8
#BAM_FILE=$1
#WD=$2
echo BAM_FILE is $BAM_FILE
echo BED_FILE is $BED_FILE
echo OUTPUT is $OUTPUT
if [ -z $WD ]; then WD=$(pwd); fi
echo WD is $WD
/slipstream/usr/local/bin/ngsplot/bin/ngs.plot.r -G hg38 -R bed -C $BAM_FILE -O $WD/$OUTPUT -E $BED_FILE -FL 375 -L 1000 

tmp=tmp_$(basename $OUTPUT)
mkdir $tmp
f=$WD/$OUTPUT".zip"
echo $f; unzip -j -d $tmp $f; new=$(basename $f .zip); mv $tmp/heatmap.RData $WD/"$new".RData; rm $tmp/*;
rm -r $tmp

