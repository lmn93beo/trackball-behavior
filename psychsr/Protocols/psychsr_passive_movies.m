function data = psychsr_passive_movies()
%% variable parameters
folder = psychsr_go_root();
repeats = 9; % # of repeats per movie
offTime = 4;
onTime = 4;

mfiles = {[folder '\movies\mov043-antelopeturn395.mat'],...
    [folder '\movies\mov055-penguins500.mat'],...
    [folder '\movies\mov184-meercatgroom268.mat']}; %4.47s long at 60Hz
contrasts = 1;

total_duration = repeats*length(mfiles)*(offTime+onTime);
screen.gammacorrect = 0;
%% constant parameters
screen.keep = 0;			% does not keep window open after program finishes
card.trigger_mode = 'out';  % starts automatically, triggers imaging
card.id = 'Dev3';
response.mode = 0;		
sound.tone_amp = 0;
presentation.frame_rate = 60;
% presentation.lag = 0.03;

%% stimuli
num_stimuli = repeats*length(mfiles)*2;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
movie_file = cell(1,num_stimuli);
fade = zeros(1,num_stimuli); % 0 = no fade, 1 = fade in, -1 = fade out

for i = 1:num_stimuli
    movie_file{i} = '';
end

for i = 1:repeats*length(mfiles)
	duration(i*2-1) = offTime;    
	stim_type{i*2-1} = 'blank';%'image';
% 	if i == 11
% 		movie_file{i*2-1} = mfiles{1};	
% 	else
% 		movie_file{i*2-1} = mfiles{2};
% 	end
%     contrast(i*2-1) = contrasts;	
% 	fade(i*2-1)=-1;
	
	duration(i*2) = onTime;
	stim_type{i*2} = 'movie';
% 	if i ==1
% 		movie_file{i*2} = mfiles{1};	
% 	else
% 		movie_file{i*2} = mfiles{2};
% 	end
    movie_file{i*2} = mfiles{mod(i,3)+1};    
    contrast(i*2) = contrasts;	
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,movie_file,fade);
stimuli.blackblank = 0;

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
