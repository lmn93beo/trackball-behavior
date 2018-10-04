function data = psychsr_simple()
%% TRIAL STRUCTURE
% delay --> response --> iti
% blank --> STIMULUS --> blank

% go/nogo
% one-screen

% spout can retract/extend to limit response window

%% input information
psychsr_go_root();

% check whether air has been turned on
x = dir('*.txt');
if today-floor(max([x.datenum])) > 0
    disp('Did you remember to turn on the air?'); pause;
end

mouse = input('Mouse #: ');

response.notify = input('Notify? (g/m/a/b/0): ','s');

%% constant parameters
sound.noise_amp = 0.5;
sound.noise_time = 2;
sound.tone_amp = 0.5;
sound.tone_time = 0.5;
screen.keep = 1;
screen.dual = 0;

response.feedback_fn = @psychsr_simple_feedback;
presentation.frame_rate = 30;
presentation.lag = 0;
blackblank = 0;                 % blank screen is black or gray?

spat_freq = 0.05;               % spatial frequency in cpd
sine_gratings = 0;              % use sine instead of square gratings
response.t_ori = 90;            % target orientation
t_speed = 2;                    % target temp freq;

% probably unused
response.iri = Inf;             % multiple rewards - inter-reward interval
response.auto_reward = 0;       % # of free rewards if no lick
response.auto_reward_time = 1.4;% time after grating onset for auto reward
response.punish_extra = 0;      % punish every second if continue licking?
response.stop_grating = 0;      % turn off grating after reward/punish?
response.extend_iti = 0;        % extend iti until animal stops licking for 1 second
blockoris = 1;                  % vary nontarget oris in blocks of this size

%% default parameters
response.description = '';

iti = 3.5;                      % ITI duration
delay = 1;                      % delay duration
response.response_time = 1.5;   % response window
response.target_time = 1.5;     % time grating is displayed
response.grace_period = 0.25;   % time during grating that licks don't matter
response.lick_threshold = 1;    % number of licks required to trigger "response"

nt_ori = 0.01;                  % nontarget orientation(s)
nt_ori_p = 1;                   % vector of probabilities for each NT ori, must sum to 1
nt_speed = 0;                   % nontarget temporal frequency
nt_p = 1;                       % probability of non-blank nontargets
aperture = [0 0 1 1];           % [xmin ymin xmax ymax] normalized to 1

ntarget = 3;                    % # of targets at beginning of session
per_targ = 0.5;                 % percent of stimuli that are targets
max_targ = 3;                   % max # of targets in a row

response.punish_time = 0;       % duration of airpuff
response.punish_timeout = 6;    % timeout if lick on nontargets
response.nt_on_timeout = 1;     % leave nontarget on during timeout?

contrasts = 1;                  % grating contrast(s)
blockcons = 1;                  % vary contrast in blocks of this size
blockconflag = 0;               % use hard/easy block structure with interleaved medium probes
firstbcon = 1;                  % which contrast(s) to use in first block? (use integer)
firstbnum = 20;                 % number in first block

% use for shaping only
response.p_targ_after_cr = 0;   % prob force next stim to be Targ after CR
response.p_ntarg_after_fa = 0;  % prob force next stim to be Targ after FA
response.antibias = 0;          % initially make NT prob 75% until animal correct rejects twice in a row

% reward correct rejects?
response.reward_cr = 0;
response.reward_cr_time = 1.5;

% vary only for trainlick
cue_sound = 4;                  % 4=right, 5=left, 2=both, 0=none

% vary only for spout retract
response.mode = 1;              % normal = 1; spout retract = 5
response.extend_onset = -3;     % time after grating onset
response.retract_onset = Inf;   % time after grating onset (Inf = do not retract every trial)
% response.spout_time = 0.2; 
resp_delays = 0;                % delay(s) between stimulus and spout onset
blockdels = 1;                  % vary contrast in blocks of this size
firstbdel = 1;                  % which contrast(s) to use in first block? (use integer)
firstbdnum = 1;                 % number in first block

