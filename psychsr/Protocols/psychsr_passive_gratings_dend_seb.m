function data = psychsr_passive_gratings_dend_seb()
psychsr_go_root();
%% variable parameters
repeats = 8; %16
offTime = 2; % 0.5
onTime = 2; %1

orients =  0:20:359;%0:20:359;
sfs = 0.05; %cycles per degree
tfs = 2; %cycles per second
contrasts = 1;
sine_gratings = 0; % square wave
  
total_duration = repeats*length(orients)*(offTime+onTime);
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
num_stimuli = repeats*length(orients)*2;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
fade = zeros(1,num_stimuli); % 0 = no fade, 1 = fade in, -1 = fade out

for i = 1:repeats*length(orients)
	duration(i*2-1) = offTime;
	stim_type{i*2-1} = 'blank';
	orientation(i*2-1) = orients(mod(i-2,length(orients))+1);
    spat_freq(i*2-1) = sfs;
    temp_freq(i*2-1) = tfs;
    contrast(i*2-1) = contrasts;	
	fade(i*2-1)=-1;
	
	duration(i*2) = onTime;
    stim_type{i*2} = 'grating';
    orientation(i*2) = orients(mod(i-1,length(orients))+1);
    spat_freq(i*2) = sfs;
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
