% records of mouse specific parameters

% 02/29/2016
% *************************************************************************    
switch mouse
% *************************************************************************
    case 5
        response.auto_stop = 1000;      % automatically stop program after X misses
        cue_sound = 0;
        [amt time b] = psychsr_set_reward(4);
        response.response_time = 1.5;   % response window
        response.target_time = 2;       % time grating is displayed
        resp_delays          = 2;       % delay(s) between stimulus and spout onset

% hs_stage_2
        psychsr_discrim_stages_HS(65);
        response.extend_iti = 1;     % extend iti until animal stops licking for 1 second
%         response.block_Hits    = 1000; % number of Hits before switch to non-target.
per_targ = 1;                 % percent of stimuli that are targets
max_targ = Inf;
        response.abortTrlStimLick = 1; % abort trial if licked during stim

% % hs_stage_1
% %         response.mode = 6; % quinine
% %         [~, response.punish_time, ~] = psychsr_set_quinine(0); % set quinine to 1uL   
% %         psychsr_discrim_stages_HS(13);
%         psychsr_discrim_stages_HS(65);
%         response.punish_timeout = 6;
%         response.extend_iti = 1;        % extend iti until animal stops licking for 1 second
%         response.block_Hits        = 1000; % number of Hits before switch to non-target.
%         response.p_targ_after_miss = 1; % prob force next stim to be Targ after Miss

%         response.p_ntarg_after_fa  = 1; % prob force next stim to be Targ after FA
%         response.block_CRs         = 1; % number of CRs before switch to target.
% % hs_stage_5
%         response.mode = 6; % quinine
%         [~, response.punish_time, ~] = psychsr_set_quinine(0); % set quinine to 1uL   
%         psychsr_discrim_stages_HS(13);
%         response.p_targ_after_miss = 1; % prob force next stim to be Targ after Miss
%         response.p_ntarg_after_fa  = 1; % prob force next stim to be Targ after FA
%         response.block_Hits        = 3; % number of Hits before switch to non-target.
%         response.block_CRs         = 1; % number of CRs before switch to target.
% % hs_stage_4
%         response.mode = 6; % quinine
%         [~, response.punish_time, ~] = psychsr_set_quinine(0); % set quinine to 1uL   
%         psychsr_discrim_stages_HS(13);
%         response.p_targ_after_miss = 1; % prob force next stim to be Targ after Miss
% %         response.block_Hits        = 3; % number of Hits before switch to non-target.
% %         response.block_NonTargets  = 1; % number of Non-Targets after Target.
% %         response.block_Hits        = 1; % number of Hits before switch to non-target.
% %         response.block_NonTargets  = 3; % number of Non-Targets after Target.
%         response.block_Hits        = 3; % number of Hits before switch to non-target.
%         response.block_NonTargets  = 3; % number of Non-Targets after Target.
% % hs_stage_3
%         response.mode = 6; % quinine
%         [~, response.punish_time, ~] = psychsr_set_quinine(0); % set quinine to 1uL   
%         psychsr_discrim_stages_HS(13);
%         response.block_Hits = 10000; % number of Hits before switch to non-target.
%         response.p_targ_after_miss = 1; % prob force next stim to be Targ after Miss
% % hs_stage_2
%         psychsr_discrim_stages_HS(2);
%         response.response_time = 4;   % response window
%         response.target_time = 4;     % time grating is displayed        
% % hs_stage_1
%         psychsr_discrim_stages_HS(2);
%         response.response_time = 16;   % response window
%         response.target_time = 16;     % time grating is displayed        

%         response.mode = 6; % quinine
%         [~, response.punish_time, ~] = psychsr_set_quinine(1); % set quinine to 1uL
%         delay = 0;                  % delay duration
%         response.extend_iti = 1;    % extend iti until animal stops licking for 1 second
        

% *************************************************************************
    case 1
%         response.p_ntarg_after_fa = 0.8;  % prob force next stim to be NTarg after FA
%         response.p_targ_after_cr  = 1;   % prob force next stim to be Targ after CR
        response.p_ntarg_after_fa = 1;  % prob force next stim to be Targ after FA
        response.mode = 6; % quinine
        [~, response.punish_time, ~] = psychsr_set_quinine(0); % set quinine to 1uL   

        cue_sound = 0;
