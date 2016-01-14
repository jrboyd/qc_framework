#!/bin/bash
OUTDIR=$1
if [ -z $OUTDIR ]; then
	echo need 1 arg for OUTDIR
	exit 1
fi
LOGS=$OUTDIR/logs
if [ ! -d $LOGS ]; then
	mkdir $LOGS
fi
OUTDIR=$(readlink -f $OUTDIR)
cd $OUTDIR
for d in *
 do if [ -d $d ]; then
  d=$(readlink -f $d)
  echo $d
  if [ $d = $LOGS ]
   then echo $d; keys=(out error)
    for key in ${keys[@]}
     do for f in $d/*$key
      do echo $f
	if [ -f $f ]; then
	 new=${f/"/"/"_"}
         mv $f $LOGS/$new
	fi
done; done; fi; 
fi; 
done
