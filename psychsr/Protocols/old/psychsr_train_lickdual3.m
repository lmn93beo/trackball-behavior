function data = psychsr_train_lickdual3()
% 2s on, 2s off
% airpuff for licks on wrong side

%% variable parameters
cd('C:\Dropbox\MouseAttention\matlab');

mouse = input('Mouse #: ');
reward = input('Reward (uL): ');
disp('Set reward amount manually; press enter when finished.')
response.reward_amt = reward;
    
clear psychsr_draw;

%% default
% delay_dur = 2;
delay = 2;
delay_var = 0;
iti_dur = 2;
stim_dur = 2;
total_duration = (60)*60;

response.grace_period = 0.5; % licks during first 250ms dont count
response.punish_time = 0.1;

invalid_cue = 0;                % percent invalid cues
neutral_cue = 0;                % percent neutral cues
nvalid = 10;                    % # of valid cues at beginning
invalid_dist = 2;               % minimum number of non-invalid cues in a row
cueon = 1;						% turn on auditory cues

%% mouse-specific parameters
side_mode = 'block'; % dual, alternate, block
blocksize = 5;
response.auto_reward = -1; %-1 = unlimited auto rewards
response.punish_timeout = 0;
response.punish = 1; % airpuff or just noise?
response.punish_extra = 0;
response.extend_iti = 1;
response.stop_grating = 0;  % turn off grating after first lick?
response.leave_grating = 0; % leave grating on until first lick
response.auto_stop = 1; % stop after 10 misses
response.auto_bias = 0;

switch mouse    
    case 29
        delay = 0.5;
        response.stop_grating = 1;
        response.leave_grating = 0;
        response.punish_extra = 1;
        response.auto_reward = 0;
        response.auto_bias = 1;
        response.punish = 1;
        response.grace_period = 0.1;
        side_mode = 'dual';
    case 34
        delay = 0.2;
        response.stop_grating = 1;
        response.leave_grating = 0; % leave grating on until first lick
        response.auto_bias = 1;
        response.auto_reward = 0;
        response.punish = 1;
        response.grace_period = 0.3;
        blocksize = 1;
        response.punish_extra = 1;
        side_mode = 'dual';
    otherwise
end

%% constant parameters    
screen.keep = 1;
screen.dual = 1;
card.trigger_mode = 'key';  
card.ai_chan = [2 3];
response.mode = 2; % dual
response.reward_time = 0.004;
response.feedback_fn = @psychsr_dualfeedback3;
sound.tone_amp = 1;        
sound.tone_time = 0.5;
sound.noise_amp = 0.5;        
sound.noise_time = 1;
presentation.frame_rate = 60;

%% stimuli
% define your stimuli	
o = 90;
sf = 0.015;
tf = 2;
con = 1;

num_loops = ceil(total_duration/(delay-delay_var/2+iti_dur+stim_dur));
num_stimuli = num_loops*3;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli); % right
contrast2 = zeros(1,num_stimuli); % left
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = NaN*ones(1,num_stimuli);
stim_side = zeros(1,num_stimuli);
cue_type = cell(1,num_stimuli);
cue_tone = zeros(1,num_stimuli);

switch side_mode
    case 'dual'
        sides = psychsr_rand(0.5,num_loops,0,3); % 1 = left, 2 = right
    case 'alternate'
        sides = 1+mod(1:num_loops,2);
    case 'block'           
        sides = repmat([2*ones(1,blocksize),ones(1,blocksize)],1,ceil(num_loops/(2*blocksize)));
        sides = sides(1:num_loops);        
end

validcounter = 0;
for i = 1:num_loops
    r = rand;
    if cueon == 0
        cue_type{3*i-1} = 'none';
        cue_tone(3*i-1) = 0;
    elseif r < invalid_cue && i > nvalid && validcounter >= invalid_dist
        cue_type{3*i-1} = 'invalid';
        cue_tone(3*i-1) = 7+sides(i);
        validcounter = 0;
    elseif r < invalid_cue+neutral_cue && i > nvalid && validcounter >= invalid_dist
        cue_type{3*i-1} = 'neutral';
        cue_tone(3*i-1) = 10; % tones on both sides
        validcounter = validcounter + 1;
    else
        cue_type{3*i-1} = 'valid';
        cue_tone(3*i-1) = 10-sides(i); % 8 = right, 9 = left
        validcounter = validcounter + 1;
    end
end

k = 1;
for i = 1:num_loops
    duration(k) = iti_dur;
    stim_type{k} = 'blank';     
    k = k+1; 

    duration(k) = delay + delay_var*(rand-0.5);
    stim_type{k} = 'blank';     
    k = k+1; 
    
    duration(k) = stim_dur;
    stim_type{k} = 'grating';    
    orientation(k) = o;
    if sides(i) == 1
        contrast2(k) = con;
    else
        contrast(k) = con;
    end
    stim_side(k) = sides(i);
    spat_freq(k) = sf;
    temp_freq(k) = tf;
    k = k+1;
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,...
    orientation,spat_freq,temp_freq,contrast,contrast2,stim_side,cue_type,cue_tone);

%% input parameters into psychsr
params = psychsr_zip(mouse,screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

%% save
date = clock;
folder = sprintf('C:/Dropbox/MouseAttention/behaviorData/mouse %04d',mouse);
if ~isdir(folder); mkdir(folder); end
uisave('data',sprintf('%s/%4d%02d%02d_trainlickdual3_%04d',folder,date(1),date(2),date(3),mouse));    


end