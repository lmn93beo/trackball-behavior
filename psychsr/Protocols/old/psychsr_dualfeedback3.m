function new_loop = psychsr_dualfeedback3(loop)
    
    global data;  

    if loop.frame == 1
        data.response.n_overall = [];
        data.response.n_bias = []; %+1 left, -1 right
        data.response.n_left = [];
        data.response.n_right = [];
        data.response.n_delay = [];
    end
    
%% new stimulus
    if loop.frame - loop.new_stim == 1        
        if strcmp(data.stimuli.stim_type{loop.stim-1},'grating')
            if isempty(data.response.licks) || max(max(data.response.licks)) < data.presentation.stim_times(end-1)+data.response.grace_period
                fprintf('%s MISS\n',datestr(loop.prev_flip_time/86400,'MM:SS'))
                if data.stimuli.stim_side(loop.stim-1) == 2
                    data.response.n_right(end+1) = 0;
                else
                    data.response.n_left(end+1) = 0;
                end
                data.response.n_overall(end+1) = 0;                
                data.response.n_bias(end+1) = 0;
            end            
            
            if data.response.auto_bias && length(data.response.n_bias)>10
                x = data.response.n_bias(end-9:end);
                nleft = sum(x==1); nright = sum(x==-1);
                nsame = sum(diff([data.response.n_bias(end-10) x])==0 & x~=0);
                nopp = sum(abs(diff([data.response.n_bias(end-10) x]))==2);
                if abs(nsame-nopp) > abs(nleft-nright)
                    xend = x(end);
                    while xend == 0
                        x = x(1:end-1);
                        xend = x(end);
                    end                        
                    if nsame>nopp % disp opp
                        disp('opp')
                        side = 1.5+0.5*xend; %1 = left, 2 = right
                        data.stimuli.stim_side(loop.stim+2) = side;
                        data.stimuli.contrast(loop.stim+2) = side-1;
                        data.stimuli.contrast2(loop.stim+2) = 2-side;                        
                    else
                        disp('same')
                        side = 1.5-0.5*xend; %1 = left, 2 = right
                        data.stimuli.stim_side(loop.stim+2) = side;
                        data.stimuli.contrast(loop.stim+2) = side-1;
                        data.stimuli.contrast2(loop.stim+2) = 2-side;
                    end
                elseif abs(nsame-nopp) < abs(nleft-nright)
                    if nleft>nright % disp right
                        disp('right')
                        data.stimuli.stim_side(loop.stim+2) = 2;
                        data.stimuli.contrast(loop.stim+2) = 1;
                        data.stimuli.contrast2(loop.stim+2) = 0;
                    else
                        disp('left')
                        data.stimuli.stim_side(loop.stim+2) = 1;
                        data.stimuli.contrast(loop.stim+2) = 0;
                        data.stimuli.contrast2(loop.stim+2) = 1;
                    end
                else
                    disp('rand')
                    side = randi(2); %1 = left, 2 = right
                    data.stimuli.stim_side(loop.stim+2) = side;
                    data.stimuli.contrast(loop.stim+2) = side-1;
                    data.stimuli.contrast2(loop.stim+2) = 2-side;
                end
            end
            
        elseif mod(loop.stim,3) == 0            
            if sum(sum(data.response.licks>=data.presentation.stim_times(end-1)))>0
                fprintf('%s EARLY',datestr(loop.prev_flip_time/86400,'MM:SS'))
                data.response.n_delay(end+1) = 1;                
            else                
                fprintf('%s NOT EARLY',datestr(loop.prev_flip_time/86400,'MM:SS'))
                data.response.n_delay(end+1) = 0;                
            end
            if data.stimuli.stim_side(loop.stim) == 2, fprintf(' RIGHT\n');
            else fprintf(' LEFT\n'); end;
        elseif mod(loop.stim,3) == 2
            psychsr_sound(data.stimuli.cue_tone(loop.stim));
            data.response.tones(end+1) = loop.prev_flip_time;
            
            per_left = round(mean(data.response.n_left(1+(end-10)*(end-10>0):end)>0)*100);
            per_right = round(mean(data.response.n_right(1+(end-10)*(end-10>0):end)>0)*100);
%             per_delay = round(mean(data.response.n_delay(1+(end-10)*(end-10>0):end))*100); 
            if isempty(data.response.licks)
                per_bias = NaN;
                leftlicks = NaN;
            else
                per_bias = round(mean(data.response.licks(1+(end-100)*(end-100>0):end,1)~=0)*100);
                leftlicks = sum(data.response.licks(:,1)~=0);            
            end

            fprintf('\n      LAST10    TOTAL\n')
            fprintf('LEFT%%   %3d%%   %3d%% of %d\n',per_left,round(mean(data.response.n_left>0)*100),length(data.response.n_left))
            fprintf('RIGHT%%  %3d%%   %3d%% of %d\n',per_right,round(mean(data.response.n_right>0)*100),length(data.response.n_right))
