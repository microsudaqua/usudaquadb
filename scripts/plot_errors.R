library(ggplot2)
library(reshape2)

summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=FALSE,
                      conf.interval=.95, .drop=TRUE) {
  library(plyr)
  
  # New version of length which can handle NA's: if na.rm==T, don't count them
  length2 <- function (x, na.rm=FALSE) {
    if (na.rm) sum(!is.na(x))
    else       length(x)
  }
  
  # This does the summary. For each group's data frame, return a vector with
  # N, mean, and sd
  datac <- ddply(data, groupvars, .drop=.drop,
                 .fun = function(xx, col) {
                   c(N    = length2(xx[[col]], na.rm=na.rm),
                     mean = mean   (xx[[col]], na.rm=na.rm),
                     sd   = sd     (xx[[col]], na.rm=na.rm)
                   )
                 },
                 measurevar
  )
  
  # Rename the "mean" column    
  datac <- rename(datac, c("mean" = measurevar))
  
  datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean
  
  # Confidence interval multiplier for standard error
  # Calculate t-statistic for confidence interval: 
  # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
  ciMult <- qt(conf.interval/2 + .5, datac$N-1)
  datac$ci <- datac$se * ciMult
  
  return(datac)
}

args = commandArgs(trailingOnly=TRUE)

setwd(file.path(args[1],"05-quality_control/"))

getwd()

data <- read.table(file.path(getwd(),"R1.txt"), sep = "\t", header = F)
colnames(data) <- c("lenght", "0.5", "1.0", "2.0")

data2 <- melt(data, id.vars = "lenght")
data2 <- data2[-grep(T, data2[,1]=="length"),]

pd <- position_dodge(0.05) # move them .05 to the left and right

df <- summarySE(data2, measurevar="value", groupvars = c("lenght", "variable"))
pdf(file.path(getwd(),"ERRORS_PLOTS.pdf"))

ggplot(df, aes(x=lenght, y=value, colour=variable)) + 
  geom_errorbar(aes(ymin=value-se, ymax=value+se), width=.1, position = pd) +
  geom_line(position = pd) +
  geom_point(position = pd) +
  scale_color_brewer(palette="Paired") +
  theme(
    panel.background = element_rect(fill = "transparent") # bg of the panel
    , plot.background = element_rect(fill = "transparent", color = NA) # bg of the plot
    , panel.grid.major = element_blank() # get rid of major grid
    , panel.grid.minor = element_blank() # get rid of minor grid
    , legend.background = element_rect(fill = "transparent") # get rid of legend bg
    , legend.box.background = element_rect(fill = "transparent") # get rid of legend panel bg
  )+
  labs(x = "Sequence length Fordware", y = "% of sequences", colour = "MaxEE",
       title = "Sequences length VS MaxEE")


data <- read.table(file.path(getwd(),"R2.txt"), sep = "\t", header = F)
colnames(data) <- c("lenght", "0.5", "1.0", "2.0")

data2 <- melt(data, id.vars = "lenght")
data2 <- data2[-grep(T, data2[,1]=="length"),]

pd <- position_dodge(0.1) # move them .05 to the left and right

df <- summarySE(data2, measurevar="value", groupvars = c("lenght", "variable"))

#pdf(file.path(getwd(),"R2_ERRORS.pdf"))
ggplot(df, aes(x=lenght, y=value, colour=variable)) + 
  geom_errorbar(aes(ymin=value-se, ymax=value+se), width=.1, position = pd) +
  geom_line(position = pd) +
  geom_point(position = pd) +
  scale_color_brewer(palette="Paired") +
  theme(
    panel.background = element_rect(fill = "transparent") # bg of the panel
    , plot.background = element_rect(fill = "transparent", color = NA) # bg of the plot
    , panel.grid.major = element_blank() # get rid of major grid
    , panel.grid.minor = element_blank() # get rid of minor grid
    , legend.background = element_rect(fill = "transparent") # get rid of legend bg
    , legend.box.background = element_rect(fill = "transparent") # get rid of legend panel bg
  )+
  labs(x = "Sequence length Reverse", y = "% of sequences", colour = "MaxEE",
       title = "Sequences length VS MaxEE")
dev.off()
