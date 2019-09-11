function data = psychsr_predictball()
% display drifting gratings successively at different orientations
% reward automatically at end of cardinal directions but not diagonal

%% default
iti_dur=2;
stim_dur=4;
num_blocks=6;       % number of blocks (norm/bounce)
stim_per_block=60;  % number of stimuli per block
n_pred=10;          % number of stimuli of block type before switches start
block_pred=10;      % blocks of predicted stimuli for one unpredicted stimulus
mfiles = {'movies\\predictStim_norm.mat','movies\\predictStim_bounce.mat'};
sound.sweep_amp = 1; % volume of sound;
sound.tone_amp = 1;

stim_switch = 1;                % Insert unpredicted stimuli?

mouse = input('Mouse #: ');

%% constant parameters
response.mode = 1;
response.feedback_fn = @psychsr_predictball_feedback;
card.trigger_mode = 'out'; 

screen.keep = 1;
presentation.frame_rate = 30;

%% stimuli
% define your stimuli
contrasts = 1;

num_loops = ceil(num_blocks*stim_per_block);
num_stimuli = num_loops*2;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = ones(1,num_stimuli);
movie_file = cell(1,num_stimuli);

% Define unpredicted stimuli
if stim_switch == 1
    switch_index=[];
    for i=1:num_blocks
        curr_mov_index=mod(i-1,2)+1;
        switch_index=[switch_index ones(1,n_pred)*curr_mov_index];
        for j=1:(stim_per_block-n_pred)/block_pred
            vector_unpred=ones(1,block_pred)*curr_mov_index;
            vector_unpred(randi(block_pred/2)+floor(block_pred/4))=mod(i,2)+1;
            switch_index=[switch_index vector_unpred];
        end
    end
else
    switch_index=zeros(1,num_loops);
end

for i = 1:num_stimuli
    movie_file{i} = '';
end

k = 1;
for i = 1:num_loops                
    duration(k) = iti_dur;
    stim_type{k} = 'blank'; 
    k = k+1; 

    duration(k) = stim_dur;
    stim_type{k} = 'movie';

    contrast(k) = contrasts;
    movie_file{k} = mfiles{switch_index(i)};
    k = k+1;
end

stimuli = psychsr_zip(num_stimuli,stim_type,duration,contrast,movie_file,switch_index);

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

%% save
date = clock;
folder = sprintf('../behaviorData/mouse %04d',mouse);
if ~isdir(folder); mkdir(folder); end
uisave('data',sprintf('%s/%4d%02d%02d_predictball_%04d',folder,date(1),date(2),date(3),mouse));    


end