%         response.mode = 6; % quinine
        psychsr_discrim_stages_HS(13)
        [amt time b] = psychsr_set_reward(4);
%         [~, response.punish_time, ~] = psychsr_set_quinine(0); % set quinine to 1uL   
%         response.response_time = 2;   % response window
%         response.target_time = 2;     % time grating is displayed        
%         delay = 0;                  % delay duration
%         response.extend_iti = 1;    % extend iti until animal stops licking for 1 second
%         nt_speed = 2;                   % nontarget temporal frequency
        sound.noise_time = 4;

%         cue_sound = 0;
%         response.response_time = 2;   % response window
%         response.target_time = 2;     % time grating is displayed        
%         [amt time b] = psychsr_set_reward(4);
%         [~, response.punish_time, ~] = psychsr_set_quinine(1); % set quinine to 1uL   
% 
% %         response.mode = 6; % quinine
% 
%         psychsr_discrim_stages_HS(3);
%         delay = 0;                  % delay duration
%         response.extend_iti = 1;    % extend iti until animal stops licking for 1 second


% *************************************************************************
    case 2
        response.auto_stop = 1000;      % automatically stop program after X misses
%         response.p_targ_after_cr   = 1; % prob force next stim to be Targ after CR
%         response.p_ntarg_after_hit = 1;

%         % block: 1T1NT
%         response.p_ntarg_after_fa  = 1; % prob force next stim to be Targ after FA
%         response.p_targ_after_miss = 1; % prob force next stim to be Targ after Miss
%         % Block design. Use with: p_ntarg_after_fa and/or p_targ_after_miss.
%         response.block_Hits = 1; % number of Hits before switch to non-target.
%         response.block_CRs  = 1; % number of CRs before switch to target.

        % random w/ NT repeats
        response.p_ntarg_after_fa  = 1; % prob force next stim to be Targ after FA
        response.p_targ_after_miss = 0; % prob force next stim to be Targ after Miss
        % Block design. Use with: p_ntarg_after_fa and/or p_targ_after_miss.
        response.block_Hits = 0; % number of Hits before switch to non-target.
        response.block_CRs  = 0; % number of CRs before switch to target.

        response.mode = 6; % quinine
        [~, response.punish_time, ~] = psychsr_set_quinine(0); % set quinine to 1uL   
        cue_sound = 0;
        psychsr_discrim_stages_HS(13)
        [amt time b] = psychsr_set_reward(4);
        sound.noise_time = 4;
%         response.response_time = 2;   % response window
%         response.target_time = 2;     % time grating is displayed        
%         delay = 0;                  % delay duration
%         response.extend_iti = 1;    % extend iti until animal stops licking for 1 second
%         nt_speed = 2;                   % nontarget temporal frequency


% *************************************************************************
    case 3
        response.auto_stop = 1000;      % automatically stop program after X misses
%         response.p_targ_after_cr   = 1; % prob force next stim to be Targ after CR
%         response.p_ntarg_after_hit = 1;

%         % block: 1T1NT
%         response.p_ntarg_after_fa  = 1; % prob force next stim to be Targ after FA
%         response.p_targ_after_miss = 1; % prob force next stim to be Targ after Miss
%         % Block design. Use with: p_ntarg_after_fa and/or p_targ_after_miss.
%         response.block_Hits = 1; % number of Hits before switch to non-target.
%         response.block_CRs  = 1; % number of CRs before switch to target.

        % random w/ NT repeats
        response.p_ntarg_after_fa  = 1; % prob force next stim to be Targ after FA
        response.p_targ_after_miss = 0; % prob force next stim to be Targ after Miss
        % Block design. Use with: p_ntarg_after_fa and/or p_targ_after_miss.
        response.block_Hits = 0; % number of Hits before switch to non-target.
        response.block_CRs  = 0; % number of CRs before switch to target.

        response.mode = 6; % quinine
        [~, response.punish_time, ~] = psychsr_set_quinine(0); % set quinine to 1uL   
        cue_sound = 0;
        psychsr_discrim_stages_HS(13)
        [amt time b] = psychsr_set_reward(4);
        sound.noise_time = 4;
