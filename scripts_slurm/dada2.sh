#!/bin/bash 



##############################
## Cluster - Pirayu - CIMEC ##
##############################


#SBATCH --job-name=dada2 # nombre para identificar el trabajo. Por defecto es el nombre del script
#SBATCH --ntasks=20 # cantidad de cores pedidos 
#SBATCH --tasks-per-node=20 # cantidad de cores por nodo, para que distribuya entre varios nodos 
#SBATCH --output=dada2-%j.log # la salida y error estandar van a este archivo. Si no es especifca es slurm-%j.out (donde %j es el Job ID) 
#SBATCH --error=dada2-%j-error.log # si se especifica, la salida de error va por separado a este archivo 
#SBATCH --time=3-0
#SBATCH --no-requeue             # para que no relance el script

module load R/3.5.0

path="path"
NCORES=20

#Values for dada2 filtering part
maxEE1=5 #maxEE value for FwD 
maxEE2=5 #maxEE value for Rev

trunc1=230 #values for trunc Fwd
trunc2=200 #values for trunc rev

trunqQ=8 #Value of quality trunc

## Run your R script in batch mode
cp $path/05-quality_control/successful/*_R1.clipped.fastq $path/06-dada2/pathF
cp $path/05-quality_control/successful/*_R2.clipped.fastq $path/06-dada2/pathR

Rscript dada2.R $path $maxEE1 $maxEE2 $trunc1 $trunc2 $trunqQ $NCORES

mv dada2-* log
