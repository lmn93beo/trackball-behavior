function data = psychsr_passive_topomap()
%% variable parameters
repeats = 30;
offTime = 4;
onTime = 4;

sfs = [0.03 0.055 0.08];
tfs = [2 2 2];	
ori = [0.01 60 120 180 240 300];

contrasts = 1;
frameRate = 1;

% trigger camera INSTEAD of prairie
card.trigger_port = 0;
card.trigger_line = 0;
card.inter_trigger_interval = 1/frameRate;

% Define Rect
num_rect=1; % [xmin ymin xmax ymax] normalized to 1	

rect_template{1}=[0.05 0.5 0.35 0.9]; % left
% rect_template{1}=[0.55 0.5 0.85 0.9]; % right
% rect_template{1}=[0.3 0.1 0.6 0.5]; % top


total_duration = repeats*num_rect*(offTime+onTime);

%% constant parameters
screen.keep = 1;
card.trigger_mode = 'out';   
card.id = 'Dev1';
response.mode = 0;
sound.tone_amp = 0.5;
presentation.frame_rate = 30;
presentation.lag = 0.0;

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
% 		orientation(i) = ori(randi(length(ori)));
        speed = floor(rem((i-1)/(2*num_rect),length(sfs))+1);
		spat_freq(i) = sfs(speed);
		temp_freq(i) = tfs(speed);
		contrast(i) = contrasts;
		rect{i} = rect_template{mod(i/2-1,num_rect)+1};
	end
end


stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,orientation,spat_freq,temp_freq,rect,randnumframes);
stimuli.blackblank = 1;

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
