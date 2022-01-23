## load dada2

library(dada2); packageVersion("dada2")
library(ggplot2)


args = commandArgs(trailingOnly=TRUE)

## Define path
setwd(args[1])

path <- file.path(getwd(), "04-clipping_primers/clipped")

## sort names
fastq <- sort(list.files(path, pattern="fastq"))

#### Plotting steps need to be done interactively

fullPath <- list.files(path, pattern="fastq", full.names = TRUE)
 
plot_quals <-plotQualityProfile(fullPath[1:6])
 
new_path <- file.path(getwd(), "05-quality_control")
ggsave(paste(new_path,"quality_plot.pdf",sep = "/"), plot_quals, device="pdf")

### end plot

