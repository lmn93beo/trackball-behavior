import numpy as np
import matplotlib.pyplot as plt
import scipy.io as sp
from sklearn.linear_model import LogisticRegression
import utils
import copy
from sklearn.datasets import load_iris

def get_choice_stim(path):
    """Given the path to the .mat behavior file,
    return the choice array and the stimulus type array"""
    data = sp.loadmat(path)
    choice = data['data']['response'][0,0]['choice'][0,0][0]
    ntrials = len(choice)
    stim = data['data']['stimuli'][0,0]['loc'][0,0][0][:ntrials]
    return choice, stim


def get_struct_field(data, field, subfield=None):
    if subfield == None:
        return data['data'][field][0,0]
    else:
        return data['data'][field][0,0][subfield][0,0][0]
def get_performance(data):
    """Given the data structure, return the performance in the form:
    An N x 3 array where the columns correspond to
    contrast, performance left, performance right,
    and each column is one contrast"""
    # Load necessary arrays
    choice = data['data']['response'][0,0]['choice'][0,0][0]
    ntrials = len(choice)
    stim = data['data']['stimuli'][0,0]['loc'][0,0][0][:ntrials]
    cons = data['data']['stimuli'][0,0]['opp_contrast'][0,0][0][:ntrials]

    # Process
    curr_con = np.unique(cons)
    output = np.zeros((len(curr_con), 3))
    for i in range(len(curr_con)):
        if np.sum((stim == 2) & (cons == curr_con[i])) == np.sum((stim == 2) & (cons == curr_con[i]) & (choice == 5)):
            perf_l = np.nan
        else:
            perf_l = float(np.sum((stim == 2) & (choice == 2) & (cons == curr_con[i]))) / \
                (np.sum((stim == 2) & (cons == curr_con[i])) - np.sum((stim == 2) & (cons == curr_con[i]) & (choice == 5)))
        #print np.sum((stim == 2) & (choice == 2) & (cons == curr_con[i]))
        if np.sum((stim == 1) & (cons == curr_con[i])) == np.sum((stim == 1) & (cons == curr_con[i]) & (choice == 5)):
            perf_r = np.nan
        else:
            perf_r = float(np.sum((stim == 1) & (choice == 1) & (cons == curr_con[i]))) / \
                (np.sum((stim == 1) & (cons == curr_con[i])) - np.sum((stim == 1) & (cons == curr_con[i]) & (choice == 5)))

        output[i,0] = curr_con[i]
        output[i,1] = perf_l
        output[i,2] = perf_r
    return output

def plot_psychometric(data, color='b', alpha=0.5):
    """Given the data structure, plot the psychometric curve"""
    performance = get_performance(data)
    contrast = get_struct_field(data, 'params', 'contrast')
    condiff = performance[:,0] - contrast
    xaxis = np.hstack([condiff, -np.flip(condiff, axis=0)])
    yaxis = np.hstack([1 - performance[:,2], np.flip(performance[:,1], axis=0)])
    #print(xaxis)
    plt.plot(xaxis, yaxis, color, alpha=alpha)
    plt.xlabel('Contrast difference')
    plt.ylabel('% Left')
    plt.ylim([0, 1])

def get_struct_field(data, field, subfield=None):
    if subfield == None:
        return data['data'][field][0,0]
    else:
        return data['data'][field][0,0][subfield][0,0][0]



