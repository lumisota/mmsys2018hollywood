
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
# ../../dash_paper/section/testing.tex:  \includegraphics[width=\columnwidth]{dash/stallduration_p2delay_16.pdf}
# ../../dash_paper/section/testing.tex:  \includegraphics[width=\columnwidth]{dash/stallduration_loss_16.pdf}
################################################################################################################

n = read.csv("stage5/networks.csv", head= T, sep= " ")
k = read.csv("stage4/data/sn_qos_stats.csv", head= T)
k$TcpHrxratio = ifelse(k$TcpHrxratio == 0, 1, k$TcpHrxratio )
k$Prot = ifelse(k$Prot != "TCP", "Hollywood", "TCP")

k = k[ k$TcpHrxratio == 0.9 | k$TcpHrxratio == 1, ]
k = as.data.table(k)
tmp = k[,list(stall = mean(TotalStallDur_ms,0.1), minstall = quantile(TotalStallDur_ms,0.2)/1000, maxstall = quantile(TotalStallDur_ms,0.8)/1000), by=c("Net","Prot", "Algo", "TcpHrxratio")]

tmp = merge(tmp, n, by = "Net")
sub = subset(tmp,Scheme == "Loss")
pdf("figures/results/stall_sn_delay_d100.pdf", height = 3)
print(ggplot(sub, aes(as.factor(Loss/100), stall/1000, fill = as.factor(Prot))) +geom_bar(stat = "identity", position=position_dodge(), width=0.35, colour="black") + geom_errorbar(aes(ymin=minstall, ymax = maxstall), width=0.2, position = position_dodge(.35)) + xlab("Network Loss Rate") + ylab("Total Stall Duration (s)")+ theme_bw(base_size = 12) + theme(legend.position="top")+ theme(legend.title = element_blank()) + guides(fill = guide_legend(nrow = 1))+ scale_fill_brewer())
dev.off()

sub = subset(tmp,Scheme == "Delay_p2Loss")
pdf("figures/results/stall_sn_loss_p2.pdf", height = 3)
print(ggplot(sub, aes(as.factor(Delay), stall/1000, fill = as.factor(Prot))) +geom_bar(stat = "identity", position=position_dodge(), width=0.35, colour="black") + geom_errorbar(aes(ymin=minstall, ymax = maxstall), width=0.2, position = position_dodge(.35)) + xlab("Network latency (ms)") +
        ylab("Total Stall Duration (s)")+ theme_bw(base_size = 12) + theme(legend.position="top")+ 
        theme(legend.title = element_blank()) + guides(fill = guide_legend(nrow = 1))+ scale_fill_brewer()) 

dev.off()

################################################################################################################
# ../../dash_paper/section/testing.tex:  \includegraphics[width=\columnwidth]{dash/startupdelay_p2delay_16.pdf}
# ../../dash_paper/section/testing.tex:  \includegraphics[width=\columnwidth]{dash/startupdelay_loss_16.pdf}
################################################################################################################
tmp = k[,list(sd = reducedmedian(StartupDelay_ms)/1000, minsdelay = quantile(StartupDelay_ms,0.2)/1000, maxsdelay = quantile(StartupDelay_ms,0.8)/1000), by=c("Net","Prot", "TcpHrxratio", "BufferLen_ms")]

tmp = merge(tmp, n, by = "Net")

sub = subset(tmp,Scheme == "Delay_p2Loss")
pdf("figures/results/startup_sn_loss_p2.pdf", height = 3)
print(ggplot(sub, aes(as.factor(Delay), sd, fill=as.factor(Prot)))+geom_bar(stat = "identity", position=position_dodge(), width=0.35,colour="black") + geom_errorbar(aes(ymin=minsdelay, ymax = maxsdelay), width=0.2, position = position_dodge(.35)) + xlab("Network latency (ms)")+ylab("Startup Delay (s)")+ theme_bw(base_size = 12) + theme(legend.position="top")+ guides(fill = guide_legend(nrow = 1))+theme(legend.title = element_blank())+ scale_fill_brewer())
dev.off()


sub = subset(tmp,Scheme == "Loss")
pdf("figures/results/startup_sn_delay_d100.pdf", height = 3)
print(ggplot(sub, aes(as.factor(Loss/100), sd, fill=as.factor(Prot)))+geom_bar(stat = "identity", position=position_dodge(), width=0.35,colour="black") + geom_errorbar(aes(ymin=minsdelay, ymax = maxsdelay), width=0.2, position = position_dodge(.35)) + theme_bw(base_size = 12) + xlab("Network Loss Rate")+ylab("Startup Delay (s)") + theme(legend.position="top") +guides(fill = guide_legend(nrow = 1))+theme(legend.title = element_blank())+ scale_fill_brewer())
dev.off()

