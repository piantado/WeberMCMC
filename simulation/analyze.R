
library(Hmisc)

d.true <- read.csv("true_W.txt", header=T)

lwd <- 2.




## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Figure 1
## A single subject at each W, giving their estimate and range
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



d <- merge(d.true, read.csv( "Wmcmc_Uniform.txt", header=T), by=c("subject"))

# Take the first subject, to get one each
q <- d[1:length(table(d$W.true)),] # the first #Wlevels rows
# q <- subset(d, c(TRUE, diff(d$W.true)!= 0))

postscript("Westimation.eps", height=4, width=4)
plot(q$W.true, q$W.mean, col=1, lwd=lwd, type="p", ylim=c(0,4), xlab="True W", ylab="Estimated W", pch=20)
errbar(q$W.true, q$W.mean, q$W.lower, q$W.upper, col=1, add=T, cap=0, pch=".")
lines(q$W.true, q$W.ML, col=2, lwd=lwd, type="p", pch=20)
abline(0,1, lty=2, lwd=lwd)
legend("topleft", c("Posterior mean", "Maximum likelihood"), col=c(1,2), pch=20)
dev.off()

postscript("Wrelativeestimation.eps", height=4, width=4)
plot(q$W.true, q$W.mean/q$W.true, col=1, lwd=lwd, type="p", ylim=c(0,5), xlab="True W", ylab="Estimated W / True W", pch=20)
errbar(q$W.true, q$W.mean/q$W.true, q$W.lower/q$W.true, q$W.upper/q$W.true, col=1, add=T, cap=0, pch=".")
lines(q$W.true, q$W.ML/q$W.true, col=2, lwd=lwd, type="p", pch=20)
abline(h=1, lty=2, lwd=lwd)
dev.off()


wf <- function(W,n1,n2) {  # log weber accuracy of correct
	pnorm( abs(n1-n2) / (W * sqrt( n1**2. + n2**2. ) ), log.p=TRUE) 
}

log1mexp <- function(x) { log(1.-exp(x)) }

# For hard-coded data set: right on (5,6), (6,7), wrong on (7,8), (8,9)
ll <- function(W) {
	(wf(W,6,7) + log1mexp(wf(W,7,8)))
}

prior <- function(W) { log(dexp(W, rate=0.1))}

post <- function(W) { ll(W) + prior(W) }

W <- seq(0.01, 100.0, 0.01)

postscript("ll.eps", height=4, width=4)
plot(W, exp(ll(W)), type="l", xlab="W", ylab="P(D | W)", xlim=c(0,2), lwd=2)
dev.off()

y <- exp(post(W))
y <- y/sum(y)
postscript("posterior.eps", height=4, width=4)
plot(W, y, type="l", xlab="W", ylab="Posterior probability P(W|D)", xlim=c(0,2), lwd=2)
dev.off()

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Means over lots of simulated subjects
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# A quick wrapper for aggregating and making the outcome be sd / value (relative sd)
agrelvar <- function( y, x ) {
	a <- aggregate( y ~ x, NULL, var) 
	a[,2] <- a[,2]/a[,1]
	a
}

NAMES <- c("Uniform", "Jeffreys", "Gamma", "Exponential")
FILES <- paste("Wmcmc_", NAMES, ".txt", sep="")

postscript("estimators.eps", height=18, width=7.5)

par(mfrow=c(4,3), mar=c(3,3,1,1), oma=c(0,3,3,0))

padjxlab <- 2.5
padjylab <- -2
for( i in 1:length(NAMES)) {

	d <- merge(d.true, read.csv(FILES[i], header=T), by=c("subject"))
		
	d <- subset(d, W.ML < 10) # throw out those crazy ML fits
	
	
	plot( aggregate(W.mean   ~ W.true, d, mean), col=5, lwd=lwd, type="b", ylim=c(0,2), main="", xlab="", ylab="")
	mtext("W", side=1, padj=padjxlab)
	mtext("Estimate", side=2, padj=padjylab)
	lines(aggregate(W.median ~ W.true, d, mean), col=4, lwd=lwd, type="b")
	lines(aggregate(W.MAP    ~ W.true, d, mean), col=3, lwd=lwd, type="b")
	lines(aggregate(W.ML    ~ W.true, d, mean), col=2, lwd=lwd, type="b")
	abline(0,1)
	
	mtext(NAMES[i], side=2, padj=-5, font=2) # Left margin label
	if(i==1) { mtext("Estimated vs True", side=3, padj=-1, font=2)} # Top label
	if(i==1) {
		legend("topleft", c("Mean", "Median", "MAP", "ML"), lty=1, col=c(5,4,3,2))
	}
	
	plot( aggregate( (W.mean/W.true)     ~ W.true, d, mean), lwd=lwd, col=5, type="b", ylim=c(0,2), main="", ylab="", xlab="")
	mtext("W", side=1, padj=padjxlab)
	mtext("Estimate / True", side=2, padj=padjylab)
	lines(aggregate( (W.median/W.true)   ~ W.true, d, mean), lwd=lwd, col=4, type="b")
	lines(aggregate( (W.MAP/W.true)    ~ W.true, d, mean), lwd=lwd, col=3, type="b")
	lines(aggregate( (W.ML/W.true)    ~ W.true, d, mean), lwd=lwd, col=2, type="b")
	abline(1,0)
	
	if(i==1) { mtext("Estimated vs True (relative)", side=3, padj=-1, font=2)} # Top label

	# Or maybe plot relative var, and change below?
	plot( agrelvar(d$W.mean, d$W.true), lwd=lwd, col=5, type="b",  ylim=c(0,2), ylab="", xlab="")
	mtext("W", side=1, padj=padjxlab)
	mtext("Variance", side=2, padj=padjylab)
	lines(agrelvar(d$W.median, d$W.true), lwd=lwd, col=4, type="b")
	lines(agrelvar(d$W.MAP, d$W.true), lwd=lwd, col=3, type="b")
	lines(agrelvar(d$W.ML, d$W.true), lwd=lwd, col=2, type="b")
	
	if(i==1) { mtext("Estimator Variance", side=3, padj=-1, font=2)} # Top label
}
# par(xpd=TRUE)

dev.off()
