#!/bin/bash
function parse_jid () 
{ #parses the job id from output of qsub
        #echo $1
	if [[ -z $1 ]]; then
	echo parse_jid expects output of qsub as first input but input was empty! stop
	exit 1
	fi
	JOBID=$(echo $1 | awk 'BEGIN {RS=" "} {if ($1 ~ "[0-9]+"){print $1; exit}}') #returns JOBID	
	#echo $JOBID >> $ALL_JIDS
	echo $JOBID
}
export -f parse_jid
qsub_out=$(qsub -cwd test_run.sh arg1 arg2)
echo qsub out is:
echo $qsub_out
jid=$(parse_jid "$qsub_out")
echo jid is $jid
