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




isBroad=F
SCRIPT_DIR=/slipstream/galaxy/production/toolshed-repositories/toolshed.g2.bx.psu.edu/repos/modencode-dcc/idr_package/6f6a9fbe264e/idr_package
gen=hg38
gen=/slipstream/galaxy/production/galaxy-dist/tool-data/bigbedwig/$gen.chrom.sizes
Rscript $SCRIPT_DIR/batch-consistency-analysis.r $SCRIPT_DIR $PEAKS1 $PEAKS2 -1 0 $isBroad p.value $gen $PREFIX.Rout.txt $PREFIX.overlapped-peaks.txt $PREFIX.npeaks-aboveIDR.txt $PREFIX.em.sav $PREFIX.uri.sav
#>batch-consistency-analysis.r \$SCRIPT_PATH $input1 $input2 $halfwidth $overlap $option $sigvalue $gtable $rout $aboveIDR $ratio $emSav $uriSav
#    <data format="txt" name="rout" label="IDR.Rout.txt"/>
#    <data format="txt" name="aboveIDR" label="IDR.npeaks-aboveIDR.txt"/>
#    <data format="txt" name="ratio" label="IDR.overlapped-peaks.txt"/>
#    <data format="txt" name="emSav" label="IDR.em.sav"/>
#    <data format="txt" name="uriSav" label="IDR.uri.sav"/>

