global data

data.params.reward = [4];
data.params.rewardProb = [1];
data.params.freeChoice = 0;     % percentage of free choices
data.params.perRight = 0.5;       % percentage of right trials (out of all non-freechoice)

data.params.antibiasRepeat = 0; % probability that antibias will repeat after a wrong trial
data.params.antibiasSwitch = 0; % probability that antibias will switch after a correct trial
data.params.antibiasNumCorrect = [1 1]; % number of correct responses before forced switch
data.params.antibiasConsecutive =  0; % must be consecutive

data.params.responseTime = 10;   % maximum reaction time
data.params.punishDelay = 0;

data.params.freeBlank = 0;
data.params.threshold = [5 5]; %in degrees, can have diff thresholds for left/right
data.params.training = 0;
data.params.trainingSide = [1 1]; % Set to [0 0] if training is on (1)
data.params.reversalFreq = 0;

data.params.proOrienting = 0;
data.params.flashStim = 2.0;
data.params.earlyCue_sound = 30;      
data.params.early_cue = 1;      % sound --> delay --> mvmt (OVERRIDES go_cue)
data.params.minGoDelay = 0;

data.params.go_cue = 1;         % play go sound? (delay --> sound --> mvmt)
data.params.noMvmtTime = 0;     % time after stimulus onset where movement is not counted (Before go sound)
data.params.earlyAbort = 0;

data.params.goDelay = 1;

data.params.simultaneous = 0;
data.params.contrast = 1;
data.params.opp_contrast = 1;

    % Laser

data.params.laser = 0;          % laser on
data.params.laser_blank_only = 0; 
data.params.laser_time = 1.3;   % duration in s
data.params.laser_mode = 'continuous';
data.params.laser_freq = 20; % frequency
data.params.laser_pw = 20; % pulse width

data.params.laser_start = -0.3 ; % time after trial start
data.params.perLaser = 0.30;    % percent laser trials
data.params.noLaser = 5;        % number of no-laser trials at beginning