% vary only for imaging (engaged/passive blocks)
blockmins = 10;                 % minutes
passive_reload = 1;             % load passive from engaged
total_duration = (90)*60;       % maximum total duration
response.auto_stop = 10;        % automatically stop program after X misses
reload = 0;                     % reload stimuli from previous file
card.trigger_mode = 'key';      % how to trigger program

% adaptive on time
response.adaptive_ontime = 0;   % vary on time of stimulus based on performance?

%% mouse specific parameters

switch mouse      
    
    case 121
        response.mode = 6; % quinine
        psychsr_discrim_stages(10);
        [amt time b] = psychsr_set_reward(5);
        [~, response.punish_time, ~] = psychsr_set_quinine(2);
        ntarget = 5;    
        cue_sound = 0;
        response.extend_iti = 1;        % extend iti until animal stops licking for 1 second
        
    case 122
        response.mode = 6; % quinine
        psychsr_discrim_stages(8);
        [amt time b] = psychsr_set_reward(6);
        [~, response.punish_time, ~] = psychsr_set_quinine(1);
        ntarget = 5;  
        cue_sound = 0;
        response.extend_iti = 1;
        
    case 123
        response.mode = 6; % quinine
        psychsr_discrim_stages(7);
        [amt time b] = psychsr_set_reward(6);
        [~, response.punish_time, ~] = psychsr_set_quinine(0.1);
        ntarget = 5;  
        cue_sound = 0;
        response.extend_iti = 1;
        
    case 999      % check timing
        psychsr_discrim_stages(20);
        [amt time b] = psychsr_set_reward(5);
        contrasts = 0;
        spat_freq = 0;
        t_speed = 0;
        nt_speed = 0;
        blackblank = 1;
        
    otherwise
        psychsr_discrim_stages(1);
end

%% set reward, engaged/passive blocks
response.reward_time = time;
response.reward_amt = amt;
response.reward_cal = b;

if strcmp(getenv('computername'),'VISSTIM-2P4')      
    if response.mode == 6
        card.dio_ports = [1 2 1 0]; 
        card.dio_lines = [0 4 1 1]; 
    end
    mode = input('Full/Engaged/Passive/Camera? (0/1/2/3): ');
    if mode > 0
        response.auto_stop = 0;
        total_duration = (blockmins)*60+iti;
        card.trigger_mode = 'out';
    end
    if mode == 2
        response.spout_time = 0;
    end
    if (mode == 2 && passive_reload) || (mode == 1 && ~passive_reload)
        reload = 1;        
        [file folder] = uigetfile(sprintf('../behaviorData/mouse %04d/',mouse));
    end
    if mode == 3 % widefield imaging
        card.trigger_port = 0;
        card.trigger_line = 0;
        card.inter_trigger_interval = 0.2;
    end  
end

fprintf('\nProgram Description:\n%s\n',response.description);
fprintf('\nProgram Parameters:\nper_targ=%d%%, tspd=%1.1f, ntspd=%1.1f\n\n',per_targ*100,t_speed,nt_speed);

%% initialize stimuli
orients = [response.t_ori nt_ori];
sfs = spat_freq;
tfs = [t_speed nt_speed];

num_loops = ceil(total_duration/(delay+response.response_time+min(resp_delays)+iti));
num_stimuli = num_loops*3;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
cue_tone = cue_sound*ones(1,num_stimuli);
stim_side = 2*ones(1,num_stimuli);
rand_phase = zeros(1,num_stimuli);
response_delay = zeros(1,num_stimuli); % delay between stimulus onset and spout extend
laser_on = zeros(1,num_stimuli);
rect = cell(1,num_stimuli);
on_time = response.target_time*ones(1,num_stimuli); % time stimulus stays on

%% randomize orientations
% randomize target/nontarget presentation
targets = [ones(1,ntarget) psychsr_rand(per_targ,num_loops-ntarget,0,max_targ,ones(1,ntarget))];

