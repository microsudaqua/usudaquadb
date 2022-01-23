#!/bin/bash 



##############################
## Cluster - Pirayu - CIMEC ##
##############################


#SBATCH --job-name=dada2_runs # nombre para identificar el trabajo. Por defecto es el nombre del script
#SBATCH --ntasks=20 # cantidad de cores pedidos 
#SBATCH --tasks-per-node=20 # cantidad de cores por nodo, para que distribuya entre varios nodos 
#SBATCH --output=dada2r-%j.log # la salida y error estandar van a este archivo. Si no es especifca es slurm-%j.out (donde %j es el Job ID) 
#SBATCH --error=dada2r-%j-error.log # si se especifica, la salida de error va por separado a este archivo 
#SBATCH --time=3-0
#SBATCH --no-requeue             # para que no relance el script

module load R/3.5.0

path=" "
NCORES=" "

# remove chmiera by dada2, format table and create a fasta file
Rscript dada2_runs.R $path $NCORES

