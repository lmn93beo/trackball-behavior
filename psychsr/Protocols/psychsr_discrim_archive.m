
%% mouse specific parameters

switch mouse      
    case 0 % cfos
        cfos_flag = 1;
        psychsr_discrim_stages(36);
        [amt time b] = psychsr_set_reward(7);
        response.laser_epoch = 'stim';     
        response.laser_time = response.laser_time +0.1;
        stmdelay = [2.5];                 % stimulus offset-response delay
        resp_delays = stmdelay + response.target_time;    % stimulus-response delay
        laser_ind = 1; % which stm delay to turn on laser?
        response.n_nolaser = 0;
        response.laser_mode = 'end_ramp';
        response.laser_ramptime = 0.1;
        response.auto_stop = Inf;
        sound.tone_amp = 0;
        sound.noise_amp = 0;
        response.spout_time = 0; 
        
    case 1 % multiple voltages      
        response.mode = 6; % quinine
        response.laser_amp = [2.35 2.7 3.3 3.85 5];
        response.laser_epoch = 'resp';    
        psychsr_discrim_stages(36);
        [amt time b] = psychsr_set_reward(5);
        [~, response.punish_time, ~] = psychsr_set_quinine(2);
        per_targ = 0.6;      
        max_targ = 3;
        
        response.n_nolaser = 10;  
        response.laser_mode = 'end_ramp';
        response.laser_ramptime = 0.1;
        stmdelay = [0 0 0];                 % stimulus offset-response delay
        resp_delays = stmdelay + response.target_time;    % stimulus-response delay
        
        switch response.laser_epoch
            case 'stim' 
                response.laser_onset = -0.1; 
                response.laser_time = response.target_time+0.2;
            case 'resp'
                response.laser_onset = response.target_time+max(stmdelay)-0.1;
                response.laser_time = response.target_time+0.2;
        end
        laser_ind = 2; % which stm delay to turn on laser?

    case 80
        response.mode = 6; % quinine
        response.laser_epoch = 'resp';    
        psychsr_discrim_stages(36);
        [amt time b] = psychsr_set_reward(7);
        [~, response.punish_time, ~] = psychsr_set_quinine(2);
        per_targ = 0.4;      
        
        response.n_nolaser = 20;       
        stmdelay = [0 0];                 % stimulus offset-response delay
        resp_delays = stmdelay + response.target_time;    % stimulus-response delay
        
        switch response.laser_epoch
            case 'stim' 
                response.laser_onset = -0.1; 
                response.laser_time = response.target_time+0.2;
            case 'resp'
                response.laser_onset = response.target_time+max(stmdelay)-0.1;
                response.laser_time = response.target_time+0.2;
        end
        laser_ind = 2; % which stm delay to turn on laser?
        
    case 88
        response.mode = 6; % quinine
        response.laser_epoch = 'stim';        
        psychsr_discrim_stages(36);
        [amt time b] = psychsr_set_reward(7);
        per_targ = 0.4;
        aperture = [0.1 0.1 0.9 0.9];           % [xmin ymin xmax ymax] normalized to 1
        response.n_nolaser = 20;
        
    case 97
        response.mode = 6; % quinine
        psychsr_discrim_stages(30);
        
        % reversal code
        response.t_ori = 0.01;
        nt_ori = 90;
        response.auto_reward = -2; % # of free rewards, -2 means sound only
        response.auto_reward_time = 2.5; 
        response.punish_timeout = 4;
        response.nt_on_timeout = 1;
        
        response.target_time = 2;       
        ntarget = 3;
        [amt time b] = psychsr_set_reward(6); 
        [~, response.punish_time, ~] = psychsr_set_quinine(2);
        sine_gratings = 1;
        blockmins = 7.5;
        response.antibias = 1;

    case 102
        response.mode = 6; % quinine
        response.laser_epoch = 'stim';
        psychsr_discrim_stages(30);
        response.description = 'STM: Fast';
        [amt time b] = psychsr_set_reward(5);
        per_targ = 0.4;
        [~, response.punish_time, ~] = psychsr_set_quinine(1.5);
        response.punish_timeout = 4;
        response.antibias = 1;        
        response.n_nolaser = 20;
        response.nt_on_timeout = 0;
        aperture = [0.1 0.1 0.9 0.9];           % [xmin ymin xmax ymax] normalized to 1
        
        % multiple time points code
        stmdelay = 0;                 % stimulus offset-response delay
        response.target_time = 1;        
        resp_delays = stmdelay + 1;    % stimulus-response delay 
        response.laser_onset = [0 0.6];%[0 0.25 0.5 0.75]; % multiple on times
        response.laser_time = 0.25*ones(size(response.laser_onset));        
        laser_ind = 1; % which stm delay to turn on laser?
        laser_per = 2/3;
      
    case 104           
        response.mode = 6; % quinine
