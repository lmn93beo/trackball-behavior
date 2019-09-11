function data = gpi_randori_laser()
% set up for laser on 2P3

psychsr_go_root();
%% variable parameters
repeats = 50;
offTime = input('Off time: ');
onTime = 2;

orients = [0 90 45 135];
sfs = 0.04;%[0 (0.01)*2.^(0:6)]; %cycles per degree
tfs = 2; %cycles per second
contrasts = 1;
sine_gratings = 1; % square wave

order = ones(1,repeats); %repmat([1:length(sfs) length(sfs):-1:1],1,repeats/2);
total_duration = repeats*length(sfs)*(offTime+onTime);
total_duration

%% laser parameters
laser_every_n = 1;
response.laser_amp = input('Laser voltage: ');%3.1;%3.1;
response.laser_time = 2.2;
response.laser_seq = 2;
response.laser_onset = -0.1;
response.feedback_fn = @gpi_randori_laser_feedback;

%% constant parameters
screen.keep = 1;
card.trigger_mode = 'out-hold';   
card.trigger_port = 1;
card.trigger_line = 1;

card.dio_ports = [1 2 0 2]; % [0]
card.dio_lines = [0 4 1 5]; % [0]

card.id = 'Dev3';
response.mode = 7;
sound.tone_amp = 0.2;
presentation.frame_rate = 30;
presentation.lag = -0.011;

%% stimuli
noris = length(orients);
num_stimuli = repeats*(noris+1)*length(sfs);

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
laser_on = zeros(1,num_stimuli);
fade = zeros(1,num_stimuli); % 0 = no fade, 1 = fade in, -1 = fade out

for i = 1:repeats*length(sfs)
    k = (noris+1)*(i-1)+1;
	duration(k) = offTime;
	stim_type{k} = 'blank';
	
	duration(k+1:k+noris) = onTime/noris;
    stim_type(k+1:k+noris) = repmat({'grating'},1,noris);
    orientation(k+1:k+noris) = orients;
    spat_freq(k+1:k+noris) = sfs(order(i));
    temp_freq(k+1:k+noris) = tfs;
    contrast(k+1:k+noris) = contrasts;	
    
    laser_on(k:k+noris) = (mod(i,laser_every_n)==0);
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,orientation,spat_freq,temp_freq,fade,sine_gratings,laser_on);
stimuli.blackblank = 0;

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);
ShowCursor;

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
