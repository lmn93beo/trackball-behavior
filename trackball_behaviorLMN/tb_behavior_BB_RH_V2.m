
% clear variables
psychsr_go_root();
close all; clearvars; clearvars -global data; clc
global data

data.mouse = input('Mouse #: ');

%% default params

data.params.reward = 8;
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
if rand < 0.5
    data.params.blockSeq = [1 2 1 2 1 2];
else
    data.params.blockSeq = [2 1 2 1 2 1];
end
data.params.blockRewards = 1;   % block size measured in # of rewards, rather than # of trials
data.params.firstBlockEqual = 0; % make first block equal rewards, 2nd block antibias
data.params.laser_blank_only = 0;

% movement parameters
data.params.threshold = 30*[1 1]; % in degrees, can have diff thresholds for left/right
data.params.extend_delay_thresh = 5;
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
data.params.quitAfterMiss = 10; % quit after this many misses
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

mvmt_test = true;


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
data.params.numMissAutoRwd = 0;

%% mouse specific parameters

switch data.mouse
    
         
    case 10078
%         mvmt_test = false;
        data.params.quitAfterMiss = 300; % quit after this many misses
        data.params.timeout = 300;
        data.params.numMissAutoRwd = 100;
        data.params.extend_delay_thresh = 5;
        
        data.params.numTrials = 600;
        data.params.freeChoice = 0;     % percentage of free choices
        data.params.perRight = 0.5;       % percentage of right trials (out of all non-freechoice)
        
        data.params.threshold = [15 15]; % in degrees, can have diff thresholds for left/right
        data.params.responseTime = 5;   % maximum reaction time
        data.params.punishDelay = 0;    % extra ITI on incorrect/timeout trials
        data.params.extenddelay = 1;
        
        data.params.noMvmtTime = 0;
        data.params.earlyAbort = 0;
        data.params.rewardDelay = 1;
        
        data.params.antibiasRepeat = 0.5;
        data.params.antibiasSwitch = 1;
        data.params.antibiasNumCorrect = [1 1];
        data.params.antibiasConsecutive =  1;
        
        data.params.itiBlack = 0;
        data.params.itiDelay = 3;
        
        % sensory task
        
        data.params.goDelay = 0; %[mean of exponential distribution, cutoff time];
        data.params.early_cue = 0; % cue --> delay --> stim (otherwise delay-->cue-->stim)
        
        data.params.training = 0;
        data.params.trainingSide = [0 0];
        
        % action value parameters
        data.params.reward = [50 50];
        data.params.rewardProb = [1 1];
        data.params.actionValue = 1;
        %         data.params.blockSeq = [1 2 1 2 1 2];
        data.params.blockSize = [7 10];
        %         data.params.blockSize = [3 3];%[10 20]; % min/max block size
        %         if rand > 0.5
        %             data.params.blockSeq = [3 1 3 2]; % sequence of blocks  ;[3 1 3 2]
        %         else
        %             data.params.blockSeq = [3 2 3 1]; % sequence of blocks  [3 2 1 2 3 1 2 1]
        %         end
        
        data.params.firstBlockEqual = 0; % make first block equal rewards, 2nd block antibias
        data.params.freeForcedBlocks = 1; % switch between forced and free choice in blocks
        data.params.blockRewards = 1
        
        % %         action value parameters
        %                 data.params.reward = [0 12];
        %                 data.params.rewardProb = [0 1];
        %                 data.params.blockSize = [10 20];%[10 20]; % min/max block size
        %                 if rand > 0.5
        %                     data.params.blockSeq = [3 2 1 2 1]; % sequence of blocks  ;[3 1 3 2]
        %                 else
        %                     data.params.blockSeq = [3 1 2 1 2]; % sequence of blocks  [3 2 1 2 3 1 2 1]
        %                 end
        %
        %         data.params.firstBlockEqual = 0; % make first block equal rewards, 2nd block antibias
        %         data.params.freeForcedBlocks = 0; % switch between forced and free choice in blocks
        
        % laser parameters
        data.params.laser = 0;             % laser on
        data.params.laser_time = 0.2;     % duration in s
        data.params.laser_start = -0.3;    % time after trial start
        data.params.perLaser = 0.30;    % percent laser trials
        data.params.noLaser = 0;        % number of no-laser trials at beginning
        
        
       
        
    case 10079
%         mvmt_test = false;
        data.params.quitAfterMiss = 300; % quit after this many misses
        data.params.timeout = 300;
        data.params.numMissAutoRwd = 100;
        data.params.extend_delay_thresh = 5;
        
        data.params.numTrials = 600;
        data.params.freeChoice = 0;     % percentage of free choices
        data.params.perRight = 0.5;       % percentage of right trials (out of all non-freechoice)
        
        data.params.threshold = [15 15]; % in degrees, can have diff thresholds for left/right
        data.params.responseTime = 3;   % maximum reaction time
        data.params.punishDelay = 0;    % extra ITI on incorrect/timeout trials
        data.params.extenddelay = 1;
        
        data.params.noMvmtTime = 0;
        data.params.earlyAbort = 0;
        data.params.rewardDelay = 1;
        
        data.params.antibiasRepeat = 0.5;
        data.params.antibiasSwitch = 1;
        data.params.antibiasNumCorrect = [1 1];
        data.params.antibiasConsecutive =  1;
        
        data.params.itiBlack = 0;
        data.params.itiDelay = 3;
        
        % sensory task
        
        data.params.goDelay = 0; %[mean of exponential distribution, cutoff time];
        data.params.early_cue = 0; % cue --> delay --> stim (otherwise delay-->cue-->stim)
        
        data.params.training = 0;
        data.params.trainingSide = [0 0];
        
        % action value parameters
        data.params.reward = [0 8];
        data.params.rewardProb = [0 0.8];
        data.params.actionValue = 1;
        %         data.params.blockSeq = [1 2 1 2 1 2];
        data.params.blockSize = [7 10];
        %         data.params.blockSize = [3 3];%[10 20]; % min/max block size
        %         if rand > 0.5
        %             data.params.blockSeq = [3 1 3 2]; % sequence of blocks  ;[3 1 3 2]
        %         else
        %             data.params.blockSeq = [3 2 3 1]; % sequence of blocks  [3 2 1 2 3 1 2 1]
        %         end
        
        data.params.firstBlockEqual = 0; % make first block equal rewards, 2nd block antibias
        data.params.freeForcedBlocks = 1; % switch between forced and free choice in blocks
        data.params.blockRewards = 1
        
        % %         action value parameters
        %                 data.params.reward = [0 12];
        %                 data.params.rewardProb = [0 1];
        %                 data.params.blockSize = [10 20];%[10 20]; % min/max block size
        %                 if rand > 0.5
        %                     data.params.blockSeq = [3 2 1 2 1]; % sequence of blocks  ;[3 1 3 2]
        %                 else
        %                     data.params.blockSeq = [3 1 2 1 2]; % sequence of blocks  [3 2 1 2 3 1 2 1]
        %                 end
        %
        %         data.params.firstBlockEqual = 0; % make first block equal rewards, 2nd block antibias
        %         data.params.freeForcedBlocks = 0; % switch between forced and free choice in blocks
        
        % laser parameters
        data.params.laser = 0;             % laser on
        data.params.laser_time = 0.2;     % duration in s
        data.params.laser_start = -0.3;    % time after trial start
        data.params.perLaser = 0.30;    % percent laser trials
        data.params.noLaser = 0;        % number of no-laser trials at beginning
        
        
        

    case 10076
