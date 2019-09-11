import trackball_suite
import numpy as np
import matplotlib.pyplot as plt
import glob

sourcedir = 'C:/Users/Sur lab/Dropbox (MIT)/trackball-behavior/Data/ACC unilateral inactivation two stim/RACC/'
sourcefiles = glob.glob(sourcedir + '*.mat')
sessions = []

for file in sourcefiles:
    try:
        session = trackball_suite.Session(file)
        sessions.append(session)
    except ValueError:
        print(file, ': no opp contrast')
        continue

    # Extract laser subsession
    #plt.figure()
    #session.plot_psychometric(color='b')
    #plt.title(file)

    laser_p1_trials = np.where(session.laser)[0] + 1
    if laser_p1_trials[-1] == len(session.laser):
        laser_p1_trials = laser_p1_trials[:-1]

    laser_trials = session.make_subsession(np.where(session.laser)[0])
    laser_plus_one = session.make_subsession(laser_p1_trials)
    no_laser_trials = session.make_subsession(np.where(session.laser == 0)[0])
    #plt.figure()
    #no_laser_trials.plot_psychometric(color='r')
    #laser_trials.plot_psychometric(color='b')
    #laser_plus_one.plot_psychometric(color='g')

# Combined sessions
all_sess = trackball_suite.combine_multiple_sessions(sessions)
laser_p1_trials = np.where(all_sess.laser)[0] + 1
if laser_p1_trials[-1] == len(all_sess.laser):
    laser_p1_trials = laser_p1_trials[:-1]
no_laser_p1_trials = np.where(all_sess.laser == 0)[0] + 1
if no_laser_p1_trials[-1] == len(all_sess.laser):
    no_laser_p1_trials = no_laser_p1_trials[:-1]

no_laser_trials_ids = np.where(all_sess.laser == 0)[0]
no_laser_p1_no_laser_ids = np.intersect1d(no_laser_trials_ids, no_laser_p1_trials)


laser_trials = all_sess.make_subsession(np.where(all_sess.laser)[0])
laser_plus_one = all_sess.make_subsession(laser_p1_trials)
no_laser_trials = all_sess.make_subsession(np.where(all_sess.laser == 0)[0])
no_laser_plus_one = all_sess.make_subsession(no_laser_p1_trials)
no_laser_p1_no_laser = all_sess.make_subsession(no_laser_p1_no_laser_ids)
plt.figure()

no_laser_trials.plot_psychometric(color='r')
laser_trials.plot_psychometric(color='b')
laser_plus_one.plot_psychometric(color='g')
#no_laser_plus_one.plot_psychometric(color='k')
no_laser_p1_no_laser.plot_psychometric(color='k')

