function data = psychsr_passive_images()
%% variable parameters
folder = psychsr_go_root();

repeats = 5; % # of repeats per image
offTime = 0;
onTime = 1;

% make mfile list
indexVector=[1:25 2:2:24 25:-2:1 25:-1:1];
for i=1:75
    mfiles{i} = [folder '\movies\image' num2str(indexVector(i)) '.mat'];
end
contrasts = 1;

total_duration = repeats*length(mfiles)*(offTime+onTime);

%% constant parameters
screen.keep = 0;			% does not keep window open after program finishes
card.trigger_mode = 'out';  % starts automatically, triggers imaging
card.id = 'Dev1';
response.mode = 0;		
sound.tone_amp = 0;
presentation.frame_rate = 30;
% presentation.lag = 0.03;

%% stimuli
num_stimuli = repeats*length(mfiles)*(sign(onTime)+sign(offTime));

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
movie_file = cell(1,num_stimuli);

for i = 1:num_stimuli
    movie_file{i} = '';
end

for i = 1:repeats*length(mfiles)
    if offTime>1
        duration(i*2-1) = offTime;
        stim_type{i*2-1} = 'blank';
        contrast(i*2-1) = contrasts;
        
        duration(i*2) = onTime;
        stim_type{i*2} = 'image';
        movie_file{i*2} = mfiles{mod(i-1,length(mfiles))+1};
        contrast(i*2) = contrasts;
    else
        duration(i) = onTime;
        stim_type{i} = 'image';
        movie_file{i} = mfiles{mod(i-1,length(mfiles))+1};
        contrast(i) = contrasts;
    end
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,movie_file);
stimuli.blackblank = 0;

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
