function data = psychsr_train_lickdiscrim4()
% Trial structure:
% t=0	tone (0.5s), blank (2 sec)
%           no abort trial             
% t=2   target stimulus (3 sec)
%           licks only count for last 2 seconds
%           lick response stops stimulus 300ms later
% t=5-  blank (4 sec) 
%           no prolonging of trial
% t=9-  next trial

%% variable parameters
    pc = input('Computer #: ');

    total_duration = (60)*60;
    if pc == 1
        response.reward_time = 0.004;    
    elseif pc == 2
        response.reward_time = 0.004;    
        screen.id = 1;    
    end
    iti = 4;   
    off_dur = 2;
    on_dur = 3; 
    
    response.grace_period = 1;
    
    ntarget = 20; % # of target-only trials
    
%% constant parameters
    screen.keep = 1;    
    card.trigger_mode = 'key';        
    response.mode = 1;
    response.ao_mode = 'putsample';    
    response.feedback_fn = @feedback_fn;
    response.tones=[];
    sound.tone_amp = 0.05;        
    sound.tone_time = 0.5;
    sound.noise_amp = 0.15;        
    sound.noise_time = 3;    
    presentation.frame_rate = 60;
    
%% stimuli
    % define your stimuli
	orients = [90 0.01];
	tfs = [2 0];	
    
	sfs = 0.015;
	contrast = 1;

    num_loops = total_duration/(iti+off_dur);
    num_stimuli = num_loops*3;
    
    stim_type = cell(1,num_stimuli);
    duration = zeros(1,num_stimuli);
    orientation = NaN*ones(1,num_stimuli);
    spat_freq = NaN*ones(1,num_stimuli);
    temp_freq = NaN*ones(1,num_stimuli);
    contrasts = NaN*ones(1,num_stimuli);
    k = 1;
    repeats = 0;
    for i = 1:num_loops                
        duration(k) = iti;
        stim_type{k} = 'blank';
        k = k+1; 
        
        duration(k) = off_dur;
        stim_type{k} = 'blank';
        k = k+1;
        
        duration(k) = on_dur;
        stim_type{k} = 'grating';
        
        if (k<=ntarget*3) || (repeats == -3) || (repeats<3 && rand>0.5)
            orientation(k) = orients(1);
            temp_freq(k) = tfs(1);
            if repeats < 1
                repeats = 1;
            else
                repeats = repeats + 1;
            end
        else
            orientation(k) = orients(2);
            temp_freq(k) = tfs(2);
            if repeats > -1
                repeats = -1;
            else
                repeats = repeats - 1;
            end
        end
        
        spat_freq(k) = sfs;
        contrasts(k) = contrast;
        k = k+1;
       
    end    
    
    stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,orientation,spat_freq,temp_freq,contrasts);       
    
%% input parameters into psychsr
    params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
    data = psychsr(params);

%% save    
    date = clock;
    mouse_num = input('Mouse number: ');
    if mouse_num ~= 0
        cd(sprintf('C:/Dropbox/MouseAttention/behaviorData/mouse %04d',mouse_num));    
        uisave('data',sprintf('%4d%02d%02d_lickdiscrim_%04d',date(1),date(2),date(3),mouse_num));
    end
end

%% feedback function
function new_loop = feedback_fn(loop)
    global data;
    
    persistent n_total;
    persistent n_targets;
    persistent n_non;
    if loop.frame == 1
        n_total = [];
        n_targets = [];
        n_non = [];       
    end
    
    if loop.response  % if lick
        % lick during blank
        if isnan(data.stimuli.orientation(loop.stim))
                        
            fprintf(' BLANK\n')
        
        % lick during stimulus        
        elseif loop.prev_flip_time < data.stimuli.end_time(loop.stim-1) + data.response.grace_period
            fprintf(' EARLY\n') % ignore first second            
            
        elseif data.stimuli.orientation(loop.stim) == 90 % correct            
            
            if isempty(data.response.rewards) || loop.prev_flip_time-max(data.response.rewards) > 1 % one reward per second       
                 % turn off stimulus 300ms after lick
                time_shift = -0.3 + data.stimuli.end_time(loop.stim)-loop.prev_flip_time;
                time_shift = time_shift*(time_shift>0);
                data.stimuli.end_time(loop.stim:end)=data.stimuli.end_time(loop.stim:end)-time_shift;            
                psychsr_reward(loop,6);
                n_total(end+1) = 1;
                n_targets(end+1) = 1;
            else
                fprintf(' EXTRA\n')
            end

        % abort if lick early
