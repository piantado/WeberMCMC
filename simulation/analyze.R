

d.true <- read.table("true_W.txt", header=T)
d.uniform <- read.table("Wmcmc_Uniform.txt", header=T)
d.jeffreys <- read.table("Wmcmc_Jeffreys.txt", header=T)
d.gamma <- read.table("Wmcmc_Gamma.txt", header=T)

d <- merge(d.true, d.uniform, by=c("subject"))

plot(d$W.true, d$W.mcmc.median, ylim=c(0,2), xlim=c(0,2) )
points(d$W.true, d$W.ML, col=2)
abline(0,1)

## TODO: Analyze R^2 and MSE -- The scatter plot is very misleading -- the MCMC models are better by these measures!
