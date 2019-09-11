function new_loop = psychsr_lick_feedback2(loop)
    
    global data;  
    
    if loop.response 
        fprintf('%s %4d',datestr(loop.prev_flip_time/86400,'MM:SS'),length(data.response.licks));
        if isempty(data.response.rewards) || loop.prev_flip_time-max(data.response.rewards) > data.response.iri
            % max two rewards per second
            psychsr_reward(loop,6);
        else
            fprintf(' EXTRA \n')
        end
        
        if isnan(data.stimuli.orientation(loop.stim))
            data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)...
                -data.stimuli.end_time(loop.stim)+loop.prev_flip_time;            
            
            data.stimuli.stim_type{loop.stim+1} = 'grating';
            data.stimuli.duration(loop.stim+1) = 1;
            data.stimuli.orientation(loop.stim+1) = 90;
            data.stimuli.spat_freq(loop.stim+1) = 0.05;
            data.stimuli.temp_freq(loop.stim+1) = 2;
            data.stimuli.contrast(loop.stim+1) = 1;
            
            data.stimuli.stim_type{loop.stim+2} = 'blank';
            data.stimuli.duration(loop.stim+2) = data.stimuli.total_duration-1-loop.prev_flip_time;
            data.stimuli.orientation(loop.stim+2) = NaN;
            data.stimuli.spat_freq(loop.stim+2) = NaN;
            data.stimuli.temp_freq(loop.stim+2) = NaN;
            data.stimuli.contrast(loop.stim+2) = NaN;                       
            
            data.stimuli.num_stimuli = data.stimuli.num_stimuli+2;
            data.stimuli.end_time = cumsum(data.stimuli.duration);            
        else
            data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)...
                +1-data.stimuli.end_time(loop.stim)+loop.prev_flip_time;            
            data.stimuli.end_time = cumsum(data.stimuli.duration);
        end
    end
    
    new_loop = loop;
end