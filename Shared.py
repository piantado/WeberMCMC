import pymc
import numpy
import scipy
import scipy.stats
import scipy.optimize
import argparse
import sys

from numpy import sqrt, exp, abs, mean, median, std, sum, log
normcdf = scipy.stats.norm.cdf

import pandas
from pandas import notnull, isnull

def Weber_probability_correct(W,n1,n2):
	""" Returns the probability of answering correctly for W, n1, n2."""
	
	return normcdf( abs(n1-n2) / (sqrt(2.0) * W * sqrt( n1**2. + n2**2. ) ))

# Convert taus (precisions) to sd/var
def tau2sd(x): return 1.0/sqrt(x)
def tau2var(x): return 1.0/x