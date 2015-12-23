#!/bin/bash
#runner called by qc_framework.sh for each raw fastq file
#arg 1 is raw fastq file, presumed in WD
#returns job_id of bam file to be used by merge bam

LOG=$1.runner.log
echo running step 1
