#!/bin/bash
#loads a set of raw fastq files from input config file
#runs qc_rep_runner.sh once per raw fastq and qc_pooled_runner.sh once per set of replicates on a merged bam file

#load a config file
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
#some useful global functions and variabls
export LOG_FILE=$OUT_DIR/samples.log
declare -Ag sample2bamjob
declare -Ag pooled2bamjob
function parse_jid () 
{ #parses the job id from output of qsub
	if [[ -z $1 ]]; then
	echo parse_jid expects output of qsub as first input but input was empty! stop
	exit 1
	fi
	JOBID=$(awk -v RS=[0-9]+ '{print RT+0;exit}' <<< "$1") #returns JOBID	
	echo $JOBID
}
export -f parse_jid
function log () 
{ #appends input string to global log file
	if [[ $# -gt 1 ]]; then
	echo expects single quoted string! stop
	exit 1
	fi
	
	if [[ -z $1 ]]; then
	echo expects single quoted string! stop
	exit 1
	fi
	echo "$1" >> $LOG_FILE
}
export -f log

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
TMP_POOL_JIDS=$OUT_DIR/tmp.pooled_jids
TMP_SAMPLE_JIDS=$OUT_DIR/tmp.sample_jids
R=1
while [ $R -le ${#RAW[@]} ]; do
sample_id=""
i=0
input_index=-1 #the position of input/histone modification in sample ids
while [ $i -lt $(( $NPARAM - 1 )) ]; do
col=$(( $i + 2 ))
param=$(tail -n +3 $CFG | awk -v col=$col -v row=$R 'BEGIN {FS=","; OFS=""} {if (NR == row) {print $col}}')
if echo $param | grep -iq input; then
input_index=$i
fi
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
echo input index is $input_index
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

while [ $i -lt ${#RAW[@]} ]; do
	sample_id=$(head -n $(( $i + 1 )) $TMP_SAMPLE | tail -n 1)
	if echo $sample_id | grep -iq input; then
    		echo $sample_id
		input=$OUT_DIR/$sample_id.fastq
		ln ${RAW[$i]} $input
		bam_job_id=$(bash qc_rep_runner.sh $input)
		sample2bamjob[$sample_id]=$bam_job_id
	fi
	i=$(( $i + 1 ))
done
#pooled input jobs
#for each unique pooled_id, if input submit all matching reps
#!/bin/bash
a=( $(cat $OUT_DIR/tmp.sample_ids) )
b=( $(cat $OUT_DIR/tmp.pooled_ids | sort | uniq) )
for key in ${b[@]}; do
	echo $key
	if ! $(echo $key | grep -iq input); then
        	continue
	fi
	topool=()
	topool_jobs=""
	for samp in ${a[@]}; do
		if echo $samp | grep -iq $key; then
			topool+=($samp.bam)
			topool_jobs=$topool_jobs","${sample2bamjob["$samp"]}
		fi
	done
	topool_jobs=${topool_jobs/","/""} #remove leading comma
	poolstr=${topool[@]}
	poolstr=${poolstr//" "/";"} #fill whitespace
	#if [ ${#topool[@]} -eq 1 ]; then
	#	echo pooling not necessary, just link for $key.bam to ${topool[0]}.bam
	#	bash qc_pool_reps.sh $topool_jobs $poolstr
		
	#else
		echo gonna pool ${topool[@]} into $key.bam
		pool_job_id=$(bash qc_pool_reps.sh $topool_jobs $poolstr $OUT_DIR/"$key"_pooled.bam)
		pooled2bamjob["$key"]=$pool_job_id
	#fi
done

#submit noninput jobs
i=0
while [ $i -lt ${#RAW[@]} ]; do
        sample_id=$(head -n $(( $i + 1 )) $TMP_SAMPLE | tail -n 1)
        if ! echo $sample_id | grep -iq input; then
                echo $sample_id
                treat=$OUT_DIR/$sample_id.fastq
                ln ${RAW[$i]} $treat
		#match sample to appropriate pooled input
		key=$(echo $sample_id | rev | cut -d _ -f 3- | rev)
		input=""
		for samp in "${!pooled2bamjob[@]}"; do
		if $(echo $samp | grep -iq "$key".*input); then
                	input=$samp
			#echo AAAA $samp AAAA
        	fi
		done
		input_jid="${pooled2bamjob["$input"]}"
		#input=$(echo $sample_id | awk 'BEGIN {FS="_"; OFS="_"} {M=NF-1; $NF=""; $M="input"; print $0}')"pooled.bam"
                bam_job_id=$(bash qc_rep_runner.sh $treat $input $input_jid)
                sample2bamjob[$sample_id]=$bam_job_id
        fi
        i=$(( $i + 1 ))
done
#pool noninput bams
for key in ${b[@]}; do
        echo $key
        if $(echo $key | grep -iq input); then
                continue
        fi
        topool=()
        topool_jobs=""
        for samp in ${a[@]}; do
                if echo $samp | grep -iq $key; then
                        topool+=($samp.bam)
                        topool_jobs=$topool_jobs","${sample2bamjob["$samp"]}
                fi
        done
        topool_jobs=${topool_jobs/","/""} #remove leading comma
        poolstr=${topool[@]}
        poolstr=${poolstr//" "/";"} #fill whitespace
        #if [ ${#topool[@]} -eq 1 ]; then
        #       echo pooling not necessary, just link for $key.bam to ${topool[0]}.bam
        #       bash qc_pool_reps.sh $topool_jobs $poolstr

        #else
	pooled_bam=$OUT_DIR/"$key"_pooled.bam
	echo $topool_jobs $poolstr $pooled_bam
        echo gonna pool ${topool[@]} into $key.bam
        pool_job_id=$(bash qc_pool_reps.sh $topool_jobs $poolstr $pooled_bam)
        pooled2bamjob["$key"]=$pool_job_id

	#match sample to appropriate pooled input
        inkey=$(echo $key | rev | cut -d _ -f 2- | rev)
	input=""
        for samp in "${!pooled2bamjob[@]}"; do
        if $(echo $samp | grep -iq "$inkey".*input); then
	         input=$samp
                 #echo AAAA $samp AAAA
        fi
        done
        input_jid="${pooled2bamjob["$input"]}"
	inputtreatpoooled=$pool_job_id,$input_jid
	input_bam=$OUT_DIR/$input"_pooled.bam"
	echo waiting for bam pool jobs $inputtreatpoooled to run macs with $pooled_bam";"$input_bam $key:$inkey
        #fi
	poolpeaks_job_id=$(bash qc_pool_runner.sh $inputtreatpoooled $pooled_bam";"$input_bam)
	
done
#submit pooled noninput jobs



for samp in "${!sample2bamjob[@]}"; do
echo "$samp","${sample2bamjob["$samp"]}" >> $TMP_SAMPLE_JIDS
done
for samp in "${!pooled2bamjob[@]}"; do
echo "$samp","${pooled2bamjob["$samp"]}" >> $TMP_POOL_JIDS
done

#associative arrays cannot be exported
#export $sample2bamjob
#export $pooled2bamjob

