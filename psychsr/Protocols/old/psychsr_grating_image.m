function data = psychsr_grating_image()
%% TRIAL STRUCTURE
% One-screen grating detection task. Animal licks in response to target
% grating, must withhold licks when nontarget natural image appears.

% 2: delay = delay period,          blank
% 3: resp = response period,        grating or natural image
% 1: iti = intertrial interval,     blank

mouse = input('Mouse #: ');
reward = input('Reward (uL): ');
disp('Set reward amount manually; press enter when finished.'); pause;

response.reward_time = 0.004; 
response.reward_amt = reward;

%% constant parameters
sound.noise_amp = 0.5; 
sound.noise_time = 1;
sound.tone_amp = 0.5;        
sound.tone_time = 0.5;
screen.keep = 1;
screen.dual = 0;
response.mode = 1;
response.feedback_fn = @psychsr_grating_image_feedback;
if strcmp(getenv('computername'),'RAINBOW')
	presentation.frame_rate = 30;
else
	presentation.frame_rate = 60;
end

%% default parameters
total_duration = (90)*60; 
response.auto_stop = 1;         % automatically stop program when animal stops
reload = 0;                     % reload stimuli?

iti = 2;                        % ITI duration
delay = 1;                      % delay duration
response.response_time = 1;     % response window
response.extend_iti = 1;        % extend ITI until stop licking? 

response.grace_period = 0.25;   % time during grating that licks don't matter
response.target_time = 1;       % time grating is actually on 

contrasts = 1;                  % grating contrast

ntarget = 3;                    % # of targets at beginning of session
per_targ = 0.5;                 % percent of stimuli that are targets
max_targ = 3;                   % max # of targets in a row

response.auto_reward = 0;       % # of free rewards if no lick
response.punish_timeout = 6;    % timeout if lick on nontargets
response.stop_grating = 1;      % turn off grating?

card.trigger_mode = 'key'; 

mfiles = {'C:\Dropbox\MouseAttention\Matlab\movies\mov043-antelopeturn395.mat',...
    'C:\Dropbox\MouseAttention\Matlab\movies\mov055-penguins500.mat',...
    'C:\Dropbox\MouseAttention\Matlab\movies\mov184-meercatgroom268.mat'};

%% mouse specific parameters

switch mouse
    case 0
    otherwise
end

%% initialize stimuli
ori = 90;                       % target orientation
sfs = 0.015;                    % target spatial frequency
tfs = 2;                        % target temp freq

num_loops = ceil(total_duration/(delay+response.response_time+iti));
num_stimuli = num_loops*3;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
movie_con = zeros(1,num_stimuli);
movie_file = cell(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
cue_tone = zeros(1,num_stimuli);
stim_side = zeros(1,num_stimuli);
rect = cell(1,num_stimuli);
