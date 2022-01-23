#!/bin/bash 

path=" "
outfix="_eest2.txt"
outfix1="_info.txt"
NCORES=4


for i in $(ls "$path/04-clipping_primers/clipped/" | grep "\.fastq")
do
	usearch10x64 -fastx_info "$path/04-clipping_primers/clipped/$i" -secs 5 -output "$path/05-quality_control/reads_$i$outfix1" -threads $NCORES
	usearch10x64 -fastq_eestats2 "$path/04-clipping_primers/clipped/$i" -output "$path/05-quality_control/reads_$i$outfix" -length_cutoffs "100,300,10" -threads $NCORES
	NAME=$( echo $i | sed "s/\(.\+\).clipped.*/\1/p" -n )
	echo $NAME
	usearch10x64 -fastx_subsample "$path/03-change_names/$NAME.fastq" -sample_size 100 -randseed 1 -fastaout "$path/05-quality_control/"$NAME".temp.fastq"
	usearch10x64 -search_oligodb "$path/05-quality_control/"$NAME".temp.fastq" -db "$path/05-quality_control/probs.fna" -strand both -userout "$path/05-quality_control/$i.primers" -userfields  query+target+qstrand+diffs+tlo+thi+trowdots -threads $NCORES
done

Rscript dada2_quality_check.R $path

python resume_quality.py -i $path

Rscript plot_errors.R $path
rm $path/05-quality_control/*$outfix $path/05-quality_control/*$outfix1 $path/05-quality_control/*.primers $path/05-quality_control/*temp.fastq


