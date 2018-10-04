function data = psychsr_passive_rand()
psychsr_go_root();
%% variable parameters
repeats = 4;
offTime = 4;
onTime = 4;
nrand = 8;

orients = 0:20:359;
sfs = (0.01)*2.^(0:5); %cycles per degree
tfs = 1:3; %cycles per second
contrasts = 1;
sine_gratings = 0; % square wave

total_duration = repeats*(offTime+onTime); 
total_duration

%% constant parameters
screen.keep = 1;
card.trigger_mode = 'out';   
card.id = 'Dev1';
response.mode = 0;
sound.tone_amp = 0.2;
presentation.frame_rate = 30;
presentation.lag = 0.0;

%% stimuli
num_stimuli = repeats*(nrand+1);

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
fade = zeros(1,num_stimuli); % 0 = no fade, 1 = fade in, -1 = fade out

for i = 1:repeats
    k = (nrand+1)*(i-1)+1;
	duration(k) = offTime;
	stim_type{k} = 'blank';
	
	duration(k+1:k+nrand) = onTime/nrand;
    stim_type(k+1:k+nrand) = repmat({'grating'},1,nrand);
    o = repmat(randperm(length(orients)),1,ceil(nrand/length(orients)));
    orientation(k+1:k+nrand) = orients(o(1:nrand));
    s = repmat(randperm(length(sfs)),1,ceil(nrand/length(sfs)));
    spat_freq(k+1:k+nrand) = sfs(s(1:nrand));
    t = repmat(randperm(length(tfs)),1,ceil(nrand/length(tfs)));
    temp_freq(k+1:k+nrand) = tfs(t(1:nrand));
    contrast(k+1:k+nrand) = contrasts;	
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,orientation,spat_freq,temp_freq,fade,sine_gratings);
stimuli.blackblank = 0;

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);
ShowCursor;

%% save
date = clock;
folder = '../behaviorData';
if ~isdir(folder); mkdir(folder); end
uisave('data',sprintf('%s/%4d%02d%02d_passiverand',folder,date(1),date(2),date(3)));

