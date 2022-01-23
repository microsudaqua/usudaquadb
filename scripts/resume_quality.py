#!/user/bin/env python3

#RESUMEN
#	- Revisar todos los archivos y crear tabla Resume.csv: Nombre archivo; F[nde seq]; R[nde seqs];large F; largen R; Nota_primers [OK/Fail]
#	- Revisar todos los _infor.txt y agregar a la tabla Resume.csv: Sequences F; Sequences R; Lengths min F; Lengths min R; Length med F;Length med R; length max F; length max R; nota_info [OK/Fail] fail cuando sequences es menor a 10k;
#	- Revisar todos los _eest2.txt y generar archivo para R1 y para R2 con los mean para x largo:
#	length;mean 0.5; mean 1; mean 2

import os
import argparse
import glob
import re
import shutil

parser = argparse.ArgumentParser()

parser.add_argument("-i", "--input", help="path to author name", type = str, required = True)

args = parser.parse_args()

path = args.input

table_out = {}
entry = []

head = "Name\tHave Primers[Y/N]\tN of R1 Sequences\tN of R2 Sequences\tMean Length R1\tMean Length R2\tMin Length R1\tMin Length R2\tMax Length R1\tMax Length R2\tNote info[OK/Fail]\n"

for i in glob.glob("{}/05-quality_control/*.primers".format(path)):
	entry = []
	#print(i)
	first = re.search("{}/05-quality_control/(.*)_R[1,2].clipped.fastq.primers".format(path),i)
#Comprobar si tiene primers
	if first:
		entry.append(first.group(1))
		if open(i, "r").read() != "":
			entry.append("Y")
		else:
			entry.append("N")
	table_out[first.group(1)] = entry			


#Buscar Info
dont_fails = []	
search = ["a", "b", "c", "d", "e", "f", "g", "h", "i"]
for i in table_out.keys():
	for j in glob.glob("{}/05-quality_control/*_info.txt".format(path)): #{}/04-quality_control/output/
		if re.search(i, j):
			#print(j)
			data = open(j, "r").read()
			#print(data)
			#Busqueda de seqs
			if re.search("([0-9]+\.[0-9])k\sseqs\,",data):
				seqs = re.search("([0-9]+\.[0-9])k\sseqs\,",data).group(1)
			else:
				seqs = re.search("([0-9]+)\sseqs\,",data).group(1)			
			#Busqueda de Mean length
			mean = re.search("med\s([0-9]+)\,",data).group(1)			
			#Busqueda de min length
			mine = re.search("min\s([0-9]+)\,",data).group(1)			
			#Busqueda de min length
			maxe = re.search("max\s([0-9]+)\n",data).group(1)
			#Comprobar falla
			if re.search("\.", seqs):			
				if float(seqs)*1000 < 10000.0:
					fail = "fail"
				else:
					fail = "OK"
					dont_fails.append("{}".format(i))
			else:
				if int(seqs) < 10000:
					fail = "fail"
				else:
					fail = "OK"
					dont_fails.append("{}".format(i))				
			if re.search("_R1.clipped.fastq",j):			
				search[0] = str(seqs)
				search[2] = str(mean)
				search[4] = str(mine)
				search[6] = str(maxe)
			elif re.search("_R2.clipped.fastq",j):
				search[1] = str(seqs)
				search[3] = str(mean)
				search[5] = str(mine)
				search[7] = str(maxe)
			search[8] = fail		
	table_out[i].append("\t".join(search))

out = open("{}/05-quality_control/resume.txt".format(path), "w")
out.write(head)
for i in table_out.keys():
	out.write("{}\n".format("\t".join(table_out[i])))
out.close()



search_R1 = []
search_R2 = []
#para graficar
head = "length\t0.5\t1\t2\n"

for j in glob.glob("{}/05-quality_control/*_eest2.txt".format(path)):
	data = open(j, "r").read()
	data = re.sub(" +","\t", data)
#	save = open(j, "w")
#	save.write(data)
#	save.close()
#	print(data)
	for i in data.split("\n"):
		line = i.split("\t")
#		print("LENGTH= ",len(line))		
		if len(line) == 8:
			new = "{}\t{}\t{}\t{}\n".format(line[1],line[3].split("%")[0],line[5].split("%")[0],line[7].split("%")[0])
			if re.search("_R1", j):
				search_R1.append(new)
			else:
				search_R2.append(new)

r1 = open("{}/05-quality_control/R1.txt".format(path), "w")
r1.write(head)
for i in search_R1:
	r1.write(i)
r2 = open("{}/05-quality_control/R2.txt".format(path), "w")
r2.write(head)
for i in search_R2:
	r2.write(i)
r1.close()
r2.close()
			
new = "{}/05-quality_control/successful/".format(path)
#os.mkdir(new)
for i in dont_fails:
	old = "{}/04-clipping_primers/clipped/{}_R1.clipped.fastq".format(path,i)
	shutil.copy("{}".format(old),"{}".format(new))	
	old = "{}/04-clipping_primers/clipped/{}_R2.clipped.fastq".format(path,i)
	shutil.copy("{}".format(old),"{}".format(new))	

