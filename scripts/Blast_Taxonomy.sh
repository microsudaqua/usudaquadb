#!/bin/bash 


path=" " #path to working directory
NCORES=4 # Number of threads

db=" " # reference database
file="seqtab_nochim.formated.fasta" # fasta file


cd $path

blastn -db ${db} -query  ${file} -evalue 1.0 -out ${file}".blastn.tmp" -num_threads $NCORES -outfmt "6 std slen" -max_target_seqs 5
#adding header
sed -e '1i\Query\tSubject\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore\tslen' ${file}".blastn.tmp" > ${file}".blastn.tsv"

#extract best hit
sort -k1,1 -k12,12nr -k11,11n ${file}".blastn.tmp" | sort -u -k1,1 --merge > ${file}".blastn.besthit.tmp"
sed -e '1i\Query\tSubject\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore\tslen' ${file}".blastn.besthit.tmp" > ${file}".blastn.besthit.tsv"

rm ${file}".blastn.besthit.tmp" ${file}".blastn.tmp"
