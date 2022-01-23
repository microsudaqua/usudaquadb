## load dada2
library(dada2); packageVersion("dada2")
library(RcppParallel)
library(ggplot2)


args = commandArgs(trailingOnly=TRUE)
setwd(args[1]) ## Set your working directory
getwd()  # check working directory


## Define path
path <- file.path(getwd(), "06-dada2") #Folder for outputs
pathF <- file.path(path, "pathF")
pathR <- file.path(path, "pathR")

## Define cores
ncores = as.numeric(args[7])

## Define filtered path
filtpathF <- file.path(pathF, "filtered") # Filtered forward files go into the pathF/filtered/ subdirectory
filtpathR <- file.path(pathR, "filtered") # ...

## sort names
fastqFs <- sort(list.files(pathF, pattern="fastq"))
fastqRs <- sort(list.files(pathR, pattern="fastq"))

if(length(fastqFs) != length(fastqRs)) stop("Forward and reverse files do not match.")

### Filter by quality

# Filtering: THESE PARAMETERS ARENT OPTIMAL FOR ALL DATASETS: i.e. you need to adjust these parameters according to your dataset
out <- filterAndTrim(fwd=file.path(pathF, fastqFs), filt=file.path(filtpathF, fastqFs),
              rev=file.path(pathR, fastqRs), filt.rev=file.path(filtpathR, fastqRs),
              truncLen=c(as.numeric(args[4]),as.numeric(args[5])), 
              maxEE=c(as.numeric(args[2]),as.numeric(args[3])), maxN = 0, truncQ = as.numeric(args[6]), rm.phix=TRUE,
              compress=FALSE, multithread=ncores)
head(out)
saveRDS(out, file.path(path, "control_files","control_filtering.rds"))


## Infer sequence variants

filtpathF <- file.path(path, "pathF","filtered")
filtpathR <- file.path(path, "pathR","filtered")
## File parsing
filtFs <- list.files(filtpathF, pattern="fastq", full.names = TRUE)
filtRs <- list.files(filtpathR, pattern="fastq", full.names = TRUE)

## Important: adjust characters that need to act as delimiters

sample.names <- sapply(strsplit(basename(filtFs), "_R1"), `[`, 1) # Fix according to filename
sample.namesR <- sapply(strsplit(basename(filtRs), "_R2"), `[`, 1) # Fix according to filename
if(!identical(sample.names, sample.namesR)) stop("Forward and reverse files do not match.")


names(filtFs) <- sample.names
names(filtRs) <- sample.names

set.seed(100)

# Learn forward error rates
errF <- learnErrors(filtFs, multithread=ncores) #nbases defoult 1e+8

# Learn reverse error rates
errR <- learnErrors(filtRs, multithread=ncores) #nbases defoult 1e+8

saveRDS(errF, file.path(path, "control_files","errorF.rds"))
saveRDS(errR, file.path(path, "control_files","errorR.rds"))

pdf(file.path(path,"control_files","fordware_error.pdf"))
plotErrors(errF, nominalQ=TRUE)
dev.off()
pdf(file.path(path,"control_files","reverse_error.pdf"))
plotErrors(errR, nominalQ=TRUE)
dev.off()

# Sample inference and merger of paired-end reads
mergers <- vector("list", length(sample.names))
names(mergers) <- sample.names
dadaFs <- vector("list", length(sample.names))
names(dadaFs) <- sample.names
dadaRs <- vector("list", length(sample.names))
names(dadaRs) <- sample.names
for(sam in sample.names) {
  cat("Processing:", sam, "\n")
  derepF <- derepFastq(filtFs[[sam]])
  ddF <- dada(derepF, err=errF, multithread=ncores, pool = TRUE)
  dadaFs[[sam]]<-ddF
  dadaFs[[sam]]
  derepR <- derepFastq(filtRs[[sam]])
  ddR <- dada(derepR, err=errR, multithread=ncores, pool = TRUE)
  dadaRs[[sam]]<-ddR
  dadaFs[[sam]]
  merger <- mergePairs(ddF, derepF, ddR, derepR, maxMismatch=0)
  mergers[[sam]] <- merger
}

rm(derepF); rm(derepR)


# Construct sequence table and remove chimeras
seqtab <- makeSequenceTable(mergers)

### Save the resulting table. This "raw" table will be used if you are later merging datasets
saveRDS(seqtab, file.path(path,"seqtab.rds"))
str(seqtab)

# Check process
getN <- function(x) sum(getUniques(x))

track <- cbind(out, sapply(dadaFs, getN), sapply(dadaRs, getN), sapply(mergers, getN), rowSums(seqtab))
colnames(track) <- c("input", "filteredF", "filteredR", "denoised", "merged", "tabled")
rownames(track) <- sample.names
track
write.table(track, file.path(path,"control_files","control_table.txt"), quote = F, sep = "\t")

