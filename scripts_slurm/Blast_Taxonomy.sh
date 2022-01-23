#!/bin/bash 



##############################
## Cluster - Pirayu - CIMEC ##
##############################


#SBATCH --job-name=blast # nombre para identificar el trabajo. Por defecto es el nombre del script
#SBATCH --ntasks=20 # cantidad de cores pedidos 
#SBATCH --tasks-per-node=20 # cantidad de cores por nodo, para que distribuya entre varios nodos 
#SBATCH --output=blst-%j.log # la salida y error estandar van a este archivo. Si no es especifca es slurm-%j.out (donde %j es el Job ID) 
#SBATCH --error=blast-%j-error.log # si se especifica, la salida de error va por separado a este archivo 
#SBATCH --time=3-0
#SBATCH --no-requeue             # para que no relance el script


path=" " #path to working directory
NCOR=4 # Number of threads

db=" " # reference database
file="seqtab_nochim.formated.fasta" # fasta file


cd $path

blastn -db ${db} -query  ${file} -evalue 1.0 -out ${file}".blastn.tmp" -num_threads 4 -outfmt "6 std slen" -max_target_seqs 5
#adding header
sed -e '1i\Query\tSubject\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore\tslen' ${file}".blastn.tmp" > ${file}".blastn.tsv"

#extract best hit
sort -k1,1 -k12,12nr -k11,11n ${file}".blastn.tmp" | sort -u -k1,1 --merge > ${file}".blastn.besthit.tmp"
sed -e '1i\Query\tSubject\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore\tslen' ${file}".blastn.besthit.tmp" > ${file}".blastn.besthit.tsv"

rm ${file}".blastn.besthit.tmp" ${file}".blastn.tmp"