################################################################################################################
# ../../dash_paper/section/testing.tex:  \includegraphics[width=\columnwidth]{dash/rate_p2delay_16.pdf}
# ../../dash_paper/section/testing.tex:  \includegraphics[width=\columnwidth]{dash/ratechange_p2delay_16.pdf}
# ../../dash_paper/section/testing.tex:  \includegraphics[width=\columnwidth]{dash/rate_loss_16.pdf}
# ../../dash_paper/section/testing.tex:  \includegraphics[width=\columnwidth]{dash/ratechange_loss_16.pdf}
################################################################################################################


k = read.csv("stage4/data/sn_rate_changes.csv", head= T, sep=" ")
k = k[ k$rxbufratio == 0.9 | k$rxbufratio == 1 | k$rxbufratio == 0.90, ]
k$prot = ifelse(k$prot == "tcp", "TCP", ifelse(k$prot == "tcph", "Hollywood", "HOLLYWOOD_SR"))
k$algo = ifelse(k$algo  == "bola", "BOLA", ifelse(k$algo  == "abma", "ABMA", ifelse(k$algo  == "panda", "PANDA", "WTF")))

k = k[k$totalchunksc > 100, ]
k = as.data.table(k)

tmp = k[,list(sdrate = mean(sd.rate, trim=0.1), rate = mean(av.rate, trim=0.1), change = mean(downswitch,0.1)*100/mean(totalchunksc), sdchange = sd.trim(downswitch, 0.1)*100/mean(totalchunksc)), by=c("net","prot", "rxbufratio")]
n = read.csv("stage5/networks.csv", head= T, sep= " ")
tmp = merge(tmp, n, by.x = "net", by.y= "Net")

sub = subset(tmp,Scheme == "Delay_p2Loss")

pdf("figures/results/bitrate_sn_loss_p2.pdf", height = 3)
print(ggplot(sub, aes(as.factor(Delay), rate/1000 ,fill = as.factor(prot))) + geom_bar(stat = "identity", position=position_dodge(),  width=0.35,colour="black")
      + geom_errorbar(aes(ymin=(rate-sdrate)/1000, ymax = (rate+sdrate)/1000), width=0.2, position = position_dodge(.35))
      + theme_bw(base_size = 12) + xlab("Network Latency (ms)") + ylab ("Average Media Bitrate (Mbps)") 
      + theme(legend.position="top")+ guides(fill = guide_legend(nrow = 1))+theme(legend.title = element_blank()) + scale_fill_brewer())
dev.off()

pdf("figures/results/ratedrops_sn_loss_p2.pdf", height = 3)
print(ggplot(sub, aes(as.factor(Delay), change ,fill = as.factor(prot))) + geom_bar(stat = "identity", position=position_dodge(),  width=0.35,colour="black")
      + geom_errorbar(aes(ymin=change-sdchange, ymax = change+sdchange), width=0.2, position = position_dodge(.35))
      + theme_bw(base_size = 12)  + xlab("Network Latency (ms)") + ylab ("Chunks with Rate Drops (%)") 
      + theme(legend.position="top")+ guides(fill = guide_legend(nrow = 1))+theme(legend.title = element_blank())+ scale_fill_brewer())
dev.off()

sub = subset(tmp,Scheme == "Loss")

pdf("figures/results/bitrate_sn_delay_d100.pdf", height = 3)
print(ggplot(sub, aes(as.factor(Loss/100), rate/1000 ,fill = as.factor(prot))) + geom_bar(stat = "identity", position=position_dodge(),  width=0.35,colour="black")
      + geom_errorbar(aes(ymin=(rate-sdrate)/1000, ymax = (rate+sdrate)/1000), width=0.20, position = position_dodge(.35))
      + theme_bw(base_size = 12) + xlab("Network Loss Rate") + ylab ("Average Media Bitrate") 
      + theme(legend.position="top")+ guides(fill = guide_legend(nrow = 1))+theme(legend.title = element_blank())+ scale_fill_brewer())
dev.off()

pdf("figures/results/ratedrops_sn_delay_d100.pdf", height = 3)
print(ggplot(sub, aes(as.factor(Loss/100), change ,fill = as.factor(prot))) + geom_bar(stat = "identity", position=position_dodge(),  width=0.35,colour="black")
      + geom_errorbar(aes(ymin=change-sdchange, ymax = change+sdchange), width=0.20, position = position_dodge(.35))
      + theme_bw(base_size = 12) + xlab("Network Loss Rate") + ylab ("Chunks with Rate Drops (%)") 
      + theme(legend.position="top")+ guides(fill = guide_legend(nrow = 1))+theme(legend.title = element_blank())+ scale_fill_brewer())
dev.off()