% randomize nontarget orientations
if blockoris < 2
    for i = 1:num_loops
        oris(i) = find(rand<cumsum(nt_ori_p),1);
    end
else
    nblocks = ceil(num_loops/blockoris);
    noris = length(nt_ori);
    oris = [1 (randperm(noris-1)+1)]; % first block is 0 degrees
    for i = 1:nblocks-noris
        oris = [oris randperm(noris)];
    end
    oris = reshape(repmat(oris,blockoris,1),1,[]);
    oris = oris(1:num_loops);
end

oris = oris+1;
oris(targets==1) = 1;

%% randomize contrasts
contrasts = sort(contrasts); %sort ascending
if length(contrasts)>1
    ncons = length(contrasts);
    if blockconflag % use hard/easy block structure
        blocksize = 30;
        nblocks = ceil(num_loops/blocksize);
        cons = [];
        for i = 1:nblocks
            main_con = mod(i,2)*2+1;
            cons = [cons main_con*ones(1,6),... % first 4 all the same
                repmat([2 main_con main_con],1,8) ...
            ];
        end
%     elseif blockcons < 2
%         cons = [ncons*ones(1,2),... % first two easy
%             ncons*ones(1,8)-mod(1:8,2),... % then alternate between easy and 2nd easiest
%             psychsr_rand(ones(ncons,1)/ncons,num_loops-10,0,3)]; % random
    else
        nblocks = ceil(num_loops/blockcons);
        % set first block
        firstcon = firstbcon(randi(length(firstbcon)));
        othercons = setxor(firstcon,1:ncons);
        cons = [firstcon othercons(randperm(ncons-1))];
        % set all other blocks
        for i = 1:nblocks-ncons
            cons = [cons randperm(ncons)];
        end
        cons = reshape(repmat(cons,blockcons,1),1,[]);
        cons = [repmat(cons(1),1,firstbnum) cons(2:end)];
        cons = cons(1:num_loops);
    end
else
    cons = ones(1,num_loops);
end
if nt_p < 1
    contrasts = [contrasts -1];
    for i = 1:num_loops
        if targets(i) == 2 && rand>=nt_p
            cons(i) = length(contrasts); % make some nontargets "blank" (neg contrast)
        end
    end
end

%% randomize response delays
resp_delays = sort(resp_delays); %sort ascending
if length(resp_delays)>1
    ndels = length(resp_delays);
    if blockdels < 2
        rdels = [ones(1,2),... % first two easy
            psychsr_rand(ones(ndels,1)/ndels,num_loops-2,0,3)];
        rdels = [repmat(rdels(1),1,firstbdnum) rdels(2:end)];
        rdels = rdels(1:num_loops);
    else
        nblocks = ceil(num_loops/blockdels);
        % set first block
        firstdel = firstbdel(randi(length(firstbdel)));
        otherdels = setxor(firstdel,1:ndels);
        rdels = [firstdel otherdels(randperm(ndels-1))];
        % set all other blocks
        for i = 1:nblocks-ndels
            rdels = [rdels randperm(ndels)];
        end
        rdels = reshape(repmat(rdels,blockdels,1),1,[]);
        rdels = rdels(1:num_loops);
    end
else
    rdels = ones(1,num_loops);
end

%% randomize laser

if response.mode == 7
    lasers = zeros(1,num_loops);    
    lasers(rdels == laser_ind) = randi(numel(response.laser_onset),[1 sum(rdels == laser_ind)]);    
    if exist('laser_per','var')
        x = find(rdels == laser_ind);
        x(rand(length(x),1)<laser_per) = [];
        lasers(x) = 0;
    end
    %     lasers(rdels == laser_ind) = randi(numel(response.laser_amp),[1 sum(rdels == laser_ind)]);
    lasers(1:response.n_nolaser) = 0;     
%     lasers = [zeros(1,n_nolaser), psychsr_rand(1-per_laser,num_loops-n_nolaser,0,3,ones(1,n_nolaser))-1];
else
    lasers = zeros(1,num_loops);
