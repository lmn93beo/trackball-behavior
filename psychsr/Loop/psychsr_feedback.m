function new_loop = psychsr_feedback(loop)
    
    global data;  
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
    
    new_loop = loop;
end