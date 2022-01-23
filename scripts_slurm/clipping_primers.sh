#!/bin/bash 

##############################
## Cluster - Pirayu - CIMEC ##
##############################


#SBATCH --job-name=cutadapt # nombre para identificar el trabajo. Por defecto es el nombre del script
#SBATCH --ntasks=20 # cantidad de cores pedidos 
#SBATCH --tasks-per-node=20 # cantidad de cores por nodo, para que distribuya entre varios nodos 
#SBATCH --output=cutadapt-%j.log # la salida y error estandar van a este archivo. Si no es especifca es slurm-%j.out (donde %j es el Job ID) 
#SBATCH --error=cutadapt-%j-error.log # si se especifica, la salida de error va por separado a este archivo 
#SBATCH --time=1-0
#SBATCH --no-requeue             # para que no relance el script

PRIMERF="CCTACGGGNGGCWGCAG"
PRIMERR="GACTACHVGGGTATCTAATCC"
NCORES=4

path=" "

module load python3

for i in $(ls "$path/03-change_names/" | sed -r 's/(.*)_R[1,2].*/\1/' | uniq); do cutadapt --discard-untrimmed  -g $PRIMERF  -G $PRIMERR --match-read-wildcards --pair-filter=any -q 10 -j $NCORES -o $path/04-clipping_primers/clipped/$i\_R1.clipped.fastq -p $path/04-clipping_primers/clipped/$i\_R2.clipped.fastq $path/03-change_names/$i\_R1.fastq $path/03-change_names/$i\_R2.fastq; done > $path/04-clipping_primers/cutadapt.log

mv cutadapt-* log
