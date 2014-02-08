WeberMCMC
=========

This library wraps PyMC to estimate Weber ratios in psychology experiments. 

This allows for statistics incorporating the reliability of measured Weber ratios, which appears to substantially influence the statistics. 

This tool is currently under heavy development by colala ( http://colala.bcs.rochester.edu/ )

Use
====

weber-mcmc.py includes python wrappers for PyMC, including several natural priors on Weber ratios.

weber-mcmc.R includes a simple R wrapper. It requires WEBER_PY_PATH to point to where weber-mcmc.py lives