end

%% make stimuli
k = 1;
for i = 1:num_loops
    duration(k) = iti;
    stim_type{k} = 'blank';
    if i>1
        response_delay(k) = resp_delays(rdels(i-1)); 
        laser_on(k) = lasers(i-1);
    end
    k = k+1;
        
    duration(k) = delay;
    stim_type{k} = 'blank';
    response_delay(k) = resp_delays(rdels(i));
    laser_on(k) = lasers(i);
    k = k+1;
    
    duration(k) = response.response_time+resp_delays(rdels(i));
    stim_type{k} = 'grating';
    spat_freq(k) = sfs;
    rand_phase(k) = 0;    
    contrast(k) = contrasts(cons(i));
    if exist('cfos_flag','var') && cfos_flag == 1 && lasers(i) ~= 1
        contrast(k) = 0;
    end
    orientation(k) = orients(oris(i));
    temp_freq(k) = tfs(targets(i));
    response_delay(k) = resp_delays(rdels(i));
    laser_on(k) = lasers(i);
    rect{k} = aperture;
    k = k+1;
end

if reload == 1
    load([folder file])
    stimuli = data.stimuli;
    %     stimuli.duration(3:3:end) = response.response_time;
    %     stimuli.total_duration = total_duration;
else
    stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,...
        orientation,spat_freq,temp_freq,cue_tone,on_time,...
        stim_side,rand_phase,response_delay,laser_on,rect,sine_gratings,blackblank);
end

%% input parameters into psychsr
params = psychsr_zip(mouse,screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

%% print out behavioral summary
targ = data.stimuli.orientation(3:3:3*length(data.response.n_overall))==data.response.t_ori;
if ~isempty(data.response.n_overall)
    if strcmp(getenv('computername'),'VISSTIM-2P4') && mode >0
        l = length(data.response.n_overall);
    else
        l = find(data.response.n_overall & targ, 1,'last'); % find last hit trial
    end
    if isempty(l); l = length(data.response.n_overall); end;
    t = (1:length(targ))<=l;
    h = round(mean(data.response.n_overall(targ & t))*100);
    f = round(mean(1-data.response.n_overall(~targ & t))*100);
    if data.response.p_targ_after_cr > 0 || data.response.p_ntarg_after_fa > 0
        ind = find(~targ);
        ind = ind(diff([0 ind])>1);
        if ~isempty(find(~t,1))
            ind(ind>=find(~t,1)) = [];
        end
        f2 = round(mean(1-data.response.n_overall(ind))*100);
    end
    d = round(mean(data.response.n_delay(t))*100);
    str = sprintf('Mouse %2d\n%s\n',data.mouse,data.response.description);
    str = [str, sprintf('%1d min, %1d hits\n',round(data.presentation.stim_times(3*l)/60),length(data.response.rewards))];
    if data.response.p_targ_after_cr > 0 || data.response.p_ntarg_after_fa > 0
        str = [str, sprintf('%2d/%1d~%1d/%1d\n',h,f,f2,d)];
    else
        str = [str, sprintf('%2d/%1d/%1d\n',h,f,d)];
    end
    str = [str, sprintf('est: %1.2f mL\n',length(data.response.rewards)*data.response.reward_amt/1000)];
    fprintf('\n\n');
    fprintf('%s',str);
    w = [];
    while isempty(w) || isnan(w) || ~isnumeric(w)
        try w = input('Amount of water consumed (mL): ');
        catch
            fprintf('\n');
            w = [];
        end
    end
    str = [str, sprintf('act: %1.2f mL\n',w)];
    data.response.summary = str;
end

%% save
date = clock;
folder = sprintf('../behaviorData/mouse %04d',mouse);
if ~isdir(folder); mkdir(folder); end
uisave('data',sprintf('%s/%4d%02d%02d_discrim_%04d',folder,date(1),date(2),date(3),mouse));

end