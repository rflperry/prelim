rm(list = ls())

library(xtable)
library(data.table)
# learner = "lasso" # uncomment for lasso results
learner = "lasso" # uncomment for boost results
metric = 'sd'
#learner = "kernel" # uncomment for kernel results

results_path = "sim_results/"

if (learner != "boost" & learner != "lasso" & learner != "kernel") {
  stop("learner needs to be boost or lasso or kernel")
}

filenames = list.files(results_path, pattern=paste0("*", learner, "*"), full.names=TRUE)

param.names = c("alg", "learner", "setup", "n", "p", "sigma", "n_reps")
setup.values = c('A', 'B', 'C', 'D')

raw = data.frame(t(sapply(filenames, function(fnm) {
  output = read.csv(fnm)[,-1]
  params = strsplit(fnm, "-")[[1]][2:8]

  mse.mean = mean(output)
  mse.sd = sd(output)

  c(params,
    mse=sprintf("%.8f", round(mse.mean, 8)),
    sd=sprintf("%.8f", round(mse.sd, 8)))
})))


rownames(raw) = 1:nrow(raw)
names(raw) = c(param.names,
               "mean", "sd")

n_reps <- raw$n_reps[1]

raw<-raw[raw$learner==learner & (raw$setup %in% setup.values), ] # only look at boost or lasso results

options(stringsAsFactors = FALSE)

raw <- raw[raw$setup %in% c('A', 'B', 'D') | (raw$setup == 'C' & raw$n_reps == 500),]

raw = dcast(setDT(raw), setup + n + p + sigma ~ alg, value.var=c(metric))

raw = raw[order(as.numeric(raw$sigma)),]
raw = raw[order(as.numeric(raw$p)),]
raw = raw[order(as.numeric(raw$n)),]
raw = raw[order(as.character(raw$setup)),]
rownames(raw) = 1:nrow(raw)

if (learner == "boost") {
  algs = c("S", "T", "X", "U", "causalboost", "R", "oracle")
  algs.tex = c("S", "T", "X", "U", "CB", "R", "oracle")
} else if (learner == "lasso") {
  algs = c("S", "T", "X", "U", "R", "RS", "oracle")
  algs.tex = algs
} else if (learner == "kernel") {
  algs = c("S", "T", "X", "U", "R", "oracle")
  algs.tex = algs
} else {
  stop("learner needs to be boost or lasso")

}
cols = c(c("setup", "n", "p", "sigma"), algs)
raw <- raw[, ..cols]
colnames(raw)[colnames(raw)=="causalboost"] <- "CB"
colnames(raw)[colnames(raw)=="p"] <- "d"

raw.round = raw
if (learner == "lasso" | learner == "boost"){
  for (col in (5:11)){
    raw.round[,col] <- round(as.numeric(unlist(raw[,..col])),2)
  }
}
if (learner == "kernel") {
  for (col in (5:10)){
    raw.round[,col] <- round(as.numeric(unlist(raw[,..col])),2)
  }
}
raw = data.frame(apply(raw, 1:2, as.character))
raw.round = data.frame(apply(raw.round, 1:2, as.character))

# write raw csv output file
write.csv(raw, file=paste0("outputs/output_", learner, "_", metric, ".csv"), row.names=FALSE)

# get a dataframe for each setup
raw.by.setup = lapply(c(setup.values), function(x) raw.round[raw.round$setup==x, ])

# write to latex tables
for (i in seq_along(setup.values)){
  tab.setup = cbind("", raw.by.setup[[i]][,-1])
  if (learner == "kernel") {
    mse.idx = 1 + c(4:8)
  } else {
    mse.idx = 1 + c(4:9)
  }
  for(iter in 1:nrow(tab.setup)) {
    best.idx = mse.idx[which(as.numeric(tab.setup[iter,mse.idx]) == min(as.numeric(tab.setup[iter,mse.idx])))]
    for (j in 1:length(best.idx)) {
      best.idx.j = best.idx[j]
      tab.setup[iter,best.idx.j] = paste("\\bf", tab.setup[iter,best.idx.j])
    }
  }
  tab.setup = tab.setup[,-1]
  print(setup.values[i])
  print(tab.setup)
  if (learner == "boost") {
    xtab.setup = xtable(tab.setup, caption = paste0("\\tt Mean-squared error running \\texttt{boosting} from Setup ", setup.values[i], ". Results are averaged across ", n_reps, " runs, rounded to two decimal places, and reported on an independent test set of size $n$."), align="ccccccccccc", label=paste0("table:setup",i))
  } else if  (learner == "lasso"){
    xtab.setup = xtable(tab.setup, caption = paste0("\\tt Mean-squared error running \\texttt{lasso} from Setup ", setup.values[i], ". Results are averaged across ", n_reps, " runs, rounded to two decimal places, and reported on an independent test set of size $n$."), align="ccccccccccc", label=paste0("table:setup",i))
  } else if  (learner == "kernel"){
    xtab.setup = xtable(tab.setup, caption = paste0("\\tt Mean-squared error running \\texttt{kernel} from Setup ", setup.values[i], ". Results are averaged across ", n_reps, " runs, rounded to two decimal places, and reported on an independent test set of size $n$."), align="cccccccccc", label=paste0("table:setup",i))
  }
  names(xtab.setup) <- c(c('n','d','$\\sigma$'), algs.tex)
  print(xtab.setup, include.rownames = FALSE, include.colnames = TRUE, sanitize.text.function = identity, file = paste("tables", "/simulation_results_setup_", setup.values[i], "_", learner, "_", metric, ".tex", sep=""))
}

