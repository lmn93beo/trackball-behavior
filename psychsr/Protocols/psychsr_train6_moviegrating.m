function data = psychsr_train6_moviegrating()
%% TRIAL STRUCTURE
% 1: iti = intertrial interval,     still image
% 2: delay = delay period,          movie
% 3: resp = response period,        grating

%% input information
psychsr_go_root();

% check whether air has been turned on
x = dir('*.txt');
if today-floor(max([x.datenum])) > 0
    disp('Did you remember to turn on the air?'); pause;
end

mouse = input('Mouse #: ');

response.notify = input('Notify? (g/m/a/0): ','s');

%% constant parameters
sound.noise_amp = 0.5;
sound.noise_time = 1;
sound.tone_amp = 0.5;
sound.tone_time = 0.5;
screen.keep = 1;
response.mode = 1;

response.feedback_fn = @psychsr_movie_feedback2;
presentation.frame_rate = 30;

%% default parameters
total_duration = (90)*60;
response.auto_stop = 10;        % automatically stop program after X misses
reload = 0;

iti = 3.5;                      % ITI duration
icontrast = 0;                  % contrast of image during iti
delay = 1;                      % delay duration
delay_var = 0;                  % total range of variability of delay
response.response_time = 2;     % response window
response.extend_iti = 0;        % extend ITI until stop licking?

side_mode = 'right';             % dual, alternate, right, left, block
blocksize = 60;
response.cue_mode = 'auditory';
invalid_cue = 0;                % percent invalid cues
neutral_cue = 0;                % percent neutral cues
nvalid = 10;                    % # of valid cues at beginning
invalid_dist = 2;               % minimum number of non-invalid cues in a row
cueon = 1;						% turn on auditory cues

response.abort = 0;             % abort if lick during movie
response.abort_grace = 0.5;     % time during movie that licks arent punished

mcontrast = 0;                  % contrast of movie

response.grace_period = 0.25;    % time during grating that licks don't matter
response.target_time = 2;       % time grating is actually on
response.iri = Inf;             % multiple rewards - inter-reward interval

aperture = [0 0 1 1];           % [xmin ymin xmax ymax] normalized to 1
aperture_nt = [0 0 1 1];
rand_rect = 0;
% randshift = 0.5;                % percent of "leftover screen" to shift by
contrasts = 1;                  % grating contrast
dcontrast = 0;                  % distractor grating contrast
response.d_auto = 0;            % automatically increment distractor contrast
per_same = 1/3;                 % percent of distractors with same orientation
response.d_inc = 0.1;           % contrast increment
sine_gratings = 0;              % use sine instead of square gratings
t_ori = 90;                     % target orientation
nt_ori = 0.01;                  % nontarget orientation
t_speed = 2;                    % target temp freq;
nt_speed = 0;                   % nontarget temporal frequency
nt_movie = 0;                   % if > 0, use first X images as nontargets
easy_movies = 0;                % number of familiar nontargets to use at beginning

ntarget = 3;                    % # of targets at beginning of session
per_targ = 0.5;                 % percent of stimuli that are targets
max_targ = 3;                   % max # of targets in a row

response.auto_reward = 0;       % # of free rewards if no lick
response.auto_reward_time = 1.9; % time after grating onset for auto reward
response.punish_time = 0;
response.punish_extra = 0;
response.punish_timeout = 6;    % timeout if lick on nontargets
response.nt_on_timeout = 0;     % leave nontarget on during timeout?
response.stop_grating = 0;      % turn off grating?

gratingtest = 0;                % use grating overlay on movie?
mask_std = 0.5;                 % degree of blend

blockcons = 1;                  % vary contrast in blocks of this size
blockoris = 1;                  % vary nontarget oris in blocks of this size

crop_movie = 0;                 % crop movies? if not, will have gray bars on side

card.trigger_mode = 'key';

response.description = '';

% mfiles = {'C:\Dropbox\MouseAttention\Matlab\movies\mov043-antelopeturn395.mat',...
%     'C:\Dropbox\MouseAttention\Matlab\movies\mov055-penguins500.mat',...
%     'C:\Dropbox\MouseAttention\Matlab\movies\mov184-meercatgroom268.mat'};
mfiles = cell(1,25);
filenums = [3 1 6 2 4 5 7:25];
for i = 1:length(filenums);
    mfiles(i) = {sprintf('movies\\image%d.mat',filenums(i))};
