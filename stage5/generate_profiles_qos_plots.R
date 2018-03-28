

library(ggplot2)
library(data.table)

reducedmean <- function(x) {
  y = x[x < max(x, na.rm=T) & x > min(x, na.rm=T)]
  return(mean(y, na.rm=T))
}

reducedmedian <- function(x) {
  y = x[x < max(x, na.rm=T) & x > min(x, na.rm=T)]
  return(as.double(median(y, na.rm=T)))
}

sd.trim <- function(x, trim=0, na.rm=FALSE, ...)
{
  if(!is.numeric(x) && !is.complex(x) && !is.logical(x)) {
    warning("argument is not numeric or logical: returning NA")
    return(NA_real_)
  }
  if(na.rm) x <- x[!is.na(x)]
  if(!is.numeric(trim) || length(trim) != 1)
    stop("'trim' must be numeric of length one")
  n <- length(x)
  if(trim > 0 && n > 0) {
    if(is.complex(x)) stop("trimmed sd are not defined for complex data")
    if(trim >= 0.5) return(0)
    lo <- floor(n * trim) + 1
    hi <- n + 1 - lo
    x <- sort.int(x, partial = unique(c(lo, hi)))[lo:hi]
  }
  sd(x)
}

multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

################################################################################################################

k = read.csv("stage4/data/vn_qos_stats.csv", head= T)
k = as.data.table(k)
k$Net = substr(k$Net, 4, 5)

tmp = k[,list(sd = reducedmedian(StartupDelay_ms)/1000, minsdelay = quantile(StartupDelay_ms,0.1)/1000, maxsdelay = quantile(StartupDelay_ms,0.9)/1000), by=c("Net","Prot", "Algo", "TcpHrxratio")]

pdf("figures/results/startup_vn_all.pdf", height = 3)
print(ggplot(tmp, aes(Net, sd, fill = as.factor(Prot))) +geom_bar(stat = "identity", position=position_dodge(), width=0.35,  colour="black") + xlab("Network Profile")  + geom_errorbar(aes(ymin=minsdelay, ymax = maxsdelay), width=0.2, position = position_dodge(.35)) + theme_bw(base_size = 12)+ ylab("Startup Delay (s)") + theme(legend.position="top") + theme(legend.title = element_blank())+ guides(fill = guide_legend(nrow = 1)) + scale_fill_brewer())
dev.off()

################################################################################################################

tmp = k[,list(stall = mean(TotalStallDur_ms,0.1), minstall = quantile(TotalStallDur_ms,0.1)/1000, maxstall = quantile(TotalStallDur_ms,0.9)/1000), by=c("Net","Prot", "Algo", "TcpHrxratio")]

pdf("figures/results/stall_vn_all.pdf", height = 3)
print(ggplot(tmp, aes(Net, stall/1000, fill = as.factor(Prot))) +  geom_bar(stat = "identity", position=position_dodge(), width=0.35,  colour="black") + xlab("Network Profile")  + geom_errorbar(aes(ymin=minstall, ymax = maxstall), width=0.2, position = position_dodge(.35)) + xlab("Network Profile")+
        theme_bw(base_size = 12)+ ylab("Total Stall Duration (s)") + theme(legend.position="top") + 
        theme(legend.title = element_blank())+ guides(fill = guide_legend(nrow = 1))+ scale_fill_brewer())
dev.off()


################################################################################################################

k = read.csv("stage4/data/vn_rate_changes.csv", head= , sep = " ")

k$prot = ifelse(k$prot == "tcp", "TCP", ifelse(k$prot == "tcph", "Hollywood", "HOLLYWOOD_SR"))
k$algo = ifelse(k$algo  == "bola", "BOLA", ifelse(k$algo  == "abma", "ABMA", ifelse(k$algo  == "panda", "PANDA", "WTF")))
k = k[k$totalchunksc > 100, ]
k = as.data.table(k)
tmp = k[,list(sdrate = mean(sd.rate, trim=0.1), rate = mean(av.rate, trim=0.1), change = mean(downswitch,0.1)*100/mean(totalchunksc), sdchange = sd.trim(downswitch, 0.1)*100/mean(totalchunksc)), by=c("net","prot", "rxbufratio")]
tmp$net = substr(tmp$net, 4, 5)

pdf("figures/results/bitrate_vn_all.pdf", height = 3)
print(ggplot(tmp, aes(as.factor(net), rate/1000 ,fill = as.factor(prot))) + geom_bar(stat = "identity", position=position_dodge(),  width=0.35,colour="black")
      + geom_errorbar(aes(ymin=(rate-sdrate)/1000, ymax = (rate+sdrate)/1000), width=0.20, position = position_dodge(.35))
      + theme_bw(base_size = 12) + xlab("Network Profile") + ylab ("Average Media Bitrate") 
      + theme(legend.position="top")+ guides(fill = guide_legend(nrow = 1))+theme(legend.title = element_blank())+ scale_fill_brewer())
dev.off()

pdf("figures/results/ratedrops_vn_all.pdf", height = 3)
print(ggplot(tmp, aes(as.factor(net), change ,fill = as.factor(prot))) + geom_bar(stat = "identity", position=position_dodge(),  width=0.35,colour="black")
      + geom_errorbar(aes(ymin=change-sdchange, ymax = change+sdchange), width=0.20, position = position_dodge(.35))
      + theme_bw(base_size = 12) + xlab("Network Profile") + ylab ("Chunks with Rate Drops (%)") 
      + theme(legend.position="top")+ guides(fill = guide_legend(nrow = 1))+theme(legend.title = element_blank())+ scale_fill_brewer())
dev.off()