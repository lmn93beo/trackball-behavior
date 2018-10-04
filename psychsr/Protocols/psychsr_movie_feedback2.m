function new_loop = psychsr_movie_feedback2(loop)
    global data;
        
    persistent dcontrast;    
    persistent newblock;
    persistent trials;

    if loop.frame == 1 || isempty(newblock)
        newblock = 0;
        trials = 0;
        if strcmp(data.stimuli.stim_type(3),'grating3')
            dcontrast = data.stimuli.contrast2(3);
        else
            dcontrast = 0;
        end    
    end
    
    if loop.frame == 1          
        data.response.n_total = [];
        data.response.n_overall = [];
        data.response.n_hits = [];
        data.response.n_false = [];
        data.response.n_delay = [];        
    end
    
%% new stimulus
    if loop.frame - loop.new_stim == 1         
% count a miss/correct reject if no licks by end of grating period
        if mod(loop.stim,3) == 1            
            data.response.n_total(end+1) = 1;
            if isempty(data.response.licks) || data.response.licks(end) < data.presentation.stim_times(end-1)+data.response.grace_period
                if data.stimuli.orientation(loop.stim-1) == 90
                	fprintf('%s MISS\n',datestr(loop.prev_flip_time/86400,'MM:SS'))                                    
                    data.response.n_hits(end+1) = 0;
                    data.response.n_overall(end+1) = 0;
                    if data.response.auto_stop > 0 && length(data.response.n_hits) > data.response.auto_stop % stop program if 10 misses in a row
                        if max(data.response.n_hits(end-min(9,data.response.auto_stop-1):end)) == 0 
                            data.stimuli.total_duration = loop.prev_flip_time;
                        end
                    end
                    
                else
                    fprintf('%s CORRECT REJECT\n',datestr(loop.prev_flip_time/86400,'MM:SS'))                                                  
                    data.response.n_false(end+1) = 0;
                    data.response.n_overall(end+1) = 1;
                end                    
            else
                if data.stimuli.orientation(loop.stim-1) == 90
                    data.response.n_hits(end+1) = 1;
                    data.response.n_overall(end+1) = 1;
                else
                    data.response.n_false(end+1) = 1;
                    data.response.n_overall(end+1) = 0;
                end
                
            end 
        end
        
