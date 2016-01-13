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
        read -p "$OUT_DIR exists, should it be [delete]d, [m]odified, [k]ill jobs from old submission and exit, or do [n]othing? modify will only rerun jobs whose output does not exists (including partial outputs from aborted jobs!). previous jobs will be killed" yn
        case $yn in
            delete ) if [ -f $OUT_DIR/tmp.all_jids ]; then echo clearing old jobs; all_jids=( $(cat $OUT_DIR/tmp.all_jids | awk 'ORS=" "') ); for jid in ${all_jids[@]}; do hidden=$(qdel $jid); done; fi; rm -r $OUT_DIR; mkdir $OUT_DIR; break;;
            [mM]* )  if [ -f $OUT_DIR/tmp.all_jids ]; then echo clearing old jobs; all_jids=( $(cat $OUT_DIR/tmp.all_jids | awk 'ORS=" "') ); for jid in ${all_jids[@]}; do hidden=$(qdel $jid); done; fi; break;;
	    [kK]* )  if [ -f $OUT_DIR/tmp.all_jids ]; then echo clearing old jobs; all_jids=( $(cat $OUT_DIR/tmp.all_jids | awk 'ORS=" "') ); for jid in ${all_jids[@]}; do hidden=$(qdel $jid); done; fi; exit;;
	    [nN]* )  exit;;
            * ) echo "Please answer m, k, n, or delete.";;
        esac
    done
fi

#if [ ! -d $OUT_DIR ]; then
 #       echo $OUT_DIR does not exist, creating
#	mkdir $OUT_DIR
        OUT_DIR=$(readlink -f $OUT_DIR)
