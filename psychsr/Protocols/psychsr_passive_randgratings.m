function data = psychsr_passive_randgratings()
%% variable parameters
repeats = 60;
offTime = 6;
onTime = 4;

sfs = 0.04;
tfs = 2;	
contrasts = 1;

% Define Rect
num_rect=1;
% [xmin ymin xmax ymax] normalized to 1	
rect_template{1}=[0 0 1 1];

total_duration = repeats*num_rect*(offTime+onTime);

%% constant parameters
screen.keep = 0;
card.trigger_mode = 'out';   
card.id = 'Dev3';
response.mode = 0;
sound.tone_amp = 0;
presentation.frame_rate = 30;
presentation.lag = 0.03;

%% stimuli
num_stimuli = repeats*num_rect*2;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
rect = cell(1,num_stimuli);
randnumframes = 15;

for i = 1:num_stimuli
	if mod(i-1,2)==0
		duration(i) = offTime;
		stim_type{i} = 'blank';
	elseif mod(i-1,2)==1
		duration(i) = onTime;
		stim_type(i) = {'rand_grating'};
		orientation(i) = 0;
		spat_freq(i) = sfs;
		temp_freq(i) = tfs;
		contrast(i) = contrasts;
		rect{i} = rect_template{mod(i/2-1,num_rect)+1};
	end
end


stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,orientation,spat_freq,temp_freq,rect,randnumframes);
stimuli.blackblank = 0;

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
