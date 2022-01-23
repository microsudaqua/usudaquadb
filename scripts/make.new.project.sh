#!/bin/bash 

NAME="Eukaryotes"
path="~/Documents/My_Project"
PRIMERF="GTGCCAGCAGCCGCG"
PRIMERR="TTTAAGTTTCAGCCTTGCG"
NCORES=4

## Run your python script
python make_new_project.py -i $path -n $NAME -fwd $PRIMERF -rev $PRIMERR -N $NCORES

