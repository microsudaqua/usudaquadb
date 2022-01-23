#!/bin/bash 

##############################
## Cluster - Pirayu - CIMEC ##
##############################


#SBATCH --job-name=change_names # nombre para identificar el trabajo. Por defecto es el nombre del script
#SBATCH --ntasks=1 # cantidad de cores pedidos 
#SBATCH --tasks-per-node=1 # cantidad de cores por nodo, para que distribuya entre varios nodos 
#SBATCH --output=change-%j.log # la salida y error estandar van a este archivo. Si no es especifca es slurm-%j.out (donde %j es el Job ID) 
#SBATCH --error=change-%j-error.log # si se especifica, la salida de error va por separado a este archivo 
#SBATCH --time=1-0
#SBATCH --no-requeue             # para que no relance el script

path=" "

module load python

## Run your python script
python change_names.py -i  $path -n list_of_names.txt

mv $path/03-change_names/list_of_names.txt ..

mv change-* log
