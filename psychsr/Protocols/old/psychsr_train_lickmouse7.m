function data = psychsr_train_lickmouse7()
% Trial structure:
% t=0	blank (2+ sec)
% user can adjust blank period using ctrl+ or ctrl-
% t=1   target stimulus (2 sec)
% reward early licks, or at end of stimulus
% t=2   reward at end of stimulus, next trial

%% variable parameters
    pc = input('Computer #: ');

    if pc == 1
        response.reward_time = 0.007;    
    elseif pc == 2
        response.reward_time = 0.004;    
        screen.id = 1;    
    end

    total_duration = (60)*60;
    iti = 2;   
    on_dur = 2; 
    
%% constant parameters
    screen.keep = 1;  
    card.trigger_mode = 'key';        
    response.mode = 1;
    response.ao_mode = 'putsample';    
    response.feedback_fn = @feedback_fn;
    sound.tone_amp = 0.05;        
    sound.tone_time = 0.5;
    presentation.frame_rate = 60;
    
%% stimuli
    % define your stimuli
	orients = 90;
	sfs = 0.015;
	tfs = 2;	
	contrast = 1;

    num_loops = total_duration/(iti+on_dur);
    num_stimuli = num_loops*2;
    
    stim_type = cell(1,num_stimuli);
    duration = zeros(1,num_stimuli);
    orientation = NaN*ones(1,num_stimuli);
    spat_freq = NaN*ones(1,num_stimuli);
    temp_freq = NaN*ones(1,num_stimuli);
    contrasts = NaN*ones(1,num_stimuli);
    k = 1;
    
    for i = 1:num_loops                
        duration(k) = iti;
        stim_type{k} = 'blank';
        k = k+1; 
                
        duration(k) = on_dur;
        stim_type{k} = 'grating';
        orientation(k) = orients;
        spat_freq(k) = sfs;
        temp_freq(k) = tfs;
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
        uisave('data',sprintf('%4d%02d%02d_lickdetection_%04d',date(1),date(2),date(3),mouse_num));
    end
end

%% feedback function
function new_loop = feedback_fn(loop)
    global data;
    
    if loop.response  % if lick
        % lick during stimulus
        if data.stimuli.orientation(loop.stim) == 90 % correct                        
            
            % turn off stimulus 300ms after lick
            time_shift = -0.3 + data.stimuli.end_time(loop.stim)-loop.prev_flip_time;
            time_shift = time_shift*(time_shift>0);
            data.stimuli.end_time(loop.stim:end)=data.stimuli.end_time(loop.stim:end)-time_shift;
            
            if isempty(data.response.rewards)
                psychsr_reward(loop,0);
            elseif loop.prev_flip_time-max(data.response.rewards) > 1 % one reward per second       
                psychsr_reward(loop,0);
            else
                fprintf(' EXTRA\n')
            end

        % lick during blank
        elseif isnan(data.stimuli.orientation(loop.stim))
            fprintf(' BLANK\n')

        else % incorrect                
            psychsr_punish(loop,1);                
        end        
    end    
    
    % give reward automatically if no licks    
%     if loop.prev_flip_time > data.stimuli.end_time(loop.stim)-0.3
%         if data.stimuli.orientation(loop.stim) == 90            
%             if (max(data.response.rewards) < loop.prev_flip_time-3)
%                 fprintf('%s FREE',datestr(loop.prev_flip_time/86400,'MM:SS'));        
%                 psychsr_reward(loop,0);
% 
%             elseif isempty(data.response.rewards)
%                 fprintf('%s FREE',datestr(loop.prev_flip_time/86400,'MM:SS'));        
%                 psychsr_reward(loop,0);
%             end
%         end
%     end    
%     
    new_loop = loop;
end