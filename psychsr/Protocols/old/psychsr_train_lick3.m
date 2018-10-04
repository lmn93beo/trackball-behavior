function data = psychsr_train_lick3()

%% variable parameters

mouse = input('Mouse #: ');
reward = input('Reward (uL): ');

disp('Set reward amount manually; press enter when finished.')
pause;
response.reward_time = 0.004; 
response.reward_amt = reward;

total_duration = (60)*60;

clear psychsr_draw;

%% constant parameters
screen.keep = 1;     
screen.dual = 1;
card.trigger_mode = 'key';        
response.mode = 1;
response.feedback_fn = @psychsr_lick_feedback3;
sound.tone_amp = 0.5;        
sound.tone_time = 0.5;
presentation.frame_rate = 60;

%% stimuli
targ_time = 20;
nt_time = 20;
orients = [90 0.01];
sfs = 0.015;
tfs = 2;
cons = 1;
blocksize = 3; % number of loops on one screen before swap
response.response_time = targ_time;

% define your stimuli	
num_loops = ceil(total_duration/(targ_time+nt_time));
num_stimuli = num_loops*2;
stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
contrast2 = zeros(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
cue_tone = 4*ones(1,num_stimuli);

sides = repmat([2*ones(1,blocksize),ones(1,blocksize)],1,ceil(num_loops/(2*blocksize)));
sides = sides(1:num_loops);  

for i = 1:num_loops       

    stim_type{2*i-1} = 'grating';
    duration(2*i-1) = targ_time;
    orientation(2*i-1) = orients(1);
    spat_freq(2*i-1) = sfs;
    temp_freq(2*i-1) = tfs;
    if sides(i)==1
        contrast(2*i-1) = 0;
        contrast2(2*i-1) = cons;
    else
        contrast(2*i-1) = cons;
        contrast2(2*i-1) = 0;
    end
    cue_tone(3*i-1) = 6-sides(i); % 4 = right, 5 = left
    
    stim_type{2*i} = 'grating';
    duration(2*i) = nt_time;
    orientation(2*i) = orients(2);
    spat_freq(2*i) = sfs;
    temp_freq(2*i) = tfs;
    if sides(i)==1
        contrast(2*i) = 0;
        contrast2(2*i) = cons;
    else
        contrast(2*i) = cons;
        contrast2(2*i) = 0;
    end
    cue_tone(3*i-1) = 6-sides(i); % 4 = right, 5 = left
    
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,orientation,spat_freq,temp_freq,contrast,contrast2,cue_tone);       

%% input parameters into psychsr
params = psychsr_zip(mouse,screen,response,card,sound,stimuli,presentation);
data = psychsr(params);
    
%% save
date = clock;
folder = sprintf('C:/Dropbox/MouseAttention/behaviorData/mouse %04d',mouse);
if ~isdir(folder); mkdir(folder); end
uisave('data',sprintf('%s/%4d%02d%02d_trainlick3_%04d',folder,date(1),date(2),date(3),mouse));    


end