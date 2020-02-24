global data
load default_params_training.mat

data.params.reward = 7;
data.params.contrast = 1;
data.params.reward_both = 0;
data.mouse = 'D32';
data.params.training = 0;
data.params.threshold = [5 5];
data.params.trainingSide = [1 1];
data.params.blockSize = 1;
data.params.alternating = 0;
data.params.incorrSound = 1;

data.params.simultaneous = 0;
data.params.perRight = 1;
data.params.switchBlock = 1;
data.params.contrast_follows_loc = 0;
data.params.antibiasConsecutive = 1;
data.params.antibiasRepeat = 0;
data.params.antibiasSwitch = 0;


data.params.responseTime = 10;

% data.params.distance_to_screen_cm = 20;
% data.params.cursor_size_deg = 10;


%% Testing default params
data.params.itiDelay = 0.5;       % duration of pre-trial no-movement interval
data.params.extenddelay = 0;    % extend ITI until mouse stops moving for 1 sec
data.params.itiBlack = 0;       % keep screen black during ITI

data.params.lickInitiate = 0;   % if >0, reward amount for animal to initiates trial with lick
data.params.goDelay = 0;        % delay after initiation before go cue
data.params.early_cue = 0;      % sound --> delay --> mvmt (OVERRIDES go_cue)
data.params.minGoDelay = 0;

data.params.go_cue = 1;         % play go sound? (delay --> sound --> mvmt)
data.params.noMvmtTime = 0;     % time after stimulus onset where movement is not counted (Before go sound)
data.params.earlyAbort = 1;     % abort if move during noMvmtTime
data.params.preCueEarlyAbort = 0;
data.params.responseTime = 20;   % maximum reaction time
data.params.servo = 0;

data.params.rewardDelay = 0;  % time after stimulus offset to drink reward
data.params.punishDelay = 3;    % extra ITI on incorrect/timeout trial1s
data.params.rewardDblBeep = 0;  % double beep?
data.params.punishFree = 0;     % punish when making the "wrong" free choice
data.params.timeout = 1000;
%data.params.incorrSound = 1; % sound cue to indicate incorrect choice
data.params.quitAfterMiss = 1000; % quit after this many es
data.params.rwdDeliveryDelay = 0; %Delay between correct choice and reward delivery

data.params.freeChoice = 0;
     