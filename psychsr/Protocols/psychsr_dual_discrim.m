function data = psychsr_dual_discrim()
% lick-left/lick-right discrimination task
% one-screen

%% variable parameters
folder = psychsr_go_root();

mouse = input('Mouse #: ');

%% default parameters

% stimulus parameters
response.task = 'dots';
response.t_ori = 180;
response.nt_ori = 0;
t_speed = 100;
nt_speed = 100;
con = 1; % coherence for dots
dot_color = [0 0 0]; blackblank = 0; % black on gray
dsize = 40;
ddens = 0.15;
win = [3 3]; % which screen? 1=left, 2=right, 3=both;
aperture = [0 0 1 1;... % unused
    0 0 1 1];
sf = 0.05; % unused
sounds = [0 0]; % sounds associated with each stimulus

% movie code
movies = [1 1]; % movies for LEFT vs RIGHT
mfolder = [folder '\movies\rvr'];
indexVector=1:5;
mfiles = cell(length(indexVector),1);
for i=1:length(indexVector)
    mfiles{i} = [mfolder '\mov' sprintf('%1d',indexVector(i)) '.mat'];
end
crop_movie = 1;

% timing
total_duration = (60)*60; % maximum session time
delay_dur = 0.1; % pre-stimulus
stim_dur = 4; % stimulus + response window
response.target_time = 2; % stimulus
iti_dur = 4;
iti_var = 0; % vary iti duration

% response window
response.go_cue = 6; % sound to play at beginning of response window
response.grace_period = 0.5; % licks during first X sec dont count
response.first_lick = 1; % count behavior based on first lick
response.lick_threshold = 1; % how many consecutive licks on one side before reward
response.p_reward = 1;  % probability of reward, given a correct choice
response.iri = Inf; % multiple rewards? inter-reward interval
response.stop_grating = 0;  % 1 = turn off grating after first lick. 2 = stop movement of grating
response.leave_grating = 0; % leave grating on until first lick

% punishment
response.punish = 1; % punish?
response.punish_timeout = 0;
response.punish_every_lick = 1; % sound for every wrong lick
response.punish_time = 0; % airpuff solenoid time
response.double_timeout = 0; % time out if they sample both ports
response.extend_iti = 1; % extend iti if they continue licking

% auto reward
response.auto_reward = 0; %-1 = unlimited auto rewards
response.auto_reward_every = 1; % every N trials
response.auto_reward_num = 1; % on the nth trial
response.auto_reward_time = 0.5; % time after stim onset
response.auto_reward_amt = 4;

% trial ordering
side_mode = 'block'; % random, alternate, block
blocksize = [4 4]; % nleft, nright
response.blockrewards = 0; % how many rewards before switching blocks?
response.consecFlag = 0;    % must be consecutive (misses are ok)
response.auto_stop = 7; % stop after X misses
response.antibias_repeat = 0; % probability of repeating incorrect stimulus


% lateral spout positioning
response.spout_xpos = [10 5]; % spout position for Rig #2, Rig #4
response.auto_adjust_spout = 0;

% spout extension/retraction
response.extend_onset = -3;
response.retract_onset = Inf;

% sound amplitude
sound.tone_amp = 0.5;
sound.tone_time = 0.5;
sound.noise_amp = 0.3;
sound.noise_time = 0.1;

% trigger
card.trigger_mode = 'key';

%% mouse-specific parameters