%         response.laser_epoch = 'resp';
        psychsr_discrim_stages(30);
%         stmdelay = [0 2 4 4];           % stimulus offset-response delay
%         resp_delays = stmdelay + response.target_time;    % stimulus-response delay
        [amt time b] = psychsr_set_reward(5);
        [~, response.punish_time, ~] = psychsr_set_quinine(3);
        response.antibias = 1;
%         firstbdnum = 15; % number in first block        
%         
%         response.punish_timeout = 4;
%         per_targ = 0.35;
        
        response.n_nolaser = 6;
        aperture = [0.1 0.1 0.9 0.9];           % [xmin ymin xmax ymax] normalized to 1
%         firstbdnum = 15; % number in first block
        
        
%         % multiple time points code
        stmdelay = 0;                 % stimulus offset-response delay
        response.target_time = 0.25;        
        resp_delays = stmdelay + 1;    % stimulus-response delay 
        response.laser_onset = [0 0.25 0.5]; % multiple on times
        response.laser_time = 0.25*ones(size(response.laser_onset));        
        laser_ind = 1; % which stm delay to turn on laser?
        laser_per = 0.75;

%         % stim+resp (0s)
%         stmdelay = 0;                 % stimulus offset-response delay
%         resp_delays = stmdelay + 2;    % stimulus-response delay 
%         response.laser_onset = [-0.1 1.9];
%         response.laser_time = [2.2 2.2];
%         laser_ind = 1; % which stm delay to turn on laser?
%         laser_per = 0.75;


        
        % old code                
%         response.laser_mode = 'end_ramp';
%         response.laser_ramptime = 0.1;        
%         response.laser_onset = [0 0.9]; % multiple on times
%         response.laser_time = 0.1+response.target_time-response.laser_onset;
        
 
    case 106
        response.mode = 6; % quinine
        psychsr_discrim_stages(30);
        
        % reversal code
        response.t_ori = 0.01;
        nt_ori = 90;
        response.auto_reward = 0;
%         response.auto_reward = -2; % # of free rewards, -2 means sound only
%         response.auto_reward_time = 2.7;
%         response.p_auto_reward = 0.5;
        
        response.target_time = 3.5;
