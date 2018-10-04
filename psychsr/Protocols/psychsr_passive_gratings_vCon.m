function data = psychsr_passive_gratings_vCon()
%% variable parameters
repeats = 8;
offTime = 4;
onTime = 4;

sfs = 0.04;
tfs = 2;	
contrasts = logspace(0,2,10)/100;
sine_gratings = 0;  

total_duration = repeats*length(contrasts)*(offTime+onTime);

%% constant parameters
screen.keep = 1;
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
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
fade = zeros(1,num_stimuli); % 0 = no fade, 1 = fade in, -1 = fade out

randnumframes = 15;

for i = 1:repeats*length(contrasts)
    contrast_idx = rem(i-1,length(contrasts))+1;
    
	duration(i*2-1) = offTime;
	stim_type{i*2-1} = 'blank';
    spat_freq(i*2-1) = sfs;
    temp_freq(i*2-1) = tfs;
    contrast(i*2-1) = contrasts(contrast_idx);	
	fade(i*2-1)=-1;
	
	duration(i*2) = onTime;
    stim_type{i*2} = 'rand_grating';
    spat_freq(i*2) = sfs;
    temp_freq(i*2) = tfs;
    contrast(i*2) = contrasts(contrast_idx);	
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,spat_freq,temp_freq,fade,sine_gratings,randnumframes);
stimuli.blackblank = 0;

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);
ShowCursor;

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
