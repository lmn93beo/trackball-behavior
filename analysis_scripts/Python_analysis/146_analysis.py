import trackball_suite
import numpy as np
import matplotlib.pyplot as plt
import glob
import utils

sourcedir = 'C:/Users/Sur lab/Dropbox (MIT)/trackball-behavior/Data/146_all/'
sourcefiles = glob.glob(sourcedir + '*.mat')
sessions = []

for file in sourcefiles:
    print(file)
    try:
        session = trackball_suite.Session(file)
    except utils.NoChoiceError:
        continue
    except utils.NoLaserError:
        pass
    except utils.NoConsError:
        continue

    sessions.append(session)

sess_group = trackball_suite.SessionGroup(sessions)
sess = sess_group.as_session()
#sess.plot_raw_performance()
#sess_group.plot_agg_performance()
#sess_group.plot_individual_raw_performance()
print('******************')
freps = []
freperrs = []
fcorrs = []
fcorrerrs = []
for sess in sess_group.sess_lst:
    frep, freperr, fcorr, fcorrerr = sess.print_summary()
    freps.append(frep)
    freperrs.append(freperr)
    fcorrs.append(fcorr)
    fcorrerrs.append(fcorrerr)
plt.plot(fcorrs)
plt.plot(fcorrerrs)
plt.legend(['correct at t', 'error at t'])
plt.title('Fraction correct at t+1')
plt.hlines(0.5, 0, sess_group.nsess + 2)
