
## MAKE THIS POINT TO WHERE WEBER-MCMC LIVES:
WEBER_PY_PATH = "/home/piantado/Desktop/Science/Libraries/WeberMCMC"

# Just a wrapper to output a data frame, run it, and return values
##UGH R's big integers get rounded. Must make them strings!
weber.mcmc <- function(d, samples="10000", skip=20, burn=2000, tune=1000, flags="") {

	f <- tempfile(pattern="webermcmc") # store our file
	o <- tempfile(pattern="webermcmc")

	print(c(f,o))
	
	write.csv(d, file=f, row.names=F)
	
	command <- paste("python ", WEBER_PY_PATH,"/weberMCMC.py --data=",f, " --samples=",samples," --skip=",skip, " --burn=",burn, " --tune=",tune, " ", flags, "--out=", o, sep="")
	
	system(command) # ignore.stdout=TRUE, ignore.stderr=TRUE)
	
	ret = read.csv(o)
	
	file.remove(f)
	file.remove(o)
	
	ret # return this
}