function data = psychsr_predictGratings_alternate()
% display drifting gratings successively at different orientations
% reward automatically at end of cardinal directions but not diagonal

%% default
iti_dur = 3;           % ITI between stimuli
stim_dur = 1;          % duration of stimuli
stim_per_block = 220;  % number of stimuli per block
n_pred = 20;           % number of stimuli of block type before switches start
block_pred = 10;        % number of predicted stimuli for one unpredicted stimulus
sound.tone_amp = 1;    % tone at beginning/end
stim_switch = 1;       % Insert unpredicted stimuli?

%% check stim switch
if stim_switch==0
    stimFlag = input('No unpredicted stimuli will be shown, is this correct? (1 = Yes, 0 = No) ');
    if stimFlag~=1
        return
    end
end

%% constant parameters
response.mode = 1;
card.trigger_mode = 'out'; 
screen.keep = 1;
presentation.frame_rate = 30;
num_loops = stim_per_block;
num_stimuli = num_loops*2;

%% stimuli

% define your stimuli
orients = [0 90];
sfs = 0.05;
tfs = 2;	
contrasts = 1;

% initialize
stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
orientation = ones(1,num_stimuli);
contrast = ones(1,num_stimuli);
spat_freq = ones(1,num_stimuli);
temp_freq = ones(1,num_stimuli);

% Define unpredicted stimuli
if stim_switch == 1
    stim_index = [];
    predict_index = [];
    stim_index = [stim_index mod([1:n_pred]-1,2)+1];
    predict_index = [predict_index -1*ones(1,n_pred)];
    for j = 1:(stim_per_block-n_pred)/block_pred
        curr_grat_index = mod(j-1,2)+1;
        vector_unpred = mod([1:block_pred]-1,2)+1;
        switch_index = find(vector_unpred~=curr_grat_index);
        rand_index = switch_index(randi(length(switch_index)-2)+1);
        vector_unpred(rand_index) = curr_grat_index;
        stim_index = [stim_index vector_unpred];
        curr_predict_index = ones(1,block_pred);
        curr_predict_index(rand_index) = 0;
        predict_index = [predict_index curr_predict_index];
    end
else
    stim_index = mod([1:num_loops]-1,2)+1;
    predict_index = zeros(1,num_loops);
end
% remove stim after oddball from analysis
numRemove=5; % number of stim after oddball to remove
oddball_index=find(predict_index==0);
for j=1:length(oddball_index)
    predict_index(oddball_index(j)+1:oddball_index(j)+numRemove)=-1;
end

% make stimuli
k = 1;
for i = 1:num_loops                
    duration(k) = iti_dur;
    stim_type{k} = 'blank'; 
    k = k+1; 

    duration(k) = stim_dur;
    stim_type{k} = 'grating';
    orientation(k) = orients(stim_index(i));
    contrast(k) = contrasts;
    spat_freq(k) = sfs;
    temp_freq(k) = tfs;
    
    k = k+1;
end

stimuli = psychsr_zip(num_stimuli,stim_type,duration,orientation,contrast,spat_freq,temp_freq,stim_index,predict_index);

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

%% save
date = clock;
folder = sprintf('../behaviorData/prediction');
if ~isdir(folder); mkdir(folder); end
uisave('data',sprintf('%s/%4d%02d%02d_predictGrating_%02d%02d%02d',folder,date(1),date(2),date(3),date(4),date(5),round(date(6))));    


end