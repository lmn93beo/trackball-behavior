function data = gp_gammacorrect()
%% variable parameters
repeats = 10;
onTime = 10;
ncolors = 3;

contrasts = 1;
colors = linspace(0,255,ncolors);

total_duration = repeats*ncolors*onTime;
total_duration
%% constant parameters
screen.keep = 1;
card.trigger_mode = 'out';   
card.id = 'Dev3';
response.mode = 0;
sound.tone_amp = 0.5;
presentation.frame_rate = 30;
presentation.lag = 0.03;

%% stimuli
num_stimuli = repeats*ncolors;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
rect = cell(1,num_stimuli);
color = zeros(1,num_stimuli);

for i = 1:repeats*ncolors
    
	duration(i) = onTime;
    stim_type{i} = 'fillrect';    
    contrast(i) = contrasts;	
	% [xmin ymin ymin ymax] normalized to 1	
    rect{i} = [0 0 1 1];
	color(i) = colors(mod(i-1,ncolors)+1);
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,orientation,spat_freq,temp_freq,rect,color);

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
