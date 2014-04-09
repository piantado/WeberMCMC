import pymc
import numpy
import scipy
import scipy.stats
import scipy.optimize
import argparse
import sys

from numpy import sqrt, exp, abs, mean, median, std, sum, log
from scipy.special import erf, erfc
normcdf = scipy.stats.norm.cdf

import pandas
from pandas import notnull, isnull

def Weber_probability_correct(W,n1,n2):
	""" Returns the probability of answering correctly for W, n1, n2, following Halberda et al 2008"""
	
	return 1.0 - 0.5 * erfc( abs(n1-n2) / (sqrt(2.0) * W * sqrt( n1**2. + n2**2. ) ))



"""
# The norm pdf version -- identical
def f(W,n1,n2):
	# Returns the probability of answering correctly for W, n1, n2.
	
	return normcdf( abs(n1-n2) / (W * sqrt( n1**2. + n2**2. ) ))

w = numpy.arange(0.01,1.5, 0.01)
f(w,5,6) - Weber_probability_correct(w,5,6)
"""


# Convert taus (precisions) to sd/var
def tau2sd(x): return 1.0/sqrt(x)
def tau2var(x): return 1.0/x