end


%% mouse specific parameters

switch mouse
    
    case 44 % discrimination with multiple non targets
        % first day
        response.description = 'Discrim - vary ori 1';
        ntoris = [45];
        ntprobs = [1];
        % second day
        response.description = 'Discrim - vary ori 2';
        ntoris = [45 0.01];
        ntprobs = [0.5 0.5];
        
%%%   Old protocols that may be useful
%
%     case 46 % optogenetic stimulation
%         response.description = '4contrast blocks';
%         nt_movie = 0;
%         per_targ = 0.5;
%         contrasts = [0 0.2 0.4 1];
%         blockcons = 10; % vary contrast in blocks of this size
%         max_targ = 3;
%         ntarget = 10;
%         response.punish_time = 0.3;
%         response.punish_timeout = 0;    % timeout if lick on nontargets
%         [amt time b] = psychsr_set_reward(5);
%         
%         disp('Laser should be connected to Analog Output 1')
%         response.mode = 3; % laser mode
%         response.laser_amp = 4; % voltage
%         response.laser_time = 3; %duration of laser pulse (s)
%         response.laser_onset = 0.01; %seconds after tone (must be less than delay)
%         response.laser_on = []; % initialize vector
%         
%     case 66 % motor control
%         response.description = 'Motor control';
%         response.response_time = 1.5;
%         response.target_time = 1.5;
%         ntprobs = 1;
%         ntoris = 89.99;
%         per_targ = 0.3;
%         ntarget = 3;
%         max_targ = 3;
%         nt_speed = 2;
%         response.punish_time = 0;
%         response.punish_timeout = 0;
%         [amt time b] = psychsr_set_reward(7);
%         sound.noise_amp = 0;
%         cueon = 0;
%         
        
    case 54
        response.description = 'STM: Delay = 1.5';
        iti = 3;
        response.mode = 5;              % spout retract mode
        stmdelay = 1.5;
        response.response_time = 3.5+stmdelay;
        response.target_time = 2;        
        response.extend_onset = 2+stmdelay;      % time after grating onset
        response.grace_period = 2.2+stmdelay;
        response.retract_onset = 3.5+stmdelay;   % time after grating onset (Inf = do not retract every trial)
        
        response.iri = Inf; % 1 reward per stim
        per_targ = 0.5;
        nt_speed = 2;
        max_targ = 3;
        ntarget = 2;
        sound.noise_time = 3;
        cueon = 1; % no cue tone
        
        response.punish_time = 0;
        response.punish_timeout = 6;
        response.nt_on_timeout = 0;     % leave nontarget on during timeout?
        response.spout_time = 0.25;
        [amt time b] = psychsr_set_reward(7);
        
    case {56, 60}
        response.description = 'Engage: SR, vOri1';
        ntoris = [45];
        ntprobs = [1];
        iti = 3;
        response.mode = 5;              % spout retract mode
        response.response_time = 3.5;
        response.target_time = 3.5;
        response.extend_onset = 2;      % time after grating onset
        response.grace_period = 2.25;
        response.retract_onset = 3.5;   % time after grating onset (Inf = do not retract every trial)
        
        response.iri = Inf; % 1 reward per stim
        per_targ = 0.5;
        nt_speed = 0;
        max_targ = 3;
        ntarget = 2;
        sound.noise_time = 3;
        cueon = 1; % no cue tone
        
        response.punish_time = 0;
        response.punish_timeout = 6;
        response.nt_on_timeout = 1;     % leave nontarget on during timeout?
        response.spout_time = 0.25;
        [amt time b] = psychsr_set_reward(7);
        
    case 62
        response.description = 'Engage: SR, vOri1';
        ntoris = [45];
        ntprobs = [1];
        iti = 3;
        response.mode = 5;              % spout retract mode
        response.response_time = 3.5;
        response.target_time = 3.5;
        response.extend_onset = 2;      % time after grating onset
        response.grace_period = 2.25;
        response.retract_onset = 3.5;   % time after grating onset (Inf = do not retract every trial)
        
        response.iri = Inf; % 1 reward per stim
        per_targ = 0.5;
        nt_speed = 2;
        max_targ = 3;
        ntarget = 3;
        sound.noise_time = 3;
        cueon = 1; % no cue tone
        
        response.punish_timeout = 8;
        response.nt_on_timeout = 1;     % leave nontarget on during timeout?
        response.spout_time = 0.25;
        [amt time b] = psychsr_set_reward(7);
        
    case 63
        response.description = 'Engage: Discrim';
        response.response_time = 1.5;
        response.target_time = 1.5;
        per_targ = 0.5;
        ntarget = 3;
        max_targ = 3;
        nt_speed = 1;
        response.punish_time = 0;
        
        response.punish_timeout = 8;
        response.nt_on_timeout = 1;     % leave nontarget on during timeout?
        response.spout_time = 0.25;
        response.mode = 5;              % spout retract mode
        response.extend_onset = -3;      %time after grating onset
        response.grace_period = 0.2;
        response.retract_onset = Inf;   %time after grating onset (Inf = do not retract every trial)
        [amt time b] = psychsr_set_reward(6);
        
    case 64  
        response.description = 'STM: Delay = 1.5';
        iti = 3;
        response.mode = 5;              % spout retract mode
        stmdelay = 1.5;
        response.response_time = 3.5+stmdelay;
        response.target_time = 2;        
        response.extend_onset = 2+stmdelay;      % time after grating onset
        response.grace_period = 2.2+stmdelay;
        response.retract_onset = 3.5+stmdelay;   % time after grating onset (Inf = do not retract every trial)
        
        response.iri = Inf; % 1 reward per stim
        per_targ = 0.5;
        nt_speed = 2;
        max_targ = 3;
        ntarget = 3;
        sound.noise_time = 3;
        cueon = 1; % no cue tone
        
        response.punish_time = 0;
        response.punish_timeout = 8;
        response.nt_on_timeout = 0;     % leave nontarget on during timeout?
        response.spout_time = 0.25;
        [amt time b] = psychsr_set_reward(7);
        
     case {67, 68}
        response.description = 'Engage: Discrim';
        response.response_time = 1.5;
        response.target_time = 1.5;
        per_targ = 0.5;
        ntarget = 3;
        max_targ = 3;
        nt_speed = 1;
        response.punish_time = 0;
        
        response.punish_timeout = 6;
        response.nt_on_timeout = 1;     % leave nontarget on during timeout?
        response.spout_time = 0.25;
        response.mode = 5;              % spout retract mode
        response.extend_onset = -3;      %time after grating onset
        response.grace_period = 0.2;
        response.retract_onset = Inf;   %time after grating onset (Inf = do not retract every trial)
        [amt time b] = psychsr_set_reward(6);
        
     case {69}
        response.description = 'Engage: Discrim';
        response.response_time = 1.5;
        response.target_time = 1.5;
        iti = 3.5;
        nt_speed = 1;
        per_targ = 0.5;
        max_targ = 3;
        ntarget = 5;
        response.nt_on_timeout = 1;     % leave nontarget on during timeout?
        response.punish_time = 0;
        response.punish_timeout = 6;
        [amt time b] = psychsr_set_reward(7);
        
     case {70}
        response.description = 'Engage: Discrim';
        response.response_time = 1.5;
        response.target_time = 1.5;
        iti = 3.5;
        nt_speed = 1;
        per_targ = 0.75;
        max_targ = 5;
        ntarget = 5;
        response.nt_on_timeout = 1;     % leave nontarget on during timeout?
        response.punish_time = 0;
        response.punish_timeout = 6;
        [amt time b] = psychsr_set_reward(7);
        
    case {71}
        response.description = 'Engage: Discrim';
        response.response_time = 1.5;
        response.target_time = 1.5;
        iti = 3.5;
        nt_speed = 1;
        per_targ = 0.5;
        max_targ = 3;
        ntarget = 5;
        response.nt_on_timeout = 1;     % leave nontarget on during timeout?
        response.punish_time = 0;
        response.punish_timeout = 6;
        [amt time b] = psychsr_set_reward(7);
        
    case {72}
        response.description = 'Engage: Discrim';
        response.response_time = 1.5;
        response.target_time = 1.5;
        iti = 3.5;
        nt_speed = 0;
        per_targ = 0.5;
        max_targ = 3;
        ntarget = 5;
        response.nt_on_timeout = 1;     % leave nontarget on during timeout?
        response.punish_time = 0;
        response.punish_timeout = 6;
        [amt time b] = psychsr_set_reward(7);
        
    otherwise
        response.description = 'Discrim: All targets';
        response.response_time = 1.5;
        response.target_time = 1.5;
        per_targ = 1;
        max_targ = inf;
        [amt time b] = psychsr_set_reward(7);
