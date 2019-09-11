function new_loop = psychsr_custom_code(loop)
global data;
disp('CUSTOM CODE')
try
% used to run custom code during execution of the program
% activated by Ctrl+Shift+C

% common options are listed below in comments

%% change notify option
% data.response.notify = 'g';

%% change reward amount
% [amt time b] = psychsr_set_reward(5);
% fprintf('CHANGED REWARD AMOUNT\n')

%% change airpuff time
% data.response.punish_time = 1;
% fprintf('CHANGED AIRPUFF TIME\n')

%% set next N stimuli to be targets/nontargets
% nextstims = [1 1 1 1 1 0]; %[0 0 0 1];%[0 1 1 1 0];%[0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 1]; % ones represent targets
% ntmovie = 0;
% % % % data.stimuli.movie.file
% % % 
% % % nextstims = psychsr_rand(0.2,floor((data.stimuli.num_stimuli-loop.stim)/3),0,3)-1;
% t_speed = max(data.stimuli.temp_freq);
% nt_speed = 0;% min(data.stimuli.temp_freq(3:3:end));
% % 
% tars = find(nextstims);
% nons = find(~nextstims);
% for i = 1:length(tars)
%     data.stimuli.stim_type{loop.stim+3*tars(i)-mod(loop.stim,3)} = 'grating';
%     data.stimuli.orientation(loop.stim+3*tars(i)-mod(loop.stim,3))=90;
%     data.stimuli.temp_freq(loop.stim+3*tars(i)-mod(loop.stim,3))=t_speed;
% end
% for i = 1:length(nons)
%     if ntmovie == 0
%     data.stimuli.stim_type{loop.stim+3*nons(i)-mod(loop.stim,3)} = 'grating';
%     data.stimuli.orientation(loop.stim+3*nons(i)-mod(loop.stim,3))=0.01;
%     data.stimuli.temp_freq(loop.stim+3*nons(i)-mod(loop.stim,3))=nt_speed;    
%     else
% 
%     data.stimuli.stim_type{loop.stim+3*nons(i)-mod(loop.stim,3)} = 'image';
%     data.stimuli.orientation(loop.stim+3*nons(i)-mod(loop.stim,3))=NaN;
%     data.stimuli.movie_file{loop.stim+3-mod(loop.stim,3)} = 'movies\image3.mat';
%     data.stimuli.movie_num(loop.stim+3-mod(loop.stim,3)) = find(strcmp(unique(data.stimuli.movie_file),'movies\image3.mat'),1,'first');
%     end
% end
% fprintf('NEXT STIMS: ')
% fprintf('%d ',nextstims)
% fprintf('\n')

%% set next N response delays
% resp_delays = 2;%[2 2.5 3 3.5 4 4 4]; % delay from grating onset
% N = 20;
% ndels = length(resp_delays);
% if length(resp_delays)>1
%     ndels = length(resp_delays);
%     % randomize with replacement
%     rdels = psychsr_rand(ones(ndels,1)/ndels,N,1,3);
% else
%     rdels = ones(1,N);
% end
% 
% % fprintf('%d\n',loop.stim)
% for i = 1:length(rdels)
% %     fprintf('%d %d %d %d\n',-1+loop.stim+3*i-mod(loop.stim,3),loop.stim+3*i-mod(loop.stim,3),1+loop.stim+3*i-mod(loop.stim,3),resp_delays(rdels(i)))
%     data.stimuli.response_delay(loop.stim+3*i-mod(loop.stim,3)-1) = resp_delays(rdels(i));
%     data.stimuli.response_delay(loop.stim+3*i-mod(loop.stim,3)) = resp_delays(rdels(i));
%     data.stimuli.duration(loop.stim+3*i-mod(loop.stim,3)) = data.response.response_time+resp_delays(rdels(i));
%     data.stimuli.response_delay(loop.stim+3*i-mod(loop.stim,3)+1) = resp_delays(rdels(i));    
% end
% data.stimuli.end_time = cumsum(data.stimuli.duration);

