library(tidyverse)
library(ggplot2)


##### real

n <- 500
df <- data_frame(
  treatment = rep(c(0,1), each=n/2),
  age = runif(n, min=18, max=65),
)
df$outcome <- 2*(df$treatment - 0.5) * (1 - ( (df$age - 18) / (65 - 18)))^2 + rnorm(n, sd=0.5)

g <- ggplot(
  data = df,
  aes(x=factor(treatment), y=outcome, group=factor(treatment))
) +
  geom_boxplot() +
  ylab('Health prognosis') +
  xlab('Treatment')
  # scale_x_continuous(breaks= pretty_breaks())
print(g)
ggsave(paste0('./figures/motivation_boxplot.png'), width = 2, height = 2, unit = "in")

g <- ggplot(
  data = df,
  aes(x=age, y=outcome, color=factor(treatment), group=factor(treatment))
) +
  geom_point(size=0.5) +
  ylab('Health prognosis') +
  xlab('Age') +
  labs(col='Treatment')
print(g)
ggsave(paste0('./figures/motivation_scatter.png'), width = 3, height = 2, unit = "in")

##### discrete
n <- 300
df <- data_frame(
  treatment = rep(c(0,1), each=n/2),
  age = runif(n, min=18, max=65),
)
df$logit <- df$treatment - 0.5 + 4*( (df$age - 18) / 65) - 2
df$p <- exp(df$logit) / (1 + exp(df$logit))
df$outcome <- rbinom(n, 1, df$p)

ggplot(df, aes(x=treatment, y = ..density..)) +
  geom_bar()

g <- ggplot(
  data = df %>%
    group_by(age, treatment) %>%
    summarise(mean_outcome = mean(outcome)),
  aes(x=age, color=treatment, y = mean_outcome)) +
  geom_bar()#breaks = c(18, 25, 35, 50, 65))
plot(g)

g <- ggplot(
  data=df,
  aes(x=age, fill=factor(treatment), color=factor(treatment), y=outcome)
) +
  stat_summary_bin(fun = "mean", geom = "bar", breaks = c(18, 25, 35, 50, 65), alpha=0.5)#, fill='white')
plot(g)
