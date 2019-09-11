function data = psychsr_passive_topomap_WFscope()
%% variable parameters

repeats = 20;
offTime = 3;
onTime = 1;

sfs = [0.09];
tfs = [2];	
ori = repmat([90*ones(1,7) 0.01*ones(1,7)],1,repeats);

contrasts = 1;
frameRate = 1;

% trigger camera INSTEAD of prairie
card.trigger_port = 0;
card.trigger_line = 0;
card.inter_trigger_interval = 1/frameRate;


% Define Rect
% for i = 1:10
% rect_template{i} = [0 0 1 1]; % fullscreen
% end

% rect_template{1}=[0.05 0.5 0.35 0.9]; % left
% rect_template{2}=[0.55 0.5 0.85 0.9]; % right
% rect_template{3}=[0.3 0.1 0.6 0.5]; % top

%%% Make drifting bars in each dimension (X/Y)
sizebar = [0 0.2005 0.3370 0.4480 0.5520 0.6630 0.7995 1.0000]; % define bar interval
screen_dim_x = 33.7;
screen_dim_y = 26.7;
sizebar_x = sizebar*(screen_dim_y/screen_dim_x)+(1-screen_dim_y/screen_dim_x)/2;
sizebar_y = sizebar(end:-1:1);
for x = 1:7
    rect_template{x} = [sizebar_x(x) 0 sizebar_x(x+1) 1];
end
for y = 1:7
    rect_template{y+7} = [0 sizebar_y(y+1) 1 sizebar_y(y)];
end

num_rect = length(rect_template);

total_duration = repeats*num_rect*(offTime+onTime);

%% constant parameters
screen.keep = 0;
card.trigger_mode = 'out';   
card.id = 'Dev1';
response.mode = 0;
sound.tone_amp = 0.25;%0.5;
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
  		stim_type(i) = {'grating'};
  		orientation(i) = ori(i/2);
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
data = psychsr_WFscope(params);

