function data = psychsr_predictclock()
% display drifting gratings successively at different orientations
% reward automatically at end of cardinal directions but not diagonal

% stimulus parameters
iti_dur=2;
stim_dur=2;

mouse = input('Mouse #: ');
reward = input('Reward (uL): ');
disp('Set reward amount manually; press enter when finished.'); pause;

response.reward_time = 0.004;
response.reward_amt = reward;

response.grace_period = 0.25; % licks during first 250ms dont count
response.punish_timeout = 0;
response.punish_time = 0.1;
response.auto_reward = 0;
    
%% constant parameters
total_duration = (75)*60;
card.trigger_mode = 'key';   
response.mode = 1;
response.feedback_fn = @psychsr_predictclock_feedback;
response.auto_stop = 1;
sound.tone_amp = 0.1;
sound.tone_time = 0.5;
sound.noise_amp = 0.5; 
sound.noise_time = 1;
screen.keep = 1;
presentation.frame_rate = 60;

%% stimuli
% define your stimuli
orients = mod((90:45:450)+179,360)-179;
orients(orients == 0) = 0.01; % bug at 0 degrees
sfs = 0.015;
tfs = 2;
contrasts = 1;

% image names
num_loops = ceil(total_duration/(iti_dur+stim_dur));
num_stimuli = num_loops*2;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = ones(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = NaN*ones(1,num_stimuli);

k = 1;
for i = 1:num_loops                
    duration(k) = iti_dur;
    stim_type{k} = 'blank'; 
    k = k+1; 

    duration(k) = stim_dur;
    stim_type{k} = 'grating';
    orientation(k) = orients(mod(i-1,8)+1);
    contrast(k) = contrasts;
    spat_freq(k) = sfs;
    temp_freq(k) = tfs;
    k = k+1;
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,orientation,spat_freq,temp_freq);

%% input parameters into psychsr
params = psychsr_zip(mouse,screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

%% save
date = clock;
folder = sprintf('C:/Dropbox/MouseAttention/behaviorData/mouse %04d',mouse);
if ~isdir(folder); mkdir(folder); end
uisave('data',sprintf('%s/%4d%02d%02d_predictclock_%04d',folder,date(1),date(2),date(3),mouse));    


end