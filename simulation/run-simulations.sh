
python simulate_staircase.py

# And run these in parallel (via &)
python model.py --data=responses.txt --prior=Jeffreys > Wmcmc_Jeffreys.txt & 
python model.py --data=responses.txt --prior=Uniform > Wmcmc_Uniform.txt &
python model.py --data=responses.txt --prior=Gamma > Wmcmc_Gamma.txt &