%         mvmt_test = false;
        data.params.quitAfterMiss = 300; % quit after this many misses
        data.params.timeout = 300;
        data.params.numMissAutoRwd = 100;
        data.params.extend_delay_thresh = 5;
        
        data.params.numTrials = 600;
        data.params.freeChoice = 0;     % percentage of free choices
        data.params.perRight = 0.5;       % percentage of right trials (out of all non-freechoice)
        
        data.params.threshold = [13 15]; % in degrees, can have diff thresholds for left/right
        data.params.responseTime = 5;   % maximum reaction time
        data.params.punishDelay = 0;    % extra ITI on incorrect/timeout trials
        data.params.extenddelay = 1;
        
        data.params.noMvmtTime = 0;
        data.params.earlyAbort = 0;
        data.params.rewardDelay = 1;
        
        data.params.antibiasRepeat = 0.5;
        data.params.antibiasSwitch = 1;
        data.params.antibiasNumCorrect = [1 1];
        data.params.antibiasConsecutive =  1;
        
        data.params.itiBlack = 0;
        data.params.itiDelay = 3;
        
        % sensory task
        
        data.params.goDelay = 0; %[mean of exponential distribution, cutoff time];
        data.params.early_cue = 0; % cue --> delay --> stim (otherwise delay-->cue-->stim)
        
        data.params.training = 0;
        data.params.trainingSide = [0 0];
        
        % action value parameters
        data.params.reward = [0 10];
        data.params.rewardProb = [0 1];
        data.params.actionValue = 1;
        %         data.params.blockSeq = [1 2 1 2 1 2];
        data.params.blockSize = [7 10];
        %         data.params.blockSize = [3 3];%[10 20]; % min/max block size
        %         if rand > 0.5
        %             data.params.blockSeq = [3 1 3 2]; % sequence of blocks  ;[3 1 3 2]
        %         else
        %             data.params.blockSeq = [3 2 3 1]; % sequence of blocks  [3 2 1 2 3 1 2 1]
        %         end
        
        data.params.firstBlockEqual = 0; % make first block equal rewards, 2nd block antibias
        data.params.freeForcedBlocks = 1; % switch between forced and free choice in blocks
        data.params.blockRewards = 1
        
        % %         action value parameters
        %                 data.params.reward = [0 12];
        %                 data.params.rewardProb = [0 1];
        %                 data.params.blockSize = [10 20];%[10 20]; % min/max block size
        %                 if rand > 0.5
        %                     data.params.blockSeq = [3 2 1 2 1]; % sequence of blocks  ;[3 1 3 2]
        %                 else
        %                     data.params.blockSeq = [3 1 2 1 2]; % sequence of blocks  [3 2 1 2 3 1 2 1]
        %                 end
        %
        %         data.params.firstBlockEqual = 0; % make first block equal rewards, 2nd block antibias
        %         data.params.freeForcedBlocks = 0; % switch between forced and free choice in blocks
        
        % laser parameters
        data.params.laser = 0;             % laser on
        data.params.laser_time = 0.2;     % duration in s
        data.params.laser_start = -0.3;    % time after trial start
        data.params.perLaser = 0.30;    % percent laser trials
        data.params.noLaser = 0;        % number of no-laser trials at beginning
        
        
      
        
    case 004
        data.params.numTrials = 1000;
        data.params.reward = [3];
        data.params.rewardProb = [1];
        data.params.freeChoice = 0;     % percentage of free choices
        data.params.perRight = 0.5;       % percentage of right trials (out of all non-freechoice)
        
        data.params.antibiasRepeat = 0; % probability that antibias will repeat after a wrong trial
        data.params.antibiasSwitch = 0; % probability that antibias will switch after a correct trial
        
        data.params.antibiasNumCorrect = [1 1]; % number of correct responses before forced switch
        data.params.antibiasConsecutive = 0; % must be consecutive
        
        data.params.threshold = [12 12]; % in degrees, can have diff thresholds for left/right
        data.params.responseTime = 3;   % maximum reaction time
        data.params.punishDelay = 0;    % extra ITI on incorrect/timeout trials
        data.params.rewardDelay = 2;
        data.params.extenddelay = 1;
        %         data.params.blockSize = 10;%[10 20]; % min/max block size
        %         data.params.blockSeq = [1 2]; % sequence of blocks
        data.params.flashStim = 0;   % flash stimulus for this long (if 0, do not flash)
        data.params.freeBlank = 0;      % free choice is blank
        data.params.reversalFreq = 0;   % frequency of contrast reversal
        %         data.params.lickInitiate = 0.5;   % animal initiates trial with lick
        data.params.goDelay = [1.8 4]; %[mean of exponential distribution, cutoff time];
        data.params.itiBlack = 0;%1;
        data.params.itiDelay = 1;
        
        data.params.noMvmtTime = 0;
        data.params.earlyAbort = 0;
        %         data.params.firstBlockEqual = 1; % make first block equal rewards, 2nd block antibias
        
        data.params.contrast = [4 4 8 8 16 16 32 32 64]/100; % hard variable contrast
        data.params.flashStim = [0.04];   % flash stimulus for this long (if 0, do not flash)
        data.params.goDelay = [0.5 2]; %[0.5 2];
        data.params.early_cue = 1; % cue --> delay --> stim (otherwise delay-->cue-->stim)
        
        %         data.params.contrast = [0 16 16 32 32 64 64 64]/100; % easy variable contrast
        
        
        %         % action value
        %         data.params.reward = [0 3];
        %         data.params.rewardProb = [0 0.8];
        %         data.params.blockSize = [12 15];%[10 20]; % min/max block size
        %         if rand > 0.5
        %             data.params.blockSeq = [3 1 3 2]; % sequence of blocks  [3 1 2 1 3 2 1 2];
        %         else
        %             data.params.blockSeq = [3 2 3 1] ; % sequence of blocks [3 2 1 2 3 1 2 1]
        %         end
        
        data.params.firstBlockEqual = 0; % make first block equal rewards, 2nd block antibias
        data.params.freeForcedBlocks = 0; % switch between forced and free choice in blocks
        
        
        % laser parameters
        data.params.laser = 0;          % laser on
        data.params.laser_time = 0.2;     % duration in s
        data.params.laser_start = -0.3;    % time after trial start
        data.params.perLaser = 0.3;    % percent laser trials
        data.params.noLaser = 0;        % number of no-laser trials at beginning
        
        
        
        %         % action value
        %         data.params.reward = [1.5 4.5]; % first block left=reward(1)
        %         data.params.rewardProb = [1 1];
        %         data.params.freeChoice = 0.2;     % percentage of free choices
        %         data.params.perRight = 0.5;     % percentage of right trials (out of all non-freechoice)
        %
        %         data.params.antibiasRepeat = 0.6; % probability that antibias will repeat after a wrong trial
        %
        %         data.params.flashStim = 1;   % flash stimulus for this long (if 0, do not flash)
        %
        %         data.params.actionValue = 1;    % reward amt is associated with left/right response (in blocks)
        %         data.params.blockSize = [40 50]; % min/max block size
