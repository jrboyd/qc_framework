#!/bin/bash
QC_DIR=output_diff_ESR1
QC_DIR=$(readlink -f $QC_DIR)
MARK=ESR1
peak_files=$(ls $QC_DIR/*$MARK*/*R[0-9]_peaks.narrowPeak | awk 'BEGIN {ORS=" "} {print $0}')
consensus_file="$MARK"_consensus_narrowPeak.bed
consensus_file=$(readlink -f $consensus_file)
if [ -f $consensus_file ]; then
  echo using previous consensus file $consensus_file
else
  echo writing consensus of $peak_files to $consensus_file
  Rscript job_scripts/cmd_narrowPeak_consensus.R -wd $(pwd) -out $consensus_file -mincov 2 $peak_files
fi
BAMS=$(ls $QC_DIR/*$MARK*/*R[0-9].bam | awk 'BEGIN {ORS=" "} {print $0}')


BED=ESR1_consensus_narrowPeak.bed
#BAMS="output_diff_ESR1/BT474_ESR1_pooled/BT474_ESR1_pooled.bam output_diff_ESR1/G5_ESR1_pooled/G5_ESR1_pooled.bam output_diff_ESR1/M3_ESR1_pooled/M3_ESR1_pooled.bam output_diff_ESR1/P6_ESR1_pooled/P6_ESR1_pooled.bam \
#output_diff_ESR1/ERneg1_ESR1_pooled/ERneg1_ESR1_pooled.bam output_diff_ESR1/G6_ESR1_pooled/G6_ESR1_pooled.bam output_diff_ESR1/MCF7_Cock90-ESR1_pooled/MCF7_Cock90-ESR1_pooled.bam output_diff_ESR1/P7_ESR1_pooled/P7_ESR1_pooled.bam \
#output_diff_ESR1/ERneg2_ESR1_pooled/ERneg2_ESR1_pooled.bam output_diff_ESR1/G7_ESR1_pooled/G7_ESR1_pooled.bam output_diff_ESR1/MCF7_ESR1_pooled/MCF7_ESR1_pooled.bam output_diff_ESR1/T47D_ESR1_pooled/T47D_ESR1_pooled.bam \
#output_diff_ESR1/G1_ESR1_pooled/G1_ESR1_pooled.bam output_diff_ESR1/G8_ESR1_pooled/G8_ESR1_pooled.bam output_diff_ESR1/P3_ESR1_pooled/P3_ESR1_pooled.bam output_diff_ESR1/TAMR_ESR1_pooled/TAMR_ESR1_pooled.bam \
#output_diff_ESR1/G2_ESR1_pooled/G2_ESR1_pooled.bam output_diff_ESR1/M1_ESR1_pooled/M1_ESR1_pooled.bam output_diff_ESR1/P4_ESR1_pooled/P4_ESR1_pooled.bam output_diff_ESR1/ZR75_ESR1_pooled/ZR75_ESR1_pooled.bam \
#output_diff_ESR1/G4_ESR1_pooled/G4_ESR1_pooled.bam output_diff_ESR1/M2_ESR1_pooled/M2_ESR1_pooled.bam output_diff_ESR1/P5_ESR1_pooled/P5_ESR1_pooled.bam"
OUT_NPZ=${BED/.bed/.npz}
#OUT_PDF=${BED/.bed/.pdf}
OUT_MAT=${BED/.bed/.txt}


echo BED is $BED
echo BAMS are $BAMS
echo OUT_NPZ is $OUT_NPZ
#echo OUT_PDF is $OUT_PDF
echo OUT_MAT is $OUT_MAT

if [ -f $OUT_NPZ ]; then
  echo using previous bins $OUT_NPZ
else
  echo writing bins to $OUT_NPZ
  multiBamSummary BED-file --BED $BED \
  --bamfiles $BAMS \
  -out $OUT_NPZ 
fi

pdf=${BED/.bed/.correlation.pdf} 
echo correlation pdf is $pdf
echo correlation matrix is $OUT_MAT
plotCorrelation --corData $OUT_NPZ \
--plotFile  $pdf \
--corMethod spearman --whatToPlot scatterplot \
--removeOutliers \
--outFileCorMatrix $OUT_MAT

pdf=${BED/.bed/.pca.pdf}
echo pca pdf is $pdf
plotPCA --corData $OUT_NPZ \
--plotFile $pdf
