function data = psychsr_passive_rfmapx()
%% variable parameters
repeats = 1;
offTime = 4;
onTime = 4;

sfs = 0.012;
tfs = [2 -2];	
contrasts = 1;

% vertical bars only
xwidth = 1/6;
xstart = 0:1/12:1-xwidth;
xorient = 90;

total_duration = repeats*length(xstart)*(offTime+onTime);

%% constant parameters
screen.keep = 0;
card.trigger_mode = 'out';   
card.id = 'Dev3';
response.mode = 0;
sound.tone_amp = 0;
presentation.frame_rate = 60;
presentation.lag = 0.03;

%% stimuli
num_stimuli = repeats*length(xstart)*3;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
rect = cell(1,num_stimuli);

for i = 1:repeats*length(xstart)
	duration(i*3-2) = offTime;
	stim_type{i*3-2} = 'blank';
	
	duration(i*3-1:i*3) = onTime/2;
    stim_type(i*3-1:i*3) = {'grating','grating'};
    orientation(i*3-1:i*3) = xorient;
    spat_freq(i*3-1:i*3) = sfs;
    temp_freq(i*3-1:i*3) = tfs;
    contrast(i*3-1:i*3) = contrasts;	
    % [xmin ymin xmax ymax] normalized to 1	
    rect{i*3-1} = [xstart(mod(i-1,length(xstart))+1), 0, xstart(mod(i-1,length(xstart))+1)+xwidth, 1];
	rect{i*3} = rect{i*3-1};
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,orientation,spat_freq,temp_freq,rect);
stimuli.blackblank = 1;

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

date = clock;
cd(sprintf('C:/Dropbox/MouseAttention/'));    
uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