switch mouse
    
    case 1002
        response.spout_xpos = [10.5 4.5];
    case 1004
        amt = 7; % reward amount (uL)
        
        response.auto_reward = -1; %-1 = unlimited auto rewards
        response.auto_reward_every = 4; % every N trials
        response.auto_reward_amt = amt;
        blocksize = [4 4]; % nleft, nright
        
        response.spout_xpos = [9.25 5];
    case 1005
        amt = 8; % reward amount (uL)
        
        response.auto_reward = -1; %-1 = unlimited auto rewards
        response.auto_reward_every = 4; % every N trials
        response.auto_reward_amt = amt;
        
        blocksize = [4 4]; % nleft, nright
        
        response.spout_xpos = [10.75 4.5];
    case 1006
        response.spout_xpos = [5.75 4.5];
    case 1007
        amt = 8;
        side_mode = 'random';
        con = 1;
        dsize = 60;
        ddens = 0.2;
        win = [1 2];
        
        response.grace_period = 0.25;
        stim_dur = 3;
        response.target_time = 3;
        
        response.go_cue = 0;
        response.auto_reward = -1; %-1 = unlimited auto rewards
        response.auto_reward_every = 4; % every N trials
        response.auto_reward_amt = 4;
        response.auto_reward_time = 1; % time after stim onset
        
        response.iri = Inf;
        response.first_lick = 1; % count behavior based on first lick
        response.punish = 1;
        response.punish_every_lick = 1;
        
        %         response.spout_xpos = [7 5];
        response.antibias_repeat = 0.6;
        %         screen.dual = 1;
        %
        %
        %         amt = 8; % reward amount (uL)
        %
        %         response.auto_reward = -1; %-1 = unlimited auto rewards
        %         response.auto_reward_every = 4; % every N trials
        %         response.auto_reward_amt = amt;
        %         blocksize = [4 4]; % nleft, nright
        
        response.spout_xpos = [10.5 4.5];
    case 1008
        amt = 8;
        side_mode = 'random';
        con = 1;
        dsize = 60;
        ddens = 0.2;
        win = [1 2];
        
        response.grace_period = 0.25;
        stim_dur = 3;
        response.target_time = 3;
        
        response.go_cue = 0;
        response.auto_reward = -1; %-1 = unlimited auto rewards
        response.auto_reward_every = 4; % every N trials
        response.auto_reward_amt = 4;
        response.auto_reward_time = 1; % time after stim onset
        
        response.iri = Inf;
        response.first_lick = 1; % count behavior based on first lick
        response.punish = 1;
        response.punish_every_lick = 1;
        
        %         response.spout_xpos = [7 5];
        response.antibias_repeat = 0.6;
        screen.dual = 1;
        %         amt = 3;
        %
        %         side_mode = 'random';
        %         con = 1;
        %         dsize = 300;
        %         ddens = 0; % one dot
        %         t_speed = 100;
        %         nt_speed = 100;
        %
        %         response.first_lick = 0; % count behavior based on first lick
        %         response.iri = 1; % multiple rewards? inter-reward interval
        %
        %         response.auto_reward = 0; %-1 = unlimited auto rewards
        %         response.auto_reward_every = 4; % every N trials
        %         response.auto_reward_amt = amt;
        %
        %         blocksize = [4 4]; % nleft, nright
        response.spout_xpos = [8.5 4.5];
    case 1009
        amt = 8;
        side_mode = 'random';
        con = 1;
        dsize = 60;
        ddens = 0.2;
        win = [1 2];
        
        response.grace_period = 0.25;
        stim_dur = 3;
        response.target_time = 3;
        
        response.go_cue = 0;
        response.auto_reward = -1; %-1 = unlimited auto rewards
        response.auto_reward_every = 4; % every N trials
        response.auto_reward_amt = 4;
        response.auto_reward_time = 1; % time after stim onset
        
        response.iri = Inf;
        response.first_lick = 1; % count behavior based on first lick
        response.punish = 1;
        response.punish_every_lick = 1;
        
        %         response.spout_xpos = [7 5];
        response.antibias_repeat = 0.6;
        screen.dual = 1;
        
        %         amt = 8;
        %         response.auto_reward = -1; %-1 = unlimited auto rewards
        %         response.auto_reward_every = 4; % every N trials
        %         response.auto_reward_amt = amt;
        %         blocksize = [4 4]; % nleft, nright
        
        response.spout_xpos = [9.25 4.5];
    case 1010
        
        response.task = 'movie';
        amt = 8;
        side_mode = 'random';
        movies = [1 4];
        win = [1 2];
        
        response.grace_period = 0.25;
        stim_dur = 3;
        response.target_time = 3;
        
        response.go_cue = 0;
        response.auto_reward = -1; %-1 = unlimited auto rewards
        response.auto_reward_every = 1; % every N trials
        response.auto_reward_amt = 4;
        response.auto_reward_time = 1; % time after stim onset
        
        response.iri = 2;
        response.first_lick = 1; % count behavior based on first lick
        response.punish = 1;
        response.punish_every_lick = 0;
        
        response.spout_xpos = [8 5];
        response.antibias_repeat = 0.5;
        screen.dual = 0;
        
        
        %         amt = 8;
        %
        %         side_mode = 'random';
        %         con = 1;
        %         dsize = 300;
        %         ddens = 0; % one dot
        %         t_speed = 100;
        %         nt_speed = 100;
        %
        %         response.auto_reward = -1; %-1 = unlimited auto rewards
        %         response.auto_reward_every = 5; % every N trials
        %         response.auto_reward_amt = amt;
        % %         blocksize = [4 2]; % nleft, nright
        %         response.spout_xpos = [7.0 4.5];
        %
        %         response.antibias_repeat = 0.9;
        
    case 1011
        response.task = 'movie';
        amt = 8;
        side_mode = 'random';
        movies = [1 4];
        win = [1 2];
        
        response.grace_period = 0.25;
        stim_dur = 3;
        response.target_time = 3;
        
        response.go_cue = 0;
        response.auto_reward = -1; %-1 = unlimited auto rewards
        response.auto_reward_every = 4 ; % every N trials
        response.auto_reward_amt = 4;
        response.auto_reward_time = 1; % time after stim onset
        
        response.iri = 2;
        response.first_lick = 1; % count behavior based on first lick
        response.punish = 1;
        response.punish_every_lick = 0;
        
        response.spout_xpos = [7 5];
        response.antibias_repeat = 0.75;
        screen.dual = 0;
        
    case 2000
        amt = 8;
        response.task = 'movie';
        movies = [1 2];
        
        
    otherwise