end

%% Setup
for i = 1:length(data.params.reward)
    [data.response.reward_amt(i),data.response.reward_time(i),...
        data.response.reward_cal] = psychsr_set_reward(data.params.reward(i));
end
if data.params.lickInitiate>0
    [~,data.response.init_time] = psychsr_set_reward(data.params.lickInitiate);
end

if data.params.laser > 0 && data.params.perLaser > 0
    n = round(1/data.params.perLaser);
    data.stimuli.laser = ones(1,data.params.numTrials);
    i = data.params.noLaser+1;
    while i < data.params.numTrials
        data.stimuli.laser(i) = 2;
        i = i+randi(3)+n-2;
    end
    
    w = [];
    while isempty(w) || isnan(w) || ~isnumeric(w)
        try w = input('Laser control voltage?: ');
        catch
            w = [];
        end
    end
    data.params.laser_amp = w;
    data.params.laser_power = input('Laser power (mW)?: ','s');    % photometer
    data.params.laser_target = input('Laser target(s)?: ','s');
    
end

trackball_screen_setup;
trackball_card_setup;       % setup daq, serial port and notification
trackball_sound_setup;
trackball_stimuli_setup;
screen = data.screen; struct_unzip(screen);

if data.params.lever>0
    baselineFlag = 0;
    disp('begin baseline measurement (1s)...')
    while baselineFlag >= 0
        start(data.card.ai);
        nsampled = 0;
        baseline_data = [];
        while nsampled < data.card.ai_fs*1
            if data.card.ai.SamplesAcquired > nsampled
                newdata = peekdata(data.card.ai,data.card.ai.SamplesAcquired-nsampled);
                nsampled = nsampled + size(newdata,1);
                if data.params.lever == 1; chans = 2; else chans = [2 3]; end;
                baseline_data = cat(1,baseline_data,newdata(:,chans));
            end
        end
        stop(data.card.ai)
        if max(std(baseline_data))<0.01
            data.params.lev_baseline = median(baseline_data);
            baselineFlag = -1;
            fprintf('measured baseline:')
            fprintf(' %1.3f',data.params.lev_baseline); fprintf('\n')
        else
            baselineFlag = baselineFlag+1;
            fprintf('retry %d\n',baselineFlag)
        end
    end
    disp('Press any key to continue')
    pause
end

%--RH -- 09/25/2016
% rmpath C:\Dropbox\MouseAttention\Matlab\gerald\helpers\mvgc_v1.0\utils\legacy\randi


%% randomize trials
maxrepeat = floor(log(0.125)/log(abs(data.params.perRight-0.5)+0.5)); if maxrepeat<0; maxrepeat = Inf; end;
data.stimuli.loc = psychsr_rand(1-data.params.perRight,data.params.numTrials,0,maxrepeat);
data.stimuli.loc(1:data.params.nRight) = 2;
if data.params.omitEarlyTone > 0 % -- RH
    data.response.playEarlyCue = psychsr_rand(1-data.params.omitEarlyTone,data.params.numTrials,0,maxrepeat);
elseif data.params.omitEarlyTone == 1
    data.response.playEarlyCue = zeros(1,data.params.numTrials);
else
    data.response.playEarlyCue = ones(1,data.params.numTrials);
end

if data.params.simultaneous
    opp_cons = data.params.opp_contrast;
    data.stimuli.opp_contrast = data.params.opp_contrast(randi(length(data.params.opp_contrast),1,data.params.numTrials));
end

if ~(data.params.actionValue && data.params.freeForcedBlocks)
    maxrepeat = floor(log(0.125)/log(abs(data.params.freeChoice-0.5)+0.5)); if maxrepeat<0; maxrepeat = Inf; end;
    data.stimuli.loc(psychsr_rand(1-data.params.freeChoice,data.params.numTrials,0,maxrepeat)>1) = 3;
end
maxrepeat = floor(log(0.125)/log(abs(data.params.perStimA-0.5)+0.5)); if maxrepeat<0; maxrepeat = Inf; end;
data.stimuli.id = psychsr_rand(data.params.perStimA,data.params.numTrials,0,maxrepeat);

data.stimuli.block = ones(size(data.stimuli.loc)); % 1:left=reward(1), 2:left=reward(2)
bs = data.params.blockSeq;
if data.params.blockRewards
    if data.params.firstBlockEqual
        %         data.stimuli.block = 3*ones(size(data.stimuli.loc));
    else
        data.stimuli.block = bs(1)*ones(size(data.stimuli.loc));
    end
    
elseif length(data.params.reward)>1 && max(data.params.blockSize) < Inf
    i = 0; j = 1;
    while i < length(data.stimuli.block)
        if length(data.params.blockSize)>1
            n = randi(data.params.blockSize);
        else
            n = data.params.blockSize;
        end
        data.stimuli.block(i+1:i+n) = bs(mod(j-1,length(bs))+1)*ones(1,n);
        if data.params.actionValue && data.params.freeForcedBlocks && bs(mod(j-1,length(bs))+1) < 3
            data.stimuli.loc(i+1:i+n) = 3;
        end
        i = i+n; j = j+1;
    end
    data.stimuli.block(length(data.stimuli.loc)+1:end) = [];
end

data.stimuli.loc(1:data.params.numTrials) = 3;


lastblock = 0;
nblocks = 0;
nrewards = 0;
nrewards_ab = 0;
if data.params.firstBlockEqual || data.stimuli.block(1) == 3
    rewardSwitch = max(data.params.blockSize);
else
    rewardSwitch = min(data.params.blockSize);
end

% link stimulus id to action in blocks
if data.params.actionValue == 0 && data.params.linkStimAction
    ix = data.stimuli.loc<3;
    data.stimuli.id(ix) = xor(data.stimuli.loc(ix)-1,data.stimuli.block(ix)-1)+1;
    ix = data.stimuli.loc==3;
    data.stimuli.id(ix) = 3-data.stimuli.block(ix);
end

if data.params.laser_blank_only
    temp_conc = [];
    for cLoop = 1:data.params.numTrials/10
        temp = randperm(10,1);
        temp = temp + (10*(cLoop - 1));
        temp_conc = cat(2,temp_conc,temp);
    end
    data.stimuli.contrast = ones(1,data.params.numTrials);
    data.stimuli.contrast(temp_conc) = 0;
else
    data.stimuli.contrast = data.params.contrast(randi(length(data.params.contrast),1,data.params.numTrials));
    data.stimuli.contrast(data.stimuli.loc==3) = max(data.params.contrast);
    data.stimuli.contrast(1:data.params.nHighContrast) = max(data.params.contrast);
end

if data.params.laser && data.params.laser_blank == 0
    poscon = data.params.contrast; poscon(poscon==0) = [];
    data.stimuli.contrast(data.stimuli.laser==2) = poscon(randi(length(poscon),1,sum(data.stimuli.laser==2)));
