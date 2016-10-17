cat gencode.v21.gene.bed | awk 'BEGIN {FS="\t"; OFS="\t"} {if($6 == "+"){$3=$2 + 5000; $2=$2 - 5000; print $0}else{$2=$3 - 5000; $3=$3 + 5000; print $0} }' > gencode.v21.gene.5kb_prom.bed
