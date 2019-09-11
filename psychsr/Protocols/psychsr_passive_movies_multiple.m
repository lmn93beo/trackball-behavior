function data = psychsr_passive_movies_multiple()
%% variable parameters
folder = psychsr_go_root();

repeats = 20; % # of repeats per image
offTime = 0;
onTime = 3;

crop_movie = 2;
mousecontrol = 0;
% make mfile list
indexVector=[13,43,49,55,102,103,162,167,169,178,184,186,187,188];
for i=1:length(indexVector)
    mfiles{i} = [folder '\movies\mov' sprintf('%03d',indexVector(i)) '.mat'];
end

rad = 0.3;
contrasts = 1;
centerpos = [0.64 0.49]; 

total_duration = repeats*length(mfiles)*(offTime+onTime);

%% constant parameters
screen.keep = 1;			% does keep window open after program finishes
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
pos = cell(1,num_stimuli);
radius = zeros(1,num_stimuli);

for i = 1:num_stimuli
    movie_file{i} = '';
end

for i = 1:repeats*length(mfiles)
    if offTime>0
        duration(i*2-1) = offTime;
        stim_type{i*2-1} = 'blank';
        contrast(i*2-1) = contrasts;
        
        duration(i*2) = onTime;
        stim_type{i*2} = 'movie_patch';
        movie_file{i*2} = mfiles{mod(i-1,length(mfiles))+1};
        contrast(i*2) = contrasts;
    else
        duration(i) = onTime;
        stim_type{i} = 'movie_patch';
        movie_file{i} = mfiles{mod(i-1,length(mfiles))+1};
        contrast(i) = contrasts;
		pos{i} = centerpos;
		radius(i) = Inf;
    end
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,movie_file,crop_movie,pos,radius,mousecontrol);
stimuli.blackblank = 0;

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
