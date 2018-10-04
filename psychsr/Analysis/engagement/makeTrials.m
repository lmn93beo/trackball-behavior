function makeTrials(file, nstims)
version = 1.0;

% split behavioral data into N trials
% Go/nogo discrimination

%% analysis parameters
ili = 0.3;                  % inter-lick interval
skip = 1;                   % skip first X stimuli

%% input parameters
% choose file
if nargin < 2
    [file, dir] = uigetfile('../behaviorData/');
    file = [dir file];    
end

% number of stimuli displayed per trial
if nargin < 1
    nstims = 3;   % default is 3: delay, response, iti
end

%% load file
load(file);
ntrials = floor((data.stimuli.num_stimuli-skip)/nstims);

all_licks = data.response.licks;
all_lickonsets = all_licks([true; diff(all_licks)>ili]);


%% vector parameters
%%%% Time parameters relative to session start %%%%
start_time = zeros(ntrials,1);  % start time of each trial relative to session start

%%%% Time parameters relative to trial start %%%%
stims = zeros(ntrials,nstims);  % end time of each stimulus
licks = cell(ntrials,1);        % lick times during trial
lickonsets = cell(ntrials,1);   % lickonsets during trial
rewards = cell(ntrials,1);      % reward times during trial
punishs = cell(ntrials,1);      % punish times during trial

%%%% Discrimination parameters %%%%
target = zeros(ntrials,1);      % was this a target trial?
rewarded = NaN*ones(ntrials,1); % 1/0 for target trials, NaN for nontarget
punished = NaN*ones(ntrials,1); % 1/0 for nontarget trials, NaN for target

%% make trials
for i = 1:ntrials    
    % start time
    if i == 1 && skip == 0; start_time(i) = 0;
    else start_time(i) = data.presentation.stim_times(skip+(i-1)*nstims); end
    
    % time parameters -- relative to session start
    stims(i,:) = data.presentation.stim_times(skip+(i-1)*nstims+1:skip+i*nstims);
    licks{i} = all_licks(all_licks>start_time(i) & all_licks<=stims(i,end));
    lickonsets{i} = all_lickonsets(all_lickonsets>start_time(i) & all_lickonsets<=stims(i,end));
    
    
end





