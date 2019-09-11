function new_loop = psychsr_dualfeedback(loop)
    
    global data;  

    if loop.frame == 1
        data.response.n_left = [];
        data.response.n_right = [];
        data.response.n_both = [];
    end
    
%% if lick
    % if animal licks ONE port
    if sum(loop.response)==1
        data.response.n_both(end+1) = 0;
        if loop.response(2) == 1
            fprintf('%s %4d RIGHT',datestr(loop.prev_flip_time/86400,'MM:SS'),size(data.response.licks,1));            
            if data.response.lickside == 2 || data.response.lickside == 0 
                data.response.n_right(end+1) = 1;
                if isempty(data.response.rewards) || loop.prev_flip_time-max(max(data.response.rewards)) > 0.5
                    % max two rewards per second
                    psychsr_reward(loop,6,2);
                else
                    fprintf(' EXTRA \n')
                end
            else
                data.response.n_left(end+1) = 0;
                fprintf(' WRONG \n')
            end
        else
            fprintf('%s %4d LEFT',datestr(loop.prev_flip_time/86400,'MM:SS'),size(data.response.licks,1));
            if data.response.lickside == 1 || data.response.lickside == 0 
                data.response.n_left(end+1) = 1;
                if isempty(data.response.rewards) || loop.prev_flip_time-max(max(data.response.rewards)) > 0.5
                    % max two rewards per second
                    psychsr_reward(loop,7,1); % reward on left
                else
                    fprintf(' EXTRA \n')
                end
            else
                data.response.n_right(end+1) = 0;
                fprintf(' WRONG \n')
            end
        end
        
    % BOTH ports = nothing
    elseif sum(loop.response) == 2
        data.response.n_both(end+1) = 1;
        fprintf('%s %4d',datestr(loop.prev_flip_time/86400,'MM:SS'),size(data.response.licks,1));
        fprintf(' BOTH \n')
    end

    if mod(floor(loop.prev_flip_time*50)/50,20)==0 % every 5 seconds
        per_left = round(mean(data.response.n_left(1+(end-20)*(end-20>0):end))*100);
        per_right = round(mean(data.response.n_right(1+(end-20)*(end-20>0):end))*100);
        per_both = round(mean(data.response.n_both(1+(end-20)*(end-20>0):end))*100);
        fprintf('\n      LAST20    TOTAL\n')
        fprintf('LEFT%%   %3d%%   %3d%% of %d\n',per_left,round(mean(data.response.n_left)*100),length(data.response.n_left))
        fprintf('RIGHT%%  %3d%%   %3d%% of %d\n',per_right,round(mean(data.response.n_right)*100),length(data.response.n_right))
        fprintf('BOTH%%   %3d%%   %3d%% of %d\n',per_both,round(mean(data.response.n_both)*100),length(data.response.n_both))
        fprintf('LAST LICK: -%s\n\n',datestr((loop.prev_flip_time-max(max(data.response.licks)))/86400,'MM:SS'))
        
        fid = fopen(sprintf('rig%1d.txt',str2num(data.screen.pc(end))),'w');
        fprintf(fid,'RIG %1d\nMOUSE %2d\n%s TRIAL %d\n',str2num(data.screen.pc(end)),data.mouse,datestr(loop.prev_flip_time/86400,'MM:SS'),floor(loop.stim/3));
        fprintf(fid,'\n      LAST20    TOTAL\n');
        fprintf(fid,'LEFT%%   %3d%%   %3d%% of %d\n',per_left,round(mean(data.response.n_left)*100),length(data.response.n_left));
        fprintf(fid,'RIGHT%%  %3d%%   %3d%% of %d\n',per_right,round(mean(data.response.n_right)*100),length(data.response.n_right));
        fprintf(fid,'BOTH%%   %3d%%   %3d%% of %d\n',per_both,round(mean(data.response.n_both)*100),length(data.response.n_both));
        fprintf(fid,'LAST LICK: -%s\n\n',datestr((loop.prev_flip_time-max(max(data.response.licks)))/86400,'MM:SS'));
        fclose(fid);
        
    end
    
    new_loop = loop;
end