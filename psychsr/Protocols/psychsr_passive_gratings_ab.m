function data = psychsr_passive_gratings_ab()
psychsr_go_root();
%% variable parameters
repeats = 30; 
offTime = 4;
onTime = 4;

sfs = 0.04;
tfs = 2;	
contrasts = 1;
sine_gratings = 0;  

total_duration = repeats*(offTime+onTime);
total_duration

%% constant parameters
screen.keep = 1;
card.trigger_mode = 'out';   
card.id = 'Dev1';
response.mode = 0;
sound.tone_amp = 0;
presentation.frame_rate = 30;
presentation.lag = 0.0;

%% stimuli
num_stimuli = repeats*2;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
fade = zeros(1,num_stimuli); % 0 = no fade, 1 = fade in, -1 = fade out

randnumframes = 15;

for i = 1:repeats
	duration(i*2-1) = offTime;
	stim_type{i*2-1} = 'blank';
    spat_freq(i*2-1) = sfs;
    temp_freq(i*2-1) = tfs;
    contrast(i*2-1) = contrasts;	
	fade(i*2-1)=-1;
	
	duration(i*2) = onTime;
    stim_type{i*2} = 'rand_grating';
    spat_freq(i*2) = sfs;
    temp_freq(i*2) = tfs;
    contrast(i*2) = contrasts;	
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
