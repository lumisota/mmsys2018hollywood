

library(ggplot2)
library(data.table)

k = read.csv("stage4/data/timeline_example_out.csv", head= F, sep = " ")
k$V1 = ifelse(k$V1 == "tcp", "TCP", ifelse(k$V1 == "tcph", "Hollywood", "HOLLYWOOD_SR"))

pdf("figures/results/timeline_vn_example.pdf", height = 3)
print(ggplot(k, aes(V5, V6/1000000, colour= V1)) + geom_line() + theme_bw(base_size = 12) + xlab("Chunk Index") + ylab ("Chunk bit rate (Mbps)") + theme(legend.position="top")+ guides(fill = guide_legend(nrow = 1))+theme(legend.title = element_blank()) + scale_colour_manual(values = c("grey", "black")))
dev.off()
