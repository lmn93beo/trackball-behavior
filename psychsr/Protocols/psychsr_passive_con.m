function data = psychsr_passive_con()
psychsr_go_root();
%% variable parameters
repeats = 3;
offTime = 4;
onTime = 4;

orients = 0;%[0 180 90 270 45 225 135 315];
sfs = 0.02;%(0.01)*2.^(0:5); %cycles per degree
tfs = 2; %cycles per second
contrasts = 2.^(-5:0);
sine_gratings = 0; % square wave

total_duration = repeats*length(contrasts)*(offTime+onTime);

%% constant parameters
screen.keep = 1;
card.trigger_mode = 'out';   
card.id = 'Dev1';
response.mode = 0;
sound.tone_amp = 0.2;
presentation.frame_rate = 30;
presentation.lag = 0.0;

%% stimuli
noris = length(orients);
num_stimuli = repeats*(noris+1)*length(contrasts);

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
fade = zeros(1,num_stimuli); % 0 = no fade, 1 = fade in, -1 = fade out

for i = 1:repeats*length(contrasts)
    k = (noris+1)*(i-1)+1;
	duration(k) = offTime;
	stim_type{k} = 'blank';
	
	duration(k+1:k+noris) = onTime/noris;
    stim_type(k+1:k+noris) = repmat({'grating'},1,noris);
    orientation(k+1:k+noris) = orients;
    spat_freq(k+1:k+noris) = sfs;
    temp_freq(k+1:k+noris) = tfs;
    contrast(k+1:k+noris) = contrasts(mod(i-1,length(contrasts))+1);	
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,orientation,spat_freq,temp_freq,fade,sine_gratings);
stimuli.blackblank = 1;

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);
ShowCursor;

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
