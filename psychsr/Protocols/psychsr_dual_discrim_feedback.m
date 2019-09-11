function new_loop = psychsr_dual_discrim_feedback(loop)

global data;

persistent blockrewards;
persistent blocksize;
persistent retract_shift;
persistent licks;
persistent choice;

if loop.frame == 1
    n = data.stimuli.num_stimuli/3;
    data.response.stim = nan(1,n); % 1 = left, 2 = right
    data.response.choice = nan(1,n); % 0 = miss, 1 = left, 2 = right
    data.response.outcome= nan(1,n); % 0 = no reward, 1 = reward, -1 = punish
    data.response.auto = nan(1,n); % 0 = normal, 1 = auto trial
    data.response.early = nan(1,n); % 0 = no early, 1 = early correct, -1 = early wrong
    
    blockrewards = 0;
    retract_shift = 0;
    licks = 0;
    choice = 0;
    blocksize = randi([min(data.response.blockrewards) max(data.response.blockrewards)]);
    
    if data.response.retract_onset ~= Inf
        psychsr_move_spout(loop,2);
        fprintf('%s RETRACT\n',datestr(loop.prev_flip_time/86400,'MM:SS'))
    end
    
    if data.response.auto_adjust_spout>0
        i = data.stimuli.stim_id(3);
        pos = sign(1.5-i)*0.25*data.response.auto_adjust_spout;
        
        data.card.ax.SetAbsMovePos(0,data.response.spout_xpos(1)+pos);
        data.card.ax.MoveAbsolute(0,1==0);
        fprintf('AUTO ADJUST: %+1.2f\n',pos)
    end
end

%% new stimulus
if loop.frame - loop.new_stim == 1
    % end of stimulus period
    if ~strcmp(data.stimuli.stim_type{loop.stim-1},'blank')
        
        n = (loop.stim-1)/3;
        data.response.stim(n) = data.stimuli.stim_id(loop.stim-1);
        data.response.choice(n) = choice;        
        data.response.auto(n) = data.stimuli.autoflag(loop.stim-1);
        if isnan(data.response.outcome(n))
            data.response.outcome(n) = 0;
        end
        if isnan(data.response.early(n))
            data.response.early(n) = 0;
        end
        
%         disp([data.response.stim(n) data.response.choice(n) data.response.auto(n) data.response.outcome(n)])
        
        if choice == 0
            fprintf('%s MISS\n',datestr(loop.prev_flip_time/86400,'MM:SS'))
                        
            % stop program if 7 misses in a row
            if data.response.auto_stop > 0 && n > data.response.auto_stop
                if max(abs(data.response.choice(max(1,n-data.response.auto_stop-1):end))) == 0
                    data.stimuli.total_duration = loop.prev_flip_time;
                end
            end
        end
        
        % antibias repeat
        if data.response.choice(n) ~= data.response.stim(n) && data.response.antibias_repeat > rand
            i = data.stimuli.stim_id(loop.stim-1);
            fprintf('ANTIBIAS REPEAT %d\n',i);
            ix = loop.stim+2;
            
            data.stimuli.stim_id(ix) = i;
            fnames = fieldnames(data.stimuli.stimparams);
            for f = 1:length(fnames)
                data.stimuli.(fnames{f})(ix) = data.stimuli.stimparams(i).(fnames{f});
            end
        end
        
        if blocksize > 0
            nonprimes = setxor(data.response.rewards(:),data.response.primes(:));
            rewardFlag = max(nonprimes) > data.presentation.stim_times(end-1)+data.response.grace_period;
            if isempty(rewardFlag); rewardFlag = false; end;
            
            if rewardFlag
                blockrewards = blockrewards+1;
                fprintf('reward #%d of %d\n',blockrewards,blocksize)
                
            elseif data.response.consecFlag && data.response.choice(n)==data.response.stim(n)
                blockrewards = 0;
            end
            
            if blockrewards == blocksize
                i = 3-data.stimuli.stim_id(loop.stim-1);
                fprintf('new block: %d\n',i);
                ix = loop.stim+2:3:data.stimuli.num_stimuli;
                
                data.stimuli.stim_id(ix) = i;
                fnames = fieldnames(data.stimuli.stimparams);
                for f = 1:length(fnames)
                    data.stimuli.(fnames{f})(ix) = data.stimuli.stimparams(i).(fnames{f});
                end
                
                blockrewards = 0;
                blocksize = randi([min(data.response.blockrewards) max(data.response.blockrewards)]);
             
            end
            
            if data.response.auto_adjust_spout>0 && blockrewards<=data.response.auto_adjust_spout
                i = data.stimuli.stim_id(loop.stim+2);
                pos = sign(1.5-i)*0.25*(data.response.auto_adjust_spout-blockrewards);
                
                data.card.ax.SetAbsMovePos(0,data.response.spout_xpos(1)+pos);
                data.card.ax.MoveAbsolute(0,1==0);
                fprintf('AUTO ADJUST: %+1.2f\n',pos)
            end
            
        end
    % begining of stimulus    
    elseif mod(loop.stim,3) == 0
        fprintf('%s TRIAL %d\n',datestr(loop.prev_flip_time/86400,'MM:SS'),loop.stim/3)
