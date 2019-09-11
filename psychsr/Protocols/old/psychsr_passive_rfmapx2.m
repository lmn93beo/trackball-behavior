function data = psychsr_passive_rfmapx2()
%% variable parameters
repeats = 1;
offTime = 4;
onTime = 4;

sfs = 0.02;
tfs = 0;	
contrasts = 1;

% vertical bars only
xwidth = 1/6;
xstart = 0:1/12:1-xwidth;
norients = 16;
nrepeats = 4;
xorient = 0:180/norients:180-180/norients;
xorient = xorient(randperm(norients));
xorient = reshape(xorient'*ones(1,nrepeats),[1 nrepeats*norients]);
norients = norients*nrepeats;

total_duration = repeats*length(xstart)*(offTime+onTime);

%% constant parameters
screen.keep = 0;
% card.trigger_mode = 'out';   
card.id = 'Dev3';
response.mode = 0;
sound.tone_amp = 0;
presentation.frame_rate = 60;
presentation.lag = 0.03;

%% stimuli
num_stimuli = repeats*length(xstart)*(1+norients);

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
rect = cell(1,num_stimuli);

for i = 1:repeats*length(xstart)
	duration(i+norients*(i-1)) = offTime;
	stim_type{i+norients*(i-1)} = 'blank';
	
    for j = 1:norients        
        duration(i+norients*(i-1)+j) = onTime/norients;
        stim_type{i+norients*(i-1)+j} = 'grating';
        orientation(i+norients*(i-1)+j) = xorient(j);
        spat_freq(i+norients*(i-1)+j) = sfs;
        temp_freq(i+norients*(i-1)+j) = tfs;
        contrast(i+norients*(i-1)+j) = contrasts;	
        % [xmin ymin xmax ymax] normalized to 1	
        rect{i+norients*(i-1)+j} = [xstart(mod(i-1,length(xstart))+1), 0, xstart(mod(i-1,length(xstart))+1)+xwidth, 1];
    end
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,orientation,spat_freq,temp_freq,rect);
stimuli.blackblank = 1;

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

date = clock;
cd(sprintf('C:/Dropbox/MouseAttention/'));    
uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
