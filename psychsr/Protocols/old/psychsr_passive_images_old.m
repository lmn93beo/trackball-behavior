function data = psychsr_passive_images_new()
%% variable parameters
repeats = 20; % # of repeats per image
offTime = 4.5;
onTime = 1.5;

mfiles = {'C:\Users\Surlab\Dropbox\MouseAttention\Matlab\movies\antelope_image.mat',...
    'C:\Users\Surlab\Dropbox\MouseAttention\Matlab\movies\penguins_image.mat',...
    'C:\Users\Surlab\Dropbox\MouseAttention\Matlab\movies\meercats_image.mat'}; %4.47s long at 60Hz
contrasts = 1;

total_duration = repeats*length(mfiles)*(offTime+onTime);

%% constant parameters
screen.keep = 0;			% does not keep window open after program finishes
card.trigger_mode = 'out';  % starts automatically, triggers imaging
card.id = 'Dev1';
response.mode = 0;		
sound.tone_amp = 0;
presentation.frame_rate = 30;
presentation.lag = 0.03;

%% stimuli
num_stimuli = repeats*length(mfiles)*2;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
movie_file = cell(1,num_stimuli);

for i = 1:num_stimuli
    movie_file{i} = '';
end

for i = 1:repeats*length(mfiles)
	duration(i*2-1) = offTime;
	stim_type{i*2-1} = 'blank';
    contrast(i*2-1) = contrasts;	
	
	duration(i*2) = onTime;
	stim_type{i*2} = 'image';
    movie_file{i*2} = mfiles{mod(i-1,length(mfiles))+1};    
    contrast(i*2) = contrasts;	
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,movie_file);
stimuli.blackblank = 0;

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