%         if sum(sum(data.response.licks>=data.presentation.stim_times(end-1)))>0
%             fprintf('%s EARLY',datestr(loop.prev_flip_time/86400,'MM:SS'))
%             data.response.n_delay(end+1) = 1;
%         else
%             fprintf('%s NOT EARLY',datestr(loop.prev_flip_time/86400,'MM:SS'))
%             data.response.n_delay(end+1) = 0;
%         end
%         if data.stimuli.stim_id(loop.stim) == 2, fprintf(' RIGHT\n');
%         else fprintf(' LEFT\n'); end;
    
    % beginning of "delay" period (prestimulus)
    elseif mod(loop.stim,3) == 2
        licks = 0; % reset lick counter
        choice = 0;
        
        psychsr_sound(data.stimuli.cue_tone(loop.stim));
        data.response.tones(end+1) = loop.prev_flip_time;
        
        last10_a = find(~isnan(data.response.stim),10,'last');
        last10_l = find(data.response.stim==1,10,'last');
        last10_r = find(data.response.stim==2,10,'last');       
        all_a = ~isnan(data.response.stim);
        all_l = data.response.stim==1; 
        all_r = data.response.stim==2;        
        c = data.response.choice;
        o = data.response.outcome;          
        e = data.response.early;
        choice_l = round([mean(c(last10_l)==1) mean(c(last10_l)==2)]*100);
        choice_r = round([mean(c(last10_r)==1) mean(c(last10_r)==2)]*100);
        choice_l_all = round([mean(c(all_l)==1) mean(c(all_l)==2)]*100);
        choice_r_all = round([mean(c(all_r)==1) mean(c(all_r)==2)]*100);        
        out_l = round([mean(o(last10_l)==1) mean(o(last10_l)==-1)]*100);
        out_r = round([mean(o(last10_r)==1) mean(o(last10_r)==-1)]*100);
        out_l_all = round([mean(o(all_l)==1) mean(o(all_l)==-1)]*100);
        out_r_all = round([mean(o(all_r)==1) mean(o(all_r)==-1)]*100);
        early = round([mean(e(last10_a)==1) mean(e(last10_a)==-1)]*100);
        early_all = round([mean(e(all_a)==1) mean(e(all_a)==-1)]*100);
        
        if isempty(data.response.licks)
            bias = NaN;
            bias_all = NaN;
        else
            bias = round(mean(data.response.licks(1+(end-100)*(end-100>0):end,1)~=0)*100);
            leftlicks = sum(data.response.licks(:,1)~=0);
            bias_all = round(leftlicks/size(data.response.licks,1)*100);
        end
        
        str = '';
        str = [str,sprintf('\n\nFIRST LICK:')];
        str = [str,sprintf('\n          LAST10      TOTAL\n')];        
        str = [str,sprintf('LEFT%%   %3d%%/%3d%%   %3d%%/%3d%% of %d\n',choice_l,choice_l_all,sum(all_l))];
        str = [str,sprintf('RIGHT%%  %3d%%/%3d%%   %3d%%/%3d%% of %d\n',choice_r,choice_r_all,sum(all_r))];
        str = [str,sprintf('BIAS%%   %3d%%/%3d%%   %3d%%/%3d%% of %d\n',bias,100-bias,bias_all,100-bias_all,size(data.response.licks,1))];

        str = [str,sprintf('\nREWARD/PUNISH:')];
        str = [str,sprintf('\n          LAST10      TOTAL\n')];
        str = [str,sprintf('EARLY%%  %3d%%/%3d%%   %3d%%/%3d%% of %d\n',early,early_all,sum(all_a))];
        str = [str,sprintf('LEFT%%   %3d%%/%3d%%   %3d%%/%3d%% of %d\n',out_l,out_l_all,sum(all_l))];
        str = [str,sprintf('RIGHT%%  %3d%%/%3d%%   %3d%%/%3d%% of %d\n',out_r,out_r_all,sum(all_r))];
               
        str = [str,sprintf('\nLAST LICK: -%s\n\n\n',datestr((loop.prev_flip_time-max(max(data.response.licks)))/86400,'MM:SS'))];
        fprintf('%s',str)
        
        if mod(loop.stim,9)==2
            fid = fopen(sprintf('rig%1d.txt',str2num(data.screen.pc(end))),'w');
            fprintf(fid,'RIG %1d\nMOUSE %2d\n%s TRIAL %d\n',str2num(data.screen.pc(end)),data.mouse,datestr(loop.prev_flip_time/86400,'MM:SS'),floor(loop.stim/3));
            fprintf(fid,'%s',str);
            fclose(fid);
        end
        
    end
    