end

response.reward_time = time;
response.reward_amt = amt;
response.reward_cal = b;

if strcmp(getenv('computername'),'VISSTIM-2P4')
    mode = input('Full/Engaged/Passive? (0/1/2): ');
    if mode > 0
        response.auto_stop = 0;
        total_duration = (10)*60;
        card.trigger_mode = 'out';
    end
    if mode == 2
        reload = 1;
        response.spout_time = 0;
        [file folder] = uigetfile(sprintf('../behaviorData/mouse %04d/',mouse));
    end
end

% fprintf('\nProgram Paramaters\n%s, %d%%, ntmov=%d, tspd=%1.1f\n\n',response.description,per_targ*100,nt_movie,t_speed);
fprintf('\nProgram Description:\n%s\n',response.description);
fprintf('\nProgram Paramaters:\nper_targ=%d%%, tspd=%1.1f, ntspd=%1.1f\n\n',per_targ*100,t_speed,nt_speed);

%% initialize stimuli
if strcmp(side_mode,'right')
    screen.dual = 0;
else
    screen.dual = 1;
end

orients = [t_ori nt_ori];
sfs = 0.05;
tfs = [t_speed nt_speed];

num_loops = ceil(total_duration/(min(delay)-delay_var/2+response.response_time+iti));
num_stimuli = num_loops*3;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
contrast2 = zeros(1,num_stimuli);
movie_con = zeros(1,num_stimuli);
movie_file = cell(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
orientation_d = NaN*ones(1,num_stimuli); % left screen
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
cue_type = cell(1,num_stimuli);
cue_tone = zeros(1,num_stimuli);
stim_side = zeros(1,num_stimuli);
rect = cell(1,num_stimuli);
rand_phase = zeros(1,num_stimuli);
laser_on = zeros(1,num_stimuli);

targets = [ones(1,ntarget) psychsr_rand(per_targ,num_loops-ntarget,0,max_targ,ones(1,ntarget))];
distractors = psychsr_rand(per_same,num_loops,0,Inf); % 1 = same, 2 = orthogonal
targets2 = xor(targets-1,distractors-1)+1;

for i = 1:num_stimuli
    movie_file{i} = '';
    cue_type{i} = '';
end

%% determine sides/cues
switch side_mode
    case 'dual'
        sides = psychsr_rand(0.5,num_loops,0,3); % 1 = left, 2 = right
    case 'alternate'
        sides = 1+mod(1:num_loops,2);
    case 'left'
        sides = ones(1,num_loops);
    case 'right'
        sides = 2*ones(1,num_loops);
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
        cues(i) = 0;
        cue_type{3*i-1} = 'invalid';
        cue_tone(3*i-1) = 3+sides(i);
        validcounter = 0;
    elseif r < invalid_cue+neutral_cue && i > nvalid && validcounter >= invalid_dist
        cues(i) = 1;
        cue_type{3*i-1} = 'neutral';
        cue_tone(3*i-1) = 2; % tones on both sides
        validcounter = validcounter + 1;
    else
        cues(i) = 2;
        cue_type{3*i-1} = 'valid';
        cue_tone(3*i-1) = 6-sides(i); % 4 = right, 5 = left
        validcounter = validcounter + 1;
    end
end

if length(delay)>1
    delays=psychsr_rand(ones(length(delay),1)/length(delay),num_loops,0,3);
end

if length(contrasts)>1
    k = length(contrasts);
    if blockcons < 2
        cons = [k*ones(1,2), k*ones(1,8)-mod(1:8,2), ...
            psychsr_rand(ones(k,1)/k,num_loops-10,0,3)];
    else
        nblocks = ceil(num_loops/blockcons);
        ncons = length(contrasts);
        cons = [ncons randperm(ncons-1)]; % first block is full contrast
        for i = 1:nblocks-ncons
            cons = [cons randperm(ncons)];
        end
        cons = reshape(repmat(cons,blockcons,1),1,[]);
        cons = cons(1:num_loops);
    end
end

if exist('ntoris','var')
    if blockoris < 2
        for i = 1:num_loops
            oris(i) = find(rand<cumsum(ntprobs),1);
        end
    else
        nblocks = ceil(num_loops/blockoris);
        noris = length(ntoris);
        oris = [1 (randperm(noris-1)+1)]; % first block is 0 degrees
        for i = 1:nblocks-noris
            oris = [oris randperm(noris)];
        end
        oris = reshape(repmat(oris,blockoris,1),1,[]);
        oris = oris(1:num_loops);
    end
end

%% make stimuli
k = 1;
j = 0;
for i = 1:num_loops
    duration(k) = iti;
    stim_type{k} = 'image';
    movie_file{k} = mfiles{mod(i,3)+1};
    contrast(k) = icontrast;
    contrast2(k) = icontrast;
    k = k+1;
    
    if length(delay)==1
        duration(k) = delay + delay_var*(rand-0.5);
    else
        duration(k) = delay(delays(i));
    end
    stim_type{k} = 'movie';
    movie_file{k} = mfiles{mod(i,3)+1};
    stim_side(k) = sides(i);
    contrast(k) = mcontrast;
    contrast2(k) = mcontrast;
    if response.mode == 3
        laser_on(k) = rand>0.5;
    end
    k = k+1;
    
    duration(k) = response.response_time;
    if nt_movie > 0 && targets(i) == 2
        stim_type{k} = 'image';
        if nt_movie > 3 && j < easy_movies
            movie_file{k} = mfiles{mod(j,3)+1};
        else
            movie_file{k} = mfiles{mod(j,nt_movie)+1};
        end
        j = j+1;
    else
        if gratingtest; stim_type{k} = 'grating2';
        elseif dcontrast > 0; stim_type{k} = 'grating3';
        else stim_type{k} = 'grating'; end;
        movie_file{k} = mfiles{mod(i,3)+1};
    end
    movie_con(k) = mcontrast;
    stim_side(k) = sides(i);
    spat_freq(k) = sfs;
    rand_phase(k) = 0;
    laser_on(k) = laser_on(k-1);
    if sides(i)==1
        if dcontrast > 0; contrast(k) = dcontrast;
        else contrast(k) = mcontrast; end;
        if length(contrasts)==1; contrast2(k) = contrasts;
        else contrast2(k) = contrasts(cons(i)); end;
    else
        if length(contrasts)==1; contrast(k) = contrasts;
        else contrast(k) = contrasts(cons(i)); end;
        if dcontrast > 0; contrast2(k) = dcontrast;
        else contrast2(k) = mcontrast; end;
    end
    orientation(k) = orients(targets(i));
    if exist('ntoris','var') && targets(i) == 2
        orientation(k) = ntoris(oris(i));
    end
    
    if dcontrast > 0; orientation_d(k) = orients(targets2(i)); end;
    temp_freq(k) = tfs(targets(i));
    if rand_rect; rect{k} = aperture+2*randshift*repmat([(randi(2)-1.5)*aperture(1) (randi(2)-1.5)*aperture(2)],1,2);
    elseif targets(i) == 1; rect{k} = aperture;
    else rect{k} = aperture_nt; end
    
    k = k+1;
end

if reload == 1
    load([folder file])
    stimuli = data.stimuli;
    stimuli.duration(3:3:end) = response.response_time;
    stimuli.total_duration = total_duration;
else
    stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,...
        contrast2,movie_file,orientation,orientation_d,spat_freq,temp_freq,cue_type,cue_tone,...
        stim_side,rect,mask_std,movie_con,crop_movie,rand_phase,laser_on,sine_gratings);
    stimuli.blackblank = 0;
end

%% input parameters into psychsr
params = psychsr_zip(mouse,screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

%% save
date = clock;
folder = sprintf('../behaviorData/mouse %04d',mouse);
if ~isdir(folder); mkdir(folder); end
uisave('data',sprintf('%s/%4d%02d%02d_train7_%04d',folder,date(1),date(2),date(3),mouse));

end