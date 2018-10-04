function data = gpe_rfsearch()
psychsr_go_root();
%% variable parameters
mousecontrol = 2; % 2: complete online control
rad = 0.64; % [0.02 0.04 0.08 0.16 0.25 0.4 Inf];
centerpos = [0.33 0.38];

repeats = 36;
offTime = 0.0;
onTime = 100;

orients = 0;
sfs = 0;% 0.04; % phase-reversing 
tfs = 2; %cycles per second
contrasts = 1;
sine_gratings = 1; 
  
total_duration = repeats*length(rad)*(offTime+onTime);
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
num_stimuli = repeats*length(rad)*2;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
pos = cell(1,num_stimuli); 
radius = zeros(1,num_stimuli); 
fade = zeros(1,num_stimuli); % 0 = no fade, 1 = fade in, -1 = fade out

for i = 1:repeats*length(rad)
	duration(i*2-1) = offTime;
	stim_type{i*2-1} = 'grating_patch';
    orientation(i*2-1) = orients;
    spat_freq(i*2-1) = sfs;
    temp_freq(i*2-1) = 0;
    contrast(i*2-1) = 0;	
    pos{i*2-1} = centerpos;
    radius(i*2-1) = rad(mod(i-1,length(rad))+1);
	
	duration(i*2) = onTime;
    stim_type{i*2} = 'grating_patch';
    orientation(i*2) = orients;
    spat_freq(i*2) = sfs;
    temp_freq(i*2) = tfs;
    contrast(i*2) = contrasts;	
    pos{i*2} = centerpos;
    radius(i*2) = rad(mod(i-1,length(rad))+1);
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,orientation,spat_freq,temp_freq,fade,sine_gratings,pos,radius,mousecontrol);
stimuli.blackblank = 0;

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);
ShowCursor;

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
