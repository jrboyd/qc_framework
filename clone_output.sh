#!/bin/bash
#src_out=output_SF_bcell_mm
src_out=output_SF_mcf7
#target=output_SF_bcell_mm.repeak
target=output_SF_mcf7.repeak
mkdir -p $target
for d in $src_out/*; do
  if [ -d $d ]; then
    target_d=$target/$(basename $d)
    mkdir -p $target_d
    ls -lha $d/*.bam
    ls -lha $d/*.fastq
    ls -lha $d/*.fastq.gz
    for f in $d/*.bam; do
      if [ -f $f ]; then
        ln -s $(readlink -f $f) $target_d
      fi
    done
    for f in $d/*.bam.bai; do
      if [ -f $f ]; then
        ln -s $(readlink -f $f) $target_d
      fi
    done
    for f in $d/*.fastq; do
      if [ -f $f ]; then
        ln -s $(readlink -f $f) $target_d
      fi
    done
    for f in $d/*.fastq.gz; do
      if [ -f $f ]; then
        ln -s $(readlink -f $f) $target_d
      fi
    done
    for f in $d/*.bw; do
      if [ -f $f ]; then
        ln -s $(readlink -f $f) $target_d
      fi
    done
    for f in $d/*_fastqc; do
      if [ -f $f ]; then
        ln -s $(readlink -f $f) $target_d
      fi
    done

    #ln -s $(readlink -f $d/*.bam) $target_d
    #ln -s $(readlink -f $d/*.fastq) $target_d
    #ln -s $(readlink -f $d/*.fastq.gz) $target_d
  fi
done
