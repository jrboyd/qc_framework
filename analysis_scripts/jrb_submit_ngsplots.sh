#toPlot=(H3K4ME3 H3K4AC H3K27AC H3K27ME3 H4K20ME3 H4K12AC)
#cells_toPlot=(BT474 MCF7 T47D TAMR ZR75)
cells_toPlot=(MCF10A MCF7)
toPlot=(H3K4ME3 H3K27ME3 H3K27AC H3K4AC H4K20ME3 H4K12AC H3K27me3 H3K4me3 H3K36ME3 CTCF RUNX1 RUNX2 ESR1-ctrl ESR1-e2 control-ESR1 control-RNAPII e2-ESR1 e2-RNAPII fulv-ESR1 fulv-RNAPII tam-ESR1 tam-RNAPII) # H3K4me2 K27 K4 c-Myc)
#toPlot=(_ESR1_)
#toPlot=(K27 K4 c-Myc)
#BAM_DIR=$(pwd)/hESC_bivalency
BAM_DIR=/slipstream/galaxy/uploads/working/qc_framework/output_MCF7_e2_response2
#BAM_DIR=/slipstream/galaxy/uploads/working/qc_framework/output_diff_ESR1
#WD=/slipstream/galaxy/uploads/working/qc_framework/ngsplot_all_drugs_5kb_prom.bed
WD=/slipstream/galaxy/uploads/working/qc_framework/MCF7_ESR1_peaks_biased_e2_response2
#BED_FILE=/slipstream/galaxy/uploads/working/gencode.v21.annotation.RP_all_transcripts.bed
SCRIPT_DIR=/slipstream/galaxy/uploads/working/qc_framework/analysis_scripts
#BED_FILE=$SCRIPT_DIR/gene_bodies_no_promoters_v3.bed
#BED_FILE=$SCRIPT_DIR/gencode.v21.gene.2k_trimmed.bed
#BED_FILE=/slipstream/galaxy/uploads/working/qc_framework/MCF7_ESR1_peaks/ESR1_peaks_4ngs.ext.bed
BED_FILE=/slipstream/galaxy/uploads/working/qc_framework/MCF7_ESR1_peaks/ESR1_peaks_4ngs.biased.ext.bed
#BED_FILE=/slipstream/galaxy/uploads/working/qc_framework/BRCA_enhancers_by_type/enhancers_by_type_no_gb_extended.bed
#BED_FILE=$SCRIPT_DIR/promoters_5kb_counted.bed
if [ ! -f $BED_FILE ]; then
	echo no such file $BED_FILE
	exit 1
fi
mkdir $WD
for f in $BAM_DIR/*pooled/*.bam
	do export NGSPLOT=$NGSPLOT
#	echo $f
	input_file=$f
        keep=0
        for tp in ${cells_toPlot[@]}; do
          if [ $f != ${f/$tp/""} ]; then
            keep=1
          fi
        done
        if [ $keep == 0 ]; then
          continue
        fi
	for tp in ${toPlot[@]}; do
		input_file=${input_file//$tp/input}
		input_file=${input_file//_R1/_pooled}
		input_file=${input_file//_R2/_pooled}
                input_file=${input_file//_R3/_pooled}
	done
	if [ $input_file == $f ]
		then continue
	fi
        if [ ! -f $f ]; then
          echo TREATMENT NOT FOUND $f
          continue
        fi
        if [ ! -f $input_file ]; then
          echo INPUT NOT FOUND $input_file
          continue
        fi

	OUTPUT=$(basename $f .bam)
#	echo BAM is $f
#	echo INPUT is $input_file
#	echo OUTPUT is $OUTPUT
#	echo BED is $BED_FILE
	qsub -pe threads 8 -wd $WD -v NGSPLOT=$NGSPLOT,BAM_FILE=$f:$input_file,WD=$WD,OUTPUT=$OUTPUT,BED_FILE=$BED_FILE $SCRIPT_DIR/jrb_run_ngsplots_FL_2500.sh
	echo $f:$input_file
	echo $OUTPUT
	#bash jrb_run_ngsplots.sh $f $WD &
#	exit 0
done
