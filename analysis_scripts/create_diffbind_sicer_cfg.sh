#!/bin/bash
#make a bunch of cfg files for diffbind with lines like:
#H7_1,H7,hESC,hESC_H7,H3K4ME3,1,reads/H7_H3K4ME3_R1.bam,H7_c,reads/H7_input.bam,peaks/H7_H3K4ME3_R1.narrowPeak,narrow
WD=/slipstream/galaxy/uploads/working/qc_framework/output
LDIR=$WD/cfg_parts_sicer
RAWDIR=$WD/raw_sicer
if [ ! -d $LDIR ]; then mkdir $LDIR; fi
if [ ! -d $RAWDIR ]; then mkdir $RAWDIR; fi
HEADER=SampleID,Tissue,Factor,Condition,Treatment,Replicate,bamReads,ControlID,bamControl,Peaks,PeakCaller
echo $HEADER > $LDIR/header.line
CFG=$WD/qc_config.csv
ids=($(cat $CFG | awk '{FS=",";OFS="_";ORS=" "} {if (NR > 2) print $2,$3,$4}'))
#echo ${ids[0]}
#echo ${ids[1]}
#make a lot of partial cfg files that will be catted together at the end
declare -A id2sicer
declare -a ids_order
for id in ${ids[@]}; do
  if [ ! $id = ${id/input/""} ]; then
     continue
  fi
#  echo $id
  input=$(echo $id | awk 'BEGIN {FS="_"} {print $1}')_input_pooled
  pooled=$(echo $id | awk 'BEGIN {FS="_"; OFS="_"} {print $1,$2}')_pooled
  sicer_dir=$WD/$pooled/$pooled"_sicer"
  #echo $sicer_dir
# declare -A id2sicer
  if [ ! -d $sicer_dir ]; then continue; fi #convert sicer results to diffbind compatible raw format -> chr start end pval
#  if [ -z $windows ]; then
    windows=( $(echo $(ls $sicer_dir) | awk 'BEGIN {RS=" "; FS="[w_g]"; ORS=" "} $0 ~"w.+_g" {print $2}') )
    gaps=( $(echo $(ls $sicer_dir) | awk 'BEGIN {RS=" "; FS="[w_g]"; ORS=" "} $0 ~"w.+_g" {print $4}') )
    i=0
    w=${windows[$i]}
    g=${gaps[$i]}
    #echo $i
    tmp=$(ls $sicer_dir/*"$w"*"$g"*/*-islands-summary-FDR.05)
    tmp=${tmp//$w/--WIN--}
    tmp=${tmp//$g/--GAP--}
    echo $tmp
    id2sicer[$id]=$tmp; ids_order+=( $id )
#  fi
done

for id in ${ids_order[@]}; do
 echo "$id" ----- $(basename "${id2sicer["$id"]}") 
done


exit 0



  for sres in $sicer_dir/w*/*-islands-summary-FDR.05; do
    as_raw=$RAWDIR/$(basename ${sres/-islands-summary-FDR.05/.raw})
    if [ ! -f $as_raw ]; then
      cat $sres | awk 'BEGIN {FS="\t"; OFS="\t"} {print $1,$2,$3,$7}' > $as_raw
    fi
#    id2sicer[$id]=$as_raw
    #echo $sres
  done
  echo $id2sicer
  #echo $sicer_dir
#  echo $id $input
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

CFGDIR=$WD/diffbind_configs_sicer
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
