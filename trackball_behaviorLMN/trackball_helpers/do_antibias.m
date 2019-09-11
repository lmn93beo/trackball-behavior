global data

% antibias selects next trial
nextstim = 0;
nextid = 0;
if data.params.antibiasNew
    if k >= 10 && k+1 < data.params.numTrials
        lastchoices = data.response.choice(k-9:k);
        prevchoice = nan(size(lastchoices));
        for p = 1:10
            ix = find(data.response.choice(1:k-11+p)~=5,1,'last');
            if ~isempty(ix)
                prevchoice(p) = data.response.choice(ix);
            end
        end
        dleftright = sum(lastchoices==1) - sum(lastchoices==2);
        ix = find(~isnan(prevchoice) & lastchoices<5);
        dsamediff = sum(lastchoices(ix)==prevchoice(ix)) - sum(lastchoices(ix)~=prevchoice(ix));
        if abs(dleftright) > abs(dsamediff)
            nextstim = (dleftright>0)+1;   
            fprintf('L-R = %d\n',dleftright)
        elseif abs(dleftright) < abs(dsamediff)
            if dsamediff > 0
                nextstim = 3-lastchoices(ix(end));
            else
                nextstim = lastchoices(ix(end));
            end
            fprintf('S-O = %d\n',dsamediff)
        else
            fprintf('|L-R| = |S-O| = %d\n',abs(dleftright))
        end

    end
elseif k+1 < data.params.numTrials && data.stimuli.loc(k) < 3 && data.userFlag ~= k+1

    % if success on last trial
    if choice == data.stimuli.loc(k)

        nrewards_ab = nrewards_ab + 1;
        if max(data.params.antibiasNumCorrect)>0
            fprintf('%d CORRECT\n',nrewards_ab)
        end

        if data.params.antibiasSwitch > 0
            if length(data.params.antibiasNumCorrect) > 1
                id = data.stimuli.loc(k);
            else
                id = 1;
            end
            if rand <= data.params.antibiasSwitch
                if nrewards_ab >= data.params.antibiasNumCorrect(id)
                    nextstim = 3-data.stimuli.loc(k); % switch side
                    nrewards_ab = 0;
                else
                    nextstim = data.stimuli.loc(k); % repeat side
                end
            else
                nextstim = 0;
            end
        end

        % if failed on last trial
    elseif choice ~= data.stimuli.loc(k)
        if data.params.antibiasConsecutive && choice < 5
            nrewards_ab = 0;
        end

        if data.params.antibiasRepeat > 0
            if rand <= data.params.antibiasRepeat
                nextstim = data.stimuli.loc(k); % repeat side
                data.stimuli.id(k+1) = data.stimuli.id(k); % repeat id and block also
                data.stimuli.block(k+1) = data.stimuli.block(k);
            else
                nextstim = 0;
                %                     nextstim = rand<data.params.perRight + 1;
                %                     if nextstim == 3-data.stimuli.loc(k)
                %                         nrewards_ab = 0;
                %                     end
            end
        end
    end
end
% change trial
if nextstim > 0
    data.stimuli.loc(k+1) = nextstim;
    if nextstim == 1
        fprintf('ANTIBIAS: NEXT STIM LEFT\n')
    else
        fprintf('ANTIBIAS: NEXT STIM RIGHT\n')
    end
end