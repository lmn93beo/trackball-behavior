function data = gpi_dots()
psychsr_go_root();
%% variable parameters
repeats = 15;
offTime = 2;    
onTime = 2;

rad = Inf;%0.25; % 2P3: 0.1 ~= 7 deg
centerpos = [0.52 0.67]; % x y from top left
mousecontrol = 0;

orients =  [0 180]; %0:30:359;%0:30:359;
tfs = 50; % degrees per second
contrasts = 0.8;
sine_gratings = 1; % square wave


order = repmat(1:length(orients),1,repeats);
% randomizeStims(mfilename('fullpath'),length(orients),repeats);

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
dot_size = 40*ones(1,num_stimuli);

for i = 1:repeats*length(orients)
	duration(i*2-1) = offTime;
	stim_type{i*2-1} = 'blank';
	
	duration(i*2) = onTime;
    stim_type{i*2} = 'dots';
    orientation(i*2) = orients(order(i));
    temp_freq(i*2) = tfs;
    contrast(i*2) = contrasts;	
	pos{i*2} = centerpos;
	radius(i*2) = rad;
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,orientation,spat_freq,temp_freq,fade,pos,radius,sine_gratings,mousecontrol,dot_size);
stimuli.blackblank = 1;

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);
ShowCursor;

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
