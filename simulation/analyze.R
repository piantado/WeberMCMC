

d.true <- read.csv("true_W.txt", header=T)

for( file in c("Wmcmc_Uniform.txt", "Wmcmc_Jeffreys.txt", "Wmcmc_Gamma.txt")) {

	d <- merge(d.true, read.csv("Wmcmc_Gamma.txt", header=T), by=c("subject"))

	par(mfrow=c(1,2))
	plot( aggregate(W.ML     ~ W.true, d, mean), col=2, type="b", ylim=c(0,3))
	lines(aggregate(W.mean   ~ W.true, d, mean), col=4, type="b")
	abline(0,1)

	plot( aggregate(W.ML     ~ W.true, d, var), col=2, type="b")
	lines(aggregate(W.mean   ~ W.true, d, var), col=4, type="b")

}