cat gencode.v21.gene.bed | awk 'BEGIN {FS="\t"; OFS="\t"} {if($3 - $2 >= 5000){$2=$2 + 2000; $3=$3 - 2000; print $0} }' > gencode.v21.gene.2k_trimmed.bed
