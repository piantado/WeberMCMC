# -*- coding: utf-8 -*-

from Shared import *


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Pymc model for Weber (uniform prior on W)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

def make_model_Exponential(n1, n2, ntrials, ncorrect):
    # Draw W from an exponential
    W = pymc.Exponential('W', 0.10, value=0.5)  # pick a reasonable start place

    @pymc.deterministic
    def p_correct(W=W, n1=n1, n2=n2): return Weber_probability_correct(W, n1, n2)

    # Now the data:n
    data = pymc.Binomial('data', n=ntrials, p=p_correct, value=ncorrect, observed=True)

    # and pymc return
    return locals()


def make_model_Uniform(n1, n2, ntrials, ncorrect):
    # Draw a uniform Weber ratio
    W = pymc.Uniform('W', 0.0, 3.0, value=0.50)  # pick a reasonable start place

    @pymc.deterministic
    def p_correct(W=W, n1=n1, n2=n2): return Weber_probability_correct(W, n1, n2)

    # Now the data:n
    data = pymc.Binomial('data', n=ntrials, p=p_correct, value=ncorrect, observed=True)

    # and pymc return
    return locals()


# A model with the an inverse prior on W, (which would be JEffrey's for a normal SD)
def make_model_Inverse(n1, n2, ntrials, ncorrect):
    # sd
    W = pymc.Uniform('W', 0.0, 10.0, value=0.50)  # pick a reasonable start place

    # encode our (improper) prior as a potential, returning a log probability
    @pymc.potential
    def JeffreysPrior(W=W): return -log(W)  # log(1/W) = -log(W)

    @pymc.deterministic
    def p_correct(W=W, n1=n1, n2=n2): return Weber_probability_correct(W, n1, n2)

    # Now the data:
    data = pymc.Binomial('data', n=ntrials, p=p_correct, value=ncorrect, observed=True)

    # and pymc return
    return locals()


def make_model_InverseGamma(n1, n2, ntrials, ncorrect):
    Wsq = pymc.InverseGamma('Wsq', 1.0, 1.0)  # shape, rate, prior on tau, not W

    @pymc.deterministic
    def W(Wsq=Wsq):
        return sqrt(Wsq)

    @pymc.deterministic
    def p_correct(W=W, n1=n1, n2=n2):
        return Weber_probability_correct(W, n1, n2)

    # Now the data:
    data = pymc.Binomial('data', n=ntrials, p=p_correct, value=ncorrect, observed=True)

    # and pymc return
    return locals()


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run as main script
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if __name__ == "__main__":

    # Parse our arguments
    parser = argparse.ArgumentParser(description='Weber MCMC')
    # parser.add_argument('--out', dest='out', type=str, default="./run/", nargs="?", help='The directory for output')

    parser.add_argument('--prior', dest='prior', type=str, default='Inverse', nargs="?",
                        help='The prior (Uniform, Jeffreys, Gamma)')

    # MCMC parameters
    parser.add_argument('--samples', dest='samples', type=int, default=10000, nargs="?",
                        help='Number of samples to run')
    parser.add_argument('--skip', dest='skip', type=int, default=20, nargs="?", help='Skip in chains')
    parser.add_argument('--burn', dest='burn', type=int, default=2000, nargs="?", help='Burn-in time')
    parser.add_argument('--tune', dest='tune', type=int, default=1000, nargs="?", help='Number of tuning steps')
    parser.add_argument('--data', dest='data', type=str, default='testing/test-1.csv', nargs="?",
                        help='What data file?')
    parser.add_argument('--firsthalf', action="store_true",  help='Run only on the first half (of input lines)')
    parser.add_argument('--out', dest='out', type=str, default='out.csv', nargs=1, help='Where to write output')
    args = vars(parser.parse_args())
    # print "# ARGS:", args

    # Load the data
    data = pandas.io.parsers.read_csv(args['data'], sep=",")  # sep=None tries to automatically determine the separate (comma, space, etc)
    # print data

    with open(args['out'], 'w') as f:
        # Loop through subjects:
        print >>f, "subject,W.ML,W.mean,W.median,W.MAP,W.sd,W.lower,W.upper,Wlog.mean,Wlog.sd,MAP.BIC,W.ML.deriv"
        for subject, ds in data.groupby('subject'):

            assert 'n1' in ds and 'n2' in ds and 'ntrials' in ds and 'ncorrect' in ds, "Bad column header!"

            # Now toss missing data
            ds = ds[notnull(ds.n1) & notnull(ds.n2) & notnull(ds.ntrials) & notnull(ds.ncorrect)]

            # now if we do firsthalf, use that
            if args['firsthalf']:
                ds = ds[:(ds.shape[0]/2)]

            n1, n2, ntrials, ncorrect = ds.n1, ds.n2, ds.ntrials, ds.ncorrect
            assert all(ntrials >= ncorrect)

            if args['prior'] == 'Inverse':
                model = pymc.Model(make_model_Inverse(n1, n2, ntrials, ncorrect))
            elif args['prior'] == 'Uniform':
                model = pymc.Model(make_model_Uniform(n1, n2, ntrials, ncorrect))
            elif args['prior'] == 'InverseGamma':
                model = pymc.Model(make_model_InverseGamma(n1, n2, ntrials, ncorrect))
            elif args['prior'] == 'Exponential':
                model = pymc.Model(make_model_Exponential(n1, n2, ntrials, ncorrect))
            else:
                assert False, "Bad prior type: " + args['prior']

            mcmc = pymc.MCMC(model)

            mcmc.sample(iter=args['samples'], burn=args['burn'], thin=args['skip'] + 1, tune_interval=args['tune'],
                        progress_bar=False)  # so skip=0 means don't skip

            Wsamp = mcmc.trace('W')[:]
            W95 = mcmc.stats('W')['W']['95% HPD interval']


            # print mcmc.W.stats()

            # And we'll also do the ML fit
            def to_optimize(W):
                p = Weber_probability_correct(W, n1, n2)
                return -sum(log(p) * ncorrect + log(1. - p) * (ntrials - ncorrect))


            o = scipy.optimize.fmin(to_optimize, 0.5, disp=False)  # optimize via scipy

            # compute numerically the derivative of the likelihood surface at the optimum
            h = 0.0001
            derivLL = (to_optimize(o) - to_optimize(o + h)) / h

            # And we'll check out the MAP fit via pymc
            mymap = pymc.MAP(model)
            mymap.fit()

            print  >>f, ','.join(map(str, [subject, o[0], mean(Wsamp), median(Wsamp), mymap.W.value, std(Wsamp), W95[0], W95[1],
                                     mean(log(Wsamp)), std(log(Wsamp)), mymap.BIC, derivLL]))
            f.flush()

    # Done.
    quit()
