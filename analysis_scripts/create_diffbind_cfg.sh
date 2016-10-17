#!/bin/bash
#make a bunch of cfg files for diffbind with lines like:
#H7_1,H7,hESC,hESC_H7,H3K4ME3,1,reads/H7_H3K4ME3_R1.bam,H7_c,reads/H7_input.bam,peaks/H7_H3K4ME3_R1.narrowPeak,narrow
WD=/slipstream/galaxy/uploads/working/qc_framework/output_drugs_with_merged_inputs
LDIR=$WD/cfg_parts
if [ ! -d $LDIR ]; then mkdir $LDIR; fi
HEADER=SampleID,Tissue,Factor,Condition,Treatment,Replicate,bamReads,ControlID,bamControl,Peaks,PeakCaller
echo $HEADER > $LDIR/header.line
CFG=$WD/qc_config_drug_treatments_with_merged_inputs.csv
ids=($(cat $CFG | awk '{FS=",";OFS="_";ORS=" "} {if (NR > 2) print $2,$3,$4}'))
#echo ${ids[0]}
#echo ${ids[1]}
#make a lot of partial cfg files that will be catted together at the end
for id in ${ids[@]}; do
  if [ ! $id = ${id/input/""} ]; then
     continue
  fi
#  echo $id
  input=$(echo $id | awk 'BEGIN {FS="_"} {print $1}')_input_pooled
  echo $id $input
  cell=$(echo $id | awk 'BEGIN {FS="_"} {print $1}')
#  drug=$(echo $id | awk 'BEGIN {FS="_"} {print $2}')
  mark=$(echo $id | awk 'BEGIN {FS="_"} {print $2}')
  rep=$(echo $id | awk 'BEGIN {FS="_"} {print $3}')
  line=$id,$cell,$cell"_"$mark,$mark,untreated,${rep/"R"/""},$WD/$id/$id.bam,$input,$WD/$input/$input.bam,$WD/$id/$id"_peaks.narrowPeak",narrowPeak
  echo $line > $LDIR/$id.line
  #echo $line
done

cells=($(cat $CFG | awk '{FS=",";OFS="_"} {if (NR > 2) print $2}' | sort | uniq))
#echo $cells; echo ${cells[0]}; echo ${cells[1]}
marks=($(cat $CFG | awk '{FS=",";OFS="_"} {if (NR > 2) print $3}' | sort | uniq))
reps=($(cat $CFG | awk '{FS=",";OFS="_"} {if (NR > 2) print $4}' | sort | uniq))

CFGDIR=$WD/diffbind_configs
if [ ! -d $CFGDIR ]; then mkdir $CFGDIR; fi
#test same mark across cell lines
for m in ${marks[@]}; do
  if [ $m = input ]; then
     continue
  fi
  echo $m
  cat $LDIR/header.line  $LDIR/*$m*.line > $CFGDIR/diffbind_config_"$m".csv
done

#echo $cells
#cells=($(cat $CFG | awk '{FS=",";OFS="_";ORS=" "} {if (NR > 2) print $2}')
