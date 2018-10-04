function new_loop = gpi_randori_laser_feedback(loop)
    persistent l_on;
    
    if loop.frame == 1        
        l_on = 0;
    end
    
    global data;  
    data.loop = loop;
    if ~isfield(data.response,'iri')
        data.response.iri = 0.5;
    end
    
    if sum(loop.response)>0
        fprintf('%s %4d',datestr(loop.prev_flip_time/86400,'MM:SS'),length(data.response.licks));
        if isempty(data.response.rewards) || loop.prev_flip_time-max(data.response.rewards) > data.response.iri
            % max two rewards per second
            psychsr_reward(loop,6);
        else
            fprintf(' EXTRA \n')
        end
    end
    
    if loop.frame == loop.new_stim
        fprintf('STIM %d: %3.3f\n',loop.stim,loop.prev_flip_time);
    end
    
    if data.card.inter_trigger_interval<Inf && loop.frame > 1
        intervals = 0:data.card.inter_trigger_interval:90*60;
        
        [x i] = min(abs(intervals-loop.prev_flip_time)); % find timepoint after        
        if abs(loop.prev_flip_time-intervals(i))< 0.5/data.presentation.frame_rate            
            putvalue(data.card.trigger,1);            
            WaitSecs(0.005);
            putvalue(data.card.trigger,0);
%             fprintf('trigger time = %1.2f\n',loop.prev_flip_time)
        end        
    end
    
    % laser
    if data.response.mode == 7 %&& min(data.stimuli.laser_on(loop.stim:loop.stim+1))>0 
        onset = data.response.laser_onset;%(data.stimuli.laser_on(loop.stim));
        dur = data.response.laser_time;%(data.stimuli.laser_on(loop.stim));
        
        nseq = find(isnan(data.stimuli.orientation(2:6)),1);
        if psychsr_timed_event(loop,data.response.laser_seq,onset,nseq)
            if (isempty(data.response.laser_on) || loop.prev_flip_time-data.response.laser_on(end) > dur) ...
                    && (data.card.ao.SamplesOutput==0) % just in case ao already running
                start(data.card.ao);
                fprintf('LASER ON -- %1.1fV\n',data.response.laser_amp)                
                l_on = 1;
                data.response.laser_on(end+1) = loop.prev_flip_time;
            end
        end
    end
    % fprintf('%d\n',data.card.ao.SamplesOutput)
    if data.response.mode ==7 && l_on == 1
        if strcmp(data.card.ao.Running,'On') || (data.card.ao.SamplesOutput>0)
        else
            fprintf('LASER OFF\n')
            data.response.laser_off(end+1) = loop.prev_flip_time;
            l_on = 0;
        end
    end
    
    
    new_loop = loop;
end