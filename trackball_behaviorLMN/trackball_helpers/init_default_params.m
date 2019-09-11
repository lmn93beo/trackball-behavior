global data

data.params.touchReward = 1;

data.params.reward = 4;
data.params.rewardProb = 1; % probability of reward
data.params.training = 0; % when 1, only counts movement towards direction specificied by data.params.trainingSide
data.params.simultaneous = 0;
data.params.MissSound = 1;

% number of trials, proportions
data.params.numTrials = 1000;
data.params.freeChoice = 1;     % percentage of free choices

data.params.perRight = 0;     % percentage of right trials (out of all non-freechoice)
data.params.perStimA = 1;     % percentage of stimulus A (out of all non-freechoice)
data.params.nRight = 0; % number of right trials at beginning

data.params.antibiasRepeat = 0; % probability that antibias will repeat after a wrong trial
data.params.antibiasSwitch = 0; % probability that antibias will switch after a correct trial
data.params.antibiasNumCorrect = 1; % number of correct responses before forced switch
data.params.antibiasConsecutive = 0; % # of correct must be consecutive
data.params.antibiasNew = 0;    % overrides other antibias algorithm. Tries to compensate for both raw bias and stay/switch biases

data.params.actionValue = 1;    % reward amt is associated with left/right response (in blocks)
data.params.freeForcedBlocks = 0; % switch between forced and free choice in blocks
data.params.linkStimAction = 0; % constant stimulus value, but link stimulus to left/right response (in blocks)
data.params.blockSize = [30 30]; % min/max block size
data.params.blockSeq = randperm(2); % sequence of blocks
data.params.blockRewards = 1;   % block size measured in # of rewards, rather than # of trials
data.params.firstBlockEqual = 0; % make first block equal rewards, 2nd block antibias
data.params.laser_blank_only = 0;

% movement parameters
data.params.threshold = 30*[1 1]; % in degrees, can have diff thresholds for left/right

% trial timing
data.params.itiDelay = 1;       % duration of pre-trial no-movement interval
data.params.extenddelay = 1;    % extend ITI until mouse stops moving for 1 sec
data.params.itiBlack = 0;       % keep screen black during ITI

data.params.lickInitiate = 0;   % if >0, reward amount for animal to initiates trial with lick
data.params.goDelay = 0;        % delay after initiation before go cue
data.params.early_cue = 0;      % sound --> delay --> mvmt (OVERRIDES go_cue)
data.params.minGoDelay = 0;

data.params.go_cue = 1;         % play go sound? (delay --> sound --> mvmt)
data.params.noMvmtTime = 0;     % time after stimulus onset where movement is not counted (Before go sound)
data.params.earlyAbort = 1;     % abort if move during noMvmtTime
data.params.preCueEarlyAbort = 0;
data.params.responseTime = 3;   % maximum reaction time

data.params.rewardDelay = 2.5;  % time after stimulus offset to drink reward
data.params.punishDelay = 3;    % extra ITI on incorrect/timeout trials
data.params.rewardDblBeep = 0;  % double beep?
data.params.punishFree = 0;     % punish when making the "wrong" free choice
data.params.timeout = 10;
data.params.incorrSound = 1; % sound cue to indicate incorrect choice
data.params.quitAfterMiss = 10; % quit after this many es
data.params.rwdDeliveryDelay = 0; %Delay between correct choice and reward delivery

% stimulus
data.params.stims = {'square', 'diamond'}; % stimuli A and B
data.params.reversalFreq = 0;   % frequency of contrast reversal
data.params.contrast = 1;       % maximum amplitude/contrast
data.params.nHighContrast = 10; % number of high contrast stimuli
data.params.whitediamond = 1;   % make diamond white
data.params.freeBlank = 0;      % free choice is blank
data.params.proOrienting = 0;
data.params.flashStim = 0;      % flash stimulus for this long (if 0, do not flash)
data.params.omitEarlyTone = 0;  % percent of trials on which pre-delay tone should be omitted
data.params.notify = '';        % text message alert?

% laser parameters
data.params.laser = 0;          % laser on
data.params.laser_time = 5;     % duration in s
data.params.laser_amp = 5;      % V
%Blue laser
% 5V = 11.5 mW
% 4V = 9.1 mW
% 3.5V = 5.1 mW
% 3V = 2.7 mW

%Blue laser -- through 200um fiber core
% 5V = 8mW

%Red Laser (635nm) -- through 200um fiber core
% 5V = 24 mW
% 4V = 18 mw

data.params.laser_mode = 'continuous'; % continuous or pulsed or end_ramp (see trackball_ao_putdata)
data.params.laser_start = 0;    % time after trial start;
data.params.perLaser = 0.2;    % percent laser trials
data.params.noLaser = 20;       % number of no laser trials
data.params.laser_blank = 0;    % stimulate on 0 contrast trials?
data.params.earlyCue_sound = 17;




% lever program
data.params.lever = 0;       % 1 == one lever (go/nogo), 2 = two levers
if strcmpi(getenv('computername'),'BEHAVE-BALL1')
    data.params.lev_cal = 0.25; % calibration voltage (for left/right levers)
else
    data.params.lev_cal = 0.40; % calibration voltage (for left/right levers) 
    %new calibration 0.4V for 5mm movement of 14g weight
    %so 3mm means 0.24 or 60% of this value (threshld should be 0.6)
end
data.params.lev_still = 0.1; % must be within this +- voltage to be still
data.params.lev_thresh = 0.5; % threshold difference between levers (percent of calibration value)
data.params.lev_touch = 1;
data.params.lev_pufftime = 0.25;    % airpuff time in sec
if data.params.lever < 2
    data.params.lev_cal = data.params.lev_cal(end);
    data.params.lev_still = data.params.lev_still(end);
    data.params.lev_thresh = data.params.lev_thresh(end);
end
data.params.lev_cont = 1; % 1 = high tone reward; 2 = low tone reward
data.params.lev_chirp = 0;