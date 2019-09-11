function data = psychsr_passive_rotgratings()
%% variable parameters
repeats = 18; 
offTime = 4; 
onTime = 4; 

orients = [90 0];
sfs = 0.012; 
tfs = 0; 
rfs = 1/8; % rotation frequency (full rotations/sec)
contrasts = 1;

total_duration = repeats*length(orients)*(offTime+onTime);

%% constant parameters
screen.keep = 0;
card.trigger_mode = 'out';   
card.id = 'Dev1';
response.mode = 0;
sound.tone_amp = 0;
presentation.frame_rate = 30;
presentation.lag = 0.00;

%% stimuli
num_stimuli = repeats*length(orients)*3;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
fade = zeros(1,num_stimuli); % 0 = no fade, 1 = fade in, -1 = fade out
rot_freq = zeros(1,num_stimuli);

k = 1;

for i = 1:repeats*length(orients)
	duration(k) = offTime;
	stim_type{k} = 'blank';
	k = k+1;
	
	duration(k) = onTime;%/2;
    stim_type{k} = 'rot_grating';
    orientation(k) = orients(1);
    rot_freq(k) = rfs*(2*mod(i,2)-1);
    spat_freq(k) = sfs;
    temp_freq(k) = 0;
    contrast(k) = contrasts;	
	k = k+1;
    
%     duration(i*3) = onTime/2;
%     stim_type{i*3} = 'rot_grating';
%     orientation(i*3) = orients(2);
%     rot_freq(i*3) = rfs*(2*mod(i,2)-1);
%     spat_freq(i*3) = sfs;
%     temp_freq(i*3) = 0;
%     contrast(i*3) = contrasts;	
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,orientation,spat_freq,temp_freq,fade,rot_freq);
stimuli.blackblank = 1; % blank screen is black instead of gray

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);
ShowCursor;

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
