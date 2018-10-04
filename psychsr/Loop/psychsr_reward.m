function psychsr_reward(loop,sound,amt,side)

global data;

if nargin<2 || isempty(sound)
    sound = 6;
end
if nargin<3 || isempty(amt)
    amt = NaN;
end
if nargin<4 || isempty(side)
    side = 1;
end

if isfield(data,'stimuli') && isfield(data.stimuli,'reward_amt')
    idx = data.stimuli.reward_amt(loop.stim);
else
    idx = 1;
end


% play click sound
psychsr_sound(sound);

% administer reward
if data.response.mode == 4 && strcmp(data.card.ao.Running,'Off') && (data.card.ao.SamplesOutput==0)
    if strcmp(data.response.reward_type,'water')
        putsample(data.card.ao,[5,0]); tstart = tic;
        WaitSecs(data.response.reward_time(idx));
        putsample(data.card.ao,[0,0]);
    else
        start(data.card.ao);
    end
elseif data.response.mode == 2
    if side == 1
        putvalue(data.card.reward1,1);
        putvalue(data.card.reward1,0);
    else
        putvalue(data.card.reward2,1);
        putvalue(data.card.reward2,0);
    end
elseif data.response.mode == 1 || data.response.mode == 3 || ...
        data.response.mode == 5 || data.response.mode == 6 || data.response.mode == 7
    if ~isnan(amt)
        data.response.reward_time = (data.response.reward_cal(1)*amt+data.response.reward_cal(2))/1000;
    end
    outdata = data.card.dio.UserData;
    outdata.dt(1) = data.response.reward_time(idx);
    outdata.tstart(1) = NaN;
    data.card.dio.UserData = outdata;
elseif data.response.mode == 8
    if ~isnan(amt)
        data.response.reward_time(side) = (data.response.reward_cal(side,1)*amt+data.response.reward_cal(side,2))/1000;
    end
    i = side*3-2; % set appropriate reward channel
    outdata = data.card.dio.UserData;
    outdata.dt(i) = data.response.reward_time(side);
    outdata.tstart(i) = NaN;
    data.card.dio.UserData = outdata;    
end

data.response.rewards(end+1,side) = loop.prev_flip_time;
if isfield(data.response,'reward_amt')
    if isnan(amt)
        fprintf(' HIT %3d = %d uL\n',size(data.response.rewards,1),data.response.reward_amt(idx));
    else
        fprintf(' HIT %3d = %d uL\n',size(data.response.rewards,1),amt);
    end
else
    fprintf(' HIT %3d\n',size(data.response.rewards,1));
end

end