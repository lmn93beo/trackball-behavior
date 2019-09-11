function data = psychsr_train_lickdual2()

%% variable parameters
cd('C:\Dropbox\MouseAttention\matlab');

mouse = input('Mouse #: ');
reward = input('Reward (uL): ');
disp('Set reward amount manually; press enter when finished.')

total_duration = (60)*60;
    
clear psychsr_draw;

%% constant parameters    
screen.keep = 1;
screen.dual = 1;
card.trigger_mode = 'key';  
card.ai_chan = [2 3];
response.mode = 2;
response.reward_time = 0.004;
response.punish_time = 0.05;
response.feedback_fn = @psychsr_dualfeedback2;
sound.tone_amp = 0.4;        
sound.tone_time = 0.1;
sound.noise_amp = 0.5;        
sound.noise_time = 0.4;
presentation.frame_rate = 60;

%% mouse-specific parameters
nlicks = [5 10]; % min/max number of licks needed to switch screens
response.punish = 0;
response.free_hits = 20;
% response.punish_timeout = 4;

switch mouse
    case 28
        nlicks = [1 3];        
%         response.punish = 1;
%         response.free_hits = 30;
    case 29
        nlicks = [2 6];        
        response.punish = 1;
    case 34
        nlicks = [2 6];  
    otherwise
end

%% stimuli

% define your stimuli	
num_stimuli = 500;

stim_type = repmat({'grating'},1,num_stimuli);
duration = ones(1,num_stimuli);
orientation = 90*ones(1,num_stimuli);
spat_freq = 0.015*ones(1,num_stimuli);
temp_freq = 2*ones(1,num_stimuli);
contrast = mod(1:num_stimuli,2);
contrast2 = 1-mod(1:num_stimuli,2);  
stim_side = 1+mod(1:num_stimuli,2);
num_licks = randi(diff(nlicks)+1,num_stimuli,1)+nlicks(1)-1; % num licks required (between 2 and 6)

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,orientation,spat_freq,temp_freq,contrast,contrast2,stim_side,num_licks);

%% input parameters into psychsr
params = psychsr_zip(mouse,screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

%% save
date = clock;
folder = sprintf('C:/Dropbox/MouseAttention/behaviorData/mouse %04d',mouse);
if ~isdir(folder); mkdir(folder); end
uisave('data',sprintf('%s/%4d%02d%02d_trainlickdual2_%04d',folder,date(1),date(2),date(3),mouse));    


end