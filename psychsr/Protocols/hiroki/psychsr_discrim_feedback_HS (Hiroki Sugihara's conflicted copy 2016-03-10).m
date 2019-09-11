function new_loop = psychsr_discrim_feedback_HS(loop)
global data;
persistent retract_shift;
persistent licks;
persistent cr;
persistent l_on;

if loop.frame == 1          
    data.response.n_total = [];
    data.response.n_overall = [];
    data.response.n_hits = [];
    data.response.n_false = [];
    data.response.n_delay = [];        
    retract_shift = 0; % shift retract time by (+/-) X seconds
    licks = 0; % number of licks during stimulus, reset every trial
    cr = 0; % was last trial a correct reject
    l_on = 0;
    if data.response.retract_onset ~= Inf
        psychsr_move_spout(loop,2);   
        fprintf('%s RETRACT\n',datestr(loop.prev_flip_time/86400,'MM:SS'))
    end
    if isfield(data.response,'alert_gp') && data.response.alert_gp && ~strcmp(data.response.notify,'g')
        email = '6177672116@messaging.sprintpcs.com';
        sendmail(email,sprintf('m%02d started on %s at %s',...
            data.mouse,data.screen.pc,datestr(now,'mm/dd HH:MM')));
        fprintf('SENT EMAIL\n');
    end
% *** 01/21/2016 HS ***
    data.response.block_Cntr_Hits = 0;
    data.response.block_Cntr_CRs  = 0;
    data.response.per_hits10   = [];
    data.response.per_false10  = [];
    data.response.per_dprime10 = [];
% *** 01/21/2016 HS ***
% *** 02/02/2016 HS ***
    data.response.block_Cntr_Targets     = 0;
    data.response.block_Cntr_NonTargets  = 0;
% *** 02/02/2016 HS ***
% *** 02/03/2016 HS ***
    data.response.per_hits    = [];
    data.response.per_false   = [];
    data.response.per_false2  = [];
    data.response.per_dprime  = [];
    data.response.per_dprime2 = [];
% *** 02/03/2016 HS ***
end

% triggering
if data.card.inter_trigger_interval<Inf && loop.frame > 1
    intervals = 0:data.card.inter_trigger_interval:90*60;

    [x i] = min(abs(intervals-loop.prev_flip_time)); % find timepoint after        
    if abs(loop.prev_flip_time-intervals(i))< 0.5/data.presentation.frame_rate        
        putvalue(data.card.trigger,1);            
        WaitSecs(0.005);
        putvalue(data.card.trigger,0);
%         fprintf('trigger time = %1.2f\n',loop.prev_flip_time)
    end        
end


%% beginning of trial
if loop.frame - loop.new_stim == 1 && mod(loop.stim,3) == 2
    psychsr_sound(data.stimuli.cue_tone(loop.stim));
    licks = 0;
    
    % <display code>
    per_overall = round(mean(data.response.n_overall(1+(end-10)*(end-10>0):end))*100);
    per_hit = round(mean(data.response.n_hits(1+(end-10)*(end-10>0):end))*100);
    per_false = round(mean(data.response.n_false(1+(end-10)*(end-10>0):end))*100);
    per_delay = round(mean(data.response.n_delay(1+(end-10)*(end-10>0):end))*100);
    str = '';
% *** 01/14/2016 HS ***
    str = [str, sprintf('\n\n*** Trial %d ***', length(data.response.n_overall)+1)];
% *** 01/14/2016 HS ***
    str = [str, sprintf('\n      LAST10    TOTAL\n')];
    str = [str, sprintf('HIT%%   %3d%%   %3d%% of %d\n',per_hit,round(mean(data.response.n_hits)*100),length(data.response.n_hits))];
    str = [str, sprintf('FALSE%% %3d%%   %3d%% of %d\n',per_false,round(mean(data.response.n_false)*100),length(data.response.n_false))];
% *** 01/14/2016 HS ***
    if data.response.p_targ_after_cr > 0 || data.response.p_ntarg_after_fa > 0
        targ = data.stimuli.orientation(3:3:3*length(data.response.n_overall))==data.response.t_ori;
        ind = find(~targ);
        ind = ind(diff([0 ind])>1);
%         l = find(data.response.n_overall & targ, 1,'last'); % find last hit trial
%         if isempty(l); l = length(data.response.n_overall); end;
%         t = (1:length(targ))<=l;
%         if ~isempty(find(~t,1))
%             ind(ind>=find(~t,1)) = [];
%         end
        f2 = round(mean(1-data.response.n_overall(ind))*100);
        str = [str, sprintf('FALSE2%%       %3d%% of %d\n',f2,length(ind))];
    end
    if     per_hit/100 == 1; ni_p_hit10 = norminv(0.99);
    elseif per_hit/100 == 0; ni_p_hit10 = norminv(0.01);
    else                     ni_p_hit10 = norminv(per_hit/100);
    end
    if     per_false/100 == 1; ni_p_false10 = norminv(0.99);
    elseif per_false/100 == 0; ni_p_false10 = norminv(0.01);
    else                       ni_p_false10 = norminv(per_false/100);
    end
    dprime10 = ni_p_hit10-ni_p_false10; % D-prime for last 10 trials.
    mn_n_hits  = mean(data.response.n_hits);
    mn_n_false = mean(data.response.n_false);
    if     mn_n_hits == 1; ni_p_hit = norminv(0.99);
    elseif mn_n_hits == 0; ni_p_hit = norminv(0.01);
    else                   ni_p_hit = norminv(mn_n_hits);
    end
    if     mn_n_false == 1; ni_p_false = norminv(0.99);
    elseif mn_n_false == 0; ni_p_false = norminv(0.01);
    else                    ni_p_false = norminv(mn_n_false);
    end
    dprime = ni_p_hit - ni_p_false; % D-prime for all.
    if data.response.p_targ_after_cr > 0 || data.response.p_ntarg_after_fa > 0
        mn_n_false2 = mean(1-data.response.n_overall(ind));
        if     mn_n_false2 == 1; ni_p_false2 = norminv(0.99);
        elseif mn_n_false2 == 0; ni_p_false2 = norminv(0.01);
        else                     ni_p_false2 = norminv(mn_n_false2);
        end
        dprime2 = ni_p_hit - ni_p_false2; % D-prime for all.
        str = [str, sprintf('D-P    %1.2f   %1.2f (%1.2f)\n',dprime10,dprime,dprime2)];
    else
        str = [str, sprintf('D-P    %1.2f   %1.2f\n',dprime10,dprime)];
    end
% *** 01/14/2016 HS ***
    str = [str, sprintf('DELAY%% %3d%%   %3d%% of %d\n',per_delay,round(mean(data.response.n_delay)*100),length(data.response.n_delay))];
    str = [str, sprintf('LAST LICK: -%s\n\n',datestr((loop.prev_flip_time-max(data.response.licks))/86400,'MM:SS'))];
    fprintf('%s',str);

% *** 01/21/2016 HS ***
    % plot performance figure.
    tmpTrl = length(data.response.n_overall);
    if tmpTrl
        % store performance.
        if isnan(per_hit);   data.response.per_hits10  (tmpTrl) = 0;
        else                 data.response.per_hits10  (tmpTrl) = per_hit;
        end
        if isnan(per_false); data.response.per_false10 (tmpTrl) = 0;
        else                 data.response.per_false10 (tmpTrl) = per_false;
        end
        if isnan(dprime10);  data.response.per_dprime10(tmpTrl) = 0;
        else                 data.response.per_dprime10(tmpTrl) = dprime10;
        end
% *** 02/03/2016 HS ***
        if isnan(mn_n_hits);  data.response.per_hits  (tmpTrl) = 0;
        else                  data.response.per_hits  (tmpTrl) = mn_n_hits*100;
        end
        if isnan(mn_n_false); data.response.per_false (tmpTrl) = 0;
        else                  data.response.per_false (tmpTrl) = mn_n_false*100;
        end
        if isnan(dprime);  data.response.per_dprime(tmpTrl) = 0;
        else                 data.response.per_dprime(tmpTrl) = dprime;
        end
        if data.response.p_targ_after_cr > 0 || data.response.p_ntarg_after_fa > 0
            if isnan(mn_n_false2); data.response.per_false2 (tmpTrl) = 0;
            else                   data.response.per_false2 (tmpTrl) = mn_n_false2*100;
            end
            if isnan(dprime2);     data.response.per_dprime2(tmpTrl) = 0;
            else                   data.response.per_dprime2(tmpTrl) = dprime2;
            end
        end
% *** 02/03/2016 HS ***
        % plot
        tmpfh = figure(1); clf(tmpfh);
        % last 10 trials
        subplot(4,1,1:3);
        tmpX = 1:tmpTrl;
        tmpP_H = data.response.per_hits10;
        tmpP_F = data.response.per_false10;
        tmpdp = data.response.per_dprime10;
        [hAX, hLineD, hLineH] = plotyy(tmpX, tmpdp, tmpX, tmpP_H);
        hold(hAX(2), 'on');
        hLineF = plot(hAX(2), tmpX, tmpP_F);
        hold(hAX(2), 'off');
        % set color
        set(hLineH, 'Color', 'b');
        set(hLineF, 'Color', 'r');
        set(hLineD, 'Color', 'k');
        % format
        set(hAX(2), 'Ytick', 0:10:100);
        ylim(hAX(2), [0 110]);
        xlim(hAX(1), [0 tmpTrl+1]);
        xlim(hAX(2), [0 tmpTrl+1]);
        set(hAX(2),'YGrid','on');
%         hold on;
%         % plot per_hit and per_false
%         plot(1:tmpTrl, data.response.per_hits10,  'b-');
%         plot(1:tmpTrl, data.response.per_false10, 'r-');
%         % add d-prime
%         ax1 = gca;
%         set(ax1, 'YAxisLocation', 'right');
%         ax2 = axes('Position', get(ax1,'Position'), 'YAxisLocation', 'left', 'Color', 'none');
%         line(1:tmpTrl, data.response.per_dprime10, 'Parent', ax2, 'Color', 'k');
%         %             hold off;
%         ylim(ax1, [0 110]);
%         xlim(ax1, [0 tmpTrl+1]);
%         xlim(ax2, [0 tmpTrl+1]);
%         set(ax2, 'XTick', []);
%         set(ax1, 'Box', 'off');
%         set(ax1,'YGrid','on');
%         hold off;

        % overall responses
        subplot(4,1,4);
        tmpP_H = data.response.per_hits;
        tmpP_F = data.response.per_false;
        tmpdp = data.response.per_dprime;
        [hAX, hLineD, hLineH] = plotyy(tmpX, tmpdp, tmpX, tmpP_H);
        hold(hAX(2), 'on');
        hLineF = plot(hAX(2), tmpX, tmpP_F);
        hold(hAX(2), 'off');
        % add d prime criterion
        hold(hAX(1), 'on');
        plot(hAX(1), [0 tmpTrl+1], [1.3 1.3], 'k-');
        hold(hAX(1), 'off');
        % set color
        set(hLineH, 'Color', 'b');
        set(hLineF, 'Color', 'r');
        set(hLineD, 'Color', 'k');
        % set line style
        set(hLineF, 'LineStyle', ':');
        set(hLineD, 'LineStyle', ':');
        % format
        set(hAX(2), 'Ytick', 0:25:100);
        ylim(hAX(2), [0 110]);
        xlim(hAX(1), [0 tmpTrl+1]);
        xlim(hAX(2), [0 tmpTrl+1]);
        set(hAX(2),'YGrid','on');
        % add 'real' false rate and d'
        if data.response.p_targ_after_cr > 0 || data.response.p_ntarg_after_fa > 0
            tmpP_F2 = data.response.per_false2;
            tmpdp2 = data.response.per_dprime2;
            hold(hAX(1), 'on');
            hold(hAX(2), 'on');
            hLineF2 = plot(hAX(2), tmpX, tmpP_F2);
            hLineD2 = plot(hAX(1), tmpX, tmpdp2);
            % set color
            set(hLineF2, 'Color', 'r');
            set(hLineD2, 'Color', 'k');
            hold(hAX(1), 'off');
            hold(hAX(2), 'off');
        end

%         hold on;
%         % plot per_hit and per_false
%         plot(1:tmpTrl, data.response.per_hits,  'b-');
%         plot(1:tmpTrl, data.response.per_false, 'r:');
%         if data.response.p_targ_after_cr > 0 || data.response.p_ntarg_after_fa > 0
%             plot(1:tmpTrl, data.response.per_false2, 'r-');
%         end
%         % add d-prime
%         ax3 = gca;
%         ax4 = axes('Position', get(ax3,'Position'), 'YAxisLocation', 'left', 'Color', 'none');
%         set(ax3, 'YAxisLocation', 'right');
%         line(1:tmpTrl, data.response.per_dprime, 'Parent', ax4, 'Color', 'k', 'LineStyle', ':');
%         if data.response.p_targ_after_cr > 0 || data.response.p_ntarg_after_fa > 0
%             line(1:tmpTrl, data.response.per_dprime2, 'Parent', ax4, 'Color', 'k');
%         end
%         % dprime criterion
%         line([0 tmpTrl+1], [1.3 1.3], 'Parent', ax4, 'Color', 'k');
%         ylim(ax3, [0 110]);
%         xlim(ax3, [0 tmpTrl+1]);
%         xlim(ax4, [0 tmpTrl+1]);
%         set(ax4, 'XTick', []);
%         set(ax3, 'Box', 'off');
%         set(ax3,'YGrid','on');
%         hold off;
        
        drawnow;
    end
% *** 01/21/2016 HS ***
    
    if mod(loop.stim,9) == 2
        fid = fopen(sprintf('rig%1d.txt',str2num(data.screen.pc(end))),'w');
        str = [sprintf('RIG %1d\nMOUSE %2d - %s\n%s TRIAL %d\n',str2num(data.screen.pc(end)),...
            data.mouse,data.response.description,datestr(loop.prev_flip_time/86400,'MM:SS'),floor(loop.stim/3)), str];
        fprintf(fid,'%s',str);
        fclose(fid);
    end
    % </display code>
    
    % change on time based on performance
    ntrials = 20;
    if isfield(data.response,'adaptive_ontime') && data.response.adaptive_ontime
        if ~isempty(data.response.n_overall) && mod(length(data.response.n_overall),ntrials) == 0

            % decrease time if performing well
            if per_hit - per_false > 30 && data.stimuli.on_time(loop.stim) > 0.1                
                data.stimuli.on_time(loop.stim:end) = data.stimuli.on_time(loop.stim)-0.1;
                fprintf('----- DECREASED STIM TIME TO %1.1fs ----- \n',data.stimuli.on_time(loop.stim));
            % increase time if performance suffers?
            elseif (per_false > 80 || per_hit - per_false < 10) && data.stimuli.on_time(loop.stim) < max(data.stimuli.on_time)
                data.stimuli.on_time(loop.stim:end) = data.stimuli.on_time(loop.stim)+0.1;
                fprintf('----- INCREASED STIM TIME TO %1.1fs ----- \n',data.stimuli.on_time(loop.stim));
            end
        end
    end    
    
    if data.stimuli.cue_tone(loop.stim) ~= 0
        data.response.tones(end+1) = loop.prev_flip_time;
        fprintf('%s CUE\n',datestr(loop.prev_flip_time/86400,'MM:SS'))
    end
        
end

%% beginning of grating
if loop.frame - loop.new_stim == 1 && mod(loop.stim,3) == 0
    if isempty(data.response.licks) || data.response.licks(end) < data.presentation.stim_times(end)-data.stimuli.duration(loop.stim-1)
        % if no lick during delay period
        fprintf('%s NOT EARLY',datestr(loop.prev_flip_time/86400,'MM:SS'))
        data.response.n_delay(end+1) = 0;
    else
        % if lick during response period
        fprintf('%s EARLY',datestr(loop.prev_flip_time/86400,'MM:SS'))
        data.response.n_delay(end+1) = 1;
    end
    if data.stimuli.orientation(loop.stim) == data.response.t_ori, fprintf(' T');
    else fprintf(' NT'); end;
    fprintf(' %2d%%\n',round(data.stimuli.contrast(loop.stim)*100));
end

%% beginning of iti period
if loop.frame - loop.new_stim == 1 && mod(loop.stim,3) == 1
    data.response.n_total(end+1) = 1; cr = 0;
    if data.stimuli.orientation(loop.stim-1) == data.response.t_ori
        if isempty(data.response.rewards) || data.response.rewards(end) < data.presentation.stim_times(end-1)+data.response.grace_period+data.stimuli.response_delay(loop.stim)
             
            % count a MISS if target
            fprintf('%s MISS\n',datestr(loop.prev_flip_time/86400,'MM:SS'))
            data.response.n_hits(end+1) = 0;
            data.response.n_overall(end+1) = 0;
            
            % stop program if 10 misses in a row
            if data.response.auto_stop > 0 && length(data.response.n_hits) > data.response.auto_stop
                if max(data.response.n_hits(end-min(9,data.response.auto_stop-1):end)) == 0
                    data.stimuli.total_duration = loop.prev_flip_time;
                end
            end
            
% *** 01/12/2016 HS ***
            % Repeat target if miss.
            if rand < data.response.p_targ_after_miss
                if data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) == -1
                    data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) = 1;
                end
                data.stimuli.orientation(loop.stim+3-mod(loop.stim,3))=data.response.t_ori;
                data.stimuli.temp_freq(loop.stim+3-mod(loop.stim,3))=max(data.stimuli.temp_freq);                
                tmpIdx = find(fliplr(diff(data.response.n_hits)));
                if isempty(tmpIdx); tmpIdx = length(data.response.n_hits); end
                disp(['NEXT STIM: TARGET ( *** REPEAT ',num2str(tmpIdx(1)), ')']);
            end