class Session(object):
    """A class for a general collection of trials, note that trial order might not be respected"""
    def __init__(self, filename=None, trial_list=None):
        if filename is not None:
            self.filename = filename
            self.data = sp.loadmat(filename)
            self.mouse = get_struct_field(self.data, 'mouse')[0, 0]
            try:
                self.choice = get_struct_field(self.data, 'response', 'choice').astype('int')
            except ValueError:
                print('Warning: no choice field')
                self.choice = None
                raise utils.NoChoiceError('No choice field')


            if trial_list is None:
                trial_list = np.arange(len(self.choice))
                self.ordered = 1  # whether trial order is respected
            else:
                self.ordered = 0
            self.choice = self.choice[trial_list]
            self.ntrials = len(self.choice)
            self.stim = get_struct_field(self.data, 'stimuli', 'loc')[trial_list].astype('int')
            self.simultaneous = self.data['data']['params'][0,0]['simultaneous'][0,0][0,0]
            self.contrast = get_struct_field(self.data, 'params', 'contrast')

            if self.simultaneous:
                self.cons = get_struct_field(self.data, 'stimuli', 'opp_contrast')[trial_list]
            else:
                print('Warning: no opp contrast')
                self.cons = None
                self.contrast = None
                raise utils.NoConsError

            try:
                self.laser = get_struct_field(self.data, 'stimuli', 'laser')[trial_list] - 1
            except ValueError:
                self.laser = None
                print('Warning: no laser')
                #raise utils.NoLaserError('No laser for this session')

    def copy(self):
        """Copy to a new object. Return the copied object"""
        return copy.deepcopy(self)

    def get_choice(self):
        """Returns an array of choice"""
        return self.choice

    def get_stim(self):
        """Returns an array of stimulus location"""
        return self.stim

    def get_opp_contrast(self):
        """Returns an array of opposite contrast"""
        return self.cons

    def get_laser(self):
        """Returns an array of laser on/off condition"""
        return self.laser

    def print_summary(self):
        print(self.filename)
        # Repeated actions
        rewarded = np.where(self.choice == self.stim)[0]
        errors = np.where((self.choice != self.stim) & (self.choice != 5))[0]
        if rewarded[-1] == len(self.choice) - 1:
            rewarded_p1 = rewarded[:-1] + 1
            rewarded = rewarded[:-1]
        else:
            rewarded_p1 = rewarded + 1

        if errors[-1] == len(self.choice) - 1:
            errors_p1 = errors[:-1] + 1
            errors = errors[:-1]
        else:
            errors_p1 = errors + 1


        choice_t1 = self.choice[rewarded_p1]
        choice_t = self.choice[rewarded][choice_t1 != 5]
        stim_t1 = self.stim[rewarded_p1][choice_t1 != 5]
        choice_t1 = choice_t1[choice_t1 != 5]
        assert(len(choice_t) == len(stim_t1) and len(choice_t) == len(choice_t1))

        choice_error_t1 = self.choice[errors_p1]
        choice_error_t = self.choice[errors][choice_error_t1 != 5]
        stim_err_t1 = self.stim[errors_p1][choice_error_t1 != 5]
        choice_error_t1 = choice_error_t1[choice_error_t1 != 5]
        assert(len(choice_error_t1) == len(choice_error_t) and len(choice_error_t1) == len(stim_err_t1))

        frac_rep = np.sum(choice_t == choice_t1) / len(choice_t)
        frac_rep_err = np.sum(choice_error_t == choice_error_t1) / len(choice_error_t)
        frac_corr = np.sum(choice_t1 == stim_t1) / len(choice_t)
        frac_corr_err = np.sum(choice_error_t1 == stim_err_t1) / len(choice_error_t1)
        print('    - Repeated fraction after correct: %.2f' % frac_rep)
        print('    - Repeated fraction after error: %.2f' % frac_corr_err)

        return frac_rep, frac_rep_err, frac_corr, frac_corr_err


    def get_performance(self):
        """Given the data structure, return the performance in the form:
        An N x 3 array where the columns correspond to
        contrast, performance left, performance right,
        and each column is one contrast"""
        # Load necessary arrays
        choice = self.get_choice()
        stim = self.get_stim()
        cons = self.get_opp_contrast()

        # Process
        curr_con = np.unique(cons)
        output = np.zeros((len(curr_con), 3))
        for i in range(len(curr_con)):
            if np.sum((stim == 2) & (cons == curr_con[i])) == np.sum((stim == 2) & (cons == curr_con[i]) & (choice == 5)):
                perf_l = np.nan
            else:
                perf_l = float(np.sum((stim == 2) & (choice == 2) & (cons == curr_con[i]))) / \
                    (np.sum((stim == 2) & (cons == curr_con[i])) - np.sum((stim == 2) & (cons == curr_con[i]) & (choice == 5)))
            #print np.sum((stim == 2) & (choice == 2) & (cons == curr_con[i]))
            if np.sum((stim == 1) & (cons == curr_con[i])) == np.sum((stim == 1) & (cons == curr_con[i]) & (choice == 5)):
                perf_r = np.nan
            else:
                perf_r = float(np.sum((stim == 1) & (choice == 1) & (cons == curr_con[i]))) / \
                    (np.sum((stim == 1) & (cons == curr_con[i])) - np.sum((stim == 1) & (cons == curr_con[i]) & (choice == 5)))

            output[i,0] = curr_con[i]
            output[i,1] = perf_l
            output[i,2] = perf_r
        return output

    def plot_raw_performance(self):
        """Plot a visualization of raw performance"""
        choice = self.get_choice()
        ntrials = self.ntrials
        stim = self.get_stim()
        trialstart = get_struct_field(self.data, 'response', 'trialstart') / 60

        # Plot the time-outs
        timeouts = np.where(choice == 5)
        plt.figure(figsize=(20, 10))
        plt.plot(np.arange(self.ntrials)[timeouts], stim[timeouts], 'ko')

        # Plot correct/incorrect trials
        corr = np.where((choice != 5) & (stim == choice))[0]
        incorr = np.where((choice != 5) & (stim != choice))[0]
        plt.plot(np.arange(self.ntrials)[corr], stim[corr], 'bo')
        plt.plot(np.arange(self.ntrials)[incorr], stim[incorr], 'ro')

        plt.xlabel('Time (min)')
        plt.yticks([1, 2], ['Left', 'Right'])

    def plot_cumulative_bias(self, n):
        """Cumulative bias of last n trials"""
        choice = self.get_choice()
        ntrials = self.ntrials
        stim = self.get_stim()
        trialstart = get_struct_field(self.data, 'response', 'trialstart') / 60

        # Plot the time-outs
        timeouts = np.where(choice == 5)
        plt.figure(figsize=(20, 10))
        plt.plot(np.arange(self.ntrials)[timeouts], stim[timeouts], 'ko')

        # Plot correct/incorrect trials
        corr = (choice != 5) & (stim == choice)
        incorr = (choice != 5) & (stim != choice)
        ncorr_cum = np.convolve(corr, np.ones(n), mode='valid')
        nincorr_cum = np.convolve(incorr, np.ones(n), mode='valid')

        perf_cum = ncorr_cum / (ncorr_cum + nincorr_cum)
        plt.plot(perf_cum)

        return perf_cum


    def plot_psychometric(self, color='b', alpha=0.5):
        """Given the data structure, plot the psychometric curve"""
        performance = self.get_performance()
        contrast = self.contrast
        condiff = performance[:,0] - contrast
        xaxis = np.hstack([condiff, -np.flip(condiff, axis=0)])
        yaxis = np.hstack([1 - performance[:,2], np.flip(performance[:,1], axis=0)])
        #print(xaxis)
        plt.plot(xaxis, yaxis, color=color, alpha=alpha)
        plt.xlabel('Contrast difference')
        plt.ylabel('% Left')
        plt.ylim([0, 1])

    def find_logistic_coef(self):
        """Returns the logistic regression of the session"""
        choice = self.get_choice() - 1
        stim = self.get_stim() - 1

        # Make a design matrix
        currchoice = choice[1:]
        currstim = stim[1:]
        prevchoice = choice[:-1]
        prevstim = stim[:-1]
        prev_reward = prevchoice == prevstim

        y_b = currchoice[(currchoice != 4) & (prevchoice != 4)]
        y_b = y_b * 2 - 1
        print(y_b)

        X = np.vstack([currstim * 2 - 1]).T
        X_b = X[(currchoice != 4) & (prevchoice != 4),:]
        #print(X_b)

        if len(np.unique(y_b)) < 2:
            raise ValueError('Only one value in y')
        # Do logistic regression
        clf = LogisticRegression(C=1e10).fit(X_b, y_b)

        # Print the coefficients
        return np.hstack([clf.intercept_, clf.coef_.flatten()])

    def make_subsession(self, trial_lst):
        """
        For making a subsession, given the list of trials
        :param trial_lst: a list of trials
        :return: a Supersession object corresponding to the indicated trials
        """
        if self.filename is not None:
            subsession = Session(self.filename, trial_lst)
        else:
            subsession = self.copy()
            subsession.ntrials = len(trial_lst)
            subsession.choice = self.choice[trial_lst]
            subsession.stim = self.stim[trial_lst]
            subsession.cons = self.cons[trial_lst]
            subsession.laser = self.laser[trial_lst]
        return subsession




