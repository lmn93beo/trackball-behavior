function data = gpi_ori2()
psychsr_go_root();
%% variable parameters
repeats = 8;
offTime = 2;
onTime = 4;

rad = Inf; % 2P3: 0.1 ~= 7 deg
centerpos = [0.66 0.65]; % x y from top left
mousecontrol = 0;

orients =  0:20:359;%0:30:359;
sfs = 0.04; %cycles per degree
tfs = 2; %cycles per second
contrasts = 1;
sine_gratings = 1; % square wave

order = randomizeStims(mfilename('fullpath'),length(orients),repeats);

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
pos = cell(1,num_stimuli); 
radius = zeros(1,num_stimuli); 

for i = 1:repeats*length(orients)
	duration(i*2-1) = offTime;
	stim_type{i*2-1} = 'blank';
	
	duration(i*2) = onTime;
    stim_type{i*2} = 'grating_patch';
    orientation(i*2) = orients(order(i));
    spat_freq(i*2) = sfs;
    temp_freq(i*2) = tfs;
    contrast(i*2) = contrasts;	
	pos{i*2} = centerpos;
	radius(i*2) = rad;
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,orientation,spat_freq,temp_freq,fade,pos,radius,sine_gratings,mousecontrol);
stimuli.blackblank = 0;

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);
ShowCursor;

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
