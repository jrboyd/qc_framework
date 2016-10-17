#!/bin/bash
SCRIPT_DIR=/slipstream/galaxy/uploads/working/qc_framework/analysis_scripts
#resubmit using ctrl input for e2 ChIP-seq
BAM_FILE=/slipstream/galaxy/uploads/working/qc_framework/output_drugs/MCF7_e2_H3K4ME3_pooled/MCF7_e2_H3K4ME3_pooled.bam:/slipstream/galaxy/uploads/working/qc_framework/output_drugs/MCF7_ctrl_input_pooled/MCF7_ctrl_input_pooled.bam
BED_FILE=/slipstream/galaxy/uploads/working/qc_framework/MCF7_ESR1_peaks/ESR1_peaks_4ngs.biased.ext.bed
OUTPUT=MCF7_e2_H3K4ME3_vs_ctrl_input
WD=/slipstream/galaxy/uploads/working/qc_framework/ngsplot_MCF7_e2_ChIP_vs_ctrl_input
mkdir $WD
qsub -pe threads 8 -wd $WD -v NGSPLOT=$NGSPLOT,BAM_FILE=$BAM_FILE,WD=$WD,OUTPUT=$OUTPUT,BED_FILE=$BED_FILE $SCRIPT_DIR/jrb_run_ngsplots_FL_2500.sh

BAM_FILE=/slipstream/galaxy/uploads/working/qc_framework/output_drugs/MCF7_e2_H3K4AC_pooled/MCF7_e2_H3K4AC_pooled.bam:/slipstream/galaxy/uploads/working/qc_framework/output_drugs/MCF7_ctrl_input_pooled/MCF7_ctrl_input_pooled.bam
#BED_FILE is /slipstream/galaxy/uploads/working/qc_framework/MCF7_ESR1_peaks/ESR1_peaks_4ngs.ext.bed
OUTPUT=MCF7_e2_H3K4AC_vs_ctrl_input

qsub -pe threads 8 -wd $WD -v NGSPLOT=$NGSPLOT,BAM_FILE=$BAM_FILE,WD=$WD,OUTPUT=$OUTPUT,BED_FILE=$BED_FILE $SCRIPT_DIR/jrb_run_ngsplots_FL_2500.sh

BAM_FILE=/slipstream/galaxy/uploads/working/qc_framework/output_drugs/MCF7_e2_H3K27ME3_pooled/MCF7_e2_H3K27ME3_pooled.bam:/slipstream/galaxy/uploads/working/qc_framework/output_drugs/MCF7_ctrl_input_pooled/MCF7_ctrl_input_pooled.bam
#BED_FILE is /slipstream/galaxy/uploads/working/qc_framework/MCF7_ESR1_peaks/ESR1_peaks_4ngs.ext.bed
OUTPUT=MCF7_e2_H3K27ME3_vs_ctrl_input
#WD is /slipstream/galaxy/uploads/working/qc_framework/MCF7_ESR1_peaks

qsub -pe threads 8 -wd $WD -v NGSPLOT=$NGSPLOT,BAM_FILE=$BAM_FILE,WD=$WD,OUTPUT=$OUTPUT,BED_FILE=$BED_FILE $SCRIPT_DIR/jrb_run_ngsplots_FL_2500.sh

BAM_FILE=/slipstream/galaxy/uploads/working/qc_framework/output_drugs/MCF7_e2_H3K27AC_pooled/MCF7_e2_H3K27AC_pooled.bam:/slipstream/galaxy/uploads/working/qc_framework/output_drugs/MCF7_ctrl_input_pooled/MCF7_ctrl_input_pooled.bam
#BED_FILE is /slipstream/galaxy/uploads/working/qc_framework/MCF7_ESR1_peaks/ESR1_peaks_4ngs.ext.bed
OUTPUT=MCF7_e2_H3K27AC_vs_ctrl_input

qsub -pe threads 8 -wd $WD -v NGSPLOT=$NGSPLOT,BAM_FILE=$BAM_FILE,WD=$WD,OUTPUT=$OUTPUT,BED_FILE=$BED_FILE $SCRIPT_DIR/jrb_run_ngsplots_FL_2500.sh