class SessionGroup(object):
    """A class for groups of sessions"""
    def __init__(self, sess_lst):
        """Initialize a group of sessions"""
        self.sess_lst = sess_lst
        self.nsess = len(sess_lst)

    def as_session(self):
        """
        Make into a Session object
        :return:
        """
        return combine_multiple_sessions(self.sess_lst)

    def plot_agg_performance(self):
        plt.figure()
        combined = combine_multiple_sessions(self.sess_lst)
        combined.plot_psychometric()

    def plot_individual_psychometric(self):
        nx = np.ceil(np.sqrt(self.nsess))
        ny = np.ceil(self.nsess / nx)
        for i in range(self.nsess):
            plt.subplot(nx, ny, i + 1)
            self.sess_lst[i].plot_psychometric()

    def plot_individual_raw_performance(self):
        T0 = 0
        plt.figure(figsize=(20, 10))
        for sess in self.sess_lst:
            choice = sess.get_choice()
            stim = sess.get_stim()
            trialstart = get_struct_field(sess.data, 'response', 'trialstart') / 60
            trialstart += T0
            T0 = trialstart[-1]
            assert(len(trialstart) == len(choice))

            # Plot the time-outs
            timeouts = np.where(choice == 5)
            plt.plot(trialstart[timeouts], stim[timeouts], 'ko')

            # Plot correct/incorrect trials
            corr = np.where((choice != 5) & (stim == choice))[0]
            incorr = np.where((choice != 5) & (stim != choice))[0]
            plt.plot(trialstart[corr], stim[corr], 'bo')
            plt.plot(trialstart[incorr], stim[incorr], 'ro')

            plt.xlabel('Time (min)')
            plt.yticks([1, 2], ['Left', 'Right'])
            plt.vlines(T0, -1, 3)