end

[amt time b] = psychsr_set_reward(amt);
[amt2 time2 b2] = psychsr_set_quinine(amt);

%% constant parameters
response.reward_time(2,:) = time;
response.reward_amt(2,:) = amt;
response.reward_cal(2,:) = b;

response.reward_time(1,:) = time2;
response.reward_amt(1,:) = amt2;
response.reward_cal(1,:) = b2;

screen.keep = 1;
% card.ai_chan = [0 3]; % dual lick channels
response.mode = 8; % dual
response.feedback_fn = @psychsr_dual_discrim_feedback;
presentation.frame_rate = 30;

%% stimuli
% define your stimuli
ori = [response.t_ori response.nt_ori];
tf = [t_speed nt_speed];

num_loops = ceil(total_duration/(delay_dur-iti_var/2+iti_dur+stim_dur));
num_stimuli = num_loops*3;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli); % right
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = NaN*ones(1,num_stimuli);
movie_file = cell(1,num_stimuli);
cue_tone = zeros(1,num_stimuli);
stim_id = zeros(1,num_stimuli);
rect = cell(1,num_stimuli);
sound_id = zeros(1,num_stimuli);
autoflag = zeros(1,num_stimuli);
dot_size = zeros(1,num_stimuli);
dot_density = zeros(1,num_stimuli);
window = zeros(1,num_stimuli);

% default stimulus parameters for LEFT versus RIGHT
stimparams = struct;
for i = 1:2
    if strcmp(response.task,'dots')
        stimparams(i).stim_type = {'dots'};
    elseif strcmp(response.task,'movie')
        stimparams(i).stim_type = {'movie'};
    else
        stimparams(i).stim_type = {'grating'};
    end
    stimparams(i).orientation = ori(i);
    stimparams(i).temp_freq = tf(i);
    stimparams(i).contrast = con;
    stimparams(i).rect = {aperture(i,:)};
    stimparams(i).sound_id = sounds(i);
    stimparams(i).window = win(i);
    stimparams(i).movie_file = mfiles(movies(i));
    stimparams(i).movie_num = i; % movie index
end

switch side_mode
    case 'random'
        sides = psychsr_rand(0.5,num_loops,0,3); % 1 = left, 2 = right
    case 'alternate'
        sides = 1+mod(1:num_loops,2);
    case 'block'
        if length(blocksize) == 1; blocksize = blocksize*[1 1]; end
        if rand>0.5
            sides = [2*ones(1,blocksize(2)),ones(1,blocksize(1))];
        else
            sides = [ones(1,blocksize(1)),2*ones(1,blocksize(2))];
        end
        sides = repmat(sides,1,ceil(num_loops/sum(blocksize)));
        sides = sides(1:num_loops);
end
if response.blockrewards > 0
    sides = ((rand>0.5)+1)*ones(1,num_loops);
end

