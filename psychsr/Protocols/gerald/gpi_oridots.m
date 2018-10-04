function data = gpi_oridots()
psychsr_go_root();
%% variable parameters
repeats = 10;
offTime = 2;    
onTime = 2;

orients = mod(180:-30:-179,360); %0:30:359;
contrasts = 1; % coherence

dot_color = [0 0 0]; blackblank = 0; % black on gray

tfs = 100; % degrees per second
dsizes = 60; % size in pixels
ddens = 0.2; % density

order = repmat(1:length(orients),1,repeats);
% randomizeStims(mfilename('fullpath'),length(orients),repeats);

total_duration = repeats*length(orients)*(offTime+onTime);
disp(total_duration)
%% constant parameters 
screen.keep = 1;
card.trigger_mode = 'out';   
card.id = 'Dev1';
response.mode = 0;
% response.mode = 1;
% response.punish_time = 0.2;
% response.feedback_fn = @psychsr_punish_feedback;
sound.tone_amp = 0.5;
presentation.frame_rate = 30;
presentation.lag = -0.011;

%% stimuli
num_stimuli = repeats*length(orients)*2;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
dot_size = zeros(1,num_stimuli);
dot_density = zeros(1,num_stimuli);

for i = 1:repeats*length(orients)
	duration(i*2-1) = offTime;
	stim_type{i*2-1} = 'blank';
	
	duration(i*2) = onTime;
    stim_type{i*2} = 'dots';
    orientation(i*2) = orients(order(i));
    temp_freq(i*2) = tfs;
    dot_size(i*2) = dsizes;
    dot_density(i*2) = ddens;
    contrast(i*2) = contrasts;	
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,...
    orientation,spat_freq,temp_freq,blackblank,dot_size,dot_density,dot_color);

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);
ShowCursor;

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
