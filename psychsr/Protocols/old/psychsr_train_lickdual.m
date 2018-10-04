function data = psychsr_train_lickdual()

%% variable parameters
cd('C:\Dropbox\MouseAttention\matlab');

mouse = input('Mouse #: ');
reward = input('Reward (uL): ');
disp('Set reward amount manually; press enter when finished.')

total_duration = (60)*60;
    
clear psychsr_draw;
    
%% constant parameters    
screen.keep = 1;
% screen.dual = 1;
card.trigger_mode = 'key';  
card.ai_chan = [2 3];
response.mode = 2;
response.reward_time = 0.004;
response.punish_time = 0.004;
response.feedback_fn = @psychsr_dualfeedback;
sound.tone_amp = 0.5;        
sound.tone_time = 0.1;
presentation.frame_rate = 60;
response.lickside = 0;
    
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
date = clock;
folder = sprintf('C:/Dropbox/MouseAttention/behaviorData/mouse %04d',mouse);
if ~isdir(folder); mkdir(folder); end
uisave('data',sprintf('%s/%4d%02d%02d_trainlickdual_%04d',folder,date(1),date(2),date(3),mouse));    


end