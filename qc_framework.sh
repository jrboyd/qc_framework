#!/bin/bash
#loads a set of raw fastq files from input config file
#runs qc_rep_runner.sh once per raw fastq and qc_pooled_runner.sh once per set of replicates on a merged bam file
CFG=$1
if [ -z $CFG ]; then
	CFG=$(pwd)/qc_config.csv
fi
CFG=$(readlink -f $CFG)
if [ ! -e $CFG ]; then
	echo $CFG config file not found! stop
	exit 1
fi
echo loading config file $CFG
#parse first line as input directory
IN_DIR=$(head -n 1 $CFG | awk 'BEGIN {FS="="} {print $2}')
IN_DIR=$(readlink -f $IN_DIR)
if [ ! -d $IN_DIR ]; then
	echo $IN_DIR does not exist! stop
	exit 1
fi
#parse second line as working/output directory
OUT_DIR=$(head -n 2 $CFG | tail -n 1 | awk 'BEGIN {FS="="} {print $2}')
if [ -d $OUT_DIR ]
then
    while true; do
        read -p "$OUT_DIR exists, should it be removed and overwritten? script will exit if no." yn
        case $yn in
            [Yy]* ) rm -r $OUT_DIR; break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
fi

if [ ! -d $OUT_DIR ]; then
        echo $OUT_DIR does not exist, creating
	mkdir $OUT_DIR
        OUT_DIR=$(readlink -f $OUT_DIR)
fi

#all remaining lines should contain info for 1 fastq file
NF=$(tail -n +3 $CFG | awk 'BEGIN {FS=","} {if (NR == 1) print NF}')
NPARAM=$(( $NF - 1 ))
RAW=( $(tail -n +3 $CFG | awk 'BEGIN {FS=","} {if ($1 != "") print $1}') )
echo configuring for ${#RAW[@]} raw fastq files, described by $NPARAM paramters
#check that all fastq exist before doing anything
for f in ${RAW[@]}; do
echo $f
if [ ! -e $IN_DIR/$f ]; then
	echo $ID_DIR/$f does not exist! bad config! stop
	exit 1
fi
done
#cocatenate paramters to sample_id, excluded last column (reps) for pooled_ids
TMP_POOL=$OUT_DIR/tmp.pooled_ids
TMP_SAMPLE=$OUT_DIR/tmp.sample_ids

R=1
while [ $R -le ${#RAW[@]} ]; do
sample_id=""
i=0
while [ $i -lt $(( $NPARAM - 1 )) ]; do
col=$(( $i + 2 ))
param=$(tail -n +3 $CFG | awk -v col=$col -v row=$R 'BEGIN {FS=","; OFS=""} {if (NR == row) {print $col}}')
sample_id=$sample_id"_"$param
i=$(( $i + 1 ))
done
sample_id=${sample_id/_/""}
pooled_id=$sample_id
rep=$(tail -n +3 $CFG | awk -v row=$R 'BEGIN {FS=","; OFS=""} {if (NR == row) print $NF}')
sample_id="$sample_id"_$rep
echo $pooled_id >> $TMP_POOL
echo $sample_id >> $TMP_SAMPLE
R=$(( $R + 1 ))
done
#check that all sample_ids are unique, report number of pooled_ids
total_samples=$(cat $TMP_SAMPLE | wc -l)
uniq_samples=$(sort $TMP_SAMPLE | uniq | wc -l)
#echo $total_samples $uniq_samples
if [ $total_samples -ne $uniq_samples ]; then
	echo all sample ids are not unique! stop
	cat $TMP_SAMPLE
	exit 1
fi
total_pooled=$(sort $TMP_POOL | uniq | wc -l)
#echo $total_pooled
echo $total_samples samples will be consolidated to $total_pooled pooled files

#submit input jobs
i=0


#submit non-input jobs
while [ $i -lt ${#RAW[@]} ]; do
	sample_id=$(head -n $(( $i + 1 )) $TMP_SAMPLE | tail -n 1)
	if echo $sample_id | grep -iq input; then
    		echo $sample_id
	fi
	i=$(( $i + 1 ))
done
