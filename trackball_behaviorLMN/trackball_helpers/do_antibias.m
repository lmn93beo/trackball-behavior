global data

% antibias selects next trial
nextstim = 0;
nextid = 0;
% antibias new used to be here...
if k+1 < data.params.numTrials && data.stimuli.loc(k) < 3 && data.userFlag ~= k+1
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