cp $CFG $OUT_DIR/
#fi
#some useful global functions and variabls
export LOG_FILE=$OUT_DIR/samples.log
export ALL_JIDS=$OUT_DIR/tmp.all_jids
#echo "" >> $ALL_JIDS
export JOB_SCRIPTS=$(pwd)/job_scripts
declare -Ag sample2bam
declare -Ag sample2bamjob
declare -Ag sample2loose
declare -Ag sample2loosejob
declare -Ag pooled2bamjob
declare -Ag pooled2peak
declare -Ag pooled2peakjob
function parse_jid () 
{ #parses the job id from output of qsub
	if [[ -z $1 ]]; then
	echo parse_jid expects output of qsub as first input but input was empty! stop
	exit 1
	fi
	JOBID=$(awk -v RS=[0-9]+ '{print RT+0;exit}' <<< "$1") #returns JOBID	
	echo $JOBID >> $ALL_JIDS
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
		mkdir $OUT_DIR/$sample_id
		input=$OUT_DIR/$sample_id/$sample_id.fastq
		input_bam=${input/.fastq/.bam}
		ln ${RAW[$i]} $input
		bam_job_id=$(bash qc_rep_runner.sh $input)
		sample2bamjob[$sample_id]=$bam_job_id
		sample2bam[$sample_id]=$input_bam
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
	pooled_name="$key"_pooled
	if ! $(echo $key | grep -iq input); then
        	continue
	fi
	topool=()
	topool_jobs=""
	for samp in ${a[@]}; do
		if echo $samp | grep -iq $key; then
			rep_file=$OUT_DIR/$samp/$samp.bam
			#rep_file=$(readlink -f $rep_file)
			topool+=($rep_file)
			topool_jobs=$topool_jobs","${sample2bamjob["$samp"]}
		fi
	done
	mkdir $OUT_DIR/$pooled_name
	topool_jobs=${topool_jobs/","/""} #remove leading comma
	poolstr=${topool[@]}
	poolstr=${poolstr//" "/";"} #fill whitespace
	#if [ ${#topool[@]} -eq 1 ]; then
	#	echo pooling not necessary, just link for $key.bam to ${topool[0]}.bam
	#	bash qc_pool_reps.sh $topool_jobs $poolstr
		
	#else
		echo gonna pool ${topool[@]} into "$pooled_name".bam
		pool_job_id=$(bash qc_pool_reps.sh $topool_jobs $poolstr $OUT_DIR/$pooled_name/"$pooled_name".bam)
		pooled2bamjob["$pooled_name"]=$pool_job_id
	#fi
done

#submit noninput jobs
i=0
while [ $i -lt ${#RAW[@]} ]; do
        sample_id=$(head -n $(( $i + 1 )) $TMP_SAMPLE | tail -n 1)
        if ! echo $sample_id | grep -iq input; then
                echo $sample_id
		mkdir $OUT_DIR/$sample_id
                treat=$OUT_DIR/$sample_id/$sample_id.fastq
		treat_bam=${treat/.fastq/.bam}
                ln ${RAW[$i]} $treat
		#match sample to appropriate pooled input
		key=$(echo $sample_id | rev | cut -d _ -f 3- | rev)
		input=""
		for samp in "${!pooled2bamjob[@]}"; do
		if $(echo $samp | grep -iq "$key".*input); then
                	input=$samp
        	fi
		done
		input_bam=$OUT_DIR/$input/$input".bam"
		input_jid="${pooled2bamjob["$input"]}"
		#input=$(echo $sample_id | awk 'BEGIN {FS="_"; OFS="_"} {M=NF-1; $NF=""; $M="input"; print $0}')"pooled.bam"
                bam_job_id=$(bash qc_rep_runner.sh $treat $input_bam $input_jid)
                sample2bamjob[$sample_id]=$bam_job_id
		sample2bam[$sample_id]=$treat_bam
		loose_job_id=$(bash step_scripts/step6*.sh $treat_bam $input_bam "$bam_job_id","$input_jid")
		loose_peaks=${treat_bam/.bam/_loose_peaks.narrowPeak}
		sample2loose[$sample_id]=$loose_peaks
		sample2loosejob[$sample_id]=$loose_job_id
        fi
        i=$(( $i + 1 ))
done
#pool noninput bams, submit at the same time
for key in ${b[@]}; do
        echo $key
	pooled_name="$key"_pooled
        if $(echo $key | grep -iq input); then
                continue
        fi
	mkdir $OUT_DIR/$pooled_name
        topool=()
        topool_jobs=""
        for samp in ${a[@]}; do
                if echo $samp | grep -iq $key; then
			rep_file=$OUT_DIR/$samp/$samp.bam
                        #rep_file=$(readlink -f $rep_file)
                        topool+=($rep_file)
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
	pooled_bam=$OUT_DIR/$pooled_name/"$pooled_name".bam
	echo $topool_jobs $poolstr $pooled_bam
        echo gonna pool ${topool[@]} into $key.bam
        pool_job_id=$(bash qc_pool_reps.sh $topool_jobs $poolstr $pooled_bam)
        pooled2bamjob["$pooled_name"]=$pool_job_id

	#match sample to appropriate pooled input
        inkey=$(echo $key | rev | cut -d _ -f 2- | rev)
#	echo AAAA $inkey AAAA
	input=""
        for samp in "${!pooled2bamjob[@]}"; do
        if $(echo $samp | grep -iq "$inkey".*input); then
	         input="$samp"
        fi
        done
#	echo AAAA $input AAAA
        input_jid="${pooled2bamjob["$input"]}"
	inputtreatpoooled=$pool_job_id,$input_jid
	input_bam=$OUT_DIR/$input/$input".bam"
	echo waiting for bam pool jobs $inputtreatpoooled to run macs with $pooled_bam";"$input_bam $key:$inkey
        #fi
	poolpeaks_job_id=$(bash qc_pool_runner.sh $inputtreatpoooled $pooled_bam";"$input_bam)
	pooled2peak["$pooled_name"]="$pooled_name"_peaks.narrowPeak
	pooled2peakjob["$pooled_name"]="$poolpeaks_job_id"
	
done

#once all rep bams are done, submit bulk compare jobs
samp_jobs=""
samp_bams=""
for samp in "${!sample2bamjob[@]}"; do
	jid="${sample2bamjob["$samp"]}"
	bam="${sample2bam["$samp"]}"
	echo $jid---$bam
	samp_jobs="$samp_jobs,$jid" 
	samp_bams="$samp_bams;$bam"

done
samp_jobs=${samp_jobs/","/""} #remove leading comma
samp_bams=${samp_bams/";"/""}
echo all samp_jobs are $samp_jobs
#step5 args
#arg 1 bam files delimited by ;
#arg 2 output directory
#arg 3 job ids passed to hold_jid to wait for
step5_o=$(bash step_scripts/step5*.sh $samp_bams $OUT_DIR $samp_jobs)

#for sanity, i'll assume 2 and only 2 replicates when doing IDR, for more we'll need a round robin loop here and different output naming scheme
#PEAKS1
#PEAKS2 - 2 rep files
#PREFIX - prefix of output file (name without extension)
#script is job_scripts/run_IDR.sh
for samp in "${!pooled2peak[@]}"; do
	root=$(echo $samp | rev | cut -d "_" -f 2- | rev) 
	echo root for IDR $samp:$root
	if echo $root | grep -iq "input"; then
		echo skipping $root as input
		continue
	fi
	IDR_OUT=$OUT_DIR/$samp #IDR output goes to pooled directory
	PREFIX=$IDR_OUT/"$root"_IDR
	rep_files=()
	rep_jids=()
	for rep in "${!sample2loose[@]}"; do #use root to match rep files
		if echo $rep | grep -iq "$root"; then
			rep_files+=("${sample2loose["$rep"]}")
			rep_jids+=("${sample2loosejob["$rep"]}")
		fi
	done
	#echo loose peak files are ${rep_files[@]}
	#echo loose peak jids are ${rep_jids[@]}
	DEP_JIDS=$(echo  ${rep_jids[@]})
	DEP_JIDS=${DEP_JIDS//" "/","}
	p1=${rep_files[0]}
	p2=${rep_files[1]}
	#echo $p1 $p2 $PREFIX
	IDR_qsub=$(qsub -v PEAKS1=$p1,PEAKS2=$p2,PREFIX=$PREFIX -wd $IDR_OUT -hold_jid $DEP_JIDS job_scripts/run_IDR.sh)
	#echo $IDR_qsub
	IDR_jid=$(parse_jid "$IDR_qsub")
	#echo IDR_jid is $IDR_jid
	
done

ALL_JIDS=$(cat output/tmp.all_jids | awk 'ORS=","')
qsub -wd $OUT_DIR -hold_jid $ALL_JIDS job_scripts/final_reports.sh
#for samp in "${!sample2bamjob[@]}"; do
#echo "$samp","${sample2bamjob["$samp"]}" >> $TMP_SAMPLE_JIDS
#done
#for samp in "${!pooled2bamjob[@]}"; do
#echo "$samp","${pooled2bamjob["$samp"]}" >> $TMP_POOL_JIDS
#done
#for samp in "${!sample2loose[@]}"; do
#echo "$samp","${sample2loose["$samp"]}" >> $OUT_DIR/tmp.loose_peaks
#done
#for samp in "${!sample2loosejob[@]}"; do
#echo "$samp","${sample2loosejob["$samp"]}" >> $OUT_DIR/tmp.loose_jobs
#done

#associative arrays cannot be exported
#export $sample2bamjob
#export $pooled2bamjob
#sample2bam[$sample_id]=$output
