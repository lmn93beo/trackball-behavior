function trackball_custom_code(k)
global data;
disp('CUSTOM CODE')
try
    % increase left threshold    
%     data.params.threshold(1) = data.params.threshold(1)+5;
%     fprintf('INCREASED LEFT THRESHOLD TO %d\n',data.params.threshold(1))
%     
    % decrease left threshold
%     data.params.threshold(1) = data.params.threshold(1)-5;
%     fprintf('DECREASED LEFT THRESHOLD TO %d\n',data.params.threshold(1))    
        
    % set both thresholds
%    data.params.threshold = [10 20];
%     fprintf('SET BOTH THRESHOLDS TO %d\n',data.params.threshold(1))    
%     data.params.lickInitiate = 0.5;
% data.params.threshold = 30*[1 1];
%     data.stimuli.block(k+1:end) = 3-data.stimuli.block(k);
%       fprintf('SET BLOCK TO %d\n',data.stimuli.block(k+1))    
    
%     data.params.punishDelay = 6;
% data.params.antibiasRepeat = 0.5; % probability that antibias will repeat after a wrong trial
% data.params.antibiasSwitch = 0.9; 
% data.params.blockSize = [5 10];%[10 20]; % min/max block size
% data.stimuli.id(k+1:k+5) = 2;
% data.stimuli.contrast(k+1:k+10) = 0.64;
% data.params.contrast = [0.25 0.5 1];
% data.response.mvmt_volts_per_mm = 0.005;
% data.params.leverthresh = [1 1];
% data.params.leverdiffthresh = [0.05 0.35];
% data.params.perRight = 1;
% maxrepeat = floor(log(0.125)/log(abs(data.params.perRight-0.5)+0.5)); if maxrepeat<0; maxrepeat = Inf; end;
% data.stimuli.loc(k+1:end) = psychsr_rand(1-data.params.perRight,data.params.numTrials-k,0,maxrepeat);
% data.params.contrast = [0 8 8 16 16 32 32 64 64]/100; % hard variable contrast
% data.stimuli.contrast(k+1:end) = data.params.contrast(randi(length(data.params.contrast),1,data.params.numTrials-k));
%data.params.antibiasNumCorrect = [3 3];
% data.stimuli.loc(k+1:end) = 3-data.stimuli.loc(k);
% disp(3-data.stimuli.loc(k));
% data.stimuli.contrast(data.stimuli.loc==3) = max(data.params.contrast);
% data.stimuli.contrast((1:length(data.stimuli.contrast))>k & data.stimuli.laser>1) = 1;
% data.stimuli.block(k+1:end) = 3-data.stimuli.block(k);
% ix = data.stimuli.loc<3;
% data.stimuli.id(ix) = xor(data.stimuli.loc(ix)-1,data.stimuli.block(ix)-1)+1;
% data.stimuli.loc(k+1:k+10) = 2;
%     data.params.antibias = 1;       % probability that antibias will force next trial
%     data.params.freeChoice = 1/3;
%     data.stimuli.loc(k+1:3:end) = 3;
%     data.param.numTrials = 200;
%data.params.responseTime = 4;
%      data.params.threshold = [15 15];
% data.params.flashStim = 0.5;   


% data.params.go_cue = 0;         % play go sound?
% data.params.reward = [6];
% for i = 1:length(data.params.reward)
%     [data.response.reward_amt(i),data.response.reward_time(i),...
%         data.response.reward_cal] = psychsr_set_reward(data.params.reward(i));
% end
% data.params.punishDelay = 0;
% data.params.itiDelay = 1.5;
% data.params.rewardDelay = 3.5;
% data.params.numTrials = 300;
% data.params.flashStim = 3;
% data.params.reversalFreq = 2;   % frequency of contrast reversal  
% data.params.threshold = [20 10];
% data.params.stims = {'square'};
%  data.params.noMvmtTime = 0.3;  
%  data.params.contrast = 1;

% clear trackball_dispperf;
% data.params.freeBlank = 0;    
% data.params.reward = [0.5 3];
% data.params.antibiasSwitch = 0;
% data.params.perRight
%  data.params.flashStim = 0;
%  data.params.rewardProb = [1];
% data.params.threshold = [6 15]; % in degrees, can have diff thresholds for left/right
%data.params.lev_thresh = 0.4;
% data.params.lev_touch= 0;
% data.params.lev_still = 0.05;%data.params.lev_cal/10;
% disp(nblocks)
% data.params.lev_pufftime = 0.5;
% outdata = data.card.dio.UserData;
% outdata.dt(2) = data.params.lev_pufftime;
% outdata.tstart(2) = NaN;
% data.card.dio.UserData = outdata;

% data.stimuli.laser(k+1:end) = 1;
% data.stimuli.laser(k+1:3:end) = 2;
% data.params.antibiasNumCorrect = [3 1]; % number of correct responses before forced switch
% data.params.noMvmtTime = 0.6;
%  data.params.goDelay = 0;
% leave this uncommented
%  data.params.laser = 0; 

% data.params.lev_cont = 2;
% disp('CHANGED CONTINGENCY: LOW = TARGET')
% data.params.threshold = data.params.threshold+3; 
% fprintf('INCREASED THRESHOLD TO %d\n',data.params.threshold(1));

% data.params.extenddelay
% %  data.params.reversalFreq = 2;
% ata.params.antibiasRepeat = 1; % probability that antibias will repeat after a wrong trial
%         data.params.antibiasSwitch = 1; % probability that antibias will switch after a correct trial%            data.params.reward = [4];
% data.params.laser_start = 0.05;
% data.params.blockSize = [12 20];
% data.params.rewardProb = [1];
% data.params.threshold = [7 7];

%data.params.extenddelay = 0;
%data.params.punishDelay = 3;
% data.params.freeBlank = 0;
%data.params.antibiasRepeat = 0.7; % probability that antibias will repeat after a wrong trial
% data.params.trainingSide = [0.6 0.6];
%  data.params.reward = [20];
% data.params.antibiasRepeat = 0; % probability that antibias will repeat after a wrong trial
% data.params.antibiasSwitch = 0; % probability that antibias will switch after a correct trial
% data.params.antibiasNumCorrect = [20 20]; % number of correct responses before forced switch
% data.params.rewardProb = [0 1];
if data.params.lever==0
    data.response.gain = (data.stimuli.startPos(1)...
        *data.response.mvmt_degrees_per_pixel)./data.params.threshold;
end
   
% data.params.laser_time = 2;     % duration in s
%         data.params.laser_start = -1; % time after trial start

data.params.threshold = [7 7];

catch
    disp('ERROR IN CUSTOM CODE')
end
