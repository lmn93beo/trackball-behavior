function psychsr_discrim_stages_HS(stage)

str = '';
switch stage

    % *** 02/29/2016 HS *** ***********************************************
    case 65
        str = verbatim;
        %{
response.description = 'Engage: 50%';
response.stagenum = 65;
nt_speed = 2;                   % nontarget temporal frequency
response.extend_onset = 0;      % time after grating onset
iti = 3;
        %}        
% response.retract_onset = 1.5;   % time after grating onset (Inf = do not retract every trial)
% resp_delays = 2;                % stimulus-response delay
% response.target_time = 1.5+resp_delays;     % length of time grating is actually on
    % *** 02/29/2016 HS *** ***********************************************

    case {1, -1, 'Trainlick'}
        str = verbatim;
        %{
data = psychsr_train_lick(mouse);
data.response.description = 'Trainlick';
if ~isempty(data.response.licks)
    str = sprintf('Mouse %2d\n%s\n',data.mouse,data.response.description);
    str = [str, sprintf('%1d min, %1d hits\n',round(data.presentation.flip_times(end)/60),length(data.response.rewards))];
    str = [str, sprintf('%1d licks, start after %s\n',length(data.response.licks),datestr(data.response.licks(1)/86400,'MM:SS'))];
    str = [str, sprintf('est: %1.2f mL\n',length(data.response.rewards)*data.response.reward_amt/1000)];
    fprintf('\n\n');
    fprintf('%s',str);
    w = str2double(input('Amount of water consumed (mL): '));
    str = [str, sprintf('act: %1.2f mL\n',w)];
    data.response.summary = str;
end;
date = clock;
folder = sprintf('../behaviorData/Hiroki/mouse %04d',mouse);
if ~isdir(folder); mkdir(folder); end;
uisave('data',sprintf('%s/%4d%02d%02d_trainlick_%04d',folder,date(1),date(2),date(3),mouse));
error('NO ERROR: Trainlick program complete.');
        
        %}
    case {'Trainlick2'}
        str = verbatim;
        %{
data = psychsr_train_lick2(mouse);
data.response.description = 'Trainlick2';
if ~isempty(data.response.licks)
    str = sprintf('Mouse %2d\n%s\n',data.mouse,data.response.description);
    str = [str, sprintf('%1d min, %1d hits\n',round(data.presentation.flip_times(end)/60),length(data.response.rewards))];
    str = [str, sprintf('%1d licks, start after %s\n',length(data.response.licks),datestr(data.response.licks(1)/86400,'MM:SS'))];
    str = [str, sprintf('est: %1.2f mL\n',length(data.response.rewards)*data.response.reward_amt/1000)];
    fprintf('\n\n');
    fprintf('%s',str);
    w = str2double(input('Amount of water consumed (mL): '));
    str = [str, sprintf('act: %1.2f mL\n',w)];
    data.response.summary = str;
end;
date = clock;
folder = sprintf('../behaviorData/Hiroki/mouse %04d',mouse);
if ~isdir(folder); mkdir(folder); end
uisave('data',sprintf('%s/%4d%02d%02d_trainlick2_%04d',folder,date(1),date(2),date(3),mouse));
error('NO ERROR: Trainlick2 program complete.');
        %}
   case {2, 'Engage: 100%, 4s'}
        str = verbatim;
        %{
response.description = 'Engage: 100%, 4s';
response.stagenum = 2;
per_targ = 1;                   % percent of stimuli that are targets
max_targ = Inf;                 % max # of targets in a row
response.iri = 0.5;         % multiple rewards - inter-reward interval
response.response_time = 4;   % response window
response.target_time = 4;     % time grating is displayed        
response.extend_iti = 1;    % extend iti until animal stops licking for 1 second
cue_sound = 0;                  % 4=right, 5=left, 2=both, 0=none
        %}
        
    case {3, 'Engage: 100%'} % 10/13/215 HS
        str = verbatim;
        %{
response.description = 'Engage: 100%';
response.stagenum = 3;
per_targ = 1;                   % percent of stimuli that are targets
max_targ = Inf;                 % max # of targets in a row
response.response_time = 2;   % response window
response.target_time = 2;     % time grating is displayed        
        %}
        
