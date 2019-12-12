goLMN();
% clear variables
psychsr_go_root();
close all; clearvars; clearvars -global data; clc
global data

data.mouse = input('Mouse #: ');
if ~ischar(data.mouse)
    data.mouse = num2str(data.mouse);
end

%% Setup parameters
init_default_params; %default

% Mouse specific parameters
% Make the correct file name. For e.g. mouse 96 will call initParams_96
initfile = sprintf('initParams_%s', data.mouse);
eval(initfile);

%% Setup
trackball_setup_master;
trackball_trial_setup;

%% Loop through all the trials
trackball_mvmt_test;

k = 0;
tstart = tic;




while k < data.params.numTrials && data.quitFlag==0
    trackball_trial_initialize;       
    % trial values
    k = k+1;            % trial number
    data.params.trial_threshold(k,:) = data.params.threshold;
    x = data.stimuli.startPos(data.stimuli.loc(k));  
    
    % ITI - force mouse to stop moving for 1s
    fprintf('%s ITI\n',datestr(toc(tstart)/86400,'MM:SS'))    
            
    display_performance;
    mouse_trial_initiation;
    
    Screen('FillRect', window, grey)
    vbl = Screen('Flip', window);
    
    % trial start
    fprintf('\n\n%s TRIAL %d START\n',datestr(toc(tstart)/86400,'MM:SS'),k)
    
    % Present stimulus (locked)
    %stim_presentation_delay;
%     Screen('FillRect', window, [1 1 1])
%     tic;
%     vbl = Screen('Flip', window);
    x = data.stimuli.startPos(data.stimuli.loc(k));
    trackball_draw(k, x, [1 1 1]);
    tic;
    vbl = Screen('Flip', window);
    
    while toc < 1
        continue
    end
    
    collect_serial_samples;
    precue_samples_start = size(data.response.mvmtdata,1); % --RH end
    
    % Random delay before go tone
    
    % Go signal
    if data.params.early_cue && data.response.playEarlyCue(k) == 1
        psychsr_sound(data.params.earlyCue_sound);
    end
    data.response.earlyCueTime(k) = toc(tstart);
      
    delay = 0;
    
    delay_manipulations;
    collect_serial_samples;
    
    % log start time
    currT = tic;
    data.response.trialstart(k) = toc(tstart);
    samples_start = size(data.response.mvmtdata,1);
    curr_laser_start = data.params.laser_start(randi(numel(data.params.laser_start)));
    
    %% track ball movements    
    abort_flip = randi(numel(data.params.noMvmtTime),1);
    data.response.mvmt_delay(k,1) = abort_flip;     
    trackball_movement_loop;
    data.response.choice(k) = choice;
    data.response.choice_id(k) = id;
    
    %% reward or punish
    reward_punish;
    
    for i = 1:10
        pause(0.1) % pause allows reward to be administered
        trackball_keycheck(k);
    end
    if data.params.itiBlack
        Screen('FillRect', window, black);
    else        
        Screen('FillRect', window, grey);
    end
    newvbl = Screen('Flip', window);
    if length(flips)<2
        flips(2) = newvbl;
    end
    
    % Select next trial based on antibias settings
    do_antibias;
    
    % Decide to quit + save trial variables
    save_trial_data;
    
    % Plot performance
    figure(1);
    visualize_helper;
end

%% Cleanup
trackball_cleanup_save;