% *** 01/12/2016 HS ***

% *** 02/02/2016 HS ***
            % block design: Number of Targets before switching to NT.
            if data.response.block_Targets > 0
                data.response.block_Cntr_Targets = data.response.block_Cntr_Targets + 1;
                if data.response.block_Targets > data.response.block_Cntr_Targets
                    % Repeat target
                    if data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) == -1
                        data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) = 1;
                    end
                    data.stimuli.orientation(loop.stim+3-mod(loop.stim,3))=data.response.t_ori;
                    data.stimuli.temp_freq(loop.stim+3-mod(loop.stim,3))=max(data.stimuli.temp_freq);                
                    disp(['NEXT STIM: TARGET (', num2str(data.response.block_Cntr_Targets), '/', num2str(data.response.block_Targets), ')']);
                else
                    % swtich to non-target
                    if min(data.stimuli.contrast) == -1 && max(data.stimuli.orientation~=data.response.t_ori & data.stimuli.contrast~=-1) == 0
                        data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) = -1;
                    end
                    ntori = data.stimuli.orientation(~isnan(data.stimuli.orientation) & data.stimuli.orientation~=data.response.t_ori);
                    data.stimuli.orientation(loop.stim+3-mod(loop.stim,3))=ntori(randi(length(ntori)));
                    data.stimuli.temp_freq(loop.stim+3-mod(loop.stim,3))=min(data.stimuli.temp_freq(3:3:end));
                    disp(['NEXT STIM: NONTARGET (', num2str(data.response.block_Cntr_Targets), '/', num2str(data.response.block_Targets), ')']);
                    data.response.block_Cntr_Targets = 0; % reset the counter.
                end
            end
