#!/bin/bash
a=( $(cat output/tmp.sample_ids) )
b=( $(cat output/tmp.pooled_ids | sort | uniq) )
for key in ${b[@]}; do
echo $key
topool=()

for samp in ${a[@]}; do
if echo $samp | grep -iq $key; then
topool+=($samp.bam)
fi
done
if [ ${#topool[@]} -eq 1 ]; then
echo pooling not necessary, just link for $key.bam to ${topool[0]}.bam
else
echo gonna pool ${topool[@]} into $key.bam
fi
done
