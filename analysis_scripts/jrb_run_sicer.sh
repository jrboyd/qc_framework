#!/bin/bash
#submit with:
#qsub -wd $res_dir -v input_dir=$out_dir,$t=$(basename $bed),c=$(basename $input_bed),w=$w,g=$g,out_dir=$res_dir jrb_run_sicer.sh
echo working in $(pwd)
if [ ! -d $input_dir ]; then echo input directory $input_dir not found!; exit 1; fi
if [ ! -f $t ]; then echo treatment file $t not found!; exit 1; fi
if [ ! -f $c ]; then echo control file $c not found!; exit 1; fi
if [ ! -d $out_dir ]; then echo output directory $out_dir not found!; exit 1; fi
if [ -z $g ]; then echo gap g not supplied!; exit 1; fi
if [ -z $w ]; then echo window w not supplied!; exit 1; fi
echo input_dir is $input_dir
echo out_dir is $out_dir
echo treatment is $t
echo control is $c
echo gap is $g
echo window is $w
cmd="bash /slipstream/home/joeboyd/lib/SICER_V1.1/SICER/SICER.sh $input_dir $(basename $t) $(basename $c) $out_dir hg38 5 $w 375 .84 $g .05"
echo cmd is \"$cmd\"
echo start! $(date)
$cmd
echo done! $(date)

#rm $out_dir/*removed.bed
#rm $out_dir/*island.bed
#rm $out_dir/*-islandfiltered-normalized.wig
#rm $out_dir/*scoreisland