% *** 02/02/2016 HS ***

        else
            % count a HIT if target
            data.response.n_hits(end+1) = 1;
            data.response.n_overall(end+1) = 1;

% *** 01/21/2016 HS ***
            % block design: Need to finish # targets before switch.
            if data.response.block_Hits > 0
                data.response.block_Cntr_Hits = data.response.block_Cntr_Hits + 1;
                if data.response.block_Hits > data.response.block_Cntr_Hits
                    % Repeat target
                    if data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) == -1
                        data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) = 1;
                    end
                    data.stimuli.orientation(loop.stim+3-mod(loop.stim,3))=data.response.t_ori;
                    data.stimuli.temp_freq(loop.stim+3-mod(loop.stim,3))=max(data.stimuli.temp_freq);                
                    disp(['NEXT STIM: TARGET (', num2str(data.response.block_Cntr_Hits), '/', num2str(data.response.block_Hits), ')']);
                else
                    % swtich to non-target
                    if min(data.stimuli.contrast) == -1 && max(data.stimuli.orientation~=data.response.t_ori & data.stimuli.contrast~=-1) == 0
                        data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) = -1;
                    end
                    ntori = data.stimuli.orientation(~isnan(data.stimuli.orientation) & data.stimuli.orientation~=data.response.t_ori);
                    data.stimuli.orientation(loop.stim+3-mod(loop.stim,3))=ntori(randi(length(ntori)));
                    data.stimuli.temp_freq(loop.stim+3-mod(loop.stim,3))=min(data.stimuli.temp_freq(3:3:end));                
                    disp(['NEXT STIM: NONTARGET (', num2str(data.response.block_Cntr_Hits), '/', num2str(data.response.block_Hits), ')']);
                    data.response.block_Cntr_Hits = 0; % reset the counter.
                end
            end
