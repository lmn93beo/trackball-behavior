function data = gpi_checkerdrift(ori)
%% variable parameters
repeats = 50;
onTime = 18;

% ori = 270; % 0 = right, 180 = left, 90 = up, 270 = down

checker_v = 8; % # vertical
checker_h = 6; % # horizontal
bw = 1/checker_v*1.5; % bar width
bh = 1/checker_h*1.5; % bar height

if mod(ori,180) == 0
    rects{1} = [-bw 0 0 1];
    rects{2} = [1 0 1+bw 1];
else
    rects{1} = [0 1 1 1+bh];
    rects{2} = [0 -bh 1 0];    
end
if ori > 90
    rects = fliplr(rects);
end

tfs = 3; 
blackblank = 1;

total_duration = repeats*onTime;
total_duration
%% constant parameters
screen.keep = 1;
screen.timing_pixels = 40;
card.trigger_mode = 'out';   
card.trigger_port = 0;
card.trigger_line = 0;
card.inter_trigger_interval = 0.2;
% card.id = 'Dev3';
response.mode = 0;
sound.tone_amp = 0.2;
presentation.frame_rate = 30;
presentation.lag = 0.03;

%% stimuli
num_stimuli = repeats;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
rect1 = cell(1,num_stimuli);
rect2 = cell(1,num_stimuli);

for i = 1:repeats    
	duration(i) = onTime;
	stim_type{i} = 'checker';
    temp_freq(i) = tfs;
    rect1{i} = rects{1};
    rect2{i} = rects{2};
    
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,temp_freq,rect1,rect2,blackblank,checker_v,checker_h);

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
