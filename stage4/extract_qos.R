#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

library(rkvo)
library(ggplot2)
library(data.table)

observations <- readkvs(args[1], ",", ":")
res = do.call(rbind, lapply(observations, unlist))
res = as.data.frame(res)

res[, c(3:(ncol(res)-1))] = sapply(res[,c(3:(ncol(res)-1))], function(x) as.numeric(as.character(x)))

write.csv(res, args[2], row.names=F)
attach(res)
aggres = aggregate(res, by=list(Net, Prot, Algo, TcpHrxratio), FUN = function(x) mean(x, trim=0.1))
print(aggres)