% *** 01/21/2016 HS ***

% *** 01/12/2016 HS ***
            % Show non-target after hits.
            if rand < data.response.p_ntarg_after_hit
                if min(data.stimuli.contrast) == -1 && max(data.stimuli.orientation~=data.response.t_ori & data.stimuli.contrast~=-1) == 0
                    data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) = -1;
                end
                ntori = data.stimuli.orientation(~isnan(data.stimuli.orientation) & data.stimuli.orientation~=data.response.t_ori);
                data.stimuli.orientation(loop.stim+3-mod(loop.stim,3))=ntori(randi(length(ntori)));
                data.stimuli.temp_freq(loop.stim+3-mod(loop.stim,3))=min(data.stimuli.temp_freq(3:3:end));                
                disp('NEXT STIM: NONTARGET');
% *** 02/02/2016 HS ***
                % If p_ntarg_after_hit is more than 1, repeat NT more;
                % e.g., if p_ntarg_after_hit = 2, two stim after Hit set NT.
                if data.response.p_ntarg_after_hit > 1
                    tmpTs = ceil(data.response.p_ntarg_after_hit)-1;
                    for tmpLoop = 1:tmpTs
                        tmpLoopIdx = loop.stim+3-mod(loop.stim,3) + 3*tmpLoop;
                        data.stimuli.orientation(tmpLoopIdx) = ntori(randi(length(ntori)));
                        data.stimuli.temp_freq  (tmpLoopIdx) = min(data.stimuli.temp_freq(3:3:end));                                        
                    end
                    disp(['NEXT ', num2str(tmpTs), ' more STIM: NONTARGET)']);
                end
