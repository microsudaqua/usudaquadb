#!/bin/bash 

PRIMERF="CCTACGGGNGGCWGCAG"
PRIMERR="GACTACHVGGGTATCTAATCC"
NCORES=4

path=" "


for i in $(ls "$path/03-change_names/" | sed -r 's/(.*)_R[1,2].*/\1/' | uniq); do cutadapt --discard-untrimmed  -g $PRIMERF  -G $PRIMERR --match-read-wildcards --pair-filter=any -q 10 -j $NCORES -o $path/04-clipping_primers/clipped/$i\_R1.clipped.fastq -p $path/04-clipping_primers/clipped/$i\_R2.clipped.fastq $path/03-change_names/$i\_R1.fastq $path/03-change_names/$i\_R2.fastq; done > $path/04-clipping_primers/cutadapt.log


