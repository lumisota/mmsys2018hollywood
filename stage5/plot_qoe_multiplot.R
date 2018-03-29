# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
# http://www.cookbook-r.com/Graphs/Multiple_graphs_on_one_page_(ggplot2)/


library(ggplot2)
library(data.table)
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



s = read.csv("stage4/data/sn_frame_ssim.csv", head= F, sep=" ")
p = read.csv("stage4/data/sn_frame_psnr.csv", head= F, sep=" ")
n = read.csv("stage5/networks.csv", head= T, sep= " ")

ptmp = merge(p, n, by.x = "V2", by.y = "Net")
ptmp$V3 = ifelse(ptmp$V3 == "tcp", "TCP", ifelse(ptmp$V3 == "tcph", "Hollywood", "HOLLYWOOD_SR"))

stmp = merge(s, n, by.x = "V2", by.y = "Net")
stmp$V3 = ifelse(stmp$V3 == "tcp", "TCP", ifelse(stmp$V3 == "tcph", "Hollywood", "HOLLYWOOD_SR"))

psub = subset(ptmp,Scheme == "Delay_p2Loss")
ssub = subset(stmp,Scheme == "Delay_p2Loss")

p0 = ggplot(psub, aes(as.factor(Delay), V9, fill = as.factor(V3)))+geom_boxplot(notch = T, colour = "black") + 
  theme_bw(base_size = 12)+ scale_colour_manual(values=c("red", "black")) + xlab("Network Latency (ms)") + 
  ylab ("Frame PSNR") + theme(legend.position="bottom")+ guides(fill = guide_legend(nrow = 1))+theme(legend.title = element_blank())+ scale_fill_brewer()
ylim1 = boxplot.stats(psub$V9)$stats[c(1, 5)]
p1 = p0+ coord_cartesian(ylim = ylim1)

s0 = ggplot(ssub, aes(as.factor(Delay), V9, fill = as.factor(V3)))+geom_boxplot(colour = "black") + 
  theme_bw(base_size = 12)+ xlab("Network Latency (ms)") + ylab ("Frame SSIM") + theme(legend.position="bottom") +
  guides(fill = guide_legend(nrow = 1))+theme(legend.title = element_blank())+ scale_fill_brewer()
s1 = s0 + coord_cartesian(ylim = c(0.90,1.0))

png("figures/results/qoe_sn_loss_p2.png", height = 3, width = 7, units = "in", res=300)
print(multiplot(p1,s1, cols = 2))
dev.off()

psub = subset(ptmp,Scheme == "Loss")
ssub = subset(stmp,Scheme == "Loss")
p0 = ggplot(psub, aes(as.factor(Loss), V9, fill = as.factor(V3)))+geom_boxplot(notch = T, colour = "black") + 
  theme_bw(base_size = 12)+ scale_colour_manual(values=c("red", "black")) + xlab("Network Loss Rate") + 
  ylab ("Frame PSNR") + theme(legend.position="bottom")+ guides(fill = guide_legend(nrow = 1))+theme(legend.title = element_blank())+ scale_fill_brewer()
ylim1 = boxplot.stats(psub$V9)$stats[c(1, 5)]
p1 = p0+ coord_cartesian(ylim = ylim1)

s0 = ggplot(ssub, aes(as.factor(Loss), V9, fill = as.factor(V3)))+geom_boxplot(colour = "black") + 
  theme_bw(base_size = 12)+ xlab("Network Loss Rate") + ylab ("Frame SSIM") + theme(legend.position="bottom") +
  guides(fill = guide_legend(nrow = 1))+theme(legend.title = element_blank())+ scale_fill_brewer()
s1 = s0 + coord_cartesian(ylim = c(0.90,1.0))

png("figures/results/qoe_sn_delay_d100.png", height = 3, width = 7, units = "in", res=300)
print(multiplot(p1,s1, cols = 2))
dev.off()



#######################PROFILES16 ##########################################
s = read.csv("stage4/data/vn_frame_ssim.csv", head= F, sep=" ")
p = read.csv("stage4/data/vn_frame_psnr.csv", head= F, sep=" ")

p$V3 = ifelse(p$V3 == "tcp", "TCP", ifelse(p$V3 == "tcph", "HOLLYWOOD", "HOLLYWOOD_SR"))
p$V2 = substr(p$V2, 4, 5)
s$V3 = ifelse(s$V3 == "tcp", "TCP", ifelse(s$V3 == "tcph", "HOLLYWOOD", "HOLLYWOOD_SR"))
s$V2 = substr(s$V2, 4, 5)

p0 = ggplot(p, aes(as.factor(V2), V9, fill = as.factor(V3)))+geom_violin(colour = "black") + 
  theme_bw(base_size = 12) + xlab("Network Profile") + ylab ("Frame PSNR") + theme(legend.position="none") + scale_fill_brewer()

s0 = ggplot(s, aes(as.factor(V2), V9, fill = as.factor(V3)))+geom_violin(colour = "black") + 
  theme_bw(base_size = 12)+ xlab("Network Profile") + ylab ("Frame SSIM") + theme(legend.position=c(0.2,0.2)) +
  theme(legend.title = element_blank())+ scale_fill_brewer()



png("figures/results/qoe_vn_all.png", height = 5, width = 7, units = "in", res=300)
print(multiplot(p0,s0))
dev.off()




