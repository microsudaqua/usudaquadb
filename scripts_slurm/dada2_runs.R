##Rscript
## load dada2
library(dada2); packageVersion("dada2")
library(RcppParallel)
library(Biostrings)

args = commandArgs(trailingOnly=TRUE)
setwd(args[1])

path <- file.path(getwd(), "07-taxonomy")
# number of threads
ncores = as.numeric(args[2])

## Load datasets
st <- readRDS(file.path(args[1],"06-dada2","seqtab.rds"))

# #Remove chimeras for ALL datasets
seqtab_nochim <- removeBimeraDenovo(st, multithread=ncores, minFoldParentOverAbundance = 2)
saveRDS(seqtab_nochim, file.path(path,"seqtab_nochim.rds"))

head(seqtab_nochim)

create_sequences_file <- function(x){
    seq <- Biostrings::DNAStringSet(x$sequence)
    names(seq) <- x$ASV
    return(seq)
}

dada2<-data.frame(ASV = paste0("ASV_", 1:ncol(seqtab_nochim)),
                  sequence = colnames(seqtab_nochim),
                  t(seqtab_nochim))

rownames(dada2) <- 1:nrow(dada2)

seq <- create_sequences_file(dada2) #change to create zotu fasta file
Biostrings::writeXStringSet(seq, file.path(path,"seqtab_nochim.formated.fasta"))
saveRDS(dada2, file.path(path,"seqtab_nochim.formated.rds"))