% *** 02/02/2016 HS ***
            end
% *** 01/12/2016 HS ***
            
% *** 02/02/2016 HS ***
            % block design: Number of Targets before switching to NT.
            if data.response.block_Targets > 0
                data.response.block_Cntr_Targets = data.response.block_Cntr_Targets + 1;
                if data.response.block_Targets > data.response.block_Cntr_Targets
                    % Repeat target
                    if data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) == -1
                        data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) = 1;
                    end
                    data.stimuli.orientation(loop.stim+3-mod(loop.stim,3))=data.response.t_ori;
                    data.stimuli.temp_freq(loop.stim+3-mod(loop.stim,3))=max(data.stimuli.temp_freq);                
                    disp(['NEXT STIM: TARGET (', num2str(data.response.block_Cntr_Targets), '/', num2str(data.response.block_Targets), ')']);
                else
                    % swtich to non-target
                    if min(data.stimuli.contrast) == -1 && max(data.stimuli.orientation~=data.response.t_ori & data.stimuli.contrast~=-1) == 0
                        data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) = -1;
                    end
                    ntori = data.stimuli.orientation(~isnan(data.stimuli.orientation) & data.stimuli.orientation~=data.response.t_ori);
                    data.stimuli.orientation(loop.stim+3-mod(loop.stim,3))=ntori(randi(length(ntori)));
                    data.stimuli.temp_freq(loop.stim+3-mod(loop.stim,3))=min(data.stimuli.temp_freq(3:3:end));
                    disp(['NEXT STIM: NONTARGET (', num2str(data.response.block_Cntr_Targets), '/', num2str(data.response.block_Targets), ')']);
                    data.response.block_Cntr_Targets = 0; % reset the counter.
                end
            end
% *** 02/02/2016 HS ***

        end
    else
        if isempty(data.response.punishs) || data.response.punishs(end) < data.presentation.stim_times(end-1)+data.response.grace_period+data.stimuli.response_delay(loop.stim)
            % count a CORRECT REJECT if nontarget
            fprintf('%s CORRECT REJECT\n',datestr(loop.prev_flip_time/86400,'MM:SS'))
            data.response.n_false(end+1) = 0;
            data.response.n_overall(end+1) = 1;
            
            if data.response.reward_cr
                retract_shift = data.response.reward_cr_time;
                psychsr_sound(6);
                fprintf('%s SOUND CR\n',datestr(loop.prev_flip_time/86400,'MM:SS'))                
                cr = 1;
            end
            
% *** 01/21/2016 HS ***
            % block design: Need to finish # non-targets before switch.
            if data.response.block_CRs > 0
                data.response.block_Cntr_CRs = data.response.block_Cntr_CRs + 1;
                if data.response.block_CRs > data.response.block_Cntr_CRs
                    % Repeat non-target
                    if min(data.stimuli.contrast) == -1 && max(data.stimuli.orientation~=data.response.t_ori & data.stimuli.contrast~=-1) == 0
                        data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) = -1;
                    end
                    ntori = data.stimuli.orientation(~isnan(data.stimuli.orientation) & data.stimuli.orientation~=data.response.t_ori);
                    data.stimuli.orientation(loop.stim+3-mod(loop.stim,3))=ntori(randi(length(ntori)));
                    data.stimuli.temp_freq(loop.stim+3-mod(loop.stim,3))=min(data.stimuli.temp_freq(3:3:end));                
                    disp(['NEXT STIM: NONTARGET (', num2str(data.response.block_Cntr_CRs), '/', num2str(data.response.block_CRs), ')']);
                else
                    % swtich to target
                    if data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) == -1
                        data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) = 1;
                    end
                    data.stimuli.orientation(loop.stim+3-mod(loop.stim,3))=data.response.t_ori;
                    data.stimuli.temp_freq(loop.stim+3-mod(loop.stim,3))=max(data.stimuli.temp_freq);                
                    disp(['NEXT STIM: TARGET (', num2str(data.response.block_Cntr_CRs), '/', num2str(data.response.block_CRs), ')']);
                    data.response.block_Cntr_CRs = 0; % reset the counter.
                end
            end
% *** 01/21/2016 HS ***

            if rand < data.response.p_targ_after_cr
                if data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) == -1
                    data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) = 1;
                end
                data.stimuli.orientation(loop.stim+3-mod(loop.stim,3))=data.response.t_ori;
                data.stimuli.temp_freq(loop.stim+3-mod(loop.stim,3))=max(data.stimuli.temp_freq);                
                disp('NEXT STIM: TARGET')
