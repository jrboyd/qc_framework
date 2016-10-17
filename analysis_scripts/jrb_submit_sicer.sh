#!/bin/bash
CL=(MCF10A MCF7 MDA231)
#CL=(H1)
HM=(H3K27ME3 H3K27AC)
DT=(_e2_ _e2bza_ _gc10_ _bza_ _ctrl_ _gc10bza_)
gaps=(600 1200 1125 2400)
wins=(200 300 375 400)
#gaps=600
#DT=(_)
WD=/slipstream/galaxy/uploads/working/diffbind_drugs/reads/as_bed
INPUTS_DIR=/slipstream/galaxy/uploads/working/diffbind_drugs/reads/inputs_pooledByCat
if [ ! -e $WD ]
then
	echo working directory $WD not found!
	exit 1
fi
for outdir in /slipstream/galaxy/uploads/working/qc_framework/output_drugs; do
for hm in ${HM[@]}; do
for bam in $outdir/*pooled/*$hm*.bam; do
if [ ! -f $bam ]; then continue; fi
#echo $bam
bed=${bam/.bam/.bed}
input_bam=${bam//$hm/input}
if [ ! -f $input_bam ]; then echo can\'t find input! $input_bam; exit 1; fi
input_bed=${input_bam/.bam/.bed}
#check bed files exist and convert bam if needed
if [ ! -f $bed ]; then echo converting $(basename $bam) to bed; bedtools bamtobed -i $bam > $bed; fi
if [ ! -f $input_bed ]; then echo converting $(basename $input_bam) to bed; bedtools bamtobed -i $input_bam > $input_bed; fi
	out_dir=${bed/".bed"/"_sicer"}
	if [ ! -d $out_dir ]; then mkdir $out_dir; fi
        if [ ! -f $out_dir/$(basename $bed) ]; then ln $bed $out_dir; fi
	if [ ! -f $out_dir/$(basename $input_bed) ]; then ln $input_bed $out_dir; fi

	i=0
	while [ $i -lt ${#gaps[@]} ]; do
		g=${gaps[$i]}
		w=${wins[$i]}
		res_dir=$out_dir/w"$w"_g"$g"
		if [ -d $res_dir ]; then 
			
			if [ $(ls -A "$res_dir" | wc -l) -gt 2 ]; then
			   echo ------- res_dir $res_dir exists and has results, skip. delete dir if incomplete; i=$(($i + 1)); continue
			#else
			   #echo -+-+-+- res_dir $res_dir is empty, run
			fi
		fi
		echo +++++++ submit for $res_dir
		if [ ! -d $res_dir ]; then mkdir $res_dir; fi
	        if [ ! -f $res_dir/$(basename $bed) ]; then ln $bed $res_dir; fi
	        if [ ! -f $res_dir/$(basename $input_bed) ]; then ln $input_bed $res_dir; fi

		qsub -wd $res_dir -v input_dir=$res_dir,t=$(basename $bed),c=$(basename $input_bed),w=$w,g=$g,out_dir=$res_dir /slipstream/galaxy/uploads/working/qc_framework/analysis_scripts/jrb_run_sicer.sh
		i=$(($i + 1 ))
	done
#echo "qsub -wd $out_dir -v t=$bed,c=$input_bed jrb_run_sicer.sh"
#cmd="bash /slipstream/home/joeboyd/lib/SICER_V1.1/SICER/SICER.sh $WD $(basename $t) $(basename $c) $out_dir hg38 5 200 375 .84 600 .05"
#cd ..
done; done; done
