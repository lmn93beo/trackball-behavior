function new_loop = psychsr_predictclock_feedback(loop)

global data;

% orients = round(data.stimuli.orientation(2:2:16));
% if loop.stim == 1
% data.response.n_grat = zeros(size(orients));
% data.response.n_iti = zeros(size(orients));
% end

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
                if (isempty(data.response.punishs) || loop.prev_flip_time-data.response.punishs(end) > data.stimuli.duration(loop.stim)) % one punish per grating
                    psychsr_punish(loop);
                    
                    % increase blank period (timeout)
                    data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)+data.response.punish_timeout;
                    data.stimuli.end_time = cumsum(data.stimuli.duration);
                    data.stimuli.total_duration = data.stimuli.total_duration+data.response.punish_timeout;
                else
                    fprintf(' GRACE\n')
                end
            end
        else
            fprintf(' EARLY\n')
        end
    else
        fprintf(' ITI\n')
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
    if data.response.auto_reward && loop.stim>1 && strcmp(data.stimuli.stim_type{loop.stim-1},'grating')
%         if isempty(data.response.licks) || max(data.response.licks) - data.presentation.stim_times(loop.stim-1) <= 0
%             i = find(orients == data.stimuli.orientation(loop.stim-1));
%             data.response.n_grat(ceil((loop.stim-2)/16),i) = 0;        
%         end
        
% free reward
        if mod(floor(data.stimuli.orientation(loop.stim-1)),90) == 0            
            
            if isempty(data.response.rewards) || max(data.response.licks)-max(data.response.rewards) > 0 && ...
                    loop.prev_flip_time-data.response.rewards(end) > data.stimuli.duration(loop.stim-1)
                fprintf('%s FREE',datestr(loop.prev_flip_time/86400,'MM:SS'));
                psychsr_reward(loop,6);
            elseif ~isempty(data.response.rewards) && (isempty(data.response.licks) || max(data.response.licks) - max(data.response.rewards) <= 0) 
                psychsr_sound(6);
                fprintf('%s TONE ONLY',datestr(loop.prev_flip_time/86400,'MM:SS'));                
                fprintf('\n');
            end
            
%             if ~isempty(data.response.rewards) && (isempty(data.response.licks) || max(data.response.licks) - max(data.response.rewards) <= 0)
%                 psychsr_sound(6);
%                 fprintf('%s TONE ONLY',datestr(loop.prev_flip_time/86400,'MM:SS'));                
%                 fprintf('\n');
%             else
%                 fprintf('%s FREE',datestr(loop.prev_flip_time/86400,'MM:SS'));
%                 psychsr_reward(loop,6);
%             end            
        else            
            fprintf('%s NO REWARD\n',datestr(loop.prev_flip_time/86400,'MM:SS'));
        end
        
        
%     elseif loop.stim>3
%         if isempty(data.response.licks) || max(data.response.licks) - data.presentation.stim_times(loop.stim-1) <= 0
%             i = find(orients == data.stimuli.orientation(loop.stim-2));
%             data.response.n_iti(ceil((loop.stim-2)/16),i) = 0;    
%         end
    end
    if ~isempty(data.response.licks) && data.response.auto_stop
        if loop.prev_flip_time-max(data.response.licks) > 120
            data.stimuli.total_duration = loop.prev_flip_time; % stop program
        end
    end
    
end



new_loop = loop;
end