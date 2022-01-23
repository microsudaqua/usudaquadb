#!/usr/bin/env python3

#Script para extraer el nombre del archivo list_of_names.txt y cambiar el nombre a las muestras

import os
import sys
import argparse

parser = argparse.ArgumentParser()

parser.add_argument("-i", "--input", help="path to author name", type = str, required = True)
parser.add_argument("-n", "--names", help="new names files", type = str, required = True)

args = parser.parse_args()

path = args.input


f1 = open("{}/03-change_names/{}".format(path, args.names))
f1.readline()

dictionary = {}

for i in f1:
	i = i.split("\n")[0]
	ids = i.split("\t")
	idF = ids[0]
	idR = ids[1]
	idFn = ids[2]
	idRn = ids[3]
	dictionary[idF] = idFn
	dictionary[idR] = idRn
f1.close()

print("number of samples: {}".format(len(dictionary.keys())))

#CHANGE NAMES
for i in os.listdir("{}/02-uncompressed/".format(path)):
	if i in dictionary.keys():
		print("old name: {}\tnew_name: {}".format(i, dictionary[i]))
		os.system("cp -f -u {}/02-uncompressed/{} {}/03-change_names/{}".format(path,i, path, dictionary[i]))
	else:
		print("{} is not in the filenames?".format(i))