k = 1;
for i = 1:num_loops
    duration(k) = iti_dur+ iti_var*(rand-0.5);
    stim_type{k} = 'blank';
    movie_file{k} = '';
    k = k+1;
    
    duration(k) = delay_dur;
    stim_type{k} = 'blank';
    movie_file{k} = '';
    k = k+1;
    
    duration(k) = stim_dur;
    if strcmp(response.task,'dots')
        stim_type{k} = 'dots';
        dot_size(k) = dsize;
        dot_density(k) = ddens;
    elseif strcmp(response.task,'movie')
        stim_type{k} = 'movie';
    else
        stim_type{k} = 'grating';
    end
    orientation(k) = ori(sides(i));
    stim_id(k) = sides(i);
    contrast(k) = con;
    spat_freq(k) = sf;
    temp_freq(k) = tf(sides(i));
    sound_id(k) = sounds(sides(i));
    rect{k} = aperture(sides(i),:);
    window(k) = win(sides(i));
    movie_file(k) = mfiles(movies(sides(i)));
    
    if response.auto_reward ~= 0
        autoflag(k) = mod(i-1,response.auto_reward_every)+1==response.auto_reward_num;
    end
    k = k+1;
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,...
    orientation,spat_freq,temp_freq,contrast,movie_file,crop_movie,cue_tone,stim_id,rect,sound_id,...
    stimparams,blackblank,autoflag,dot_color,dot_size,dot_density,window);

%% input parameters into psychsr
params = psychsr_zip(mouse,screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

%%
ntrials = find(abs(data.response.choice)>0,1,'last');
data.response.stim(ntrials+1:end) = nan;

all_a = ~isnan(data.response.stim);
all_l = data.response.stim==1;
all_r = data.response.stim==2;
c = data.response.choice;
o = data.response.outcome;
e = data.response.early;
choice_l_all = round([mean(c(all_l)==1) mean(c(all_l)==2)]*100);
choice_r_all = round([mean(c(all_r)==1) mean(c(all_r)==2)]*100);
out_l_all = round([mean(o(all_l)==1) mean(o(all_l)==-1)]*100);
out_r_all = round([mean(o(all_r)==1) mean(o(all_r)==-1)]*100);
early_all = round([mean(e(all_a)==1) mean(e(all_a)==-1)]*100);
if isempty(data.response.licks)
    bias_all = NaN;
else
    leftlicks = sum(data.response.licks(:,1)~=0);
    bias_all = round(leftlicks/size(data.response.licks,1)*100);
end
str = '';
str = [str,sprintf('Mouse %d\n',data.mouse)];
str = [str,sprintf('%s, sp=%1.2f, bl=%d\n',data.response.task,data.response.spout_xpos(1),mean(data.response.blockrewards))];
str = [str,sprintf('%d mins, %d hits\n',round(max(data.presentation.stim_times)/60),length(data.response.rewards))];
if isfield(data.response,'spout_pos')
    str = [str,sprintf('spout pos: %1.2f\n',mode(data.response.spout_pos))];
end

str = [str,sprintf('\nFIRST LICK:')];
str = [str,sprintf('\n         TOTAL\n')];
str = [str,sprintf('LEFT%%   %3d%%/%3d%% of %d\n',choice_l_all,sum(all_l))];
str = [str,sprintf('RIGHT%%  %3d%%/%3d%% of %d\n',choice_r_all,sum(all_r))];
str = [str,sprintf('BIAS%%   %3d%%/%3d%% of %d\n',bias_all,100-bias_all,size(data.response.licks,1))];

str = [str,sprintf('\nREWARD/PUNISH:')];
str = [str,sprintf('\n        TOTAL\n')];
str = [str,sprintf('EARLY%%  %3d%%/%3d%% of %d\n',early_all,sum(all_a))];
str = [str,sprintf('LEFT%%   %3d%%/%3d%% of %d\n',out_l_all,sum(all_l))];
str = [str,sprintf('RIGHT%%  %3d%%/%3d%% of %d\n\n',out_r_all,sum(all_r))];

fprintf('%s',str)
w = [];
while isempty(w) || isnan(w) || ~isnumeric(w)
    fprintf('\nAmount of water consumed (mL): ')
    try w = input('');
    catch
        fprintf('\n');
        w = [];
    end
end
str = [str, sprintf('act: %1.2f mL\n',w)];
data.response.summary = str;

%% save
date = clock;
folder = sprintf('C:/Dropbox/MouseAttention/behaviorData/mouse %04d',mouse);
if ~isdir(folder); mkdir(folder); end
uisave('data',sprintf('%s/%4d%02d%02d_dual_discrim_%04d',folder,date(1),date(2),date(3),mouse));


end