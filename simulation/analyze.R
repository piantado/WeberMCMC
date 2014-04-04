

d.true <- read.csv("true_W.txt", header=T)

par(mfrow=c(3,2))
	
for( file in c("Wmcmc_Uniform.txt", "Wmcmc_Jeffreys.txt", "Wmcmc_Gamma.txt")) {

	d <- merge(d.true, read.csv(file, header=T), by=c("subject"))
	
	
	d <- subset(d, W.ML < 10) # throw out those crazy ML fits
	
	plot( aggregate(W.ML     ~ W.true, d, mean), col=2, type="b", ylim=c(0,5), main=file, ylab="Estimate mean")
	lines(aggregate(W.mean   ~ W.true, d, mean), col=4, type="b")
	lines(aggregate(W.MAP    ~ W.true, d, mean), col=3, type="b")
	abline(0,1)

	plot( aggregate(W.ML     ~ W.true, d, var), col=2, type="b",  ylim=c(0,5), ylab="Estimate variance")
	lines(aggregate(W.mean   ~ W.true, d, var), col=4, type="b")
	lines(aggregate(W.MAP    ~ W.true, d, var), col=3, type="b")
}