% play tone (and display info) if movie starting    
        if mod(loop.stim,3) == 2 %strcmp('movie',data.stimuli.stim_type{loop.stim})
            if data.response.mode == 3 && strcmp(data.card.ao.Running,'Off') && (data.card.ao.SamplesOutput==0) 
                putsample(data.card.ao,0);
            end
            % check if new block
            if loop.stim<=3 || data.stimuli.cue_tone(loop.stim)~=data.stimuli.cue_tone(loop.stim-3)
                if dcontrast > 0 && (loop.stim<=3 || trials >= 80 || (dcontrast == 1 && newblock >= 20))
                    % reset distractor contrast for new block
                    newblock = 0;
                    trials = 0;
                    dcontrast = data.stimuli.contrast2(3);
                    fprintf('\nDCONTRAST RESET TO %1.1f\n',dcontrast);
                elseif dcontrast > 0
                    % extend current block until reach 100 trials or
                    % dcontrast == 1 for 20 trials
                    if dcontrast < 1
                        n_ex = 5;
                    else
                        n_ex = min([100-trials,20-newblock]);
                    end                                                           
                    data.stimuli.cue_tone(loop.stim+3*n_ex:3:end) = data.stimuli.cue_tone(loop.stim:3:end-3*n_ex);
                    data.stimuli.cue_tone(loop.stim:3:loop.stim+3*(n_ex-1)) = data.stimuli.cue_tone(loop.stim-3);
                    data.stimuli.stim_side(loop.stim+3*n_ex:3:end) = data.stimuli.stim_side(loop.stim:3:end-3*n_ex);
                    data.stimuli.stim_side(loop.stim:3:loop.stim+3*(n_ex-1)) = data.stimuli.stim_side(loop.stim-3);
                    data.stimuli.stim_side(loop.stim+3*n_ex+1:3:end) = data.stimuli.stim_side(loop.stim+1:3:end-3*n_ex+1);
                    data.stimuli.stim_side(loop.stim+1:3:loop.stim+3*n_ex-2) = data.stimuli.stim_side(loop.stim-3);
                    data.stimuli.contrast(loop.stim+3*n_ex+1:3:end) = data.stimuli.contrast(loop.stim+1:3:end-3*n_ex+1);
                    data.stimuli.contrast(loop.stim+1:3:loop.stim+3*n_ex-2) = data.stimuli.contrast(loop.stim-2);
                    data.stimuli.contrast2(loop.stim+3*n_ex+1:3:end) = data.stimuli.contrast2(loop.stim+1:3:end-3*n_ex+1);
                    data.stimuli.contrast2(loop.stim+1:3:loop.stim+3*n_ex-2) = data.stimuli.contrast2(loop.stim-2);
                    fprintf('\nEXTEND BLOCK TO %d TRIALS\n',trials+n_ex);
                end
            end
                        
            if strcmp(data.response.cue_mode,'visual')
                loop.cue = 18+1; %300 ms
            elseif strcmp(data.response.cue_mode,'simultaneous')                
            else
                psychsr_sound(data.stimuli.cue_tone(loop.stim));
            end            
            data.response.tones(end+1) = loop.prev_flip_time;            
       
            % display information
            per_overall = round(mean(data.response.n_overall(1+(end-10)*(end-10>0):end))*100);
            per_hit = round(mean(data.response.n_hits(1+(end-10)*(end-10>0):end))*100);
            per_false = round(mean(data.response.n_false(1+(end-10)*(end-10>0):end))*100);
            per_delay = round(mean(data.response.n_delay(1+(end-10)*(end-10>0):end))*100);
            per_abort = round((1-mean(data.response.n_total(1+(end-10)*(end-10>0):end)))*100);
            fprintf('\n      LAST10    TOTAL\n')            
            fprintf('HIT%%   %3d%%   %3d%% of %d\n',per_hit,round(mean(data.response.n_hits)*100),length(data.response.n_hits))
            fprintf('FALSE%% %3d%%   %3d%% of %d\n',per_false,round(mean(data.response.n_false)*100),length(data.response.n_false))
            fprintf('DELAY%% %3d%%   %3d%% of %d\n',per_delay,round(mean(data.response.n_delay)*100),length(data.response.n_delay))
            fprintf('ABORT%% %3d%%   %3d%% of %d\n',per_abort,round((1-mean(data.response.n_total))*100),length(data.response.n_total))
            if dcontrast > 0
                fprintf('DCONTRAST: %1.1f\n',dcontrast)
            end
            fprintf('LAST LICK: -%s\n\n',datestr((loop.prev_flip_time-max(data.response.licks))/86400,'MM:SS'))            
            
            if mod(loop.stim,9) == 2
                fid = fopen(sprintf('rig%1d.txt',str2num(data.screen.pc(end))),'w');
                fprintf(fid,'RIG %1d\nMOUSE %2d\n%s TRIAL %d\n',str2num(data.screen.pc(end)),data.mouse,datestr(loop.prev_flip_time/86400,'MM:SS'),floor(loop.stim/3));
                fprintf(fid,'\n      LAST10    TOTAL\n');
                fprintf(fid,'HIT%%   %3d%%   %3d%% of %d\n',per_hit,round(mean(data.response.n_hits)*100),length(data.response.n_hits));
                fprintf(fid,'FALSE%% %3d%%   %3d%% of %d\n',per_false,round(mean(data.response.n_false)*100),length(data.response.n_false));
                fprintf(fid,'DELAY%% %3d%%   %3d%% of %d\n',per_delay,round(mean(data.response.n_delay)*100),length(data.response.n_delay));
                fprintf(fid,'ABORT%% %3d%%   %3d%% of %d\n',per_abort,round((1-mean(data.response.n_total))*100),length(data.response.n_total));
                if dcontrast > 0
                    fprintf(fid,'DCONTRAST: %1.1f\n',dcontrast);
                end
                fprintf(fid,'LAST LICK: -%s\n\n',datestr((loop.prev_flip_time-max(data.response.licks))/86400,'MM:SS'));
                fclose(fid);
            end
            
            % check performance and possibly change distractor contrast            
            if mod(loop.stim,15) == 2 && newblock >= 5 && dcontrast > 0                
                if newblock >= 10
                    fprintf('PERFORMANCE AT %d%%\n',per_overall)
                end                
                if data.response.d_auto || min(data.response.n_overall(end-4:end))==1 || (per_overall > 70 && newblock >= 10)
                    % increase distractor contrast if performance > 70% in 10 trials
                    % or if 100% in 5 trials
                    newblock = 0;
                    if dcontrast < 0.6
                        dcontrast = dcontrast + 0.3;
                    else
                        dcontrast = dcontrast + 0.2;
                    end
                    if dcontrast > 1; dcontrast = 1;end               
                    indices = (loop.stim+1:3:length(data.stimuli.contrast));
                    indices = indices(data.stimuli.stim_side(loop.stim+1:3:end)==data.stimuli.stim_side(loop.stim+1));
                    lastinblock = find(diff(indices)>3,1); 
                    if isempty(lastinblock); lastinblock = length(indices); end;
                    indices = indices(1:lastinblock);
                    if data.stimuli.stim_side(loop.stim+1) == 2
                        data.stimuli.contrast2(indices) = dcontrast;
                    else
                        data.stimuli.contrast(indices) = dcontrast;
                    end                    
                    fprintf('DCONTRAST SET TO %1.1f FOR %d TRIALS\n\n',dcontrast,length(indices));            
                end
            end
            newblock = newblock + 1;
            trials = trials + 1;
                
            fprintf('%s CUE %s %1.2f\n',datestr(loop.prev_flip_time/86400,'MM:SS'),data.stimuli.cue_type{loop.stim},data.stimuli.duration(loop.stim))
    	                  
        % beginning of grating
        elseif mod(loop.stim,3) == 0
            if strcmp(data.response.cue_mode,'simultaneous')
                psychsr_sound(11);
            end
            if isempty(data.response.licks) || data.response.licks(end) < data.presentation.stim_times(end)-data.stimuli.duration(loop.stim-1)
                fprintf('%s NOT EARLY',datestr(loop.prev_flip_time/86400,'MM:SS'))
                data.response.n_delay(end+1) = 0;
            else
                fprintf('%s EARLY',datestr(loop.prev_flip_time/86400,'MM:SS'))
                data.response.n_delay(end+1) = 1;
            end
            if data.stimuli.orientation(loop.stim) == 90, fprintf(' T\n');
            else fprintf(' NT\n'); end;
        end

    end
    
