function new_loop = psychsr_dual_feedback(loop)

global data;
persistent curr_side

if loop.frame == 1
    curr_side = 0;
end
if data.response.switchFlag>0 && curr_side==0 && ~isempty(data.response.rewards)
    curr_side = find(data.response.rewards>0);
end

n = data.response.max_consec;

if sum(loop.response)==1
    if loop.response(1) == 1 % lick on left
        fprintf('%s %4d LEFT',datestr(loop.prev_flip_time/86400,'MM:SS'),size(data.response.licks,1));
        if isempty(data.response.rewards) || loop.prev_flip_time-max(data.response.rewards(:)) > data.response.iri
            if n > 0 && ~isempty(data.response.rewards) && sum(data.response.rewards(max([1,end-n+1]):end,2)==0)==n
                fprintf(' MAX\n')
            elseif curr_side ~= 2
                psychsr_reward(loop,7,[],1); % reward on left
                if data.response.switchFlag && sum(data.response.rewards(max([1,end-n+1]):end,2)==0)==n
                    curr_side = 2;
                end
            else
                fprintf(' WRONG\n')
            end
        else
            fprintf('\n')
        end
    else % lick on left
        fprintf('%s %4d RIGHT',datestr(loop.prev_flip_time/86400,'MM:SS'),size(data.response.licks,1));
        if isempty(data.response.rewards) || loop.prev_flip_time-max(data.response.rewards(:)) > data.response.iri
            if n > 0 && ~isempty(data.response.rewards) && sum(data.response.rewards(max([1,end-n+1]):end,1)==0)==n
                fprintf(' MAX\n')
            elseif curr_side ~= 1            
                psychsr_reward(loop,6,[],2); % reward on right
                if data.response.switchFlag && sum(data.response.rewards(max([1,end-n+1]):end,1)==0)==n
                    curr_side = 1;
                end
            else
                fprintf(' WRONG\n')
            end
        else
            fprintf('\n')
        end
    end
    
    % BOTH ports = nothing
elseif sum(loop.response) == 2
    fprintf('%s %4d BOTH\n',datestr(loop.prev_flip_time/86400,'MM:SS'),size(data.response.licks,1));
end


new_loop = loop;
end