end

if data.params.laser_blank_only %by default, activate 50% of blank trials
    blanks = find(data.stimuli.contrast < 1);
    lase_idx = datasample(blanks, round(numel(blanks)/2),'replace',false);
    data.stimuli.laser = ones(1,data.params.numTrials);
    data.stimuli.laser(lase_idx) = 2;
end





if numel(data.params.laser_time) > 1
    data.params.laser_time = ones(1,numTrials)
end

if numel(data.params.goDelay) > 1 % -- RH, to account for laser stim for variable delay
    varDelayFlag = 1;
end
data.stimuli.sound = zeros(size(data.stimuli.loc));
%% Loop through all the trials

% wait for movement
%     mvmt_test = true; << CHANGE
fprintf('testing, waiting for mvmt...\n')

if data.params.lever>0
    start(data.card.ai);
    nsampled = 0;
    while mvmt_test
        if data.card.ai.SamplesAcquired > nsampled
            newdata = peekdata(data.card.ai,data.card.ai.SamplesAcquired-nsampled);
            nsampled = nsampled + size(newdata,1);
            if data.params.lever == 1; chans = 2; else chans = [2 3]; end;
            vals = max(abs(smooth(newdata(:,chans)-repmat(data.params.lev_baseline,size(newdata,1),1),16)))./data.params.lev_cal;
            if max(vals > data.params.lev_still)
                mvmt_test = false;
            end
        end
        pause(0.1)
    end
    stop(data.card.ai)
else
    while mvmt_test
        bytes = data.serial.in.BytesAvailable;
        while bytes > 4
            [d,b] = fscanf(data.serial.in,'%d'); % read x and y
            bytes = bytes-b;
            if length(d) == 2 && d(2)~= 0
                mvmt_test = false;
                break;
            end
        end
        pause(0.1);
    end
end
fprintf('movement detected.\n')
data.response.start_time = now;
start(data.card.ai);
if strcmp(data.card.trigger_mode, 'out')
    putvalue(data.card.trigger,1);
    WaitSecs(0.005);
    putvalue(data.card.trigger,0);
    disp('Triggered')
end
data.response.nsampled = 0; % ai samples
data.response.lickdata = [];
data.response.mvmtdata = [];
% if data.params.lev_touch
data.response.touchdata = [];
% end
data.quitFlag = 0;
data.userFlag = 0;
data.response.choice = [];
data.response.choice_id = [];
data.response.reward = [];
data.response.rewardtimes = [];

k = 0;
tstart = tic;

numMissAutoRwd = data.params.numMissAutoRwd;

