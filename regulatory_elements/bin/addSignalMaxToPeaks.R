#!/usr/bin/env Rscript

params <- commandArgs(T)
peaks.fn <- params[1]
signal.fn <- params[2]
out.fn <- params[3]

peaks <- read.table(peaks.fn,sep="\t",header=F,stringsAsFactors=F)
colnames(peaks) <- c("#chr","start","stop","name","score","strand","fold_change","minusLog10PVal","minusLog10QVal","summit")

signal.data <- read.table(signal.fn,sep="\t",header=T,stringsAsFactors=F)[,c("name","max")]

out.data <- merge(peaks,signal.data,by="name")

out.data <- out.data[,c("#chr","start","stop","name","score","strand","fold_change","minusLog10PVal","minusLog10QVal","summit","max")]

write.table(out.data,file=out.fn,sep="\t",quote=F,row.names=F)
