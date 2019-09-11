function data = psychsr_scroll()

%% variable parameters
% cd('C:\Dropbox\MouseAttention\matlab');

% mouse = input('Mouse #: ');
% [amt time b] = psychsr_set_reward(4);
% response.reward_time = time; 
% response.reward_amt = amt;
% response.reward_cal = b;

total_duration = (60)*60;
    
clear psychsr_draw;
    
%% constant parameters    
screen.keep = 1;
card.trigger_mode = 'key';        
response.mode = 1;
response.feedback_fn = @psychsr_scroll_feedback;
sound.tone_amp = 0.5;        
sound.tone_time = 0.5;
presentation.frame_rate = 60;
    
%% stimuli
% define your stimuli	
num_stimuli = 1;

stim_type = {'grating'};
duration = total_duration;
orientation = 90;
spat_freq = 0.05;
temp_freq = 0;
contrast = 1;
sine_gratings = 0; % square wave

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,orientation,spat_freq,temp_freq,contrast,sine_gratings);       

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

%% save
% date = clock;
% folder = sprintf('../behaviorData/mouse %04d',mouse);
% if ~isdir(folder); mkdir(folder); end
% uisave('data',sprintf('%s/%4d%02d%02d_trainlick_%04d',folder,date(1),date(2),date(3),mouse));    


end