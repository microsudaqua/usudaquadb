#!/bin/bash 

path="path"
NCORES=4

#Values for dada2 filtering part
maxEE1=5 #maxEE value for FwD 
maxEE2=5 #maxEE value for Rev

trunc1=240 #values for trunc Fwd
trunc2=200 #values for trunc rev

trunqQ=2 #Value of quality trunc

## Run your R script in batch mode
cp $path/05-quality_control/successful/*_R1.clipped.fastq $path/06-dada2/pathF
cp $path/05-quality_control/successful/*_R2.clipped.fastq $path/06-dada2/pathR

Rscript dada2.R $path $maxEE1 $maxEE2 $trunc1 $trunc2 $trunqQ $NCORES

