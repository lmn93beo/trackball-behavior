
switch mouse
    case 1001
        disp('Check that system volume is set to 30.')
        pause
        
        data.params.lever = 1;
        
        data.params.reward = [6];
        data.params.rewardProb = [1];
        data.params.lev_cal = 0.44;
        data.params.lev_cont = 1; % 1 = high tone reward; 2 = low tone reward
        
        % motor learning
        %         data.sound.tone_amp = 0;
        %         data.params.freeChoice = 0;     % percentage of free choices
        %         data.params.perRight = 1;       % percentage of right trials (out of all non-freechoice)
        %         data.params.responseTime = 10;   % maximum reaction time
        %         data.params.lev_thresh = 0.3; % threshold difference between levers (percent of single threshold)
        %         data.params.punishDelay = 0;    % extra ITI on incorrect/timeout trials
        %         data.params.rewardDelay = 1;
        %         data.params.lev_pufftime = 0;    % airpuff time in sec
        
        % go/no-go learning
        data.params.go_cue = 0;
        data.params.freeChoice = 0;     % percentage of free choices
        data.params.perRight = 0.7;       % percentage of right trials (out of all non-freechoice)
        data.params.nRight = 5;
        data.sound.noise_amp = 0;
        data.params.responseTime = 3;   % maximum reaction time
        data.params.punishDelay = 3;    % extra ITI on incorrect/timeout trials
        data.params.extenddelay = 1;    % extend ITI until mouse stops moving for 1 sec
        data.params.lev_thresh = 0.3; % threshold difference between levers (percent of single threshold)
        data.params.stims = {'grating'};
        
        data.params.lev_touch = 0;
        
        % laser parameters
        data.params.goDelay = 0.1;
        data.params.laser = 0;          % laser on
        data.params.laser_time = 2.2;     % duration in s
        data.params.laser_start = -0.1;    % time after trial start
        data.params.perLaser = 0.25;    % percent laser trials
        data.params.noLaser = 20;        % number of no-laser trials at beginning
        
    case 1002
        disp('Check that system volume is set to 30.')
        pause
        %         data.screen.
        data.params.lever = 1;
        
        data.params.reward = [6];
        data.params.rewardProb = [1];
        data.params.lev_cal = 0.44;
        data.params.lev_cont = 1; % 1 = high tone reward; 2 = low tone reward
        
        if strcmp(getenv('computername'),'VISSTIM-2P4')
            data.sound.tone_amp = 0.7;
        end
        
        % motor learning
        %         data.params.go_cue = 1;
        %         data.params.freeChoice = 0;     % percentage of free choices
        %         data.params.perRight = 1;       % percentage of right trials (out of all non-freechoice)
        %         data.params.responseTime = 5;   % maximum reaction time
        %         data.params.lev_thresh = 0.3; % threshold difference between levers (percent of single threshold)
        %         data.params.punishDelay = 0;    % extra ITI on incorrect/timeout trials
        %         data.params.rewardDelay = 2.5;
        %         data.params.lev_pufftime = 0;    % airpuff time in sec
        %         data.params.contrast = 0;       % maximum amplitude/contrast
        
        % go/no-go
        data.params.freeChoice = 0;     % percentage of free choices
        data.params.perRight = 0.6;       % percentage of right trials (out of all non-freechoice)
        data.params.nRight = 20;
        data.params.responseTime = 2;   % maximum reaction time
        data.params.punishDelay = 3;    % extra ITI on incorrect/timeout trials
        data.params.extenddelay = 1;    % extend ITI until mouse stops moving for 1 sec
        data.params.lev_thresh = 0.3; % threshold difference between levers (percent of single threshold)
        
        % gratings
        %         data.params.stims = {'grating'};
        %         data.params.go_cue = 0;
        %         data.sound.noise_amp = 0;
        %         data.params.lev_chirp = 0;
        %         data.sound.tone_time = 0.25;
        
        % chirps
        data.params.contrast = 0;
        data.params.go_cue = 1;
        data.sound.noise_amp = 0;
        data.params.lev_chirp = 1;
        data.sound.tone_time = 0.25;
        
        data.params.lev_touch = 0;
        
    case 1003
        disp('Check that system volume is set to 30.')
        pause
        
        data.params.lever = 1;
        
        data.params.reward = [6];
        data.params.rewardProb = [1];
        data.params.lev_cal = 0.44;
        data.params.lev_cont = 1; % 1 = high tone reward; 2 = low tone reward
        
        if strcmp(getenv('computername'),'VISSTIM-2P4')
            data.sound.tone_amp = 0.7;
        end
        
        % motor learning
        %         data.sound.tone_amp = 0.7;
        %         data.params.go_cue = 1;
        %         data.params.freeChoice = 0;     % percentage of free choices
        %         data.params.perRight = 1;       % percentage of right trials (out of all non-freechoice)
        %         data.params.responseTime = 5;   % maximum reaction time
        %         data.params.lev_thresh = 0.2; % threshold difference between levers (percent of single threshold)
        %         data.params.punishDelay = 0;    % extra ITI on incorrect/timeout trials
        %         data.params.rewardDelay = 2.5;
        %         data.params.lev_pufftime = 0;    % airpuff time in sec
        %         data.params.contrast = 0;       % maximum amplitude/contrast
        
        % go/no-go
        data.params.freeChoice = 0;     % percentage of free choices
        data.params.perRight = 0.8;       % percentage of right trials (out of all non-freechoice)
        data.params.nRight = 20;
        data.params.responseTime = 2;   % maximum reaction time
        data.params.punishDelay = 3;    % extra ITI on incorrect/timeout trials
        data.params.extenddelay = 1;    % extend ITI until mouse stops moving for 1 sec
        data.params.lev_thresh = 0.3; % threshold difference between levers (percent of single threshold)
        
        % gratings
        %         data.params.stims = {'grating'};
        %         data.params.go_cue = 0;
        %         data.sound.noise_amp = 0;
        %         data.params.lev_chirp = 0;
        %         data.sound.tone_time = 0.25;
        
        % chirps
        data.params.contrast = 0;
        data.params.go_cue = 1;
        data.sound.noise_amp = 0;
        data.params.lev_chirp = 1;
        data.sound.tone_time = 0.25;
        
        data.params.lev_touch = 0;
        
    case 1004
        data.params.lever = 1;
        data.params.reward = [6];
        data.params.rewardProb = [1];
        
        % motor learning
        data.sound.noise_amp = 0;
        if strcmp(getenv('computername'),'VISSTIM-2P4')
            data.sound.tone_amp = 0.7;
        end
        % chirps
        data.params.contrast = 0;
        data.params.go_cue = 1;
        data.sound.noise_amp = 0;
        data.params.lev_chirp = 1;
        data.sound.tone_time = 0.25;
        
        data.params.freeChoice = 0;     % percentage of free choices
        data.params.perRight = 0.6;       % percentage of right trials (out of all non-freechoice)
        data.params.responseTime = 2;   % maximum reaction time
        data.params.lev_thresh = 0.3; % threshold difference between levers (percent of single threshold)
        data.params.punishDelay = 0;    % extra ITI on incorrect/timeout trials
        data.params.lev_pufftime = 0.25;    % airpuff time in sec
        data.params.contrast = 0;       % maximum amplitude/contrast
        
        data.params.nRight = 20; % number of right trials at beginning
        
        data.params.lev_touch = 0;
        
    case {2001, 2003}
        data.params.lever = 1;
        data.params.reward = [6];
        data.params.rewardProb = [1];
        
        % motor learning
        data.sound.noise_amp = 0;
        if strcmp(getenv('computername'),'VISSTIM-2P4')
            data.sound.tone_amp = 0.7;
        end
        % chirps
        data.params.contrast = 0;
        data.params.go_cue = 1;
        data.sound.noise_amp = 0;
        data.params.lev_chirp = 0;
        data.sound.tone_time = 0.25;
        
        data.params.freeChoice = 0;     % percentage of free choices
        data.params.perRight = 1;       % percentage of right trials (out of all non-freechoice)
        data.params.responseTime = 4;   % maximum reaction time
        data.params.lev_thresh = 0.2; % threshold difference between levers (percent of single threshold)
        data.params.punishDelay = 0;    % extra ITI on incorrect/timeout trials
        data.params.lev_pufftime = 0.25;    % airpuff time in sec
        data.params.contrast = 0;       % maximum amplitude/contrast
        
        data.params.nRight = 20; % number of right trials at beginning
        
        data.params.lev_touch = 0;
        
    case {2002}
        data.params.lever = 1;
        data.params.reward = [6];
        data.params.rewardProb = [1];
        
        % motor learning
        data.sound.noise_amp = 0;
        if strcmp(getenv('computername'),'VISSTIM-2P4')
            data.sound.tone_amp = 0.7;
        end
        % chirps
        data.params.contrast = 0;
        data.params.go_cue = 1;
        data.sound.noise_amp = 0;
        data.params.lev_chirp = 0;
        data.sound.tone_time = 0.25;
        
        data.params.freeChoice = 0;     % percentage of free choices
        data.params.perRight = 1;       % percentage of right trials (out of all non-freechoice)
        data.params.responseTime = 5;   % maximum reaction time
        data.params.lev_thresh = 0.2; % threshold difference between levers (percent of single threshold)
        data.params.punishDelay = 0;    % extra ITI on incorrect/timeout trials
        data.params.lev_pufftime = 0.25;    % airpuff time in sec
        data.params.contrast = 0;       % maximum amplitude/contrast
        
        data.params.nRight = 20; % number of right trials at beginning
        
        data.params.lev_touch = 0;
        
    case {2005}
        data.params.lever = 1;
        data.params.reward = [6];
        data.params.rewardProb = [1];
        
        % motor learning
        data.sound.noise_amp = 0;
        if strcmp(getenv('computername'),'VISSTIM-2P4')
            data.sound.tone_amp = 0.7;
        end
        % chirps
        data.params.contrast = 0;
        data.params.go_cue = 1;
        data.sound.noise_amp = 0;
        data.params.lev_chirp = 0;
        data.sound.tone_time = 0.25;
        
        data.params.freeChoice = 0;     % percentage of free choices
        data.params.perRight = 1;       % percentage of right trials (out of all non-freechoice)
        data.params.responseTime = 10;   % maximum reaction time
        data.params.lev_thresh = 0.2; % threshold difference between levers (percent of single threshold)
        data.params.punishDelay = 0;    % extra ITI on incorrect/timeout trials
        data.params.lev_pufftime = 0.25;    % airpuff time in sec
        data.params.contrast = 0;       % maximum amplitude/contrast
        
        data.params.nRight = 20; % number of right trials at beginning
        
        data.params.lev_touch = 0;
        
        
        
        
    case {2004}
        data.params.lever = 1;
        data.params.reward = [6];
        data.params.rewardProb = [1];
        
        % motor learning
        data.sound.noise_amp = 0;
        if strcmp(getenv('computername'),'VISSTIM-2P4')
            data.sound.tone_amp = 0.7;
        end
        % chirps
        data.params.contrast = 0;
        data.params.go_cue = 1;
        data.sound.noise_amp = 0;
        data.params.lev_chirp = 0;
        data.sound.tone_time = 0.25;
        
        data.params.freeChoice = 0;     % percentage of free choices
        data.params.perRight = 1;       % percentage of right trials (out of all non-freechoice)
        data.params.responseTime = 5;   % maximum reaction time
        data.params.lev_thresh = 0.15; % threshold difference between levers (percent of single threshold)
        data.params.punishDelay = 0;    % extra ITI on incorrect/timeout trials
        data.params.lev_pufftime = 0.25;    % airpuff time in sec
        data.params.contrast = 0;       % maximum amplitude/contrast
        
        data.params.nRight = 20; % number of right trials at beginning
        
        data.params.lev_touch = 0;
end