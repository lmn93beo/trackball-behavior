global data

for i = 1:length(data.params.reward)
    [data.response.reward_amt(i),data.response.reward_time(i),...
        data.response.reward_cal] = psychsr_set_reward(data.params.reward(i));
end
if data.params.lickInitiate>0
    [~,data.response.init_time] = psychsr_set_reward(data.params.lickInitiate);
end

if data.params.laser > 0 && data.params.perLaser > 0
    n = round(1/data.params.perLaser);
    data.stimuli.laser = ones(1,data.params.numTrials);
    i = data.params.noLaser+1;
    while i < data.params.numTrials
        data.stimuli.laser(i) = 2;        
        i = i+randi(3)+n-2;
    end
    
    w = [];
    while isempty(w) || isnan(w) || ~isnumeric(w)
        try w = input('Laser control voltage?: ');
        catch
            w = [];
        end
    end
    data.params.laser_amp = w;
    data.params.laser_power = input('Laser power (mW)?: ','s');    % photometer
    data.params.laser_target = input('Laser target(s)?: ','s');

end

trackball_screen_setup;
trackball_card_setup;       % setup daq, serial port and notification
trackball_sound_setup;
trackball_stimuli_setup;
screen = data.screen; struct_unzip(screen);

if data.params.lever>0
    baselineFlag = 0;
    disp('begin baseline measurement (1s)...')
    while baselineFlag >= 0
        start(data.card.ai);
        nsampled = 0;
        baseline_data = [];
        while nsampled < data.card.ai_fs*1
            if data.card.ai.SamplesAcquired > nsampled
                newdata = peekdata(data.card.ai,data.card.ai.SamplesAcquired-nsampled);
                nsampled = nsampled + size(newdata,1);
                if data.params.lever == 1; chans = 2; else chans = [2 3]; end;
                baseline_data = cat(1,baseline_data,newdata(:,chans));
            end
        end
        stop(data.card.ai)
        if max(std(baseline_data))<0.01
            data.params.lev_baseline = median(baseline_data);
            baselineFlag = -1;
            fprintf('measured baseline:')
            fprintf(' %1.3f',data.params.lev_baseline); fprintf('\n')
        else
            baselineFlag = baselineFlag+1;
            fprintf('retry %d\n',baselineFlag)
        end
    end
    disp('Press any key to continue')
    pause
end