%% change all stm delays
% resp_delay = 3.5;
% data.stimuli.duration(loop.stim+3-mod(loop.stim,3):3:end) = data.response.response_time+resp_delay;
% data.stimuli.response_delay(loop.stim+1:end) = resp_delay;
% data.stimuli.end_time = cumsum(data.stimuli.duration);
% fprintf('DELAY PERIOD: %1.2f\n',resp_delay);

% change all sr delays
% data.response.extend_onset = 0;
% data.response.retract_onset = 1.5;
% resp_delay = 1;
% data.stimuli.duration(loop.stim+3-mod(loop.stim,3):3:end) = data.response.response_time+resp_delay*(resp_delay>0);
% data.response.target_time = data.response.response_time+resp_delay*(resp_delay>0);
% data.stimuli.response_delay(loop.stim+1:end) = resp_delay*(resp_delay>0);
% data.response.extend_onset = resp_delay*(resp_delay<0); % only change if negative
% data.stimuli.end_time = cumsum(data.stimuli.duration);
% fprintf('SR DELAY: %1.2f\n',resp_delay);

%% change all delay periods
% delay = 5;
% delay_var = 0;
% n = length(data.stimuli.duration(loop.stim+2-mod(loop.stim,3):3:end));
% data.stimuli.duration(loop.stim+2-mod(loop.stim,3):3:end) = delay + delay_var*(rand(1,n)-0.5);
% data.stimuli.end_time = cumsum(data.stimuli.duration);
% fprintf('DELAY PERIOD: %1.2f\n',delay);

%% change response window
%  data.response.grace_period = 0.25;
%  data.response.target_time = 2;
%  data.response.response_time = 4;
%  data.stimuli.duration(loop.stim+3-mod(loop.stim,3):3:end) = data.response.response_time;
%  data.stimuli.end_time = cumsum(data.stimuli.duration);
% 
% clear psychsr_user_input;
%  stmdelay = 0;
%  data.response.response_time = 3.5+stmdelay;
%  data.stimuli.duration(loop.stim+3-mod(loop.stim,3):3:end) = data.response.response_time;
%  data.stimuli.end_time = cumsum(data.stimuli.duration);
%  data.response.target_time = 2;
%  data.response.target_time 
%  data.response.extend_onset = 2+stmdelay;      % time after grating onset
%  data.response.grace_period = 2.2+stmdelay;
%  data.response.retract_onset = 3.5+stmdelay;   % time after grating onset (Inf = do not retract every trial)
%  fprintf('STM DELAY: %1.2f\n',stmdelay);
% 
%  data.stimuli.duration(loop.stim+3-mod(loop.stim,3):3:end) = data.response.response_time;
%  data.stimuli.end_time = cumsum(data.stimuli.duration);
%  fprintf('TARGET TIME: %1.2f\n',data.response.response_time);

%% change target speed
% t_speed = 2;
% next_stim = loop.stim+3-mod(loop.stim,3);
% ori = data.stimuli.orientation;
% for i = next_stim:3:length(ori)
%     if ori(i) == 90
%         data.stimuli.temp_freq(i) = t_speed;     
%     end
% end
% fprintf('CHANGED TARGET SPEED TO %1.1f\n',t_speed);

% change nontarget speed
% nt_speed = 2;
% next_stim = loop.stim+3-mod(loop.stim,3);
% ori = data.stimuli.orientation;
% for i = next_stim:3:length(ori)
%     if ori(i) ~= 90
%         data.stimuli.temp_freq(i) = nt_speed;     
%     end
% end
% fprintf('CHANGED NONTARGET SPEED TO %1.1f\n',nt_speed);

%% change contrast
% contrast = [0.16 0.32 0.64];
% % contrast = 1;%contrast(6);
% next_stim = loop.stim+3-mod(loop.stim,3);
% nstims =floor((length(data.stimuli.contrast)-next_stim)/3);
% 
% ncons = length(contrast);
% nblocks = floor(nstims/ncons);
% cons = contrast(randi(ncons,nstims,1));
% for i = 1:nblocks
%     cons((i-1)*ncons+1:i*ncons) = contrast(randperm(ncons));
% end
% 
% data.stimuli.contrast(next_stim:3:next_stim+(nstims-1)*3) = cons;
% fprintf('CHANGED NEXT %d STIMS CONTRAST TO %1.2f\n',nstims,contrast(1));

