global data
% save trial end time
samples_stop = size(data.response.mvmtdata,1);

if stimtime > 0 
    Screen('FillRect', window, grey);
    newvbl = Screen('Flip', window);
    if length(flips)<2
        flips(2) = newvbl;
    end
end

% Delay between correct choice and reward -- RH
if sum(data.params.rwdDeliveryDelay) > 0
    if data.stimuli.loc(k) == choice %if correct
        rwdDelay = tic;
        currDelay = data.params.rwdDeliveryDelay(randi(numel(data.params.rwdDeliveryDelay)));
        while toc(rwdDelay) < currDelay
        end
    end
end

% Timeout
if choice == 5 || choice == 7
    if data.params.MissSound
        if data.params.lever == 0
            psychsr_sound(1);
        end
    end
    data.response.reward(k) = 0;
    
% Correct choice
elseif choice == data.stimuli.loc(k) || data.stimuli.loc(k)==3 

    if length(data.response.reward_time)==1
        id = 1;
    else
        id = choice;
    end

    if rand < data.params.rewardProb(id) && ~(data.params.lever == 1 && data.stimuli.loc(k) == 1)
        % play reward sound
        psychsr_sound(6);
        

        % deliver reward            
        fprintf('%s REWARD %duL\n',datestr(toc(tstart)/86400,'MM:SS'),data.params.reward(id))
        data.response.rewardtimes(end+1) = toc(tstart);
        if data.response.reward_time(id)>0
            outdata = data.card.dio.UserData;
            outdata.dt(1) = data.response.reward_time(id);
            outdata.tstart(1) = NaN;
            data.card.dio.UserData = outdata;
        end
        data.response.reward(k) = data.params.reward(id);

        % potentially change block
        
    else
        fprintf('%s REWARD 0uL\n',datestr(toc(tstart)/86400,'MM:SS'))
        data.response.reward(k) = 0;
    end
% Incorrect choice  
else                     
    if data.params.incorrSound > 0
        psychsr_sound(1);
    end
    data.response.reward(k) = 0;
    
    % Timeout
    pause(3)
end

% Switch to a new block if block switching condition is satisfied