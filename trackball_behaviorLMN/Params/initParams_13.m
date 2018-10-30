global data

data.params.reward = [8];

% Eliminate all delays
data.params.responseTime = 0;   
data.params.itiDelay = 0;       % duration of pre-trial no-movement interval
data.params.rewardDelay = 0;
data.params.goDelay = 0;
data.params.punishDelay = 0;
data.params.minGoDelay = 0;
data.params.extenddelay = 0;    % extend ITI until mouse stops moving for 1 sec
data.params.minGoDelay = 0;

% Other params for trials tructure
data.params.freeChoice = 1;     % bonus if move after touch!
data.params.MissSound = 0; %no sound
data.params.incorrSound = 0; %no sound

% Do not end early
data.params.timeout = 1000;

% No stimulus shown
data.params.simultaneous = 0;
data.params.contrast = 0;