% *** 12/18/2015 HS ***
                if data.response.p_targ_after_cr > 1
                    tmpTs = ceil(data.response.p_targ_after_cr)-1;
                    for tmpLoop = 1:tmpTs
                        tmpLoopIdx = loop.stim+3-mod(loop.stim,3) + 3*tmpLoop;
                        data.stimuli.orientation(tmpLoopIdx)=data.response.t_ori;
                        data.stimuli.temp_freq(tmpLoopIdx)=max(data.stimuli.temp_freq);                                        
                    end
                end
% *** 12/18/2015 HS ***
            end

% *** 02/02/2016 HS ***
            % block design: Number of Non-Targets before switching to T.
            if data.response.block_NonTargets > 0
                data.response.block_Cntr_NonTargets = data.response.block_Cntr_NonTargets + 1;
                if data.response.block_NonTargets > data.response.block_Cntr_NonTargets
                    % Repeat non-target
                    if min(data.stimuli.contrast) == -1 && max(data.stimuli.orientation~=data.response.t_ori & data.stimuli.contrast~=-1) == 0
                        data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) = -1;
                    end
                    ntori = data.stimuli.orientation(~isnan(data.stimuli.orientation) & data.stimuli.orientation~=data.response.t_ori);
                    data.stimuli.orientation(loop.stim+3-mod(loop.stim,3))=ntori(randi(length(ntori)));
                    data.stimuli.temp_freq(loop.stim+3-mod(loop.stim,3))=min(data.stimuli.temp_freq(3:3:end));
                    disp(['NEXT STIM: NONTARGET (', num2str(data.response.block_Cntr_NonTargets), '/', num2str(data.response.block_NonTargets), ')']);
                else
                    % swtich to target
                    if data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) == -1
                        data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) = 1;
                    end
                    data.stimuli.orientation(loop.stim+3-mod(loop.stim,3))=data.response.t_ori;
                    data.stimuli.temp_freq(loop.stim+3-mod(loop.stim,3))=max(data.stimuli.temp_freq);                
                    disp(['NEXT STIM: TARGET (', num2str(data.response.block_Cntr_NonTargets), '/', num2str(data.response.block_NonTargets), ')']);
                    data.response.block_Cntr_NonTargets = 0; % reset the counter.
                end
            end
% *** 02/02/2016 HS ***

        else
            % count a FALSE ALARM if nontarget
            data.response.n_false(end+1) = 1;
            data.response.n_overall(end+1) = 0;
            if rand < data.response.p_ntarg_after_fa
                if min(data.stimuli.contrast) == -1 && max(data.stimuli.orientation~=data.response.t_ori & data.stimuli.contrast~=-1) == 0
                    data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) = -1;
                end
                ntori = data.stimuli.orientation(~isnan(data.stimuli.orientation) & data.stimuli.orientation~=data.response.t_ori);
                data.stimuli.orientation(loop.stim+3-mod(loop.stim,3))=ntori(randi(length(ntori)));
                data.stimuli.temp_freq(loop.stim+3-mod(loop.stim,3))=min(data.stimuli.temp_freq(3:3:end));                
% *** 12/17/2015 HS ***
%                 disp('NEXT STIM: NONTARGET')
                tmpIdx = find(fliplr(diff(data.response.n_false)));
                if isempty(tmpIdx); tmpIdx = length(data.response.n_false); end
                disp(['NEXT STIM: NONTARGET ( *** REPEAT ',num2str(tmpIdx(1)), ')']);
% *** 12/17/2015 HS ***
% *** 01/29/2016 HS ***
                % If p_ntarg_after_fa is more than 1, repeat NT after FA;
                % e.g., if p_ntarg_after_fa = 2, two stim after FA set NT.
                if data.response.p_ntarg_after_fa > 1
                    tmpTs = ceil(data.response.p_ntarg_after_fa)-1;
                    for tmpLoop = 1:tmpTs
                        tmpLoopIdx = loop.stim+3-mod(loop.stim,3) + 3*tmpLoop;
                        data.stimuli.orientation(tmpLoopIdx) = ntori(randi(length(ntori)));
                        data.stimuli.temp_freq  (tmpLoopIdx) = min(data.stimuli.temp_freq(3:3:end));                                        
                    end
                    disp(['NEXT ', num2str(tmpTs), ' more STIM: NONTARGET)']);
                end
% *** 01/29/2016 HS ***
            end
            
% *** 02/02/2016 HS ***
            % block design: Number of Non-Targets before switching to T.
            if data.response.block_NonTargets > 0
                data.response.block_Cntr_NonTargets = data.response.block_Cntr_NonTargets + 1;
                if data.response.block_NonTargets > data.response.block_Cntr_NonTargets
                    % Repeat non-target
                    if min(data.stimuli.contrast) == -1 && max(data.stimuli.orientation~=data.response.t_ori & data.stimuli.contrast~=-1) == 0
                        data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) = -1;
                    end
                    ntori = data.stimuli.orientation(~isnan(data.stimuli.orientation) & data.stimuli.orientation~=data.response.t_ori);
                    data.stimuli.orientation(loop.stim+3-mod(loop.stim,3))=ntori(randi(length(ntori)));
                    data.stimuli.temp_freq(loop.stim+3-mod(loop.stim,3))=min(data.stimuli.temp_freq(3:3:end));
                    disp(['NEXT STIM: NONTARGET (', num2str(data.response.block_Cntr_NonTargets), '/', num2str(data.response.block_NonTargets), ')']);
                else
                    % swtich to target
                    if data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) == -1
                        data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) = 1;
                    end
                    data.stimuli.orientation(loop.stim+3-mod(loop.stim,3))=data.response.t_ori;
                    data.stimuli.temp_freq(loop.stim+3-mod(loop.stim,3))=max(data.stimuli.temp_freq);                
                    disp(['NEXT STIM: TARGET (', num2str(data.response.block_Cntr_NonTargets), '/', num2str(data.response.block_NonTargets), ')']);
                    data.response.block_Cntr_NonTargets = 0; % reset the counter.
                end
            end
