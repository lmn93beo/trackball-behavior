function data = psychsr_passive_orisf()
psychsr_go_root();
%% variable parameters
repeats = 2;
offTime = 4;
onTime = 4;

order = [27,12,24,31,33,23,19,1,29,8,10,35,13,20,14,2,36,37,32,15,11,22,17,16,25,3,30,9,7,26,34,28,21,6,18,5,4];

oris = [0:30:359,        0:30:359,        0, 90:120:359,    90:120:359,    90:120:359,       90:120:359];
sfs = [0.02*ones(1,12), 0.08*ones(1,12),  0, 0.01*ones(1,3), 0.04*ones(1,3), 0.16*ones(1,3), 0.32*ones(1,3)];

tfs = 2; %cycles per second
contrasts = 1;
sine_gratings = 1; % square wave
  
total_duration = repeats*length(oris)*(offTime+onTime);
disp(total_duration)
%% constant parameters 
screen.keep = 1;
card.trigger_mode = 'out';   
card.id = 'Dev1';
response.mode = 0;
% response.mode = 1;
% response.punish_time = 0.2;
% response.feedback_fn = @psychsr_punish_feedback;
sound.tone_amp = 0.5;
presentation.frame_rate = 30;
presentation.lag = -0.011;

%% stimuli
num_stimuli = repeats*length(oris)*2;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
fade = zeros(1,num_stimuli); % 0 = no fade, 1 = fade in, -1 = fade out

for i = 1:repeats*length(oris)
	idx = mod(i-1,length(order))+1;
    
    duration(i*2-1) = offTime;
	stim_type{i*2-1} = 'blank';
	
	duration(i*2) = onTime;
    stim_type{i*2} = 'grating';
    orientation(i*2) = oris(order(idx));
    spat_freq(i*2) = sfs(order(idx));
    temp_freq(i*2) = tfs;
    contrast(i*2) = contrasts;	
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,orientation,spat_freq,temp_freq,fade,sine_gratings);
stimuli.blackblank = 0;

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);
ShowCursor;

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
