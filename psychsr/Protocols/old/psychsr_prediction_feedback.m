function new_loop = psychsr_prediction_feedback(loop)

global data;

if loop.stim == 1
    data.response.n_overall = [];
    data.response.n_hits = [];
    data.response.n_false = [];
    data.response.n_switch = [];
end

if loop.response
    % print time of lick
    fprintf('%s %4d',datestr(loop.prev_flip_time/86400,'MM:SS'),length(data.response.licks));
    % licks don't count in first 250ms
    if strcmp(data.stimuli.stim_type(loop.stim),'grating')
        if (loop.prev_flip_time > data.presentation.stim_times(end)+data.response.grace_period)
            if mod(floor(data.stimuli.orientation(loop.stim)),90) == 0 
                if (isempty(data.response.rewards) || loop.prev_flip_time-data.response.rewards(end) > data.stimuli.duration(loop.stim)) % one reward per grating
                    fprintf('RT %1.3f',loop.prev_flip_time-data.presentation.stim_times(loop.stim-1));
                    psychsr_reward(loop,6);
                else
                    fprintf(' EXTRA\n')
                end
                
            else
                if data.response.punish && (isempty(data.response.punishs) || loop.prev_flip_time-data.response.punishs(end) > data.stimuli.duration(loop.stim)) % one punish per grating
                    psychsr_punish(loop);
                    
                    % increase blank period (timeout)
                    data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)+data.response.punish_timeout;
                    data.stimuli.end_time = cumsum(data.stimuli.duration);
                    data.stimuli.total_duration = data.stimuli.total_duration+data.response.punish_timeout;
                else
                    fprintf(' GRACE\n')
                end
            end
            
            if data.response.stop_grating
                loop.hide_stim = 1;
            end
        else
            fprintf(' EARLY\n')
        end
    else
        if data.response.extend_iti && loop.stim > 1 && data.stimuli.orientation(loop.stim-1)==90 ...
                && data.stimuli.duration(loop.stim) <6 && loop.prev_flip_time > data.stimuli.end_time(loop.stim)-1
            data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)+1;
            data.stimuli.end_time = cumsum(data.stimuli.duration);
            fprintf(' EXTEND ITI\n')
        else
            fprintf(' ITI\n')
        end
    end
    
%     if ~isnan(data.stimuli.orientation(loop.stim))
%         i = find(orients == data.stimuli.orientation(loop.stim));
%         data.response.n_grat(ceil((loop.stim-1)/16),i) = 1;
%     elseif loop.stim>1        
%         i = find(orients == data.stimuli.orientation(loop.stim-1));
%         data.response.n_iti(ceil((loop.stim-1)/16),i) = 1;
%     end
end

% previous stimulus type
% if mod(loop.stim,2) == 1 && size(data.response.n_grat,1)>2
%     mg = round(mean(data.response.n_grat)*100);
%     mi = round(mean(data.response.n_iti)*100);
%     for i = 1:length(orients)
%         fprintf('%4d: %2d/%2d of %2d\n',orients(i),mg(i),mi(i),size(data.response.n_grat,1));
%     end    
% end

if loop.frame-loop.new_stim==1
    % update hit/FA percentages
    if loop.stim>2 && mod(loop.stim,2) == 1
        if sum(data.response.licks>=data.presentation.stim_times(end-1)+data.response.grace_period & ...
                data.response.licks<data.presentation.stim_times(end-1)+data.response.auto_time)>0
            if data.stimuli.orientation(loop.stim-1)==90; 
                data.response.n_hits(end+1) = 1;
                data.response.n_overall(end+1) = 1;
            else 
                data.response.n_false(end+1) = 1;
                data.response.n_overall(end+1) = 0;
            end
%             if data.stimuli.switch_index(loop.stim-1)*-240+450 == data.stimuli.orientation(loop.stim-1)
%                 data.response.n_switch(end+1) = 1;
%             end            
        else
            if data.stimuli.orientation(loop.stim-1) == 90
                data.response.n_hits(end+1) = 0;
                data.response.n_overall(end+1) = 0;
            else 
                data.response.n_false(end+1) = 0;
                data.response.n_overall(end+1) = 1;
            end
%             if data.stimuli.switch_index(loop.stim-1)*-240+450 == data.stimuli.orientation(loop.stim-1)
%                 data.response.n_switch(end+1) = 0;
%             end
            data.response.n_overall(end+1) = 0;
        end
    end
    
    % display information
    if mod(loop.stim,6) == 1
        per_hit = round(mean(data.response.n_hits(1+(end-10)*(end-10>0):end))*100);
        per_false = round(mean(data.response.n_false(1+(end-10)*(end-10>0):end))*100);
        per_switch = round(mean(data.response.n_switch(1+(end-10)*(end-10>0):end))*100);
        fprintf('\n       LAST10    TOTAL\n')
        fprintf('HIT%%    %3d%%   %3d%% of %d\n',per_hit,round(mean(data.response.n_hits)*100),length(data.response.n_hits))
        fprintf('FALSE%%  %3d%%   %3d%% of %d\n',per_false,round(mean(data.response.n_false)*100),length(data.response.n_false))
        fprintf('SWITCH%% %3d%%   %3d%% of %d\n',per_switch,round(mean(data.response.n_switch)*100),length(data.response.n_switch))
        fprintf('LAST LICK: -%s\n\n',datestr((loop.prev_flip_time-max(data.response.licks))/86400,'MM:SS'))
        
        fid = fopen(sprintf('rig%1d.txt',str2num(data.screen.pc(end))),'w');
        fprintf(fid,'RIG %1d\nMOUSE %2d\n%s TRIAL %d\n',str2num(data.screen.pc(end)),data.mouse,datestr(loop.prev_flip_time/86400,'MM:SS'),floor(loop.stim/3));
        fprintf(fid,'\n       LAST10    TOTAL\n');
        fprintf(fid,'HIT%%    %3d%%   %3d%% of %d\n',per_hit,round(mean(data.response.n_hits)*100),length(data.response.n_hits));
        fprintf(fid,'FALSE%%  %3d%%   %3d%% of %d\n',per_false,round(mean(data.response.n_false)*100),length(data.response.n_false));
        fprintf(fid,'SWITCH%% %3d%%   %3d%% of %d\n',per_switch,round(mean(data.response.n_switch)*100),length(data.response.n_switch));
        fprintf(fid,'LAST LICK: -%s\n\n',datestr((loop.prev_flip_time-max(data.response.licks))/86400,'MM:SS'));
        fclose(fid);
    end
    
    if ~isempty(data.response.licks) && data.response.auto_stop
        if loop.prev_flip_time-max(data.response.licks) > 120
            data.stimuli.total_duration = loop.prev_flip_time; % stop program
        end
    end
    
end

if data.stimuli.orientation(loop.stim)==90 && ...
        loop.prev_flip_time-data.presentation.stim_times(end)>data.response.auto_time    
    if data.response.auto_reward ~= 0
        if isempty(data.response.rewards) || max(data.response.licks)-max(data.response.rewards) > 0 && ...
                loop.prev_flip_time-data.response.rewards(end) > 2
            fprintf('%s FREE',datestr(loop.prev_flip_time/86400,'MM:SS'));
            psychsr_reward(loop,6);
            data.response.primes(end+1) = loop.prev_flip_time;
        end
    end
end

new_loop = loop;
end