%             fprintf('DELAY%%  %3d%%   %3d%% of %d\n',per_delay,round(mean(data.response.n_delay)*100),length(data.response.n_delay))
            fprintf('BIAS%%   %3d%%   %3d%% of %d\n',per_bias,round(leftlicks/size(data.response.licks,1)*100),size(data.response.licks,1))
            fprintf('LAST LICK: -%s\n\n',datestr((loop.prev_flip_time-max(max(data.response.licks)))/86400,'MM:SS'))
            if mod(loop.stim,9)==2
                fid = fopen(sprintf('rig%1d.txt',str2num(data.screen.pc(end))),'w');
                fprintf(fid,'RIG %1d\nMOUSE %2d\n%s TRIAL %d\n',str2num(data.screen.pc(end)),data.mouse,datestr(loop.prev_flip_time/86400,'MM:SS'),floor(loop.stim/3));
                fprintf(fid,'\n      LAST10    TOTAL\n');
                fprintf(fid,'LEFT%%   %3d%%   %3d%% of %d\n',per_left,round(mean(data.response.n_left>0)*100),length(data.response.n_left));
                fprintf(fid,'RIGHT%%  %3d%%   %3d%% of %d\n',per_right,round(mean(data.response.n_right>0)*100),length(data.response.n_right));
                fprintf(fid,'BIAS%%   %3d%%   %3d%% of %d\n',per_bias,round(leftlicks/size(data.response.licks,1)*100),size(data.response.licks,1));
%                 fprintf(fid,'DELAY%%   %3d%%   %3d%% of %d\n',per_delay,round(mean(data.response.n_delay)*100),length(data.response.n_delay));
                fprintf(fid,'LAST LICK: -%s\n\n',datestr((loop.prev_flip_time-max(max(data.response.licks)))/86400,'MM:SS'));
                fclose(fid);
            end
            
        end
        
        if ~isempty(data.response.licks) && data.response.auto_stop
            if loop.prev_flip_time-max(max(data.response.licks)) > 120
                data.stimuli.total_duration = loop.prev_flip_time; % stop program
            end
        end
        
    end
    
%% auto reward        
    if data.stimuli.orientation(loop.stim)==90 && loop.prev_flip_time-data.presentation.stim_times(end)>1.9
        if data.response.auto_reward ~= 0
            if (isempty(data.response.licks) || max(max(data.response.licks))-data.presentation.stim_times(end)-data.response.grace_period < 0) ...
                && (isempty(data.response.rewards) || (~isempty(data.response.licks) && max(max(data.response.licks))-max(max(data.response.rewards)) > 0))
                fprintf('%s FREE',datestr(loop.prev_flip_time/86400,'MM:SS'));
                if data.stimuli.stim_side(loop.stim) == 2
                    fprintf(' RIGHT')
                    psychsr_reward(loop,6,2); % reward on right
                else
                    fprintf(' LEFT')
                    psychsr_reward(loop,7,1);
                end
                data.response.primes(end+1) = loop.prev_flip_time;
                data.response.auto_reward = data.response.auto_reward-1;
            end
        end
    end
    
%% leave grating on?
    if loop.stim > 1
        numlicks = sum(sum(data.response.rewards > data.presentation.stim_times(end)));
    else
        numlicks = size(data.response.rewards,1);
    end

    if data.response.leave_grating && strcmp(data.stimuli.stim_type{loop.stim},'grating')
        if numlicks < 1 && loop.prev_flip_time > data.stimuli.end_time(loop.stim)-2.5*data.screen.flip_int*data.presentation.wait_frames
            data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim) + 1;
            data.stimuli.end_time = cumsum(data.stimuli.duration);
        end
    end
