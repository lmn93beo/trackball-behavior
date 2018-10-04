function new_loop = psychsr_movie_feedback(loop)
    global data;
    
    persistent n_total;
    persistent n_hits;
    persistent n_delay;
    persistent n_fast;
    if loop.frame == 1
        n_total = [];
        n_fast = [];
        n_hits = []; 
        n_delay = [];
    end
    
%% new stimulus
    if loop.frame - loop.new_stim == 1         
        % count a miss if no licks by end of blank period
        if strcmp('blank',data.stimuli.stim_type{loop.stim-1})
            n_total(end+1) = 1;
            if isempty(data.response.licks) || data.response.licks(end) < data.presentation.stim_times(end-1)
                fprintf('%s MISS\n',datestr(loop.prev_flip_time/86400,'MM:SS'))                
                n_hits(end+1) = 0;
            else
                n_hits(end+1) = 1;
                % check for licks within the first 1 second
                if max(data.response.licks >= data.presentation.stim_times(end-1) & ...
                        (data.response.licks < data.presentation.stim_times(end-1)+1))
                    n_fast(end+1) = 1;
                else
                    n_fast(end+1) = 0;
                end
            end 
        end
        
        % play tone if movie starting    
        if strcmp('movie',data.stimuli.stim_type{loop.stim})
            psychsr_sound(data.stimuli.cue_tone(loop.stim));
            data.response.tones(end+1) = loop.prev_flip_time;
            
            % display information
            per_fast = round(mean(n_fast(1+(end-10)*(end-10>0):end))*100);
            per_hit = round(mean(n_hits(1+(end-10)*(end-10>0):end))*100);
            per_delay = round(mean(n_delay(1+(end-10)*(end-10>0):end))*100);
            per_abort = round((1-mean(n_total(1+(end-10)*(end-10>0):end)))*100);
            fprintf('\n      LAST10    TOTAL\n')
            fprintf('FAST%%  %3d%%   %3d%% of %d\n',per_fast,round(mean(n_fast)*100),length(n_fast))
            fprintf('HIT%%   %3d%%   %3d%% of %d\n',per_hit,round(mean(n_hits)*100),length(n_hits))
            fprintf('DELAY%% %3d%%   %3d%% of %d\n',per_delay,round(mean(n_delay)*100),length(n_delay))
            fprintf('ABORT%% %3d%%   %3d%% of %d\n',per_abort,round((1-mean(n_total))*100),length(n_total))
            fprintf('LAST LICK: -%s\n\n',datestr((loop.prev_flip_time-max(data.response.licks))/86400,'MM:SS'))
            
            fprintf('%s TONE %1.2f\n',datestr(loop.prev_flip_time/86400,'MM:SS'),data.stimuli.duration(loop.stim))                   
    	                  
        % beginning of blank
        elseif strcmp('blank',data.stimuli.stim_type{loop.stim})
            if isempty(data.response.licks) || data.response.licks(end) < data.presentation.stim_times(end)-2
                fprintf('%s CORRECT REJECT\n',datestr(loop.prev_flip_time/86400,'MM:SS'))
                n_delay(end+1) = 0;
            else
                fprintf('%s FALSE ALARM\n',datestr(loop.prev_flip_time/86400,'MM:SS'))
                n_delay(end+1) = 1;
            end                                
            
        end 
        
    end    
    
    % free reward near the end of blank
    if strcmp('blank',data.stimuli.stim_type{loop.stim}) && ...
            loop.prev_flip_time-data.presentation.stim_times(end)>1.7            
        if data.response.auto_reward ~= 0
            if isempty(data.response.rewards) 
                fprintf('%s FREE',datestr(loop.prev_flip_time/86400,'MM:SS'));    
                temp = data.response.reward_time;
                data.response.reward_time = 0.004;
                psychsr_reward(loop);
                data.response.reward_time = temp;
                data.response.auto_reward = data.response.auto_reward-1;
            elseif ~isempty(data.response.licks)
                if max(data.response.licks) - max(data.response.rewards) > 0 &&...
                        loop.prev_flip_time-data.response.rewards(end) > data.response.blank_time
                    fprintf('%s FREE',datestr(loop.prev_flip_time/86400,'MM:SS'));
                    temp = data.response.reward_time;
                    data.response.reward_time = 0.004;
                    psychsr_reward(loop);
                    data.response.reward_time = temp;
                    data.response.auto_reward = data.response.auto_reward-1;
                end                        
            end
        end
    end    
    
%% lick feedback
    if loop.response  
        fprintf('%s %4d',datestr(loop.prev_flip_time/86400,'MM:SS'),length(data.response.licks));
        % reward if lick during blank
        if strcmp('blank',data.stimuli.stim_type{loop.stim})
            % ignore licks in first 300ms
