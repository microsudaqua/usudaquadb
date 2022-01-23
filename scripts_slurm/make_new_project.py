#!/user/bin/env python

import os
import re
import argparse
import shutil

parser = argparse.ArgumentParser()

parser.add_argument("-i", "--input", help="path to folder for the new project", type = str, required = True)
parser.add_argument("-n", "--name", help = "project name", type = str, required = True)
parser.add_argument("-fwd", "--primer_forward", help = "Primer forward", type = str, required = True)
parser.add_argument("-rev", "--primer_reverse", help = "Primer reverse", type = str, required = True)
parser.add_argument("-N", "--ncores", help = "Number of cores/threads", type = int, required = True)
args = parser.parse_args()

path = args.input
name = args.name
primerF = args.primer_forward
primerR = args.primer_reverse
ncores = args.ncores



if path[len(path)-1] == "/":
	head = "{}/{}".format(path, name)
else:
	head = "{}/{}".format(path, name)

print(head)
if os.path.isdir(head) == False:
	os.mkdir(head)
	os.mkdir("{}/01-raw_data".format(head))

	os.mkdir("{}/02-uncompressed".format(head))

	os.mkdir("{}/03-change_names".format(head))

	os.mkdir("{}/04-clipping_primers".format(head))
	os.mkdir("{}/04-clipping_primers/clipped".format(head))

	os.mkdir("{}/05-quality_control".format(head))
	os.mkdir("{}/05-quality_control/successful".format(head))

	os.mkdir("{}/06-dada2".format(head))
	os.mkdir("{}/06-dada2/pathF".format(head))
	os.mkdir("{}/06-dada2/pathR".format(head))
	os.mkdir("{}/06-dada2/control_files".format(head))
	os.mkdir("{}/07-taxonomy".format(head))
	os.mkdir("{}/log".format(head))

data = open("{}/scripts_slurm/change_names.sh".format(path), "r").read()
data = re.sub("\npath=\".+\"\n", "\npath=\"{}\"\n".format(head), data)
fw = open("{}/change_names.sh".format(head), "w")
fw.write(data)
fw.close()

var = "R1.fastq_name\tR2.fastq_name\tNew_name_R1\tNew_name_R2".format(primerF, primerR)
fw = open("{}/03-change_names/list_of_names.txt".format(head), "w")
fw.write(var)
fw.close()


data = open("{}/scripts_slurm/clipping_primers.sh".format(path), "r").read()
data = re.sub("\npath=\".+\"\n", "\npath=\"{}\"\n".format(head), data)
data = re.sub("\nPRIMERF=\".+\"\n", "\nPRIMERF=\"{}\"\n".format(primerF), data)
data = re.sub("\nPRIMERR=\".+\"\n", "\nPRIMERR=\"{}\"\n".format(primerR), data)
data = re.sub("\nNCORES=.+\n", "\nNCORES={}\n".format(ncores), data)
data = re.sub("ntasks=[0-9]+", "ntasks={}".format(ncores), data)
data = re.sub("tasks-per-node=[0-9]+", "tasks-per-node={}".format(ncores), data)
fw = open("{}/clipping_primers.sh".format(head), "w")
fw.write(data)
fw.close()

data = open("{}/scripts_slurm/check_quality.sh".format(path), "r").read()
data = re.sub("\npath=\".+\"\n", "\npath=\"{}\"\n".format(head), data)
data = re.sub("\nNCORES=.+\n", "\nNCORES={}\n".format(ncores), data)
data = re.sub("ntasks=[0-9]+", "ntasks={}".format(ncores), data)
data = re.sub("tasks-per-node=[0-9]+", "tasks-per-node={}".format(ncores), data)
fw = open("{}/check_quality.sh".format(head), "w")
fw.write(data)
fw.close()

var = ">PrimerF\n{}\n>PrimerR\n{}".format(primerF, primerR)
fw = open("{}/05-quality_control/probs.fna".format(head), "w")
fw.write(var)
fw.close()


data = open("{}/scripts_slurm/dada2.sh".format(path), "r").read()
data = re.sub("\npath=\".+\"\n", "\npath=\"{}\"\n".format(head), data)
data = re.sub("\nNCORES=.+\n", "\nNCORES={}\n".format(ncores), data)
data = re.sub("ntasks=[0-9]+", "ntasks={}".format(ncores), data)
data = re.sub("tasks-per-node=[0-9]+", "tasks-per-node={}".format(ncores), data)
fw = open("{}/dada2.sh".format(head), "w")
fw.write(data)
fw.close()

data = open("{}/scripts_slurm/dada2_runs.sh".format(path), "r").read()
data = re.sub("\npath=\".+\"\n", "\npath=\"{}\"\n".format(head), data)
data = re.sub("\nNCORES=.+\n", "\nNCORES={}\n".format(ncores), data)
data = re.sub("ntasks=[0-9]+", "ntasks={}".format(ncores), data)
data = re.sub("tasks-per-node=[0-9]+", "tasks-per-node={}".format(ncores), data)
fw = open("{}/dada2_runs.sh".format(head), "w")
fw.write(data)
fw.close()


shutil.copy("change_names.py","{}".format(head))
shutil.copy("dada2_quality_check.R","{}".format(head))
shutil.copy("resume_quality.py","{}".format(head))
shutil.copy("plot_errors.R","{}".format(head))
shutil.copy("dada2.R","{}".format(head))
shutil.copy("dada2_runs.R","{}".format(head))

