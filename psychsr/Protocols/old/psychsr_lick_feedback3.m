function new_loop = psychsr_lick_feedback3(loop)
    
    global data;  
    
    if loop.stim == 1
        data.response.n_left = [];
        data.response.n_right = [];
    end
    
    % about to show new stimulus
    if loop.prev_flip_time > data.stimuli.end_time(loop.stim)-2.5*data.screen.flip_int*data.presentation.wait_frames 
        if data.stimuli.orientation(loop.stim) == 90
            % did animal earn reward during this stimulus?
            if (isempty(data.response.rewards) || loop.prev_flip_time-data.response.rewards(end) > data.response.response_time)        
                data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim) + 5;
                data.stimuli.end_time = cumsum(data.stimuli.duration);                      
                fprintf(' INCREASE TARG PERIOD\n');
            end
        end
    end
    
    if loop.frame - loop.new_stim == 1  
        psychsr_sound(data.stimuli.cue_tone(loop.stim));
        fprintf('%s CUE\n',datestr(loop.prev_flip_time/86400,'MM:SS'))
    end
    
    if loop.response 
        fprintf('%s %4d',datestr(loop.prev_flip_time/86400,'MM:SS'),length(data.response.licks));
        
        % target grating -- reward 2x a second
        if data.stimuli.orientation(loop.stim) == 90                     
            if isempty(data.response.rewards) || loop.prev_flip_time-max(data.response.rewards) > 0.5
                % max two rewards per second
                psychsr_reward(loop,0);
            else
                fprintf(' EXTRA \n')
            end
            
        % nontarget grating -- do nothing
        else
            % force animal to stop licking for at least 5 seconds
            if loop.prev_flip_time > data.stimuli.end_time(loop.stim) - 5
                data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim) + 5;
                data.stimuli.end_time = cumsum(data.stimuli.duration);                      
%                 psychsr_punish(loop);
                fprintf(' PUNISH + INCREASE NT PERIOD\n');
            else
                fprintf(' GRACE \n')    
            end
        end        
        
    end
    
    new_loop = loop;
end