global data

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

while toc(ttemp) < delay
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
end
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