def concat_safe(arr1, arr2):
    """
    Concatenate, but handle cases of None
    :param arr1:
    :param arr2:
    :return:
    """
    if arr1 is not None and arr2 is not None:
        combined = np.concatenate((arr1, arr2))
    else:
        print('Warning: during combine sessions, encountered none in choice')
        if arr1 is None:
            combined = arr2
        else:
            combined = arr1
    return combined

# For combining sessions
def combine_sessions(sess1, sess2):
    """
    Combine two sessions
    :param sess1: a Session instance
    :param sess2: a Session instance
    :return: a Session object
    """
    sess1copy = sess1.copy()
    sess1copy.ntrials = sess1.ntrials + sess2.ntrials

    sess1copy.choice = concat_safe(sess1.choice, sess2.choice)
    sess1copy.stim = concat_safe(sess1.stim, sess2.stim)
    sess1copy.cons = concat_safe(sess1.cons, sess2.cons)
    sess1copy.laser = concat_safe(sess1.laser, sess2.laser)
    sess1copy.ordered = 0
    sess1copy.filename = None
    return sess1copy

def combine_multiple_sessions(session_list):
    """
    for combining multiple sessions given by a list
    :param session_list: a list of Session instances
    :return: a Session object
    """
    if len(session_list) == 1:
        return session_list[0]
    else:
        sess1copy = session_list[0].copy()
        ntrials = sess1copy.ntrials
        for id, session in enumerate(session_list[1:]):
            ntrials += session.ntrials
            sess1copy = combine_sessions(sess1copy, session)
    assert len(sess1copy.choice) == ntrials
    assert len(sess1copy.stim) == ntrials
    assert len(sess1copy.cons) == ntrials
    #assert len(sess1copy.laser) == ntrials
    return sess1copy




