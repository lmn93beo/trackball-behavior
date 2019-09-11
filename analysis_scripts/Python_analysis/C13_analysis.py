import trackball_suite
import numpy as np
import matplotlib.pyplot as plt

sourcedir = 'C:/Users/Sur lab/Dropbox (MIT)/trackball-behavior/Data/Data_for_Lupe/C13_leftACCSTR/'

sourcefiles = ['20190220_trackball_0013.mat', '20190222_trackball_0013.mat',
               '20190224_trackball_0013.mat', '20190226_trackball_0013b.mat']

laser_sessions = []
non_laser_sessions = []
for id, file in enumerate(sourcefiles):
    session = trackball_suite.Session(sourcedir + file)

    # Make a subsession with only laser
    laser_trials = np.where(session.laser == 1)[0]
    one_after_laser = laser_trials + 1
    two_after_laser = laser_trials + 2
    one_after_and_nolaser = np.setdiff1d(one_after_laser, laser_trials)
    two_after_and_nolaser = np.setdiff1d(two_after_laser, laser_trials)
    # In case trial + 1 gets off bound
    one_after_and_nolaser = one_after_and_nolaser[one_after_and_nolaser < len(session.laser)]
    two_after_and_nolaser = two_after_and_nolaser[two_after_and_nolaser < len(session.laser)]
    laser_subsess = session.make_subsession(laser_trials)
    non_laser_subsess = session.make_subsession(one_after_and_nolaser)
    two_subsess = session.make_subsession(two_after_and_nolaser)

    #non_laser_trials = np.where(session.laser == 0)[0]
    #laser_subsess = session.make_subsession(laser_trials)
    #non_laser_subsess = session.make_subsession(non_laser_trials)


    laser_sessions.append(laser_subsess)
    non_laser_sessions.append(non_laser_subsess)

    plt.subplot(2, 2, id + 1)
    plt.title('Session #' + str(id + 1))
    laser_subsess.plot_psychometric(color='b', alpha=0.8)
    non_laser_subsess.plot_psychometric(color='r', alpha=0.8)
    two_subsess.plot_psychometric(color='k', alpha=0.8)
    plt.legend(['Laser', 'One after'])

# Combine all sessions
laser_combined_sess = trackball_suite.combine_multiple_sessions(laser_sessions)
nolaser_combined_sess = trackball_suite.combine_multiple_sessions(non_laser_sessions)
plt.figure()
laser_combined_sess.plot_psychometric(color='r')
nolaser_combined_sess.plot_psychometric(color='b')