% turn off grating after response.target_time
    if mod(loop.stim,3) == 0 && loop.prev_flip_time-data.presentation.stim_times(end) > data.response.target_time...
            && ~(data.response.nt_on_timeout == 1 && data.stimuli.orientation(loop.stim) ~= 90);
        loop.hide_stim = 1;   
        if data.response.mode == 3 && strcmp(data.card.ao.Running,'Off') && (data.card.ao.SamplesOutput==0)
            putsample(data.card.ao,0);
        end
    end

% laser stim
    if mod(loop.stim,3) == 2 && data.response.mode == 3 && data.stimuli.laser_on(loop.stim) && loop.prev_flip_time-data.presentation.stim_times(end) > data.response.laser_onset
        if (isempty(data.response.laser_on) || loop.prev_flip_time-data.response.laser_on(end) > data.response.laser_time) ...
            	&& (data.card.ao.SamplesOutput==0) % just in case ao already running            
            start(data.card.ao);             
            fprintf('LASER ON\n')
            data.response.laser_on(end+1) = loop.prev_flip_time;
        end
    end    
        
% spout extend/retract
    if data.response.mode == 5 && psychsr_timed_event(loop,3,data.response.extend_onset)        
        psychsr_move_spout(loop,1);
        fprintf('%s EXTEND\n',datestr(loop.prev_flip_time/86400,'MM:SS'))
    end
    if data.response.mode == 5 && psychsr_timed_event(loop,3,data.response.retract_onset)
        psychsr_move_spout(loop,2);
        fprintf('%s RETRACT\n',datestr(loop.prev_flip_time/86400,'MM:SS'))
    end
    
