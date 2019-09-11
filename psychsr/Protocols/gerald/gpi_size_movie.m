function data = gpi_size_movie()
%% variable parameters
folder = psychsr_go_root();

mousecontrol = 0; % 2: complete online control
rad = [0.08 0.16 0.4 Inf]; %[0.02 0.04 0.08 0.16 0.25 0.4 Inf];
% 2P3: 0.1 ~= 7 deg
centerpos = [0.52 0.67]; % x y from top left

repeats = 5; % # of repeats per image
offTime = 2;
onTime = 4;

% make mfile list
mfolder = [folder '\movies\rvr'];
indexVector=1:5;
for i=1:length(indexVector)
    mfiles{i} = [mfolder '\mov' sprintf('%1d',indexVector(i)) '.mat'];
end
crop_movie = 1;
contrasts = 1;

% order = repmat([1:length(rad) length(rad):-1:1],1,repeats/2);
% order = repmat(1:length(rad)*length(mfiles),1,repeats);
order = randomizeStims(mfilename('fullpath'),length(rad)*length(mfiles),repeats);

total_duration = repeats*length(mfiles)*length(rad)*(offTime+onTime);
total_duration
screen.gammacorrect = 0;
%% constant parameters
screen.keep = 1;			% does keep window open after program finishes
card.trigger_mode = 'out';  % starts automatically, triggers imaging
card.id = 'Dev1';
response.mode = 0;		
sound.tone_amp = 0;
presentation.frame_rate = 30;
% presentation.lag = 0.03;

%% stimuli
num_stimuli = numel(order)*2;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
movie_file = cell(1,num_stimuli);
pos = cell(1,num_stimuli);
radius = zeros(1,num_stimuli);

for i = 1:num_stimuli
    movie_file{i} = '';
end

for i = 1:numel(order)
%     if offTime>0
        duration(i*2-1) = offTime;
        stim_type{i*2-1} = 'blank';
        contrast(i*2-1) = contrasts;
        
        duration(i*2) = onTime;
        stim_type{i*2} = 'movie_patch';
        movie_file{i*2} = mfiles{mod(order(i)-1,length(mfiles))+1};
        contrast(i*2) = contrasts;
		pos{i*2} = centerpos;
		radius(i*2) = rad(ceil(order(i)/length(mfiles)));
%     else
%         duration(i) = onTime;
%         stim_type{i} = 'movie_patch';
%         movie_file{i} = mfiles{mod(order(i)-1,length(mfiles))+1};
%         contrast(i) = contrasts;
% 		pos{i} = centerpos;
% 		radius(i) = ceil(order(i)/length(mfiles));
%     end
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,movie_file,crop_movie,pos,radius,mousecontrol);
stimuli.blackblank = 0;

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