end

%% auto reward
if data.response.go_cue>0 && psychsr_timed_event(loop,3,data.response.grace_period)
    psychsr_sound(data.response.go_cue);
    fprintf('%s GO CUE\n',datestr(loop.prev_flip_time/86400,'MM:SS'));
end
if data.response.auto_reward ~= 0 && psychsr_timed_event(loop,3,data.response.auto_reward_time) ...
        && data.stimuli.autoflag(loop.stim)
    side = data.stimuli.stim_id(loop.stim);    
    if (sum(data.response.rewards(:,side))==0 ||... % no rewards yet OR
            max(data.response.licks(:,side))-max(data.response.rewards(:,side)) > 0)  
        fprintf('%s FREE',datestr(loop.prev_flip_time/86400,'MM:SS'));
        
        if side == 2
            fprintf(' RIGHT')
        else
            fprintf(' LEFT')
        end
        psychsr_reward(loop,0,data.response.auto_reward_amt,side); % reward on right
        data.response.primes(end+1,side) = loop.prev_flip_time;
        data.response.auto_reward = data.response.auto_reward-1;
    else
        fprintf('%s FREE WATER STILL THERE\n',datestr(loop.prev_flip_time/86400,'MM:SS'));
    end
end

%% spout extend/retract
if psychsr_timed_event(loop,3,data.response.extend_onset)
    psychsr_move_spout(loop,1);
    fprintf('%s EXTEND DELAY %1.1f\n',datestr(loop.prev_flip_time/86400,'MM:SS'),data.response.extend_onset)
end

if psychsr_timed_event(loop,3,data.response.retract_onset + retract_shift)    
    psychsr_move_spout(loop,2);   
    fprintf('%s RETRACT\n',datestr(loop.prev_flip_time/86400,'MM:SS'))
    retract_shift = 0;
end

%% leave grating on?
if psychsr_timed_event(loop,3,data.response.target_time)
    loop.hide_stim = 1;
end

if loop.stim > 1
    numlicks = sum(sum(data.response.rewards > data.presentation.stim_times(end)));
else
    numlicks = size(data.response.rewards,1);
end 

if data.response.leave_grating && ~strcmp(data.stimuli.stim_type{loop.stim},'blank')
    if numlicks < 1 && loop.prev_flip_time > data.stimuli.end_time(loop.stim)-2.5*data.screen.flip_int*data.presentation.wait_frames
        data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim) + 1;
        data.stimuli.end_time = cumsum(data.stimuli.duration);
    end
end
%% if lick
% if animal licks ONE port
if sum(loop.response)==1
    
    % licking during stimulus
    if ~strcmp(data.stimuli.stim_type{loop.stim},'blank')
        side = find(loop.response);
        fprintf('%s %4d',datestr(loop.prev_flip_time/86400,'MM:SS'),size(data.response.licks,1));
        if side == 1; fprintf(' LEFT');
        else fprintf(' RIGHT'); end
        
            
        % if lick occurs during response window
        if (loop.prev_flip_time > data.presentation.stim_times(end)+data.response.grace_period)
            
            if sign(licks) == sign(side-1.5) % left = neg, right = pos
                licks = licks + sign(side-1.5);
            else % reset counter if side switched
                licks = sign(side-1.5);
            end
            
            % meet lick threshold?
            threshFlag = abs(licks) >= data.response.lick_threshold;
            
            % no recent reward?