%     case {3, 'Engage: 100%'}
%         str = verbatim;
%         %{
% response.description = 'Engage: 100%';
% response.stagenum = 3;
% per_targ = 1;                   % percent of stimuli that are targets
% max_targ = Inf;                 % max # of targets in a row
%         %}
% 10/13/215 HS

    case {4, 'Engage: 75%'}
        str = verbatim;
        %{
response.description = 'Engage: 75%';
response.stagenum = 4;
ntarget = 5;                    % # of targets at beginning of session
per_targ = 0.75;                % percent of stimuli that are targets
max_targ = 4;                   % max # of targets in a row
        %}
    case {5, 'Engage: 60%'}
        str = verbatim;
        %{
response.description = 'Engage: 60%';
response.stagenum = 5;
ntarget = 8;                    % # of targets at beginning of session
per_targ = 0.6;                 % percent of stimuli that are targets
max_targ = 4;                   % max # of targets in a row
        %}
    case {6, 'Engage: 50%'} % default
        str = verbatim;
        %{
response.description = 'Engage: 50%';
response.stagenum = 6;
        %}
    case {7, 'Engage: RP'}
        str = verbatim;
        %{
response.description = 'Engage: RP';
response.stagenum = 7;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end;
        %}
    case {8, 'Engage: NT=1'}
        str = verbatim;
        %{
response.description = 'Engage: NT=1';
response.stagenum = 8;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end;
nt_speed = 1;                   % nontarget temporal frequency
        %}
    case {9, 'Engage: NT=2'}
        str = verbatim;
        %{
response.description = 'Engage: NT=2';
response.stagenum = 9;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end
nt_speed = 2;                   % nontarget temporal frequency
        %}
    case {10, 'Engage: SR=-1'}
        str = verbatim;
        %{
response.description = 'Engage: SR=-1';
response.stagenum = 10;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end
nt_speed = 2;                   % nontarget temporal frequency
response.extend_onset = -1;      % time after grating onset
response.retract_onset = 1.5;   % time after grating onset (Inf = do not retract every trial)
response.nt_on_timeout = 0;
        %}
    case {11, 'Engage: SR=0'}
        str = verbatim;
        %{
response.description = 'Engage: SR=0';
response.stagenum = 11;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end
nt_speed = 2;                   % nontarget temporal frequency
response.extend_onset = 0;      % time after grating onset
response.retract_onset = 1.5;   % time after grating onset (Inf = do not retract every trial)
resp_delays = 0;                % stimulus-response delay
response.target_time = 1.5+resp_delays;     % length of time grating is actually on
iti = 3;
        %}
    case {12, 'Engage: SR=1'}
        str = verbatim;
        %{
response.description = 'Engage: SR=1';
response.stagenum = 12;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end
nt_speed = 2;                   % nontarget temporal frequency
response.extend_onset = 0;      % time after grating onset
response.retract_onset = 1.5;   % time after grating onset (Inf = do not retract every trial)
resp_delays = 1;                % stimulus-response delay
response.target_time = 1.5+resp_delays;     % length of time grating is actually on
iti = 3;
        %}
    case {13, -11, 'Engage: SR=2'}
        str = verbatim;
        %{
response.description = 'Engage: SR=2';
response.stagenum = 13;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end
nt_speed = 2;                   % nontarget temporal frequency
response.extend_onset = 0;      % time after grating onset
response.retract_onset = 1.5;   % time after grating onset (Inf = do not retract every trial)
resp_delays = 2;                % stimulus-response delay
response.target_time = 1.5+resp_delays;     % length of time grating is actually on
iti = 3;
        %}        
    case {20, 'Engage: vOri'}
        str = verbatim;
        %{
response.description = 'Engage: vOri';
response.stagenum = 20;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end
nt_speed = 2;                   % nontarget temporal frequency
response.extend_onset = 0;      % time after grating onset
response.retract_onset = 1.5;   % time after grating onset (Inf = do not retract every trial)
resp_delays = 2;                % stimulus-response delay
response.target_time = 1.5+resp_delays;     % length of time grating is actually on
nt_ori = [45 0.01];
nt_ori_p = [0.5 0.5];
iti = 3;
        %}
    case {25, 'Engage: vCon'}
        str = verbatim;
        %{
response.description = 'Engage: vCon';
response.stagenum = 25;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end
nt_speed = 2;                   % nontarget temporal frequency
response.extend_onset = 0;      % time after grating onset
response.retract_onset = 1.5;   % time after grating onset (Inf = do not retract every trial)
resp_delays = 2;                % stimulus-response delay
response.target_time = 1.5+resp_delays;     % length of time grating is actually on
contrasts = [0.125 0.25 0.5 1];
blockcons = 20;
firstbcon = 2:4;          % which contrast(s) to use in first block? (use integers)
iti = 3;
        %}
    case {26, 'Engage: LowCon 50%'}
        str = verbatim;
        %{
response.description = 'Engage: LowCon';
response.stagenum = 26;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end
nt_speed = 2;                   % nontarget temporal frequency
response.extend_onset = 0;      % time after grating onset
response.retract_onset = 1.5;   % time after grating onset (Inf = do not retract every trial)
resp_delays = 2;                % stimulus-response delay
response.target_time = 1.5+resp_delays;     % length of time grating is actually on
contrasts = [0.5 0.5];
blockcons = 1;                  % vary contrast in blocks of this size
firstbcon = 1;                  % which contrast(s) to use in first block? (use integer)
iti = 3;
        %}
    case {27, 'Engage: LowCon 25%'}
        str = verbatim;
        %{
response.description = 'Engage: LowCon';
response.stagenum = 26;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end
nt_speed = 2;                   % nontarget temporal frequency
response.extend_onset = 0;      % time after grating onset
response.retract_onset = 1.5;   % time after grating onset (Inf = do not retract every trial)
resp_delays = 2;                % stimulus-response delay
response.target_time = 1.5+resp_delays;     % length of time grating is actually on
contrasts = [0.25 0.25];
blockcons = 1;                  % vary contrast in blocks of this size
firstbcon = 1;                  % which contrast(s) to use in first block? (use integer)
iti = 3;
        %}
    case {28, 'Engage: LowCon 12%'}
        str = verbatim;
        %{
response.description = 'Engage: LowCon';
response.stagenum = 26;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end
nt_speed = 2;                   % nontarget temporal frequency
response.extend_onset = 0;      % time after grating onset
response.retract_onset = 1.5;   % time after grating onset (Inf = do not retract every trial)
resp_delays = 2;                % stimulus-response delay
response.target_time = 1.5+resp_delays;     % length of time grating is actually on
contrasts = [0.125 0.125];
blockcons = 1;                  % vary contrast in blocks of this size
firstbcon = 1;                  % which contrast(s) to use in first block? (use integer)
iti = 3;
        %}
    case {30, -12, 'STM: Del=0'}
        str = verbatim;
        %{
response.description = 'STM: Del=0';
response.stagenum = 30;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end
nt_speed = 2;                   % nontarget temporal frequency
response.target_time = 2;       % length of time grating is actually on
response.extend_onset = 0;      % time after grating onset
response.retract_onset = 1.5;   % time after grating onset (Inf = do not retract every trial)
stmdelay = 0;                   % stimulus offset-response delay
resp_delays = response.target_time+stmdelay;       % stimulus-response delay
response.nt_on_timeout = 0;
iti = 3;
        %}
    case {31, 'STM: Del=0~1'}
        str = verbatim;
        %{
response.description = 'STM: Del=0~1';
response.stagenum = 31;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end
nt_speed = 2;                   % nontarget temporal frequency
response.target_time = 2;       % length of time grating is actually on
response.extend_onset = 0;      % time after grating onset
response.retract_onset = 1.5;   % time after grating onset (Inf = do not retract every trial)
stmdelay = [0 1];               % stimulus offset-response delay
resp_delays = stmdelay + response.target_time;    % stimulus-response delay
response.nt_on_timeout = 0;
blockdels = 1;
iti = 3;
        %}
    case {32, 'STM: Del=0~2'}
        str = verbatim;
        %{
response.description = 'STM: Del=0~2';
response.stagenum = 32;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end
nt_speed = 2;                   % nontarget temporal frequency
response.target_time = 2;       % length of time grating is actually on
response.extend_onset = 0;      % time after grating onset
response.retract_onset = 1.5;   % time after grating onset (Inf = do not retract every trial)
stmdelay = [0 1 2];             % stimulus offset-response delay
resp_delays = stmdelay + response.target_time;    % stimulus-response delay
response.nt_on_timeout = 0;
blockdels = 1;
iti = 3;
        %}
    case {33, 'STM: Del=0~3'}
        str = verbatim;
        %{
response.description = 'STM: Del=0~3';
response.stagenum = 33;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end
nt_speed = 2;                   % nontarget temporal frequency
response.target_time = 2;       % length of time grating is actually on
response.extend_onset = 0;      % time after grating onset
response.retract_onset = 1.5;   % time after grating onset (Inf = do not retract every trial)
stmdelay = [0 1.5 3];           % stimulus offset-response delay
resp_delays = stmdelay + response.target_time;    % stimulus-response delay
response.nt_on_timeout = 0;
blockdels = 1;
iti = 3;
        %}
    case {34, 'STM: Del=0~4'}
        str = verbatim;
        %{
response.description = 'STM: Del=0~4';
response.stagenum = 34;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end
nt_speed = 2;                   % nontarget temporal frequency
response.target_time = 2;       % length of time grating is actually on
response.extend_onset = 0;      % time after grating onset
response.retract_onset = 1.5;   % time after grating onset (Inf = do not retract every trial)
stmdelay = [0 2 4];             % stimulus offset-response delay
resp_delays = stmdelay + response.target_time;    % stimulus-response delay
response.nt_on_timeout = 0;
blockdels = 1;
iti = 3;
        %}
    case {35, 'STM: Del=0~6'}
        str = verbatim;
        %{
response.description = 'STM: Del=0~6';
response.stagenum = 35;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end
nt_speed = 2;                   % nontarget temporal frequency
response.target_time = 2;       % length of time grating is actually on
response.extend_onset = 0;      % time after grating onset
response.retract_onset = 1.5;   % time after grating onset (Inf = do not retract every trial)
stmdelay = [0 3 3 6 6];             % stimulus offset-response delay
resp_delays = stmdelay + response.target_time;    % stimulus-response delay
response.nt_on_timeout = 0;
blockdels = 1;
iti = 3;
        %}
    case {36, 'STM: Laser'}
        str = verbatim;
        %{
response.description = 'STM: Laser';
response.stagenum = 36;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end
nt_speed = 2;                   % nontarget temporal frequency
response.target_time = 2;       % length of time grating is actually on
response.extend_onset = 0;      % time after grating onset
response.retract_onset = 1.5;   % time after grating onset (Inf = do not retract every trial)
stmdelay = [0 2 4 4];                 % stimulus offset-response delay
resp_delays = stmdelay + response.target_time;    % stimulus-response delay
laser_ind = 4; % which stm delay to turn on laser?
response.nt_on_timeout = 0;
iti = 3;
        
response.mode = 7;              % laser mode
if ~isfield(response,'laser_amp')
    w = [];
    while isempty(w) || isnan(w) || ~isnumeric(w)
        try w = input('Laser control voltage?: ');
        catch
            w = [];
        end
    end
    response.laser_amp = w; 
end    
response.laser_power = input('Laser power (mW)?: ','s');    % photometer
response.laser_target = input('Laser target(s)?: ','s');
response.laser_seq = 3;
if ~isfield(response,'laser_epoch')
    response.laser_epoch = input('Laser epoch (s/d/r/a)?: ','s');
end
switch response.laser_epoch
    case {'prestim', 'p'}  % turns on for 2s before stimulus (control)        
        response.laser_onset = -2.2; 
        response.laser_time = response.target_time+0.2;
    case {'stim', 's'}  % turns on 100ms before stimulus        
        response.laser_onset = -0.1; 
        response.laser_time = response.target_time+0.2;
    case {'delay', 'd'} % turns on 0.9s after stimulus turns off        
        response.laser_onset = response.target_time+0.9;
        response.laser_time = response.target_time+0.2;
    case {'delay_early'} % turns on 0s after stimulus turns off        
        response.laser_onset = response.target_time-0.1;
        response.laser_time = response.target_time+0.2;
    case {'delay_late'} % turns on 2s after stimulus turns off        
        response.laser_onset = response.target_time+1.9;
        response.laser_time = response.target_time+0.2;
    case {'resp', 'r'} % turns on 100ms before spout comes forward        
        response.laser_onset = response.target_time+max(stmdelay)-0.1;
        response.laser_time = response.target_time+0.2;
    case {'all', 'a'} % lasts whole trial
        response.laser_onset = -0.1; 
        response.laser_time = response.target_time+max(stmdelay)+response.response_time+0.2;
end;       
response.n_nolaser = 20;
        
        %}
    case {50, 'Motor control'} % no spout retract
        str = verbatim;
        %{
response.description = 'Motor control';
response.stagenum = 50;
nt_ori = 89.99;
per_targ = 0.3;
nt_speed = 2;
response.punish_timeout = 0;
sound.noise_amp = 0;
cue_sound = 0;
        %}        
    case {-2, 'Trainlick-SR'} % incomplete
        str = verbatim;
        %{
response.description = 'Trainlick-SR';
response.stagenum = -2;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end
response.iri = 1;               % mult rewards: inter-reward interval (seconds) 
per_targ = 1;                   % percent of stimuli that are targets
max_targ = Inf;                 % max # of targets in a row
nt_speed = 0;                   % nontarget temporal frequency
nt_p = 0;                     % percentage of non-blank nontargets
cue_sound = 0;
response.extend_onset = 0;      % time after grating onset
response.retract_onset = 10;   % time after grating onset (Inf = do not retract every trial)
resp_delays = 2;                % stimulus-response delay
response.target_time = 10+resp_delays;     % length of time grating is actually on
response.response_time = 10;
iti = 5;
        %}  
    case {-3, 'SR 3s'}
        str = verbatim;
        %{
response.description = 'SR 3s';
response.stagenum = -3;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end
response.iri = 1;               % mult rewards: inter-reward interval (seconds) 
per_targ = 1;                   % percent of stimuli that are targets
max_targ = Inf;                 % max # of targets in a row
nt_speed = 0;                   % nontarget temporal frequency
nt_p = 0;                     % percentage of non-blank nontargets
response.extend_onset = 0;      % time after grating onset
response.retract_onset = 3;   % time after grating onset (Inf = do not retract every trial)
resp_delays = 2;                % stimulus-response delay
response.target_time = 3+resp_delays;     % length of time grating is actually on
response.response_time = 3;
iti = 3;
        %}   
    case {-4, 'SR blank: 0% 1.5s'}
        str = verbatim;
        %{
response.description = 'SR blank: 0% 1.5s';
response.stagenum = -4;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end
per_targ = 1;                   % percent of stimuli that are targets
max_targ = Inf;                 % max # of targets in a row
nt_speed = 0;                   % nontarget temporal frequency
nt_p = 0;                     % percentage of non-blank nontargets
response.extend_onset = 0;      % time after grating onset
response.retract_onset = 1.5;   % time after grating onset (Inf = do not retract every trial)
resp_delays = 2;                % stimulus-response delay
response.target_time = 1.5+resp_delays;     % length of time grating is actually on
iti = 3;
        %}           
    case {-5, 'SR blank: 25%'}
        str = verbatim;
        %{
response.description = 'SR blank: 25%';
response.stagenum = -5;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end
ntarget = 8;                    % # of targets at beginning of session
per_targ = 0.75;                 % percent of stimuli that are targets
max_targ = 4;                   % max # of targets in a row        
nt_speed = 0;                   % nontarget temporal frequency
nt_p = 0;                     % percentage of non-blank nontargets
response.extend_onset = 0;      % time after grating onset
response.retract_onset = 1.5;   % time after grating onset (Inf = do not retract every trial)
resp_delays = 2;                % stimulus-response delay
response.target_time = 1.5+resp_delays;     % length of time grating is actually on
iti = 3;
        %}           
    case {-6, 'SR blank: 50%'} % decrease spout time
        str = verbatim;
        %{
response.description = 'SR blank: 50%';
response.stagenum = -6;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end
nt_speed = 0;                   % nontarget temporal frequency
nt_p = 0;                     % percentage of non-blank nontargets
response.extend_onset = 0;      % time after grating onset
response.retract_onset = 1.5;   % time after grating onset (Inf = do not retract every trial)
resp_delays = 2;                % stimulus-response delay
response.target_time = 1.5+resp_delays;     % length of time grating is actually on
iti = 3;
        %} 
    case {-7, 'SR NT: 50%'}
        str = verbatim;
        %{
response.description = 'SR NT: 50%';
response.stagenum = -7;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end
nt_speed = 0;                   % nontarget temporal frequency
nt_p = 0.5;                     % percentage of non-blank nontargets
response.extend_onset = 0;      % time after grating onset
response.retract_onset = 1.5;   % time after grating onset (Inf = do not retract every trial)
resp_delays = 2;                % stimulus-response delay
response.target_time = 1.5+resp_delays;     % length of time grating is actually on
iti = 3;
        %}  
    case {-8, 'SR NT: 100%'}
        str = verbatim;
        %{
response.description = 'SR NT: 100%';
response.stagenum = -8;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end
nt_speed = 0;                   % nontarget temporal frequency
response.extend_onset = 0;      % time after grating onset
response.retract_onset = 1.5;   % time after grating onset (Inf = do not retract every trial)
resp_delays = 2;                % stimulus-response delay
response.target_time = 1.5+resp_delays;     % length of time grating is actually on
iti = 3;
        %}        
    case {-9, 'SR NT=1'}
        str = verbatim;
        %{
response.description = 'SR NT=1';
response.stagenum = -9;
if response.mode < 5
    response.mode = 5;              % normal = 1; spout retract = 5
end
nt_speed = 1;                   % nontarget temporal frequency
response.extend_onset = 0;      % time after grating onset
response.retract_onset = 1.5;   % time after grating onset (Inf = do not retract every trial)
resp_delays = 2;                % stimulus-response delay
response.target_time = 1.5+resp_delays;     % length of time grating is actually on
iti = 3;
        %}        
end
if evalin('caller','response.mode==6 || response.mode == 7')
    str2 = verbatim;
    %{

response.description = [response.description ' (Q)'];
[~, response.punish_time, ~] = psychsr_set_quinine(3);
response.punish_timeout = 0;
    %}
    str = [str, str2];
end


evalin('caller',str);