%             if loop.prev_flip_time-max(data.presentation.stim_times) < 0.3
%                 fprintf(' EARLY\n')
                
            if (isempty(data.response.rewards) || loop.prev_flip_time-data.response.rewards(end) > data.response.blank_time) ... % one reward per blank
                    && (data.stimuli.duration(loop.stim) == data.response.blank_time) %&& (loop.frame - loop.new_stim > 1) 
                psychsr_reward(loop);
%                 if length(data.response.licks)>1
%                     n_onset(end+1) = (data.response.licks(end) - data.response.licks(end-1) > 0.5);
%                 else
%                     n_onset(end+1) = 1;                    
%                 end                 
                
%             elseif data.response.licks(end-1) < max(data.presentation.stim_times)
%                 psychsr_sound(6);
%                 fprintf(' HIT\n')
            else
                fprintf(' EXTRA\n')
            end
            
            if data.response.long_blank && data.stimuli.end_time(loop.stim)-loop.prev_flip_time < 1 && data.stimuli.duration(loop.stim) < 20
                data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)+1;
                data.stimuli.end_time = cumsum(data.stimuli.duration);  
                loop.new_stim = -1;
                fprintf(' LONGER BLANK\n')                
            end
            
        elseif strcmp('free',data.stimuli.stim_type{loop.stim})
            % free period: 2 rewards per second
            if (isempty(data.response.rewards) || loop.prev_flip_time-data.response.rewards(end) > 0.5)
                psychsr_reward(loop);
            else
                fprintf(' EXTRA\n')
            end
            if length(data.response.rewards) == data.response.free_rewards
                time_shift = data.stimuli.end_time(loop.stim)-loop.prev_flip_time;
                data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)-time_shift;
                data.stimuli.end_time = cumsum(data.stimuli.duration);
                fprintf('STOPPED FREE TIME AT %d\n',round(data.stimuli.duration(loop.stim)))
            end

        % abort/punish if lick during movie
        elseif strcmp('movie',data.stimuli.stim_type{loop.stim})
            
            % no punishment during grace periods
            if (loop.prev_flip_time >= max(data.presentation.stim_times)+data.response.abort_win1 ...
                    && loop.prev_flip_time < data.stimuli.end_time(loop.stim)-data.response.abort_win2) ...
                    || loop.prev_flip_time < max(data.presentation.stim_times)+data.response.abort_grace                                
                % start ... movie playing ... stop
                %   |abort_win1| ... |abort_win2|
                %   |grace|    |     |          |
                %   |     |XXXX|     |XXXXXXXXXX| (punished if lick during X)                     
                psychsr_sound(1);
                fprintf(' GRACE\n')
                
            else
                % abort trial, time out
                if data.response.abort
                    loop.stim = loop.stim - 1;
                    loop.new_stim = -1;
                    timeout = data.response.abort_timeout;
                    data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)+timeout;
                    data.stimuli.end_time = cumsum(data.stimuli.duration);  
                    fprintf(' ABORT')
                    n_total(end+1) = 0;     
                    n_delay(end+1) = 1;
                end                                
                % punish with noise and airpuff                
                if data.response.punish && (isempty(data.response.punishs) || loop.prev_flip_time-data.response.punishs(end) > 0.5 )
                    psychsr_punish(loop);
                else
                    fprintf(' GRACE\n')
                end
                
            end
            
            if data.response.long_movie && data.stimuli.end_time(loop.stim)-loop.prev_flip_time < 2 ...
                    && loop.frame ~= loop.new_stim%&& data.stimuli.duration(loop.stim) < 50
                data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)+2;
                data.stimuli.end_time = cumsum(data.stimuli.duration);  
                loop.new_stim = -1;
                fprintf(' LONGER MOVIE %d\n',data.stimuli.duration(loop.stim))                
            end
            
        
        % additional punishment if continue to lick after abort
        elseif data.response.punish_extra && data.stimuli.duration(loop.stim)>data.response.abort_timeout            
            if data.stimuli.end_time(loop.stim)-loop.prev_flip_time < 1 && data.stimuli.duration(loop.stim) < 20
                data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)+1;
                data.stimuli.end_time = cumsum(data.stimuli.duration);  
                fprintf(' LONGER ITI')
            end
            % one airpuff per 200ms
            if isempty(data.response.punishs) || loop.prev_flip_time-data.response.punishs(end) > 0.2 
                psychsr_punish(loop);
            else
                fprintf(' GRACE\n')
            end
            
        % nothing if lick during still frame
        else
            fprintf(' ITI\n')
        end       
    end    

%% update loop structure
    new_loop = loop;
end