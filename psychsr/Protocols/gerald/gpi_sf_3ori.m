function data = gpi_sf_3ori()
psychsr_go_root();
%% variable parameters

mousecontrol = 0; % 2: complete online control
rad = 0.08; %[0.02 0.04 0.08 0.16 0.25 0.4 Inf];
% 2P3: 0.1 ~= 7 deg
centerpos = [0.47 0.54]; % x y from top left

repeats = 5;
offTime = 4;
onTime = 2;

% orients = 0:20:359;
orients = 90:120:359;
% orients = [200 220 240];%90:120:359;%[220 240 260];
% sfs = (0.01)*2.^(0:5); %cycles per degree
sfs = [0 (0.01)*2.^(0:5)];
% sfs = (0.01)*2.^(3:6); %cycles per degree

tfs = 2; %cycles per second
contrasts = 1;
sine_gratings = 0; % square wave

order = randomizeStims(mfilename('fullpath'),length(sfs)*length(orients),repeats);

total_duration = repeats*length(orients)*length(sfs)*(offTime+onTime);
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
num_stimuli = repeats*length(orients)*length(contrasts)*2;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
fade = zeros(1,num_stimuli); % 0 = no fade, 1 = fade in, -1 = fade out
pos = cell(1,num_stimuli); 
radius = zeros(1,num_stimuli); 

k = 1;
for i = 1:numel(order)
%     for j = 1:length(orients)
        duration(k) = offTime;
        stim_type{k} = 'blank';
        k = k+1;

        duration(k) = onTime;
        stim_type{k} = 'grating_patch';
        orientation(k) = orients(mod(order(i)-1,length(orients))+1);
        spat_freq(k) = sfs(ceil(order(i)/length(orients)));
        temp_freq(k) = tfs;
        contrast(k) = contrasts;
		pos{k} = centerpos;
		radius(k) = rad;
        k = k+1;
%     end
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,orientation,spat_freq,temp_freq,fade,sine_gratings,radius,pos,mousecontrol);
stimuli.blackblank = 0;

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);
ShowCursor;

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
