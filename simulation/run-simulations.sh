
python simulate_staircase.py

# And run these in parallel (via &)
python ../weber-mcmc.py --data=responses.txt --prior=Uniform > Wmcmc_Uniform.txt &

python ../weber-mcmc.py --data=responses.txt --prior=Jeffreys > Wmcmc_Jeffreys.txt & 

python ../weber-mcmc.py --data=responses.txt --prior=Gamma > Wmcmc_Gamma.txt &

python ../weber-mcmc.py --data=responses.txt --prior=Exponential > Wmcmc_Exponential.txt &

