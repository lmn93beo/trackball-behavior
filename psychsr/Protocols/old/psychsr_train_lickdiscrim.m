function data = psychsr_train_lickdiscrim()
% Trial structure:
% t=0	tone (0.5s), blank (2 sec)
% t=2   target stimulus
%           lick response stops stimulus, otherwise reward at t=6
% t<=6  blank
% t<=10 next trial

%% variable parameters
    total_duration = (60)*60;
    response.reward_time = 0.004;    
    iti = 4;   
    off_dur = 2;
    on_dur = 4; 
    
%% constant parameters
    screen.keep = 1;        
%     screen.id = 1;
    card.trigger_mode = 'key';        
    response.mode = 1;
    response.ao_mode = 'putsample';    
    response.feedback_fn = @feedback_fn;
    sound.tone_amp = 0.05;        
    sound.tone_time = 0.5;
    sound.noise_amp = 0.05;
    sound.noise_time = 0.5;
    presentation.frame_rate = 60;
    
%% stimuli
    % define your stimuli
	orients = [90 0.01];
	tfs = [2 0];	
    
    sfs = 0.015;	
	contrast = 1;

    num_loops = total_duration/(iti+off_dur+on_dur);
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
        
        if (repeats == -3) || (repeats<3 && rand>0.5)
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
        uisave('data',sprintf('%4d%02d%02d_lickdiscrimination_%04d',date(1),date(2),date(3),mouse_num));
    end
end

function new_loop = feedback_fn(loop)
    global data;
    
    if loop.response    
        if data.stimuli.orientation(loop.stim) == 90 % correct            
            psychsr_reward(loop,0);
            time_shift = data.stimuli.end_time(loop.stim)-loop.prev_flip_time;
%             data.stimuli.end_time(loop.stim)=data.stimuli.end_time(loop.stim)-time_shift;
            data.stimuli.end_time(loop.stim:end)=data.stimuli.end_time(loop.stim:end)-time_shift;
            
%             if isempty(data.response.rewards)
%                 psychsr_reward(loop);
%             elseif loop.prev_flip_time-max(data.response.rewards) > 1 % one reward per second       
%                 psychsr_reward(loop);
%             else
%                 fprintf(' EXTRA\n')
%             end

        elseif (loop.frame - loop.new_stim) < data.response.grace_period*data.presentation.frame_rate
            fprintf('GRACE\n');

        elseif isnan(data.stimuli.orientation(loop.stim))
            fprintf(' BLANK\n')

        else % incorrect                
            psychsr_punish(loop,1);                
        end        
    end    
    
    if loop.frame - loop.new_stim == 1         
    % if blank --> blank
    % play tone with new stimulus
        if strcmp(data.stimuli.stim_type{loop.stim},data.stimuli.stim_type{loop.stim-1}) 
            psychsr_sound(4);
            fprintf('%s TONE\n',datestr(loop.prev_flip_time/86400,'MM:SS'))

    % if stim --> blank
    % give reward automatically if no licks    
        elseif data.stimuli.orientation(loop.stim-1) ==90 && strcmp(data.stimuli.stim_type{loop.stim},'blank')
            if (max(data.response.rewards) < loop.prev_flip_time-4)
                fprintf('%s FREE',datestr(loop.prev_flip_time/86400,'MM:SS'));        
                psychsr_reward(loop,0);

            elseif isempty(data.response.rewards)
                fprintf('%s FREE',datestr(loop.prev_flip_time/86400,'MM:SS'));        
                psychsr_reward(loop,0);
            end
        end
    end    
    new_loop = loop;
end