##Rscript
##load dada2
library(dada2); packageVersion("dada2")
library(RcppParallel)
library(Biostrings)

args = commandArgs(trailingOnly=TRUE)
setwd(args[1])

path <- file.path(getwd(), "07-taxonomy")
# Number of threads
ncores = as.numeric(args[2])

# Load datasets
st1 <- readRDS(file.path(args[1],"06-dada2","seqtab.rds"))

#st2 <- readRDS(file.path(args[1],"06-dada2","seqtab.rds"))

# Merge datasets - 
st_f <- mergeSequenceTables(st1) # for more than 1 project mergeSequenceTables(st1, st2, ....)


# Remove chimeras for ALL datasets
seqtab_nochim <- removeBimeraDenovo(st_f, multithread=ncores, minFoldParentOverAbundance = 2)
saveRDS(seqtab_nochim, file.path(path,"seqtab_nochim.rds"))

head(seqtab_nochim)

# Create a fasta file function
create_sequences_file <- function(x){
    seq <- Biostrings::DNAStringSet(x$sequence)
    names(seq) <- x$ASV
    return(seq)
}

# Assign new name to the ASV
dada2<-data.frame(ASV = paste0("ASV_", 1:ncol(seqtab_nochim)),
                  sequence = colnames(seqtab_nochim),
                  t(seqtab_nochim))

rownames(dada2) <- 1:nrow(dada2)

# Save fasta file
seq <- create_sequences_file(dada2) #change to create zotu fasta file
Biostrings::writeXStringSet(seq, file.path(path,"seqtab_nochim.formated.fasta"))
saveRDS(dada2, file.path(path,"seqtab_nochim.formated.rds"))


