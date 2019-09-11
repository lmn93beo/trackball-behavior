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
        %psychsr_sound(6); %play reward sound
        rwdDelay = tic;
        currDelay = data.params.rwdDeliveryDelay(randi(numel(data.params.rwdDeliveryDelay)));
        while toc(rwdDelay) < currDelay
        end
    end
end


id = 5;
if choice == 5 | choice == 7 % timeout
    if data.params.MissSound
        if data.params.lever == 0
            psychsr_sound(1);
        end
    end
    data.response.reward(k) = 0;
elseif choice == 6 % abort sound
    psychsr_sound(18);
    data.response.reward(k) = 0;
elseif choice == data.stimuli.loc(k) || data.stimuli.loc(k)==3 % correct choice
    if length(data.response.reward_time)==1
        id = 1;
    else
        id = choice;
    end
        
        
%     elseif data.params.actionValue % left/right
%         if data.stimuli.block(k) == 3 % equal value
%             [~,id] = max(data.params.reward);
%         else
%             id = xor(choice-1,data.stimuli.block(k)-1)+1;
%         end
%     elseif data.params.linkStimAction % diamond/square with fixed values
%         if data.stimuli.loc(k) == 3
%             id = ~xor(choice-1,data.stimuli.id(k)-1)+1;
%         else
%             id = data.stimuli.id(k);
%         end
%     else % diamond/square with values changing as function of block
%         if data.stimuli.loc(k) == 3            
%             id = xor(~xor(choice-1,data.stimuli.id(k)-1),data.stimuli.block(k)-1)+1;
%         else
%             id = xor(data.stimuli.id(k)-1,data.stimuli.block(k)-1)+1;
%         end
%     end

    if rand < data.params.rewardProb(id) && ~(data.params.lever == 1 && data.stimuli.loc(k) == 1)
        % play reward sound
        if length(data.params.reward) > 1 && data.params.reward(id) == max(data.params.reward) && data.params.rewardDblBeep
            psychsr_sound(16);
        elseif data.params.reward(id)>0 && ~(data.params.lever==1 && data.params.lev_chirp) 
            psychsr_sound(6);
        end

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
        nrewards = nrewards + 1;
        if nrewards == rewardSwitch && length(data.params.reward)>1
            nblocks = nblocks + 1;
            nrewards = 0;

            if data.params.firstBlockEqual
                if nblocks == 1
                    if sum(data.response.choice(1:k)==1) > sum(data.response.choice(1:k)==2)
                        data.stimuli.block(k+1:end)=1; %left bias, reward right more
                    else
                        data.stimuli.block(k+1:end)=2;
                    end                        
                else
                    data.stimuli.block(k+1:end) = 3-data.stimuli.block(k);
                end
            else                
                data.stimuli.block(k+1:end) = bs(mod(nblocks,length(bs))+1);
            end

            % determine next block size
            if length(data.params.blockSize)>1
                rewardSwitch = randi(data.params.blockSize);
            end

            if data.params.actionValue && data.params.freeForcedBlocks 
                if data.stimuli.block(k+1) < 3
                    data.stimuli.loc(k+1:end) = 3;
                else                    
                    maxrepeat = floor(log(0.125)/log(abs(data.params.perRight-0.5)+0.5)); if maxrepeat<0; maxrepeat = Inf; end;
                    data.stimuli.loc(k+1:end) = psychsr_rand(1-data.params.perRight,data.params.numTrials-k,0,maxrepeat);                        
                    rewardSwitch = max(data.params.blockSize);
                end                    
            end

        end
    else
        fprintf('%s REWARD 0uL\n',datestr(toc(tstart)/86400,'MM:SS'))
        data.response.reward(k) = 0;
    end
else % incorrect choice
    if data.params.lever>0
        if data.params.lev_pufftime > 0             
            outdata = data.card.dio.UserData;
            outdata.dt(2) = data.params.lev_pufftime;
            outdata.tstart(2) = NaN;
            data.card.dio.UserData = outdata;
        end

    elseif data.params.incorrSound > 0
        psychsr_sound(3);
    end
    data.response.reward(k) = 0;
end