%         per_targ = 0.99999;                 % percent of stimuli that are targets
        
%         cue_sound = 0;
% %         response.mode = 6; % quinine
%         psychsr_discrim_stages_HS(3)
%         [amt time b] = psychsr_set_reward(4);
% %         [~, response.punish_time, ~] = psychsr_set_quinine(2); % set quinine to 1uL   
%         response.response_time = 2;   % response window
%         response.target_time = 2;     % time grating is displayed        
%         delay = 0;                  % delay duration
%         response.extend_iti = 1;    % extend iti until animal stops licking for 1 second
%         nt_speed = 2;                   % nontarget temporal frequency
%         sound.noise_time = 4;
        

% *************************************************************************
    case 4
        response.auto_stop = 1000;      % automatically stop program after X misses
        cue_sound = 0;
%         response.mode = 6; % quinine
        psychsr_discrim_stages_HS(6)
        [amt time b] = psychsr_set_reward(4);
%         [~, response.punish_time, ~] = psychsr_set_quinine(1); % set quinine to 1uL   
        response.response_time = 2;   % response window
        response.target_time = 2;     % time grating is displayed        
        delay = 0;                  % delay duration
        response.extend_iti = 1;    % extend iti until animal stops licking for 1 second
        nt_speed = 2;                   % nontarget temporal frequency
        sound.noise_time = 4;
        
%     case 5
%         response.auto_stop = 1000;      % automatically stop program after X misses
%         cue_sound = 0;
%         [amt time b] = psychsr_set_reward(4);
%         sound.noise_time = 4;
%         nt_speed = 2;                   % nontarget temporal frequency
% 
% % hs_stage_5
%         response.mode = 6; % quinine
%         [~, response.punish_time, ~] = psychsr_set_quinine(0); % set quinine to 1uL   
%         psychsr_discrim_stages_HS(13);
%         response.p_targ_after_miss = 1; % prob force next stim to be Targ after Miss
%         response.p_ntarg_after_fa  = 1; % prob force next stim to be Targ after FA
%         response.block_Hits        = 3; % number of Hits before switch to non-target.
%         response.block_CRs         = 1; % number of CRs before switch to target.
% % % hs_stage_4
% %         response.mode = 6; % quinine
% %         [~, response.punish_time, ~] = psychsr_set_quinine(0); % set quinine to 1uL   
% %         psychsr_discrim_stages_HS(13);
% %         response.p_targ_after_miss = 1; % prob force next stim to be Targ after Miss
% % %         response.block_Hits        = 3; % number of Hits before switch to non-target.
% % %         response.block_NonTargets  = 1; % number of Non-Targets after Target.
% % %         response.block_Hits        = 1; % number of Hits before switch to non-target.
% % %         response.block_NonTargets  = 3; % number of Non-Targets after Target.
% %         response.block_Hits        = 3; % number of Hits before switch to non-target.
% %         response.block_NonTargets  = 3; % number of Non-Targets after Target.
% % % hs_stage_3
% %         response.mode = 6; % quinine
% %         [~, response.punish_time, ~] = psychsr_set_quinine(0); % set quinine to 1uL   
% %         psychsr_discrim_stages_HS(13);
% %         response.block_Hits = 10000; % number of Hits before switch to non-target.
% %         response.p_targ_after_miss = 1; % prob force next stim to be Targ after Miss
% % % hs_stage_2
% %         psychsr_discrim_stages_HS(2);
% %         response.response_time = 4;   % response window
% %         response.target_time = 4;     % time grating is displayed        
% % % hs_stage_1
% %         psychsr_discrim_stages_HS(2);
% %         response.response_time = 16;   % response window
% %         response.target_time = 16;     % time grating is displayed        
% 
% %         response.mode = 6; % quinine
% %         [~, response.punish_time, ~] = psychsr_set_quinine(1); % set quinine to 1uL
% %         delay = 0;                  % delay duration
% %         response.extend_iti = 1;    % extend iti until animal stops licking for 1 second

end
% *************************************************************************