% *** 02/02/2016 HS ***

        end
        
    end
    
    % force animal not to lick impulsively 
    if data.response.antibias                        
        if (length(data.response.n_false)>2 && max(data.response.n_false(end-1:end))==0) || round(mean(data.response.n_hits(1+(end-5)*(end-5>0):end))*100)<100;
            data.response.antibias = 0;
            disp('ANTIBIAS OFF')
        elseif loop.stim-7>1 && (data.stimuli.orientation(loop.stim-1) == data.response.t_ori || min(data.stimuli.orientation(loop.stim-7:3:loop.stim-1) ~= data.response.t_ori)==0) && rand > 0.1
            if min(data.stimuli.contrast) == -1 && max(data.stimuli.orientation~=data.response.t_ori & data.stimuli.contrast~=-1) == 0
                data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) = -1;
            end
            ntori = data.stimuli.orientation(~isnan(data.stimuli.orientation) & data.stimuli.orientation~=data.response.t_ori);                
            data.stimuli.orientation(loop.stim+3-mod(loop.stim,3))=ntori(randi(length(ntori)));
            data.stimuli.temp_freq(loop.stim+3-mod(loop.stim,3))=min(data.stimuli.temp_freq(3:3:end));
            disp('NEXT STIM: NONTARGET')
        elseif loop.stim-7>1
            if data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) == -1
                data.stimuli.contrast(loop.stim+3-mod(loop.stim,3)) = 1;
            end
            data.stimuli.orientation(loop.stim+3-mod(loop.stim,3))=data.response.t_ori;
            data.stimuli.temp_freq(loop.stim+3-mod(loop.stim,3))=max(data.stimuli.temp_freq);
            disp('NEXT STIM: TARGET')
        end        
    end
    
    % *** 12/03/2015 HS ***
    % non-target training: repeat non-target until correct rejection
    if data.response.repeatNT
        if (length(data.response.n_false)>1 && data.response.n_false(end)==1);
            tmpIdx = find(fliplr(diff(data.response.n_false)));
            if isempty(tmpIdx); tmpIdx = length(data.response.n_false); end
            ntori = data.stimuli.orientation(~isnan(data.stimuli.orientation) & data.stimuli.orientation~=data.response.t_ori);                
            data.stimuli.orientation(loop.stim+3-mod(loop.stim,3))=ntori(randi(length(ntori)));
            data.stimuli.temp_freq(loop.stim+3-mod(loop.stim,3))=min(data.stimuli.temp_freq(3:3:end));
            disp(['NEXT STIM: NONTARGET (REPEAT ',num2str(tmpIdx(1)), ')'])
        end        
    end
    % *** 12/03/2015 HS ***

end

%% turn off grating after response.target_time
if isfield(data.stimuli,'on_time') && data.response.target_time ~= data.stimuli.on_time(loop.stim)
    data.response.target_time = data.stimuli.on_time(loop.stim);
end
if psychsr_timed_event(loop,3,data.response.target_time)...
        && ~(data.response.nt_on_timeout == 1 && data.stimuli.orientation(loop.stim) ~= data.response.t_ori);
    loop.hide_stim = 1;   
end

%% laser on
if data.response.mode == 7 && data.stimuli.laser_on(loop.stim)>0 
    onset = data.response.laser_onset(data.stimuli.laser_on(loop.stim));
    dur = data.response.laser_time(data.stimuli.laser_on(loop.stim));    
    if psychsr_timed_event(loop,data.response.laser_seq,onset)
        if (isempty(data.response.laser_on) || loop.prev_flip_time-data.response.laser_on(end) > dur) ...
                && (data.card.ao.SamplesOutput==0) % just in case ao already running
            start(data.card.ao);
            if numel(data.response.laser_amp) > 1
                fprintf('LASER ON -- %s\n',upper(data.response.laser_epoch))
            elseif numel(data.response.laser_onset) > 1
                fprintf('LASER ON -- %s %3d ms\n',upper(data.response.laser_epoch),onset*1000)
            else
                fprintf('LASER ON -- %s %1.1fV\n',upper(data.response.laser_epoch),data.response.laser_amp)
            end
            
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
        l_on = 0;        
    end
end

%% spout extend/retract
if max(data.response.mode == [5, 6, 7]) && psychsr_timed_event(loop,3,data.response.extend_onset...
        + data.stimuli.response_delay(loop.stim))
    psychsr_move_spout(loop,1);
    fprintf('%s EXTEND DELAY %1.1f\n',datestr(loop.prev_flip_time/86400,'MM:SS'),data.stimuli.response_delay(loop.stim))
end

if max(data.response.mode == [5, 6, 7]) && psychsr_timed_event(loop,3,data.response.retract_onset...
        + data.stimuli.response_delay(loop.stim) + retract_shift)    
    psychsr_move_spout(loop,2);   
    fprintf('%s RETRACT\n',datestr(loop.prev_flip_time/86400,'MM:SS'))
    retract_shift = 0;
end

