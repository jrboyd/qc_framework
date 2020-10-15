#!/bin/bash
rm run_broadpeak_cmds.sh
rm run_broadpeak_cmds.forceOverwrite.sh
mark=$1
if [ -z $mark ]; then mark=H3K27ME3; fi
bams=$(ls outpu*/*$mark*/*bam); 
for b in $bams; 
  do if [ $b = ${b//input/""} ]; then 
    bi=$b; 
	bi=${bi//$mark/input}; 
	bi=${bi//R1/pooled}; 
	bi=${bi//R2/pooled}; 
	if [ $b = $bi ]; then exit 1; fi
	if [ -f $b ] && [ -f $bi ]; then 
	  #echo $b $bi;
          if [ ! -f ${b/.bam/_broadCall_model.r} ]; then
	    echo "qsub -cwd /slipstream/home/joeboyd/scripts/run_cmd.sh \"macs2 callpeak -t $b -c $bi --broad -g hs --broad-cutoff 0.1 --name $(basename $b .bam)_broadCall --outdir $(dirname $b)\"" >> run_broadpeak_cmds.sh
          else
            echo "qsub -cwd /slipstream/home/joeboyd/scripts/run_cmd.sh \"macs2 callpeak -t $b -c $bi --broad -g hs --broad-cutoff 0.1 --name $(basename $b .bam)_broadCall --outdir $(dirname $b)\"" >> run_broadpeak_cmds.forceOverwrite.sh
          fi
	fi; 
  fi; done
