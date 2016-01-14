#!/bin/bash
OUTDIR=$1
if [ -z $OUTDIR ]; then
	echo need 1 arg for OUTDIR
	exit 1
fi
OUTDIR=$(readlink -f $OUTDIR)
LOGS=$OUTDIR/logs
if [ ! -d $LOGS ]; then
	mkdir $LOGS
fi
cd $OUTDIR
echo getting logs from:
for d in *
 do if [ -d $d ]; then
  d=$(readlink -f $d)
  #echo $d
  if [ ${d/logs/match} = $d ]; then #dir must contain string log
    echo "    "$d
    keys=(out error)
    for key in ${keys[@]}
     do for f in $d/*$key; do
      #do echo $f
	if [ -f $f ]; then
	 new=${f/"/"/"_"}
         mv $f $LOGS/$new
	fi
done; done; fi; 
fi; 
done
SUFF=$(date | awk 'BEGIN {FS="[ :]"; OFS="_"} {print $2,$3,$8,$4$5$6}')
mv $LOGS $LOGS"_$SUFF"