%         response.nt_on_timeout = 0;
%         contrasts = [0.02 0.04 0.08 0.16 0.32 0.64];%[0.08 0.16 0.32 0.64]; %[0.08 0.16 0.32 0.64];
% %         [0.02 0.04 0.08 0.16 0.32 0.64];
%         blockcons = 1;
%         firstbcon = length(contrasts);          % which contrast(s) to use in first block? (use integers)
%         firstbnum = 5;                 % number in first block
        [amt time b] = psychsr_set_reward(6);
        [~, response.punish_time, ~] = psychsr_set_quinine(3);
        ntarget = 10;
        sine_gratings = 1;        
        response.antibias = 1;        
        per_targ = 0.4;
        blockmins = 7.5; 
        
    case 109
        response.mode = 6;   
        response.laser_epoch = 'stim';
        psychsr_discrim_stages(30);   
        response.description = 'STM: Fast';
        [amt time b] = psychsr_set_reward(5);
        [~, response.punish_time, ~] = psychsr_set_quinine(1.5);
        response.n_nolaser = 20;
        aperture = [0.1 0.1 0.9 0.9];           % [xmin ymin xmax ymax] normalized to 1
        response.nt_on_timeout = 0;
        
        response.adaptive_ontime = 1;

        % multiple time points code
        stmdelay = 0;                 % stimulus offset-response delay
        response.target_time = 0.3;        
        resp_delays = stmdelay + 1;    % stimulus-response delay 
        response.laser_onset = [0 0.6];%[0 0.25 0.5 0.75]; % multiple on times
        response.laser_time = 0.25*ones(size(response.laser_onset));        
        laser_ind = 1; % which stm delay to turn on laser?
        laser_per = 0.5;
        
    case 113
        response.mode = 6;   
        response.laser_epoch = 'prestim';
        delay = 2.5;                      % delay duration
        iti = 2;                          % ITI duration
        psychsr_discrim_stages(36);   
        [amt time b] = psychsr_set_reward(6);
        [~, response.punish_time, ~] = psychsr_set_quinine(1);
        response.n_nolaser = 50;
        aperture = [0.1 0.1 0.9 0.9];           % [xmin ymin xmax ymax] normalized to 1
        response.nt_on_timeout = 0;

    case 114
        response.mode = 6;   
        response.laser_epoch = 'prestim';
        delay = 2.5;                      % delay duration
        iti = 2;                          % ITI duration
        psychsr_discrim_stages(36);   
        [amt time b] = psychsr_set_reward(8);
        [~, response.punish_time, ~] = psychsr_set_quinine(2);
        response.n_nolaser = 20;
        aperture = [0.1 0.1 0.9 0.9];           % [xmin ymin xmax ymax] normalized to 1
        response.nt_on_timeout = 0;
        
    case 115
        response.mode = 6; % quinine
        psychsr_discrim_stages(35);
        [~, response.punish_time, ~] = psychsr_set_quinine(2);
        cue_sound = 0;
        [amt time b] = psychsr_set_reward(6);
        firstbdnum = 20;  % number of easy delays in first block

    case 117
        response.mode = 6; % quinine      
        psychsr_discrim_stages(25);
        [~, response.punish_time, ~] = psychsr_set_quinine(0.1);
        cue_sound = 0;
        [amt time b] = psychsr_set_reward(3);
        response.target_time = 2;      
        response.nt_on_timeout = 0;     % leave nontarget on during timeout?                
        contrasts = [0.02 0.04 0.08 0.16 0.32 0.64];
        contrasts = 1; %contrasts(6);
        blockcons = 1;
        firstbcon = length(contrasts);          % which contrast(s) to use in first block? (use integers)
        firstbnum = 60;                 % number in first block
        sine_gratings = 1;
        per_targ = 0.5;
        blockmins= 7.5;
        
        response.t_ori = 0.01;
        nt_ori = 90;
        response.auto_reward = -2;  % # of free rewards, -2 means sound only
        response.auto_reward_time = 2.4;
        response.p_auto_reward = 0.5;
        response.punish_timeout = 4;
        response.p_targ_after_cr = 1;   % prob force next stim to be Targ after CR
        response.p_ntarg_after_fa = 0.7;  % prob force next stim to be Targ after FA
        
    case 118
        response.mode = 6; % quinine
        psychsr_discrim_stages(25);
        [~, response.punish_time, ~] = psychsr_set_quinine(2);
        cue_sound = 0;
        [amt time b] = psychsr_set_reward(6);
        response.target_time = 2;      
        response.nt_on_timeout = 0;     % leave nontarget on during timeout?                
        contrasts = [0.02 0.04 0.08 0.16 0.32 0.64];
        contrasts = contrasts(5:6);
        blockcons = 1;
        firstbcon = length(contrasts);          % which contrast(s) to use in first block? (use integers)
        firstbnum = 40;                 % number in first block
        sine_gratings = 1;
        per_targ = 0.4;
        
    case 119
        response.mode = 6; % quinine      
        psychsr_discrim_stages(25);
        [~, response.punish_time, ~] = psychsr_set_quinine(1);
        cue_sound = 0;
        [amt time b] = psychsr_set_reward(3);
        response.target_time = 2;      
        response.nt_on_timeout = 0;     % leave nontarget on during timeout?                
        contrasts = [0.02 0.04 0.08 0.16 0.32 0.64];
        contrasts = contrasts(6);
        blockcons = 1;
        firstbcon = length(contrasts);          % which contrast(s) to use in first block? (use integers)
        firstbnum = 5;                 % number in first block
        sine_gratings = 1;
        per_targ = 0.4;
        blockmins = 7.5;
        
        % reversal code
        response.t_ori = 0.01;
        nt_ori = 90;
        response.auto_reward = -2;   % # of free rewards, -2 means sound only
        response.auto_reward_time = 2.4;
        response.p_auto_reward = 0.5;
        response.punish_timeout = 4;
        response.p_targ_after_cr = 1;   % prob force next stim to be Targ after CR
        response.p_ntarg_after_fa = 0.6;  % prob force next stim to be Targ after FA

     case 121
        response.mode = 6; % quinine
        psychsr_discrim_stages(25);
        [amt time b] = psychsr_set_reward(6);
        [~, response.punish_time, ~] = psychsr_set_quinine(1);
        cue_sound = 0;
        
        response.target_time = 2;      
        response.nt_on_timeout = 0;     % leave nontarget on during timeout?                
        contrasts = [0.16 0.32 0.64];
        blockcons = 1;
        firstbcon = length(contrasts);          % which contrast(s) to use in first block? (use integers)
        firstbnum = 20;                 % number in first block
        sine_gratings = 1;
        
        per_targ = 0.35;                 % percent of stimuli that are targets
        blockmins = 20;
        plexon_flag = 1;                % setup trigger for plexon
        
    case 122
        response.mode = 6; % quinine
        psychsr_discrim_stages(35);
        [amt time b] = psychsr_set_reward(6);
        [~, response.punish_time, ~] = psychsr_set_quinine(0);
        cue_sound = 0;
        firstbdnum = 20;                 % number in first block
        
        per_targ = 0.35;                 % percent of stimuli that are targets
        blockmins = 20;
        plexon_flag = 1;                % setup trigger for plexon

        
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