%% if lick
    % if animal licks ONE port
    if sum(loop.response)==1
        if strcmp(data.stimuli.stim_type{loop.stim},'grating')
            if loop.response(1) == 1 % lick on left
                fprintf('%s %4d LEFT',datestr(loop.prev_flip_time/86400,'MM:SS'),size(data.response.licks,1));                
                if (loop.prev_flip_time > data.presentation.stim_times(end)+data.response.grace_period)
                    % if first lick                    
                    if sum(sum(data.response.licks>data.presentation.stim_times(end)+data.response.grace_period))==1
                        data.response.n_bias(end+1) = 1;
                        if data.stimuli.stim_side(loop.stim) == 1
                            psychsr_reward(loop,7,1); % reward on left
                            data.response.n_left(end+1) = 1;
                            data.response.n_overall(end+1) = 1;
                        else
                            if data.response.punish; psychsr_punish(loop,1,1); % punish on left
                            else psychsr_sound(1); fprintf(' WRONG \n'); end;
                            data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)+data.response.punish_timeout;
                            data.stimuli.end_time = cumsum(data.stimuli.duration);
                            data.stimuli.total_duration = data.stimuli.total_duration+data.response.punish_timeout;
                            data.response.n_right(end+1) = -1;
                            data.response.n_overall(end+1) = -1;
                        end
                        if data.response.stop_grating; loop.hide_stim = 1; end;
                    elseif loop.hide_stim == 0 % subsequent licks
                        if data.stimuli.stim_side(loop.stim) == 1 && ...
                                sum(sum(data.response.rewards>data.presentation.stim_times(end)+data.response.grace_period))==0
                            psychsr_reward(loop,7,1); % reward on left
                        elseif data.stimuli.stim_side(loop.stim) == 2
                            if data.response.punish && data.response.punish_extra
                                psychsr_punish(loop,1,1);
                            else psychsr_sound(1); fprintf(' WRONG \n'); end;
                        else
                            fprintf(' EXTRA \n')
                        end
                    else
                        fprintf(' EXTRA \n')
                    end
                else
                    fprintf(' GRACE\n')
                end
                
            else % lick on left
                fprintf('%s %4d RIGHT',datestr(loop.prev_flip_time/86400,'MM:SS'),size(data.response.licks,1));
                
                if (loop.prev_flip_time > data.presentation.stim_times(end)+data.response.grace_period)
                    if sum(sum(data.response.licks>data.presentation.stim_times(end)+data.response.grace_period))==1
                        data.response.n_bias(end+1) = -1;
                        if data.stimuli.stim_side(loop.stim) == 2
                            psychsr_reward(loop,6,2); % reward on right
                            data.response.n_right(end+1) = 1;
                            data.response.n_overall(end+1) = 1;
                        else
                            if data.response.punish; psychsr_punish(loop,1,2); % punish on left
                            else psychsr_sound(1); fprintf(' WRONG \n'); end;
                            data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)+data.response.punish_timeout;
                            data.stimuli.end_time = cumsum(data.stimuli.duration);
                            data.stimuli.total_duration = data.stimuli.total_duration+data.response.punish_timeout;
                            data.response.n_left(end+1) = -1;
                            data.response.n_overall(end+1) = -1;
                        end
                        if data.response.stop_grating; loop.hide_stim = 1; end;
                    elseif loop.hide_stim == 0 % subsequent licks
                        if data.stimuli.stim_side(loop.stim) == 2 && ...
                                sum(sum(data.response.rewards>data.presentation.stim_times(end)+data.response.grace_period))==0
                            psychsr_reward(loop,6,2); % reward on right
                        elseif data.stimuli.stim_side(loop.stim) == 1
                            if data.response.punish && data.response.punish_extra
                                psychsr_punish(loop,1,2);
                            else psychsr_sound(1); fprintf(' WRONG \n'); end;
                        else
                            fprintf(' EXTRA \n')
                        end
                    else
                        fprintf(' EXTRA \n')
                    end
                else
                    fprintf(' GRACE\n')
                end
            end
        elseif mod(loop.stim,3) == 1
            if loop.response(1) == 1
                fprintf('%s %4d LEFT',datestr(loop.prev_flip_time/86400,'MM:SS'),size(data.response.licks,1));
            else
                fprintf('%s %4d RIGHT',datestr(loop.prev_flip_time/86400,'MM:SS'),size(data.response.licks,1));
            end
            if data.response.extend_iti && loop.prev_flip_time > data.stimuli.end_time(loop.stim)-1
                data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)+1;
                data.stimuli.end_time = cumsum(data.stimuli.duration);
                fprintf(' EXTEND ITI\n')
            else
                fprintf(' ITI\n')
            end
        end
        
    % BOTH ports = nothing
    elseif sum(loop.response) == 2        
        fprintf('%s %4d',datestr(loop.prev_flip_time/86400,'MM:SS'),size(data.response.licks,1));
        psychsr_sound(1);
        fprintf(' BOTH\n')
%         if data.response.punish; psychsr_punish(loop,0,1); psychsr_punish(loop,1,2); 
%         else psychsr_sound(1); fprintf(' WRONG \n'); end;        
    end
    
    new_loop = loop;
end