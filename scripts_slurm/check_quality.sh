#!/bin/bash 



##############################
## Cluster - Pirayu - CIMEC ##
##############################


#SBATCH --job-name=quality_check # nombre para identificar el trabajo. Por defecto es el nombre del script
#SBATCH --ntasks=1 # cantidad de cores pedidos 
#SBATCH --tasks-per-node=1 # cantidad de cores por nodo, para que distribuya entre varios nodos 
#SBATCH --output=quality-%j.log # la salida y error estandar van a este archivo. Si no es especifca es slurm-%j.out (donde %j es el Job ID) 
#SBATCH --error=quality-%j-error.log # si se especifica, la salida de error va por separado a este archivo 
#SBATCH --time=1-0
#SBATCH --no-requeue             # para que no relance el script


path=" "
outfix="_eest2.txt"
outfix1="_info.txt"
NCORES=4

module load R/3.5.0
module load python

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

mv quality-*  log