%% automatic free reward near the end of grating
if data.stimuli.orientation(loop.stim)==data.response.t_ori
    if data.response.auto_reward ~= 0 && psychsr_timed_event(loop,3,data.response.auto_reward_time)
        if ~isfield(data.response,'p_auto_reward') || rand<data.response.p_auto_reward            
            if isempty(data.response.rewards) || (max(data.response.licks)-max(data.response.rewards) > 0 && ...
                    loop.prev_flip_time-data.response.rewards(end) > data.response.target_time)
                
                if data.response.auto_reward == -2
                    fprintf('%s BEEP\n',datestr(loop.prev_flip_time/86400,'MM:SS'));
                    psychsr_sound(6);
                    data.response.primes(end+1) = loop.prev_flip_time;
                else                    
                    fprintf('%s FREE',datestr(loop.prev_flip_time/86400,'MM:SS'));
                    psychsr_reward(loop,6);
                    data.response.primes(end+1) = loop.prev_flip_time;
                    data.response.auto_reward = data.response.auto_reward-1;
                end
            end
        end
    end
else
%     if data.response.auto_reward ~= 0 && psychsr_timed_event(loop,3,data.response.auto_reward_time) 
%         if data.response.auto_reward == -2
%             fprintf('%s NOISE\n',datestr(loop.prev_flip_time/86400,'MM:SS'));
%             psychsr_sound(12);            
%         end
%     end
end    

%% lick feedback
if loop.response  
    fprintf('%s %4d',datestr(loop.prev_flip_time/86400,'MM:SS'),length(data.response.licks));
    if strcmp(data.stimuli.stim_type{loop.stim},'free')
    % free reward period
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
    else
    % normal trial structure    
        switch mod(loop.stim,3)
            case 0
                % reward/punish if lick during grating
                if (loop.prev_flip_time > data.presentation.stim_times(end)+data.response.grace_period+data.stimuli.response_delay(loop.stim))
                    % REWARD
                    if data.stimuli.orientation(loop.stim) == data.response.t_ori
                        if (isempty(data.response.rewards) || loop.prev_flip_time-data.response.rewards(end) > data.response.response_time+data.stimuli.response_delay(loop.stim)...
                                || loop.prev_flip_time-max(data.response.rewards) > data.response.iri)
                            licks = licks + 1;
                            if licks >= data.response.lick_threshold
                                % one reward per grating
                                onset = data.response.extend_onset+data.stimuli.response_delay(loop.stim);
                                if onset < 0; onset = 0; end;
                                rt = loop.prev_flip_time-data.presentation.stim_times(loop.stim-1)-onset;
                                fprintf('RT %1.3f',rt);
                                psychsr_reward(loop,6);
                                if licks == data.response.lick_threshold && data.response.response_time-rt < 1.5
                                    retract_shift = rt;
                                end
                            else
                                fprintf(' LICK #%d\n',licks)
                            end
                        else
                            fprintf(' EXTRA\n')
                        end
                        
                        % PUNISH
                    else
                        if (isempty(data.response.punishs) || loop.prev_flip_time-data.response.punishs(end) > data.stimuli.duration(loop.stim))
                            licks = licks + 1;
                            if licks >= data.response.lick_threshold
                                % one punish per grating
                                onset = data.response.extend_onset+data.stimuli.response_delay(loop.stim);
                                if onset < 0; onset = 0; end;
                                rt = loop.prev_flip_time-data.presentation.stim_times(loop.stim-1)-onset;
                                fprintf('RT %1.3f',rt);
                                psychsr_punish(loop);
                                if max(data.response.mode == [6, 7])
                                    retract_shift = rt;
                                else
                                    retract_shift = data.response.punish_time;
                                end                                
                                
                                % increase blank period (timeout)
                                data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)+data.response.punish_timeout;
                                data.stimuli.end_time = cumsum(data.stimuli.duration);
                                data.stimuli.total_duration = data.stimuli.total_duration+data.response.punish_timeout;
                            else
                                fprintf(' LICK #%d\n',licks)
                            end
%                         elseif max(data.response.mode == [6, 7]) && licks == 1
%                             licks = licks + 1;
%                             psychsr_sound(1);
%                             fprintf(' PUNISH SOUND\n')
                            
                        elseif data.response.punish_extra && (isempty(data.response.punishs) || loop.prev_flip_time-data.response.punishs(end) > 1)
                            % punish multiple times
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
% *** 03/09/2016 HS *** ***************************************************
%                     fprintf(' GRACE\n')
                    fprintf(' DURING STIM or GRACE\n')
                    fprintf(' STIM OFF\n')
                    loop.hide_stim = 1;                    
% *** 03/09/2016 HS *** ***************************************************
                end
            case 2
                fprintf(' GRACE\n')
            case 1
                if data.response.reward_cr && cr == 1
                    if loop.prev_flip_time > data.presentation.stim_times(end)+data.response.grace_period && ...                            
                            (isempty(data.response.rewards) || loop.prev_flip_time-data.response.rewards(end) > data.stimuli.duration(loop.stim))
                        rt = loop.prev_flip_time-data.presentation.stim_times(loop.stim-1);
                        fprintf('RT %1.3f',rt);
                        psychsr_reward(loop,6);
                        retract_shift = data.response.reward_cr_time+rt;
                    else
                        fprintf(' ITI\n')
                    end
                    
                elseif data.response.extend_iti && loop.prev_flip_time > data.stimuli.end_time(loop.stim)-1
                    data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)+1;
                    data.stimuli.end_time = cumsum(data.stimuli.duration);  
                    % retract_shift = retract_shift+1;
                    fprintf(' EXTEND ITI\n')                    
                else
                    fprintf(' ITI\n')
                end
                
        end
    end
end    

%% update loop structure
new_loop = loop;
end