while k < data.params.numTrials && data.quitFlag==0
    
    % trial values
    k = k+1;            % trial number
    currX = 0;          % current trackball position (actual)
    currT = 0;          % current trial time
    screenX = [];       % log of all screen positions
    ballX = [];         % log of all trackball positions
    samps = [];         % samples (serial) per loop
    timePC = [];        % log of all timestamps
    licks = [];         % log all licks
    choice = 0;         % current trial choice
    go = 0;             % count mvmts?
    drawFlag = 0;       % was stimulus drawn on last loop?
    flips = [];         % fliptimes of stimulus ON v OFF
    godelay = 0;        % delay between trial start and stimulus on
    actdelay = 0;       % actual flip time diff
    data.params.trial_threshold(k,:) = data.params.threshold;
    
    data.response.missAutoRwd(k) = 0;
    if data.params.numMissAutoRwd & numel(data.response.choice) > numMissAutoRwd
        if sum(data.response.choice(end-(numMissAutoRwd-1):end) == 5) >= numMissAutoRwd & ~data.response.missAutoRwd(k-1)
            psychsr_sound(6);
            fprintf('FREE REWARD\n')
            outdata = data.card.dio.UserData;
            outdata.dt(1) = data.response.reward_time;
            outdata.tstart(1) = NaN;
            data.card.dio.UserData = outdata;
            
            data.response.missAutoRwd(k) = 1;
            
            
        end
    end
    
    if max(data.params.flashStim) > 0 % randomly choose a stimulus duration
        stimtime = data.params.flashStim(randi(numel(data.params.flashStim)));
        %stimtime = min(data.params.flashStim) + rand*range(data.params.flashStim);
    else
        stimtime = 0;
    end
    % current screen position
    x = data.stimuli.startPos(data.stimuli.loc(k));
    
    % ITI - force mouse to stop moving for 1s
    fprintf('%s ITI\n',datestr(toc(tstart)/86400,'MM:SS'))
    
    % display behavioral performance
    if lastblock ~= data.stimuli.block(k)
        fprintf('\n\nSWITCH TO BLOCK %d: ',data.stimuli.block(k));
        if data.stimuli.block(k)==3 || length(data.params.reward) == 1
            fprintf('EQUAL\n')
        elseif data.params.actionValue
            fprintf('LEFT = %d\n',data.params.reward(data.stimuli.block(k)));
        elseif data.params.linkStimAction
            fprintf('LEFT-%s = %d\n',upper(data.params.stims{data.stimuli.block(k)}),data.params.reward(data.stimuli.block(k)));
        else
            fprintf('%s = %d\n',upper(data.params.stims{1}),data.params.reward(data.stimuli.block(k)));
        end
        
        lastblock = data.stimuli.block(k);
    end
    str = trackball_dispperf(0);
    fprintf('%s',str);
    
    if data.params.blockRewards && length(data.params.reward) > 1
        fprintf('BLOCK %d: %d rewards of %d\n',data.stimuli.block(k),nrewards,rewardSwitch)
        fprintf('NEXT BLOCK: %d\n',bs(mod(nblocks+1,length(bs))+1))
    end
    
    if k>1 && mod(k,3) == 1
        i = str2num(data.screen.pc(end));
        if ~isempty(strfind(lower(data.screen.pc),'ball'))
            i = i+4;
        end
        fid = fopen(sprintf('rig%1d.txt',i),'w');
        str = [sprintf('RIG %1d\nMOUSE %2d\n%s TRIAL %d\n',i,...
            data.mouse,datestr(toc(tstart)/86400,'MM:SS'),k), str];
        fprintf(fid,'%s',str);
        fclose(fid);
    end
    
    % pre-trial delay period
    if data.params.lickInitiate>0
        % no licking for 1 second
        ttemp = tic;
        while toc(ttemp) < data.params.itiDelay
            trackball_keycheck(k);
            % record licks
            newdata = trackball_getdata(1);
            if ~isempty(newdata)
                testdata = newdata; % testdata is newdata plus previous data point
                if ~isempty(data.response.lickdata)
                    testdata = cat(1,data.response.lickdata(end,:),testdata);
                end
                abovetrs = testdata > data.params.extend_delay_thresh;
                crosstrs = find([0;abovetrs(2:end)-abovetrs(1:end-1)] > 0);
                if ~isempty(crosstrs) && data.params.extenddelay && data.quitFlag==0
                    if toc(ttemp) > 0.1;
                        fprintf('%s EXTEND DELAY...\n',datestr(toc(tstart)/86400,'MM:SS'));
                    end
                    ttemp = tic;
                end
            end
        end
        % mouse must lick to initiate trial
        licked = 0;
        ttemp = tic; lastt = 1;
        while ~licked
            trackball_keycheck(k);
            newdata = trackball_getdata(1);
            if ~isempty(newdata)
                testdata = [data.response.lickdata(end,:);newdata]; % testdata is newdata plus previous data point
                abovetrs = testdata > 1;
                crosstrs = find([0;abovetrs(2:end)-abovetrs(1:end-1)] > 0);
                licked = ~isempty(crosstrs);
            end
            if toc(ttemp)>lastt
                fprintf('%s WAITING FOR LICK %ds...\n',datestr(toc(tstart)/86400,'MM:SS'),lastt);
                lastt = lastt+1;
                if lastt > 30;
                    licked = 1;
                    data.quitFlag = 1;
                end
            end
        end
        % deliver a small reward
        fprintf('%s INITIATE %1.1fuL\n',datestr(toc(tstart)/86400,'MM:SS'),data.params.lickInitiate)
        if data.response.init_time>0
            outdata = data.card.dio.UserData;
            outdata.dt(1) = data.response.init_time;
            outdata.tstart(1) = NaN;
            data.card.dio.UserData = outdata;
        end
        
    else
        % mouse must stop moving for 1s to initiate trial
        ttemp = tic; ttemp2 = tic;
        lastval = [];
        while toc(ttemp) < data.params.itiDelay
            trackball_keycheck(k);
            newdata = trackball_getdata(2);
            
            if ~isempty(newdata) && data.params.extenddelay && data.quitFlag==0
                if data.params.lever>0
                    if isempty(lastval)
                        lastval = mean(newdata)./data.params.lev_cal;
                    elseif max(abs(smooth(newdata,16)./data.params.lev_cal-lastval)) > data.params.lev_still ...
                            || (data.params.lev_touch && min(data.response.touchdata(end-size(newdata,1)+1:end))<1)
                        if toc(ttemp2) > 1
                            fprintf('%s EXTEND DELAY...\n',datestr(toc(tstart)/86400,'MM:SS'));
                            ttemp2 = tic;
                        end
                        lastval = mean(newdata)./data.params.lev_cal;
                        ttemp = tic;
                    end
                    
                elseif abs(newdata(2)) > data.params.extend_delay_thresh;
                    if toc(ttemp2) > 1
                        fprintf('%s EXTEND DELAY...\n',datestr(toc(tstart)/86400,'MM:SS'));
                        ttemp2 = tic;
                    end
                    ttemp = tic;
                end
                if data.params.lever > 0
                    curr_baseline = mean(newdata)./data.params.lev_cal;
                end
            end
        end
        if data.params.lever > 0
            fprintf('baseline: %1.1f%%',curr_baseline*100);
        end
        
    end
    
    Screen('FillRect', window, grey)
    vbl = Screen('Flip', window);
    
    
    % trial start
    fprintf('\n\n%s TRIAL %d START\n',datestr(toc(tstart)/86400,'MM:SS'),k)
    
    % collect extra serial samples  -- RH
    if data.params.lever>0
        trackball_getdata(2);
    else
        while data.serial.in.BytesAvailable > 4
            trackball_keycheck(k);
            trackball_getdata(2);
        end
    end
    
    precue_samples_start = size(data.response.mvmtdata,1); % --RH end
    
    if data.params.early_cue & data.response.playEarlyCue(k) == 1
        psychsr_sound(data.params.earlyCue_sound);
    end
    data.response.earlyCueTime(k) = toc(tstart);
    
    if numel(data.params.goDelay) > 1
        %delay = min(data.params.goDelay) + range(data.params.goDelay)*rand;
        delay = exprnd(data.params.goDelay(1));
        if delay > data.params.goDelay(2)
            delay = data.params.goDelay(2);
        elseif delay < data.params.minGoDelay;
            delay = data.params.minGoDelay;
        end
    else
        delay = data.params.goDelay;
    end
    
    if delay>0
        fprintf('go delay =  %1.3f\n',delay)
    end
    godelay = delay;
    ttemp = tic;
    laserFlag = 0;
    while toc(ttemp)<delay && choice == 0
        pause(0.01) % pause allows reward to be administered
        
        if data.params.preCueEarlyAbort>0
            newdata = trackball_getdata(2); % -- RH
            if ~isempty(newdata) && abs(newdata(2)) > 1
                choice = 7; %7 = aborted because mvmt during foreperiod -- RH
                fprintf('%s PRECUE EARLY ABORT - %1.2fs\n',datestr(toc(tstart)/86400,'MM:SS'))
            end
        end
        
        if choice == 0 && data.params.early_cue && ~laserFlag && data.params.laser && data.stimuli.laser(k) == 2 && data.params.laser_start < 0
            if toc(ttemp) > delay + data.params.laser_start
                start(data.card.ao)
                data.response.laserTimeAfterBeep(k) = toc(ttemp); %laser start time relative to trial start
                fprintf('LASER ON -- %d s\n',data.params.laser_time)
                laserFlag = 1;
            end
        end
        trackball_keycheck(k);
    end
    
    if ~laserFlag && (data.params.laser || data.params.laser_blank_only) && data.params.laser_start ==  0 && data.stimuli.laser(k) == 2 && ~data.params.early_cue
        start(data.card.ao)
        data.response.actualLaserTime(k) = toc(tstart);
        fprintf('LASER ON -- %d s\n',data.params.laser_time)
    elseif ~laserFlag && data.params.laser && data.params.laser_start < 0 && ~data.params.early_cue   %RH -- start laser before trial start
        if data.stimuli.laser(k) == 2
            start(data.card.ao);
            fprintf('LASER ON -- %d s\n',data.params.laser_time)
        end
        preLaserDelay = tic;
        while toc(preLaserDelay) < abs(data.params.laser_start); end
    end
    
    
    
    % collect extra serial samples
    if data.params.lever>0
        trackball_getdata(2);
    else
        while data.serial.in.BytesAvailable > 4
            trackball_keycheck(k);
            trackball_getdata(2);
        end
    end
    
    % log start time
    currT = tic;
    data.response.trialstart(k) = toc(tstart);
    samples_start = size(data.response.mvmtdata,1);
    
    %% track ball movements
    while choice == 0
        
        
        % collect serial samples
        n = 0;
        if data.params.lever>0
            newdata = trackball_getdata(2);
            n = n+size(newdata,1);
        else
            while data.serial.in.BytesAvailable > 4
                trackball_keycheck(k);
                newdata = trackball_getdata(2);
                n = n+size(newdata,1);
            end
        end
        
        % play go cue
        if go == 0 && toc(currT) > data.params.noMvmtTime
            go = 1;
            if data.params.go_cue & ~(data.params.early_cue)% == 1
                if data.params.lever>0
                    if data.params.lev_chirp
                        if data.params.lev_cont==1
                            ix = 20+data.stimuli.loc(k);
                        else
                            ix = 23-data.stimuli.loc(k);
                        end
                    else
                        if data.params.lev_cont==1
                            ix = 12+data.stimuli.loc(k);
                        else
                            ix = 15-data.stimuli.loc(k);
                        end
                    end
                else
                    if data.params.noMvmtTime > 0
                        ix = 14;
                    else
                        ix = data.params.earlyCue_sound;
                    end
                end
                psychsr_sound(ix);
                data.stimuli.sound(k) = ix;
                %             elseif data.params.go_cue==2
                %                 psychsr_sound(18+data.stimuli.block(k));
            end
        end
        
        timePC(end+1) = toc(currT);
        
        % Pre-movement delay
        if data.params.lever>0
            if n>0
                d = mean(data.response.mvmtdata(end-n+1:end,:))./data.params.lev_cal - curr_baseline;
                if data.params.lever == 1
                    currX = d;
                else
                    currX = diff(d);
                end
                x = currX * data.stimuli.startPos(1)/max(data.params.lev_thresh);
                
                x = x + data.stimuli.startPos(data.stimuli.loc(k));
            end
        else
            % integrate values
            if go && n>0
                d_all = data.response.mvmtdata(end-n+1:end,1);
            else
                d_all = 0;
                if ~go && n>0 && data.params.earlyAbort>0 && max(abs(data.response.mvmtdata(end-n+1:end,1)))>data.params.earlyAbort
                    choice = 6;
                    fprintf('%s PREMVMT EARLY ABORT - %1.2fs\n',datestr(toc(tstart)/86400,'MM:SS'),timePC(end))
                end
            end
            
            % multiply by gain to get screen position
            if max(data.params.training) > 0 && data.params.proOrienting
                if data.stimuli.loc(k) == 2
                    d = sum(d_all(d_all<0))*data.response.gain(2) + sum(d_all(d_all>0))*data.response.gain(1)*data.params.trainingSide(2);
                elseif data.stimuli.loc(k) == 1
                    d = sum(d_all(d_all>0))*data.response.gain(1) + sum(d_all(d_all<0))*data.response.gain(2)*data.params.trainingSide(1) ;
                end
            elseif max(data.params.training) > 0
                if data.stimuli.loc(k) == 2
                    d = sum(d_all(d_all<0))*data.response.gain(2) + sum(d_all(d_all>0))*data.response.gain(1)*data.params.trainingSide(1);
                elseif data.stimuli.loc(k) == 1
                    d = sum(d_all(d_all>0))*data.response.gain(1) + sum(d_all(d_all<0))*data.response.gain(2)*data.params.trainingSide(2) ;
                end
            else
                d = sum(d_all(d_all>0))*data.response.gain(1) + ...
                    sum(d_all(d_all<0))*data.response.gain(2);
            end
            if data.params.proOrienting
                x = d+x;
            else
                x = -d+x;
            end
            
            % log actual ball movement/time
            currX = -sum(d_all,1) + currX;
        end
        
        ballX(end+1) = currX;
        samps(end+1) = n;
        
        
        % prevent cursor from moving beyond boundaries
        if sign(x) == sign(data.stimuli.loc(k)-1.5)
            x = 0;
        elseif abs(x) > data.stimuli.stopPos(1);
            x = sign(x)*data.stimuli.stopPos(1);
        end
        screenX(end+1) = x;
        
        % check for key press
        trackball_keycheck(k);
        
        %% Define choice threshold and save data when threshold is met.
        dstCenterRect = CenterRectOnPointd(data.stimuli.cursor, xCenter+x, yCenter);
        
        % check for choice
        if data.params.lever == 0
            if x == 0 % successfully moved to center
                if data.stimuli.loc(k) == 3; choice = 2;
                else choice = data.stimuli.loc(k); end
            elseif abs(x) == data.stimuli.stopPos(1) % moved to end
                if data.stimuli.loc(k) == 3; choice = 1;
                else choice = 3-data.stimuli.loc(k); end
            elseif choice==0 && toc(currT) >= data.params.responseTime
                choice = 5; %5 -- a choice was not made within alloted time
                fprintf('%s TIMEOUT - %1.2fs\n',datestr(toc(tstart)/86400,'MM:SS'),timePC(end))
            end
        elseif data.params.lever == 1
            if data.stimuli.loc(k)==2 && currX > data.params.lev_thresh % GO trial
                choice = 2;
            elseif data.stimuli.loc(k)==1 && abs(currX) > data.params.lev_thresh
                choice = 2;
            elseif choice==0 && toc(currT) >= data.params.responseTime
                if data.stimuli.loc(k) == 1
                    choice = 1;
                else
                    choice = 5;
                    fprintf('%s TIMEOUT - %1.2fs\n',datestr(toc(tstart)/86400,'MM:SS'),timePC(end))
                end
            end
            
        elseif data.params.lever == 2
            if currX < -data.params.lev_thresh(1)
                choice = 1;
            elseif currX > data.params.lev_thresh(2)
                choice = 2;
            elseif choice==0 && toc(currT) >= data.params.responseTime
                choice = 5; %5 -- a choice was not made within alloted time
                fprintf('%s TIMEOUT - %1.2fs\n',datestr(toc(tstart)/86400,'MM:SS'),timePC(end))
            end
        end
        
        % update performance markers
        if choice ~= 0
            switch choice
                case 1; fprintf('%s LEFT - %1.2fs\n',datestr(toc(tstart)/86400,'MM:SS'),timePC(end))
                case 2; fprintf('%s RIGHT - %1.2fs\n',datestr(toc(tstart)/86400,'MM:SS'),timePC(end))
            end
        end
        
        % Draw center cursor
        if choice==0
            color = [1 1 1]*grey*(1-data.stimuli.contrast(k)*cos(2*pi*data.params.reversalFreq*toc(currT)));
        else
            color = [1 1 1]*grey*(1-data.stimuli.contrast(k));
        end
        
        %         if sum(data.params.flashStim) > 0
        newdrawFlag = choice < 6 && (stimtime==0 || toc(currT)<stimtime);
        %         end
        
        if newdrawFlag
            trackball_draw(k,x,color);
        end
        
        newvbl = Screen('Flip', window, vbl + (wait_frames-0.5)*flip_int);
        %         fprintf('%2.1f\n',1000*(newvbl-vbl))
        
        if newdrawFlag ~= drawFlag || length(samps)==1 % stimulus turns ON/OFF
            flips(end+1) = newvbl;
            if drawFlag == 0 % save first flip time
                actdelay = newvbl-vbl;
                if stimtime>0
                    fprintf('stim time = %1.3f\n',stimtime);
                end
            end
        end
        vbl = newvbl;
        drawFlag = newdrawFlag;
        
        
        if ~laserFlag && (data.params.laser || data.params.laser_blank_only) && data.params.laser_start > 0 && toc(currT) >= data.params.laser_start && data.stimuli.laser(k) == 2 % RH -- laser start after cue onset
            start(data.card.ao);
            fprintf('LASER ON -- %d s\n',data.params.laser_time)
            data.response.actualLaserTime(k) = toc(currT);
            laserFlag = 1;
        end
    end
    
    data.response.choice(k) = choice;
    data.response.choice_id(k) = id;
    
    %% reward or punish
    
    % save trial end time
    samples_stop = size(data.response.mvmtdata,1);
    
    if stimtime > 0
        Screen('FillRect', window, grey);
        newvbl = Screen('Flip', window);
        if length(flips)<2
            flips(2) = newvbl;
        end
    end
    
    % Delay between correct choice and reward -- RH
    if sum(data.params.rwdDeliveryDelay) > 0
        if data.stimuli.loc(k) == choice %if correct
            %psychsr_sound(6); %play reward sound
            rwdDelay = tic;
            currDelay = data.params.rwdDeliveryDelay(randi(numel(data.params.rwdDeliveryDelay)));
            while toc(rwdDelay) < currDelay
            end
        end
    end
    
    
    id = 5;
    if choice == 5 | choice == 7 % timeout
        if data.params.MissSound
            if data.params.lever == 0
                psychsr_sound(1);
            end
        end
        data.response.reward(k) = 0;
    elseif choice == 6 % abort sound
        psychsr_sound(18);
        data.response.reward(k) = 0;
    elseif choice == data.stimuli.loc(k) || data.stimuli.loc(k)==3 % correct choice
        if length(data.response.reward_time)==1
            id = 1;
        elseif data.params.actionValue % left/right
            if data.stimuli.block(k) == 3 % equal value
                [~,id] = max(data.params.reward);
            else
                id = xor(choice-1,data.stimuli.block(k)-1)+1;
            end
        elseif data.params.linkStimAction % diamond/square with fixed values
            if data.stimuli.loc(k) == 3
                id = ~xor(choice-1,data.stimuli.id(k)-1)+1;
            else
                id = data.stimuli.id(k);
            end
        else % diamond/square with values changing as function of block
            if data.stimuli.loc(k) == 3
                id = xor(~xor(choice-1,data.stimuli.id(k)-1),data.stimuli.block(k)-1)+1;
            else
                id = xor(data.stimuli.id(k)-1,data.stimuli.block(k)-1)+1;
            end
        end
        
        if rand < data.params.rewardProb(id) && ~(data.params.lever == 1 && data.stimuli.loc(k) == 1)
            % play reward sound
            if length(data.params.reward) > 1 && data.params.reward(id) == max(data.params.reward) && data.params.rewardDblBeep
                psychsr_sound(16);
            elseif data.params.reward(id)>0 && ~(data.params.lever==1 && data.params.lev_chirp)
                psychsr_sound(6);
            end
            
            % deliver reward
            fprintf('%s REWARD %duL\n',datestr(toc(tstart)/86400,'MM:SS'),data.params.reward(id))
            data.response.rewardtimes(end+1) = toc(tstart);
            if data.response.reward_time(id)>0
                outdata = data.card.dio.UserData;
                outdata.dt(1) = data.response.reward_time(id);
                outdata.tstart(1) = NaN;
                data.card.dio.UserData = outdata;
            end
            data.response.reward(k) = data.params.reward(id);
            
            % potentially change block
            nrewards = nrewards + 1;
            if nrewards == rewardSwitch && length(data.params.reward)>1
                nblocks = nblocks + 1;
                nrewards = 0;
                
                if data.params.firstBlockEqual
                    if nblocks == 1
                        if sum(data.response.choice(1:k)==1) > sum(data.response.choice(1:k)==2)
                            data.stimuli.block(k+1:end)=1; %left bias, reward right more
                        else
                            data.stimuli.block(k+1:end)=2;
                        end
                    else
                        data.stimuli.block(k+1:end) = 3-data.stimuli.block(k);
                    end
                else
                    data.stimuli.block(k+1:end) = bs(mod(nblocks,length(bs))+1);
                end
                
                % determine next block size
                if length(data.params.blockSize)>1
                    rewardSwitch = randi(data.params.blockSize);
                end
                
                if data.params.actionValue && data.params.freeForcedBlocks
                    if data.stimuli.block(k+1) < 3
                        data.stimuli.loc(k+1:end) = 3;
                    else
                        maxrepeat = floor(log(0.125)/log(abs(data.params.perRight-0.5)+0.5)); if maxrepeat<0; maxrepeat = Inf; end;
                        data.stimuli.loc(k+1:end) = psychsr_rand(1-data.params.perRight,data.params.numTrials-k,0,maxrepeat);
                        rewardSwitch = max(data.params.blockSize);
                    end
                end
                
            end
        else
            fprintf('%s REWARD 0uL\n',datestr(toc(tstart)/86400,'MM:SS'))
            data.response.reward(k) = 0;
            psychsr_sound(3);
        end
    else % incorrect choice
        if data.params.lever>0
            if data.params.lev_pufftime > 0
                outdata = data.card.dio.UserData;
                outdata.dt(2) = data.params.lev_pufftime;
                outdata.tstart(2) = NaN;
                data.card.dio.UserData = outdata;
            end
            
        elseif data.params.incorrSound > 0
            psychsr_sound(3);
        end
        data.response.reward(k) = 0;
    end
    
    for i = 1:10
        pause(0.1) % pause allows reward to be administered
        trackball_keycheck(k);
    end
    if data.params.itiBlack
        Screen('FillRect', window, black);
    else
        Screen('FillRect', window, grey);
    end
    newvbl = Screen('Flip', window);
    if length(flips)<2
        flips(2) = newvbl;
    end
    
    % antibias selects next trial
    nextstim = 0;
    nextid = 0;
    if data.params.antibiasNew
        if k >= 10 && k+1 < data.params.numTrials
            lastchoices = data.response.choice(k-9:k);
            prevchoice = nan(size(lastchoices));
            for p = 1:10
                ix = find(data.response.choice(1:k-11+p)~=5,1,'last');
                if ~isempty(ix)
                    prevchoice(p) = data.response.choice(ix);
                end
            end
            dleftright = sum(lastchoices==1) - sum(lastchoices==2);
            ix = find(~isnan(prevchoice) & lastchoices<5);
            dsamediff = sum(lastchoices(ix)==prevchoice(ix)) - sum(lastchoices(ix)~=prevchoice(ix));
            if abs(dleftright) > abs(dsamediff)
                nextstim = (dleftright>0)+1;
                fprintf('L-R = %d\n',dleftright)
            elseif abs(dleftright) < abs(dsamediff)
                if dsamediff > 0
                    nextstim = 3-lastchoices(ix(end));
                else
                    nextstim = lastchoices(ix(end));
                end
                fprintf('S-O = %d\n',dsamediff)
            else
                fprintf('|L-R| = |S-O| = %d\n',abs(dleftright))
            end
            
        end
    elseif k+1 < data.params.numTrials && data.stimuli.loc(k) < 3 && data.userFlag ~= k+1
        
        % if success on last trial
        if choice == data.stimuli.loc(k)
            
            nrewards_ab = nrewards_ab + 1;
            if max(data.params.antibiasNumCorrect)>0
                fprintf('%d CORRECT\n',nrewards_ab)
            end
            
            if data.params.antibiasSwitch > 0
                if length(data.params.antibiasNumCorrect) > 1
                    id = data.stimuli.loc(k);
                else
                    id = 1;
                end
                if rand <= data.params.antibiasSwitch
                    if nrewards_ab >= data.params.antibiasNumCorrect(id)
                        nextstim = 3-data.stimuli.loc(k); % switch side
                        nrewards_ab = 0;
                    else
                        nextstim = data.stimuli.loc(k); % repeat side
                    end
                else
                    nextstim = 0;
                end
            end
            
            % if failed on last trial
        elseif choice ~= data.stimuli.loc(k)
            if data.params.antibiasConsecutive && choice < 5
                nrewards_ab = 0;
            end
            
            if data.params.antibiasRepeat > 0
                if rand <= data.params.antibiasRepeat
                    nextstim = data.stimuli.loc(k); % repeat side
                    data.stimuli.id(k+1) = data.stimuli.id(k); % repeat id and block also
                    data.stimuli.block(k+1) = data.stimuli.block(k);
                else
                    nextstim = 0;
                    %                     nextstim = rand<data.params.perRight + 1;
                    %                     if nextstim == 3-data.stimuli.loc(k)
                    %                         nrewards_ab = 0;
                    %                     end
                end
            end
        end
    end
    % change trial
    if nextstim > 0
        data.stimuli.loc(k+1) = nextstim;
        if nextstim == 1
            fprintf('ANTIBIAS: NEXT STIM LEFT\n')
        else
            fprintf('ANTIBIAS: NEXT STIM RIGHT\n')
        end
    end
    
    
    % quit if 10 timeouts in a row
    if k >= data.params.timeout && min(data.response.choice(k-(data.params.timeout-1):k))==5 %RH, turned timeout to variable
        data.quitFlag = 1;
    elseif data.params.lever>0 && length(data.response.choice(data.stimuli.loc(1:k)==2))>=data.params.quitAfterMiss
        ix = find(data.stimuli.loc(1:k)==2,data.params.quitAfterMiss,'last');
        if min(data.response.choice(ix))==5
            data.quitFlag = 1;
        end
    end
    
    % save post-trial ball movements/licks
    ttemp = tic;
    nlicks = 0;
    
    if data.params.lever>0
        if choice==2 && data.stimuli.loc(k)==1 % false alarm
            delay = data.params.rewardDelay-1+data.params.punishDelay;
        else
            delay = data.params.rewardDelay-1;
        end
        
    else
        if choice~=data.stimuli.loc(k) && ~(data.stimuli.loc(k)==3 && choice~=5)
            delay = data.params.rewardDelay-1+data.params.punishDelay;
        else
            delay = data.params.rewardDelay-1;
        end
    end
    