%% change reward amount
% amt = 5;
% b = data.response.reward_cal;
% time = (amt*b(1)+b(2))/1000;
% data.response.reward_amt = amt;
% data.response.reward_time = time;
% fprintf('CHANGED REWARD TIME\n')
% % % % % % % % % % % % % % % % % 
% [~, data.response.punish_time, ~] = psychsr_set_quinine(3);
% % 


% data.response.iri = Inf;
% 
% amt = 5;
% [amt time b] = psychsr_set_reward(amt);
% [amt2 time2 b2] = psychsr_set_quinine(amt);
% data.response.reward_time(2,:) = time;
% data.response.reward_amt(2,:) = amt;
% data.response.reward_cal(2,:) = b;
% 
% data.response.reward_time(1,:) = time2;
% data.response.reward_amt(1,:) = amt2;
% data.response.reward_cal(1,:) = b2;


%% preview results
% 
% perf = data.response.n_overall;
% targ = data.stimuli.orientation(3:3:end) == 90;
% del = data.stimuli.response_delay(3:3:end);
% las = data.stimuli.laser_on(3:3:end);
% ntrials = length(perf);
% targ = targ(1:ntrials);
% del = del(1:ntrials);
% las = las(1:ntrials);
% d = unique(del);
% 
% for i = 1:length(d)
%     fprintf('Control (%1.1f s):\n',d(i)-2)
%     fprintf('%1.3f %1.3f\n',mean(perf(las==0 & del==d(i) & targ)),1-mean(perf(las==0 & del==d(i) & ~targ)))    
% %     fprintf('Laser (%1.1f s):\n',d(i)-2)
% %     fprintf('%1.3f %1.3f\n',mean(perf(las==1 & del==d(i) & targ)),1-mean(perf(las==1 & del==d(i) & ~targ)))
% end

%% other parameters
% % data.stimuli.laser_on(3:3:300)
% data.response.target_time = 3;
% data.response.iri = Inf;
% data.response.consecFlag = 1;
% data.card.ax.SetJogStepSize(0,0.25);
% data.response.antibias = 1;
% data.response.extend_iti = 2;
% % data.response.stop_grating = 0;
% data.response.auto_reward = 0;
% data.response.auto_amt = 3;
% % data.response.auto_reward = -2-data.response.auto_reward;
% data.response.auto_reward_time = 2;
% data.response.p_auto_reward = 0.5;
% data.response.auto_reward = 0;
% % data.response.auto_stop = 25;
% data.response.auto_adjust_spout = 0;
% data.response.blockrewards = 2;%[4 8];
% data.response.lick_threshold=3;
% data.response.p_targ_after_cr = 1;   % prob force next stim to be Targ after CR
% data.response.p_ntarg_after_fa = 0.6;  % prob force next stim to be Targ after FA
% data.response.punish_timeout = 6;
% data.response.nt_on_timeout = 0;     % leave nontarget on during timeout?
% psychsr_sound(1)
% psychsr_sound(6)
% data.response.iri = Inf;
% data.response.extend_onset = -0.25;
% data.response.nt_on_timeout = 1;
% clear psychsr_discrim_feedback;
% data.response.switchFlag = false; % force animal to switch back and forth
% clear psychsr_move_spout;
% clear psychsr_punish;
% clear psychsr_reward;
% data.response.punish = 0;
% data.response.punish_every_lick = 1;
% data.response.first_lick = 1;
% disp('first lick off')
% data.response.punish_time = 0;
% data.response.max_consec = 7;
% data.response.extend_onset = 0;      % time after grating onset
% pause
% data.response.spout_xpos(1) = 10.25;
% data.response.retract_onset = 4;   % time after grating onset (Inf = do not retract every trial)
% data.response.extend_onset = -3;     % time after grating onset
% % data.response.retract_onset = Inf;   % time after grating onset (Inf = do not retract every trial)
% data.response.punish_timeout = 0;
% data.response.spout_time = 0.4;
% movespout(2)
% data.response.nt_on_timeout = 1;     % leave nontarget on during timeout?
% response.laser_amp = 3.3;
catch
    disp('ERROR IN CUSTOM CODE')
end

%% update loop
new_loop = loop; 