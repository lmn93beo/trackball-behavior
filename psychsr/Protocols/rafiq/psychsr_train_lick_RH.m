function data = psychsr_train_lick_RH(mouse)

%% variable parameters
% cd('C:\Dropbox\MouseAttention\matlab');
if nargin < 1
mouse = input('Mouse #: ');
end
[amt time b] = psychsr_set_reward(6);
response.reward_time = time; 
response.reward_amt = amt;
response.reward_cal = b;

total_duration = (60)*60;
    
clear psychsr_draw;
    
%% constant parameters    
screen.keep = 1;
card.trigger_mode = 'key';        
response.mode = 1;
sound.tone_amp = 0.5;        
sound.tone_time = 0.5;
presentation.frame_rate = 60;
    
%% stimuli
% define your stimuli	
num_stimuli = 1;

stim_type = {'blank'};
duration = total_duration;
orientation = NaN;
spat_freq = NaN;
temp_freq = NaN;
contrast = NaN;

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,orientation,spat_freq,temp_freq,contrast);       

%% input parameters into psychsr
params = psychsr_zip(mouse,screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

%% save
if nargin<1
date = clock;
folder = sprintf('C:\Dropbox\Rafiq\behaviorData\mouse %04d',mouse);
if ~isdir(folder); mkdir(folder); end
uisave('data',sprintf('%s/%4d%02d%02d_trainlick_%04d',folder,date(1),date(2),date(3),mouse));    
end

end