%     while toc(ttemp) < delay
        trackball_keycheck(k);
        newdata = trackball_getdata(3);
        if ~isempty(newdata{1})
            testdata = newdata{1}; % testdata is newdata plus previous data point
            if ~isempty(data.response.lickdata)
                testdata = cat(1,data.response.lickdata(end,1),testdata);
            end
            abovetrs = testdata > 1;
            crosstrs = find([0;abovetrs(2:end)-abovetrs(1:end-1)] > 0);
            nlicks = length(crosstrs) + nlicks;
        end
%     end
    licks(end+1) = nlicks;
    fprintf('%s LICKED %d TIMES\n',datestr(toc(tstart)/86400,'MM:SS'),licks(end))
    
    if (data.params.laser || data.params.laser_blank_only) && (strcmp(data.card.ao.Running,'On') || (data.card.ao.SamplesOutput>0))
        fprintf('WAITING FOR LASER... ')
        wait(data.card.ao,5)
        fprintf('DONE.\n')
    end
    
    % save trial variables
    data.response.trialtime(k) = toc(tstart);
    data.response.screenX{k} = screenX;
    data.response.ballX{k} = ballX;
    data.response.samps{k} = samps;
    data.response.timePC{k} = timePC;
    data.response.samples_start{k} = samples_start;
    data.response.precue_samples_start{k} = precue_samples_start;
    data.response.samples_stop{k} = samples_stop;
    data.response.samples_reward{k} = size(data.response.mvmtdata,1);
    data.response.licksamples{k} = size(data.response.lickdata,1);
    if stimtime > 0
        data.response.stimdur(k) = stimtime;
    else
        data.response.stimdur(k) = data.response.trialtime(k);
    end
    data.response.actstimdur(k) = diff(flips);
    data.response.delay(k) = godelay;
    data.response.actdelay(k) = actdelay;