% free reward near the end of grating
    if data.stimuli.orientation(loop.stim)==90
        if data.response.auto_reward ~= 0   && psychsr_timed_event(loop,3,data.response.auto_reward_time)
            if isempty(data.response.rewards) || max(data.response.licks)-max(data.response.rewards) > 0 && ...
                    loop.prev_flip_time-data.response.rewards(end) > data.response.target_time
                fprintf('%s FREE',datestr(loop.prev_flip_time/86400,'MM:SS'));    
                psychsr_reward(loop,6);
                data.response.primes(end+1) = loop.prev_flip_time;
                data.response.auto_reward = data.response.auto_reward-1;
            end
        end
    end    
    
%% lick feedback
    if loop.response  
        fprintf('%s %4d',datestr(loop.prev_flip_time/86400,'MM:SS'),length(data.response.licks));
        switch mod(loop.stim,3)
            case 0
            % reward/punish if lick during grating
                if (loop.prev_flip_time > data.presentation.stim_times(end)+data.response.grace_period)
                    % REWARD
                    if data.stimuli.orientation(loop.stim) == 90    
                        if (isempty(data.response.rewards) || loop.prev_flip_time-data.response.rewards(end) > data.response.response_time... % one reward per grating        
                                || loop.prev_flip_time-max(data.response.rewards) > data.response.iri)
                            fprintf('RT %1.3f',loop.prev_flip_time-data.presentation.stim_times(loop.stim-1));                            
                            psychsr_reward(loop,6);
                        else
                            fprintf(' EXTRA\n')
                        end

                    % PUNISH
                    else 
                        if (isempty(data.response.punishs) || loop.prev_flip_time-data.response.punishs(end) > data.stimuli.duration(loop.stim)) % one punish per grating
                            psychsr_punish(loop);
        
                            % increase blank period (timeout)
                            data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)+data.response.punish_timeout;
                            data.stimuli.end_time = cumsum(data.stimuli.duration);                      
							data.stimuli.total_duration = data.stimuli.total_duration+data.response.punish_timeout; 
                        elseif data.response.punish_extra && (isempty(data.response.punishs) || loop.prev_flip_time-data.response.punishs(end) > 1)
                            psychsr_punish(loop);
                            
                            % increase blank period (timeout)
                            data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)+data.response.punish_timeout;
                            data.stimuli.end_time = cumsum(data.stimuli.duration);                      
							data.stimuli.total_duration = data.stimuli.total_duration+data.response.punish_timeout;                             
                        else                            
                            fprintf(' GRACE\n')
                        end
                    end            

                    % turn off grating after reward/punish
                    if data.response.stop_grating
                        loop.hide_stim = 1;
                    end

                else
                    fprintf(' GRACE\n')
                end
%             case 'free'
%             % free period: 2 rewards per second
%                 if (isempty(data.response.rewards) || loop.prev_flip_time-data.response.rewards(end) > 0.5)
%                     psychsr_reward(loop,6);
%                 else
%                     fprintf(' EXTRA\n')
%                 end
%                 if length(data.response.rewards) == data.response.free_rewards
%                     time_shift = data.stimuli.end_time(loop.stim)-loop.prev_flip_time;
%                     data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)-time_shift;
%                     data.stimuli.end_time = cumsum(data.stimuli.duration);
%                     fprintf('STOPPED FREE TIME AT %d\n',round(data.stimuli.duration(loop.stim)))
%                 end
            case 2
            % abort/punish if lick during movie
                if data.response.abort && (loop.prev_flip_time > data.presentation.stim_times(end)+data.response.abort_grace)
                    loop.stim = loop.stim - 1;
                    loop.new_stim = -1;                    
                    data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)+data.response.punish_timeout;
                    data.stimuli.end_time = cumsum(data.stimuli.duration);                      
                    fprintf(' ABORT')
                    psychsr_punish(loop);
                    data.response.n_total(end+1) = 0;     
                    data.response.n_delay(end+1) = 1;
                    
                else
                    fprintf(' GRACE\n')
                end
            case 1
                if data.response.extend_iti && loop.prev_flip_time > data.stimuli.end_time(loop.stim)-1
                    data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)+1;
                    data.stimuli.end_time = cumsum(data.stimuli.duration);                      
                    fprintf(' EXTEND ITI\n')                    
                else
                    fprintf(' ITI\n')
                end
        end       
    end    

%% update loop structure
    new_loop = loop;
end