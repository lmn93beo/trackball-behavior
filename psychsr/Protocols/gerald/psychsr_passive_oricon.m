% unfinished
function data = psychsr_passive_oricon()
psychsr_go_root();
%% variable parameters
repeats = 1;
offTime = 4;
onTime = 4;

order = [36,12,2,25,11,29,31,1,26,30,28,21,10,24,35,5,17,23,6,13,20,3,27,34,33,16,4,14,15,8,7,32,19,22,9,18];

oris = [0:30:359,        0:30:359,        90:120:359,    90:120:359,    90:120:359     90:120:359];
contrasts = [ones(1,12), .125*ones(1,12), .50*ones(1,3),  .25*ones(1,3),  .0625*ones(1,3)  .03125*ones(1,3)];
sfs = 0.04;
%sfs = [0.02*ones(1,12), 0.08*ones(1,12),  0, 0.01*ones(1,3), 0.04*ones(1,3), 0.16*ones(1,3), 0.32*ones(1,3)];

tfs = 2; %cycles per second
sine_gratings = 1; % square wave
  
total_duration = repeats*length(oris)*(offTime+onTime);
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
num_stimuli = repeats*length(oris)*2;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
fade = zeros(1,num_stimuli); % 0 = no fade, 1 = fade in, -1 = fade out

for i = 1:repeats*length(oris)
	idx = mod(i-1,length(order))+1;
    
    duration(i*2-1) = offTime;
	stim_type{i*2-1} = 'blank';
	
	duration(i*2) = onTime;
    stim_type{i*2} = 'grating';
    orientation(i*2) = oris(order(idx));
    spat_freq(i*2) = sfs;
    temp_freq(i*2) = tfs;
    contrast(i*2) = contrasts(order(idx));	
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,orientation,spat_freq,temp_freq,fade,sine_gratings);
stimuli.blackblank = 0;

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);
ShowCursor;

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
