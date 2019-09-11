function data = psychsr_ori_gp_WFscope()
%% variable parameters

repeats = 1;
offTime = 0.5;
onTime = 0.5;

sfs = [0.04];
tfs = [2];	
ori = 0.01:60:359; %[0.01 60 120 180 240 300];

contrasts = 1;
frameRate = 1;

% trigger camera INSTEAD of prairie
card.trigger_port = 0;
card.trigger_line = 0;
card.inter_trigger_interval = 1/frameRate;


% Define Rect

 rect_template{1}=[0 0 1 1]; % fullscreen
% rect_template{1}=[0.05 0.5 0.35 0.9]; % left
% rect_template{2}=[0.55 0.5 0.85 0.9]; % right
% rect_template{3}=[0.3 0.1 0.6 0.5]; % top
% for x = 1:3
%     for y = 1:3
%         rect_template{(y-1)*3+x} = [(x-1)*0.33 1-y*0.33 x*0.33 1-(y-1)*0.33];
%     end
% end

num_rect = length(rect_template);

order = randomizeStims(mfilename('fullpath'),length(ori),repeats);

total_duration = repeats*length(ori)*(offTime+onTime)

%% constant parameters
screen.keep = 1;
card.trigger_mode = 'out';   
card.id = 'Dev1';
response.mode = 0;
sound.tone_amp = 0.5;
presentation.frame_rate = 30;
presentation.lag = 0.0;

%% stimuli
num_stimuli = repeats*length(ori)*2;

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
		orientation(i) = ori(order(i/2));        
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
data = psychsr_WFscope(params);

