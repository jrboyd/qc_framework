for f in output_diff_ESR1/*/*pooled.bam; do 
  insub=${f/input/""} 
  if [ $f == $insub ]; then 
    #input=$(echo $f | awk 'BEGIN {FS="_"; OFS="_"} {$4="input"; $7="input"; print $0}')
    input=$(echo $f | awk 'BEGIN {FS="_"; OFS="_"} {$4="input"; $6="input"; print $0}')
    png=$(basename $f .bam).chr5.png
    cnts=$(basename $f .bam).chr5.txt
    if [ ! -f $input ]; then
	echo NOT FOUND: $input
        continue
    fi
    if [ ! -s $png ] || [ ! -s $cnts ]; then
      echo RUN $(basename $f)
 
      cmd="plotFingerprint -b $f $input -plot $png --region 5 --outRawCounts $cnts --numberOfProcessors=1"
#      echo $cmd
      qsub -cwd -v cmd="$cmd" blank_wrapper.sh
    else
      echo SKIP $(basename $f)
    fi
    #plotFingerprint -b $f $input -plot $png
  fi
done
