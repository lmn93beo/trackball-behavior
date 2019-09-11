function data = psychsr_prediction()
% display drifting gratings successively at different orientations
% reward automatically at end of cardinal directions but not diagonal

mouse = input('Mouse #: ');
reward = input('Reward (uL): ');
disp('Set reward amount manually; press enter when finished.'); pause;

response.reward_time = 0.012;
response.reward_amt = reward;

%% default
iti_dur=2;
stim_dur=2;
total_duration = (75)*60;

response.grace_period = 0;      % licks during first 250ms dont count
response.punish = 0;            % punish animal for licks to wrong grating?
response.punish_timeout = 0;    % timeout after punish
response.punish_time = 0.1;     % length of punishment
response.auto_reward = 1;       % automatically reward on target if no early lick
response.auto_time = 0.98;         % time after stimulus onset to give auto reward
response.auto_stop = 1;         % turn off if animal is not responding
response.stop_grating = 0;      % turn off grating after lick
response.extend_iti = 1;
num_stim = 3;                   % number of gratings to show
card.trigger_mode = 'key'; 

stim_switch = 0;                % Insert unpredicted stimuli?

%% mouse-specific parameters
switch mouse
    case 26
        response.auto_stop = 0;       % run stimuli until end of imaging
        total_duration = (20)*60;
        stim_switch = 1;  
        card.trigger_mode = 'out';   
		card.id = 'Dev1';
    case 30
        response.auto_stop = 0;       % run stimuli until end of imaging
        total_duration = (20)*60;
        stim_switch = 1;  
        card.trigger_mode = 'out';   
		card.id = 'Dev1';
    case 31
        response.auto_stop = 0;       % run stimuli until end of imaging
        total_duration = (20)*60;
        stim_switch = 1;  
        card.trigger_mode = 'out';   
		card.id = 'Dev1';
    case 35
        iti_dur=1;
        stim_dur=1;
        response.auto_reward = 1; 
    case 36
        iti_dur=1;
        stim_dur=1;
        response.auto_reward = 1; 
    otherwise
end

%% constant parameters
response.mode = 1;
response.feedback_fn = @psychsr_prediction_feedback;
sound.tone_amp = 0.3;
sound.tone_time = 0.5;
sound.noise_amp = 0.5; 
sound.noise_time = 1;
screen.keep = 1;
presentation.frame_rate = 60;

%% stimuli
% define your stimuli
orients = [90 -30 210];
sfs = 0.015;
tfs = 2;
contrasts = 1;

num_loops = ceil(total_duration/(iti_dur+stim_dur));
num_stimuli = num_loops*2;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = ones(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = NaN*ones(1,num_stimuli);

% Define unpredicted stimuli
if stim_switch == 1
    switch_rate = 1/30;
    num_switch = floor(num_loops*switch_rate);
    delay_vec = [round(1/switch_rate)-9:3:round(1/switch_rate)+5];
    rand_vec = mod(randperm(num_switch),5)+1;
    switch_index=[];
    for i=1:num_switch
        switch_index = [switch_index zeros(1,delay_vec(rand_vec(i))) ones(1,3)*(mod(i-1,2)+1)];
    end
else
    switch_index=zeros(1,num_loops);
end

k = 1;
o = 1;
for i = 1:num_loops                
    duration(k) = iti_dur;
    stim_type{k} = 'blank'; 
    k = k+1; 

    duration(k) = stim_dur;
    stim_type{k} = 'grating';
    if o>1
        o = o-1;
    else
        o = num_stim;
    end        
    if switch_index(i)==1 && o==2
        orientation(k) = orients(3);
    elseif switch_index(i)==2 && o==3
        orientation(k) = orients(2);
    else
        orientation(k) = orients(o);
    end
    contrast(k) = contrasts;
    spat_freq(k) = sfs;
    temp_freq(k) = tfs;
    k = k+1;
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,orientation,spat_freq,temp_freq,switch_index);

%% input parameters into psychsr
params = psychsr_zip(mouse,screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

%% save
date = clock;
folder = sprintf('C:/Dropbox/MouseAttention/behaviorData/mouse %04d',mouse);
if ~isdir(folder); mkdir(folder); end
uisave('data',sprintf('%s/%4d%02d%02d_prediction_%04d',folder,date(1),date(2),date(3),mouse));    


end