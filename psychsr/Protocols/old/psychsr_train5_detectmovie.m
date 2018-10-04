function data = psychsr_train5_detectmovie()
% 3s movie
% 1s response (blank)
% no punishments, reward during blank

%% variable parameters
pc = input('Computer #: ');
mouse_num = input('Mouse #: ');

total_duration = (60)*60;
if pc == 1
    response.reward_time = 0.006;    
elseif pc == 2
    response.reward_time = 0.004; 
    screen.id = 1;    
end

iti = 2;
delay = 4;
delay_var = 2;
resp = 2;

response.blank_time = resp;
response.auto_reward = 0;       

response.abort = 1;
response.abort_win1 = 0;
response.abort_win2 = 0.5;
response.abort_grace = 0;
response.abort_timeout = 8;

response.punish = 1;
response.punish_extra = 0;

sound.noise_amp = 0.5; 
sound.noise_time = 1;
%% constant parameters
screen.keep = 1;    
card.trigger_mode = 'key';        
response.mode = 1;
response.feedback_fn = @psychsr_movie_feedback;
response.abort_timeout = 6;
sound.tone_amp = 0.2;        
sound.tone_time = 0.5; 
presentation.frame_rate = 60;

%% stimuli
mfiles = {'C:\Dropbox\MouseAttention\Matlab\movies\mov043-antelopeturn395.mat',...
    'C:\Dropbox\MouseAttention\Matlab\movies\mov055-penguins500.mat',...
    'C:\Dropbox\MouseAttention\Matlab\movies\mov184-meercatgroom268.mat'};
    
contrasts = 1;

num_loops = ceil(total_duration/(delay-delay_var/2+resp+iti));
num_stimuli = num_loops*3;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
movie_file = cell(1,num_stimuli);
cue_tone = zeros(1,num_stimuli);

for i = 1:num_stimuli
    movie_file{i} = '';
end

k = 1;
for i = 1:num_loops                
    duration(k) = iti;
    stim_type{k} = 'image';
    movie_file{k} = mfiles{mod(floor(k/3),3)+1};
    contrast(k) = 1;
    k = k+1; 

    duration(k) = delay + delay_var*(rand-0.5);
    stim_type{k} = 'movie';
    movie_file{k} = mfiles{mod(floor(k/3),3)+1};
    cue_tone(k) = 0; % 0 = mute, 4 = right, 5 = left    
    contrast(k) = 1;
    k = k+1;
    
    duration(k) = resp;
    stim_type{k} = 'blank';
    k = k+1;
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,movie_file,cue_tone);

stimuli.blackblank = 1;

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

%% save
date = clock;
if input('Save File? (0/1): ')
    cd(sprintf('C:/Dropbox/MouseAttention/behaviorData/mouse %04d',mouse_num));    
    uisave('data',sprintf('%4d%02d%02d_train5_%04d',date(1),date(2),date(3),mouse_num));    
end
end