%         elseif strcmp(data.stimuli.stim_type{loop.stim+1},'grating') && ...            
%                 (loop.prev_flip_time > data.stimuli.end_time(loop.stim) - 0.5)
%             %psychsr_punish(loop,1)
%             loop.stim = loop.stim - 1;
%             time_shift = 4;
%             data.stimuli.end_time(loop.stim:end)=data.stimuli.end_time(loop.stim:end)+time_shift;
% %             psychsr_sound(1);
%             fprintf(' ABORT\n')
%             n_total(end+1) = 0;

        else % incorrect                
            
            if isempty(data.response.punishs) || loop.prev_flip_time-max(data.response.punishs) > 1 % one reward per second       
                % turn off stimulus
                time_shift = -0.3 + data.stimuli.end_time(loop.stim)-loop.prev_flip_time;
                time_shift = time_shift*(time_shift>0);            
                timeout = 2;  
                data.stimuli.end_time(loop.stim:end)=data.stimuli.end_time(loop.stim:end)-time_shift;
                data.stimuli.end_time(loop.stim+1:end)=data.stimuli.end_time(loop.stim+1:end)+timeout;
                psychsr_punish(loop,1);
                n_total(end+1) = 1;
                n_non(end+1) = 1;
            else
                fprintf(' EXTRA\n')
            end            
        end        
    end    
    
    % prolong ITI unless licking stopped for 1 second
%     flip_int = data.screen.flip_int;    
%     wait_frames = data.presentation.wait_frames;
%     if loop.prev_flip_time > data.stimuli.end_time(loop.stim)-2.5*flip_int*wait_frames
%         if strcmp(data.stimuli.stim_type{loop.stim},data.stimuli.stim_type{loop.stim+1}) 
%             if loop.prev_flip_time-max(data.response.licks) < 1
%                 time_shift = 1;%-loop.prev_flip_time+max(data.response.licks);
%                 data.stimuli.end_time(loop.stim:end)=data.stimuli.end_time(loop.stim:end)+time_shift;
%                 fprintf('LONGER ITI %1.3f\n',time_shift);
%             end
%         end
%     end    
   
    if loop.frame - loop.new_stim == 1         
    % if blank --> blank
    % play tone with new stimulus
        if strcmp(data.stimuli.stim_type{loop.stim},data.stimuli.stim_type{loop.stim-1}) 
            psychsr_sound(4);
            data.response.tones(end+1) = loop.prev_flip_time;
            per_hit = round(mean(n_targets(1+(end-10)*(end-10>0):end))*100);
            per_false = round(mean(n_non(1+(end-10)*(end-10>0):end))*100);
            per_abort = round((1-mean(n_total(1+(end-10)*(end-10>0):end)))*100);
            fprintf('\n      LAST10    TOTAL\n')
            fprintf('HIT%%   %3d%%   %3d%% of %d\n',per_hit,round(mean(n_targets)*100),length(n_targets))
            fprintf('FALSE%% %3d%%   %3d%% of %d\n',per_false,round(mean(n_non)*100),length(n_non))
            fprintf('ABORT%% %3d%%   %3d%% of %d\n\n',per_abort,round((1-mean(n_total))*100),length(n_total))
            
            fprintf('%s TONE\n',datestr(loop.prev_flip_time/86400,'MM:SS'))            
        
    % if stim --> blank
        elseif data.stimuli.orientation(loop.stim-1) == 90
            if isempty(data.response.rewards) || loop.prev_flip_time-max(data.response.rewards) > 1
                fprintf('%s MISS\n',datestr(loop.prev_flip_time/86400,'MM:SS'))
                n_total(end+1) = 1;
                n_targets(end+1) = 0;
            end
               
        elseif ~isnan(data.stimuli.orientation(loop.stim-1))
            if isempty(data.response.punishs) || loop.prev_flip_time-max(data.response.punishs) > 1
                fprintf('%s CORRECT REJECT\n',datestr(loop.prev_flip_time/86400,'MM:SS'))
                n_total(end+1) = 1;
                n_non(end+1) = 0;
            end
            
        end
    end    
    new_loop = loop;
end