%             rewardFlag = loop.prev_flip_time-max(data.response.rewards(:)) > max(data.stimuli.duration(3:3:end)) ...
%                 | loop.prev_flip_time-max(data.response.rewards(:)) > data.response.iri;
%             if isempty(rewardFlag); rewardFlag = true; end
%             
%             % no recent punishment?
%             punishFlag = loop.prev_flip_time-max(data.response.punishs(:)) > max(data.stimuli.duration(3:3:end));
%             if isempty(punishFlag); punishFlag = true; end
            
            % if correct lick
            if side == data.stimuli.stim_id(loop.stim)
                if threshFlag && (choice == 0 || ...
                        (data.response.first_lick==0 && choice~=side) || ...
                        choice == side && loop.prev_flip_time-max(data.response.rewards(:)) > data.response.iri)
                                  
                    choice = side;
                    all_r = loop.prev_flip_time-data.presentation.stim_times(loop.stim-1);%-data.response.extend_onset;
                    fprintf(' RT %1.3f',all_r);
                    
                    if data.response.stop_grating==1; loop.hide_stim = 1;
                    elseif data.response.stop_grating==2; data.stimuli.temp_freq(loop.stim) = 0; end;
                    
                    if rand<data.response.p_reward %&& ~data.stimuli.autoflag(loop.stim) % probabilistically provide reward
                        psychsr_reward(loop,6,[],side); % reward
                        data.response.outcome(loop.stim/3) = 1;
                        
                        resptime = data.response.retract_onset-data.response.extend_onset;
                        if resptime-all_r < 1.5
                            retract_shift = 1.5 + all_r - resptime;
                        end
                    else
                        fprintf(' NO REWARD\n')
                    end
                elseif choice == 3-side && data.response.double_timeout > 0 ...
                        && loop.hide_stim == 0 % abort if they switch to other side
                    psychsr_sound(1);                      
                    data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)+data.response.double_timeout;
                    data.stimuli.end_time = cumsum(data.stimuli.duration);
                    data.stimuli.total_duration = data.stimuli.total_duration+data.response.double_timeout;
                    loop.hide_stim = 1;
                    psychsr_move_spout(loop,2);   
                    fprintf(' DOUBLE LICK %d\n',abs(licks))
                else
                    fprintf(' EXTRA %d\n',abs(licks))
                end
                
                if data.stimuli.autoflag(loop.stim)
                    data.response.outcome(loop.stim/3) = 1;
                end
                
            % if incorrect lick
            else
                fprintf(' WRONG');                
                if choice == 0 && threshFlag
                    if ~(data.response.first_lick==0 && choice==3-side)
                        choice = side;
                    end
                    all_r = loop.prev_flip_time-data.presentation.stim_times(loop.stim-1);%-data.response.extend_onset;
                    fprintf(' RT %1.3f',all_r);
                    
                    if data.response.punish>0 
                        psychsr_punish(loop,1);
                        if data.stimuli.autoflag(loop.stim)==0 || isnan(data.response.outcome(loop.stim/3))
                            data.response.outcome(loop.stim/3) = -1;
                        end
                        
                        data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)+data.response.punish_timeout;
                        data.stimuli.end_time = cumsum(data.stimuli.duration);
                        data.stimuli.total_duration = data.stimuli.total_duration+data.response.punish_timeout;       

                        if data.response.stop_grating==1; loop.hide_stim = 1;
                        elseif data.response.stop_grating==2; data.stimuli.temp_freq(loop.stim) = 0; end;
                    else                    
                        fprintf(' %d\n',abs(licks))
                    end
                elseif choice == 3-side && data.response.double_timeout > 0 ...
                        && loop.hide_stim == 0 % abort if they switch to other side
                    
                    psychsr_sound(1);  
                    data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)+data.response.double_timeout;
                    data.stimuli.end_time = cumsum(data.stimuli.duration);
                    data.stimuli.total_duration = data.stimuli.total_duration+data.response.double_timeout;
                    loop.hide_stim = 1;
                    psychsr_move_spout(loop,2);   
                    fprintf(' DOUBLE LICK %d\n',abs(licks))
                else
                    if data.response.punish_every_lick
                        psychsr_sound(1);
                    end
                    
                    fprintf(' %d\n',abs(licks))
                end
            end
            
        else
            data.response.early(loop.stim/3) = sign((side==data.stimuli.stim_id(loop.stim))-0.5);
            fprintf(' GRACE\n')
        end
            
        
    else
        if loop.response(1) == 1
            fprintf('%s %4d LEFT',datestr(loop.prev_flip_time/86400,'MM:SS'),size(data.response.licks,1));
        else
            fprintf('%s %4d RIGHT',datestr(loop.prev_flip_time/86400,'MM:SS'),size(data.response.licks,1));
        end
        if mod(loop.stim,3) == 1
            eiti = data.response.extend_iti;
            if eiti>0 && loop.prev_flip_time > data.stimuli.end_time(loop.stim)-eiti
                data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)+eiti;
                data.stimuli.end_time = cumsum(data.stimuli.duration);
                fprintf(' EXTEND ITI\n')
            else
                fprintf(' ITI\n')
            end
        else
            side = find(loop.response);
            data.response.early((loop.stim+1)/3) = sign((side==data.stimuli.stim_id(loop.stim+1))-0.5);
            fprintf(' EARLY\n')
        end
        
        
    end
    
% BOTH ports = nothing
elseif sum(loop.response) == 2
    fprintf('%s %4d',datestr(loop.prev_flip_time/86400,'MM:SS'),size(data.response.licks,1));
%         psychsr_sound(1);
    fprintf(' BOTH\n')
%         if data.response.punish; psychsr_punish(loop,0,1); psychsr_punish(loop,1,2);
%         else psychsr_sound(1); fprintf(' WRONG \n'); end;
end

new_loop = loop;
end