global data

% Determine stimulus locations
if data.params.alternating
    % For alternating condition
    data.stimuli.loc = ones(1, data.params.numTrials);
    data.stimuli.loc(1:2:end) = 2;
else
    maxrepeat = floor(log(0.125)/log(abs(data.params.perRight-0.5)+0.5)); if maxrepeat<0; maxrepeat = Inf; end;
    data.stimuli.loc = psychsr_rand(1-data.params.perRight,data.params.numTrials,0,maxrepeat);
    data.stimuli.loc(1:data.params.nRight) = 2;
end

% For a block structure
data.stimuli.loc = repelem(data.stimuli.loc, data.params.blockSize);

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
        data.stimuli.block = 3*ones(size(data.stimuli.loc));    
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

lastblock = 0;
nblocks = 0;
nrewards = 0;
nrewards_ab = 0;
rewardSwitch = 10000;
% if data.params.firstBlockEqual || data.stimuli.block(1) == 3
%     rewardSwitch = max(data.params.blockSize);
% else
%     rewardSwitch = min(data.params.blockSize);
% end

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
    if data.params.alternating
        % Alternating condition for contrast
        n = numel(data.params.contrast);
        data.stimuli.contrast = ones(1, data.params.numTrials);
        for i = 1:n
            data.stimuli.contrast(i:n:end) = data.params.contrast(i);
        end
    else
        % Random contrast from the array
        data.stimuli.contrast = data.params.contrast(randi(length(data.params.contrast),1,data.params.numTrials));
        data.stimuli.contrast(data.stimuli.loc==3) = max(data.params.contrast);
        data.stimuli.contrast(1:data.params.nHighContrast) = max(data.params.contrast);
    end
end

% Block structure for contrast
data.stimuli.contrast = repelem(data.stimuli.contrast, data.params.blockSize);


if data.params.contrast_follows_loc
    data.stimuli.contrast = data.stimuli.loc - 1;
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


%% Initiate some empty structures
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