end

%% Cleanup
psychsr_sound(3);
Screen('FillRect', window, grey);
Screen('Flip', window);
if data.params.lever==0
    fclose(data.serial.in);
    delete(data.serial.in);
    data.serial = rmfield(data.serial,'in');
end
if data.params.laser || data.params.laser_blank_only
    tstart = tic;
    while (strcmp(data.card.ao.Running,'On') || (data.card.ao.SamplesOutput>0)) && toc(tstart)<10
        pause(0.1)
    end
    putsample(data.card.ao,zeros(size(data.card.ao_chans)));
    putsample(data.card.ao,zeros(size(data.card.ao_chans)));
    wait(data.card.ao,10);
    stop(data.card.ao);
    delete(data.card.ao)
    data.card = rmfield(data.card,'ao');
end
putvalue(data.card.dio,0);
stop(data.card.dio)
delete(data.card.dio);
data.card = rmfield(data.card,'dio');
data.card = rmfield(data.card,'trigger');
stop(data.card.ai);
delete(data.card.ai);
data.card = rmfield(data.card,'ai');


% notify
if data.quitFlag<2 && max(strcmp(data.params.notify,{'g','l','r'}))
    i = str2num(data.screen.pc(end));
    if ~isempty(strfind(lower(data.screen.pc),'ball'))
        i = i+4;
    end
    for e = 1:length(data.params.email)
        sendmail(data.params.email{e},sprintf('m%02d done on rig %d at %s after %smin',...
            data.mouse,i,datestr(now,'mm/dd HH:MM'),datestr(max(data.response.trialtime)/86400,'MM')));
        fprintf('SENT EMAIL\n');
    end
    data.response.notify = '0';
end

data = rmfield(data,'quitFlag');
data = rmfield(data,'userFlag');

% convert serial timestamps
if data.params.lever==0
    time = data.response.mvmtdata(:,2);
    neg = find(diff(time)<-1000,1);
    while ~isempty(neg)
        time(neg+1:end,1) = time(neg+1:end,1) + 2^16;
        neg = find(diff(time)<-1000,1);
    end
    time = time/1000;
    x = data.response.mvmtdata(:,1);
    data.response.time = time;
    data.response.dx = x;
end

% display performance
str = trackball_dispperf;
str = [sprintf('\nMouse %d\n',data.mouse), str];
fprintf('%s',str);

i = str2num(data.screen.pc(end));
if ~isempty(strfind(lower(data.screen.pc),'ball'))
    i = i+4;
end
fid = fopen(sprintf('rig%1d.txt',i),'w');
fprintf(fid,'RIG %1d\nEMPTY\n',i);
fclose(fid);

%% save data
date = clock;
folder = sprintf('../behaviorData/trackball/mouse %04d',data.mouse);
if ~isdir(folder); mkdir(folder); end
uisave('data',sprintf('%s/%4d%02d%02d_trackball_%04d',folder,date(1),date(2),date(3),data.mouse));