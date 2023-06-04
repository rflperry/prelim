library(tidyverse)
library(RColorBrewer)

method =  "lasso" #"boost" #  "lasso" #  
metric = 'mean'

load_dir = 'outputs'
save_dir = 'figures'

colors = brewer.pal(8, "Dark2")
if (method == "boost") {
  breaks = c("S", "T", "X", "U", "CB", "R")
  colors = c(colors[3], colors[7], colors[4], colors[8], colors[2], colors[1])
  shapes=c(12, 13, 8, 17, 11, 15)
  sizes = c(2, 2, 1.7, 2, 1.5, 2)
} else if (method == "lasso") {
  # breaks = c("S", "T", "X", "U", "RS", "R")
  # colors = c(colors[1], colors[5], colors[3], colors[7], colors[8], colors[4])
  # shapes = c(15,18,12,13,17,8)
  # sizes = c(2,2.8,2,2,2,1.7)
  breaks = c("S", "T", "X", "U", "RS", "R")
  colors = c(colors[3], colors[7], colors[4], colors[8], colors[5], colors[1])
  shapes=c(12, 13, 8, 17, 18, 15)
  sizes = c(2, 2, 1.7, 2, 2.8, 2)
} else if (method == "kernel") {
  breaks = c("S", "T", "X", "U", "R")
  colors = c(colors[3], colors[7], colors[4], colors[8], colors[1])
  shapes=c(12, 13, 8, 17, 15)
  sizes = c(2, 2, 1.7, 2, 2)
}

plotsize = function(x,y) options(repr.plot.width=x, repr.plot.height=y)

plotsize(8,8)
out = read_csv(paste0(load_dir, "/output_", method, "_", metric, ".csv"))


if (metric == 'mean') {
  label_wrap <- function(variable, value) {
    paste0("Setup ", value)
  }
  out %>%
    select(-n, -d, -sigma) %>%
    gather(learner, mse, -setup, -oracle) %>%
    ggplot(aes(x=log(oracle), y=log(mse), color=learner, shape=learner, size=learner, breaks=learner)) +
    scale_size_manual(breaks=breaks, values=sizes)+
    scale_shape_manual(breaks=breaks, values=shapes)+
    scale_colour_manual(breaks=breaks, values = colors) +
    geom_point() +
    geom_abline(slope=1) +
    facet_wrap(~setup, ncol=2, scales="free", labeller = label_wrap) +
    labs(x = "Oracle log mean-squared error", y = "log mean-squared error")
  ggsave(paste0(save_dir, "/simulation_", method, "_", metric, ".pdf"), width=6, height=3)
  ggsave(paste0(save_dir, "/simulation_", method, "_", metric, ".png"), width=6, height=3)
} else if (metric == 'sd') {
  label_wrap <- function(variable, value) {
    paste0("Setup ", value)
  }
  out %>%
    select(-n, -d, -sigma) %>%
    gather(learner, sd, -setup, -oracle) %>%
    ggplot(aes(x=log(oracle), y=log(sd), color=learner, shape=learner, size=learner, breaks=learner)) +
    scale_size_manual(breaks=breaks, values=sizes)+
    scale_shape_manual(breaks=breaks, values=shapes)+
    scale_colour_manual(breaks=breaks, values = colors) +
    geom_point() +
    geom_abline(slope=1) +
    facet_wrap(~setup, ncol=2, scales="free", labeller = label_wrap) +
    labs(x = "Oracle log standard deviation", y = "log standard deviation")
  ggsave(paste0(save_dir, "/simulation_", method, "_sd.pdf"), width=6, height=3)
  ggsave(paste0(save_dir, "/simulation_", method, "_sd.png"), width=6, height=3)
}
