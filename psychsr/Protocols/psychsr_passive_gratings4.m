function data = psychsr_passive_gratings4()
%% variable parameters
repeats = 3;
offTime = 4;
onTime = 4;

% orients = 0:20:340;
orients = 0;
sfs = 0.012;
tfs = 2;	
contrasts = [0.01 0.04 0.08 0.16 0.64 1];

total_duration = repeats*length(contrasts)*(offTime+onTime);

%% constant parameters
screen.keep = 0;
card.trigger_mode = 'out';   
card.id = 'Dev1';
response.mode = 0;
sound.tone_amp = 0;
presentation.frame_rate = 30;
presentation.lag = 0.0;

%% stimuli
num_stimuli = repeats*length(contrasts)*2;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
fade = zeros(1,num_stimuli); % 0 = no fade, 1 = fade in, -1 = fade out

for i = 1:repeats*length(contrasts)
	duration(i*2-1) = offTime;
	stim_type{i*2-1} = 'blank';
	orientation(i*2-1) = orients;
    spat_freq(i*2-1) = sfs;
    temp_freq(i*2-1) = tfs;
    contrast(i*2-1) = contrasts(mod(i-1,length(contrasts))+1);	
	fade(i*2-1)=-1;
	
	duration(i*2) = onTime;
    stim_type{i*2} = 'grating';
    orientation(i*2) = orients;
    spat_freq(i*2) = sfs;
    temp_freq(i*2) = tfs;
    contrast(i*2) = contrasts(mod(i-1,length(contrasts))+1);	
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,orientation,spat_freq,temp_freq,fade);
stimuli.blackblank = 1;

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);
ShowCursor;

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
