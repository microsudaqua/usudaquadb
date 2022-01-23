#!/bin/bash 

##############################
## Cluster - Pirayu - CIMEC ##
##############################


#SBATCH --job-name=make_project # nombre para identificar el trabajo. Por defecto es el nombre del script
#SBATCH --ntasks=1 # cantidad de cores pedidos 
#SBATCH --tasks-per-node=1 # cantidad de cores por nodo, para que distribuya entre varios nodos 
#SBATCH --output=make_pr-%j.log # la salida y error estandar van a este archivo. Si no es especifca es slurm-%j.out (donde %j es el Job ID) 
#SBATCH --error=make_pr-%j-error.log # si se especifica, la salida de error va por separado a este archivo 
#SBATCH --time=1-0
#SBATCH --no-requeue             # para que no relance el script


NAME="Eukaryotes"
path="~/My_Project/"
PRIMERF="GTGCCAGCAGCCGCG"
PRIMERR="TTTAAGTTTCAGCCTTGCG"
NCORES=4

module load python

## Run your python script
python make_new_project.py -i $path -n $NAME -fwd $PRIMERF -rev $PRIMERR -N $NCORES

mv make_pr-*  "$path/$NAME/log"
