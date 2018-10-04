function data = psychsr_train2_freemovie()
% Trial structure
% t=0   tone cues screen -- always same screen (0.5s) 
% t=0   movie plays (2 sec) on that screen
%           lick --> punish and abort (timeout 8 secs)
%           for mouse 4, additional punishs/prolongations for each lick
% t=2   blank (2 sec)
%           lick --> reward (only one reward per blank)
% t=4   still frame from movie
% t=8   next trial

%% variable parameters
pc = input('Computer #: ');
mouse_num = input('Mouse #: ');

total_duration = (60)*60;
if pc == 1
    response.reward_time = 0.005;    
elseif pc == 2
    response.reward_time = 0.004;    
    screen.id = 1;    
end

% if mouse_num == 4
%     response.punish_extra = 1;
% end

iti = 4;   
delay = 2;
resp = 2;

free = 30; %  free
response.free_rewards = 5; % max num of rewards

response.blank_time = 2;
response.abort_grace = 0;
response.abort_win1 = 0;
response.abort_win2 = 0.25;
response.auto_reward = 0;

sound.noise_amp = 0.2;        
sound.noise_time = 1;

%% constant parameters
screen.keep = 1;    
card.trigger_mode = 'key';        
response.mode = 1;
response.feedback_fn = @psychsr_movie_feedback;
response.abort_timeout = 6;
sound.tone_amp = 0.05;        
sound.tone_time = 0.5; 
presentation.frame_rate = 60;

%% stimuli
mfiles = 'C:\Dropbox\MouseAttention\mov043.mat';
contrasts = 1;

num_loops = total_duration/(iti+delay+resp);
num_stimuli = num_loops*3+1;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
movie_file = cell(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
cue_tone = zeros(1,num_stimuli);

for i = 1:num_stimuli
    movie_file{i} = '';
end

duration(1) = free;
stim_type{1} = 'free';

k = 2;
for i = 1:num_loops                
    duration(k) = iti;
    stim_type{k} = 'image';
    movie_file{k} = mfiles;
    contrast(k) = 1;
    k = k+1; 

    duration(k) = delay;
    stim_type{k} = 'movie';
    movie_file{k} = mfiles;
    cue_tone(k) = 0; % 0 = mute, 4 = right, 5 = left
    
    contrast(k) = 1;
    k = k+1;
    
    duration(k) = resp;
    stim_type{k} = 'blank';
    k = k+1;
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,movie_file,temp_freq,cue_tone);

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

%% save
date = clock;
if input('Save File? (0/1): ')
    cd(sprintf('C:/Dropbox/MouseAttention/behaviorData/mouse %04d',mouse_num));    
    uisave('data',sprintf('%4d%02d%02d_movieone_%04d',date(1),date(2),date(3),mouse_num));    
end
end

