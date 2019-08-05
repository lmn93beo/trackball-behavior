global data
load default_params_training.mat

data.params.reward = 6;
data.params.contrast = 0.64;
data.mouse = '13';
data.params.training = 0;
data.params.trainingSide = [1 1];
data.params.blockSize = 1;
data.params.alternating = 0;

data.params.simultaneous = 1;
data.params.opp_contrast = [0 0.16 0.32 0.48];
data.params.contrast_follows_loc = 0;
data.params.flashStim = 0.4;

% Antibias
data.params.antibiasConsecutive = 1;
data.params.perRight = 0.5;
data.params.antibiasRepeat = 0; % probability that antibias will repeat after a wrong trial        
data.params.antibiasSwitch = 0; % probability that antibias will switch after a correct trial

data.params.responseTime = 1;

  % Laser
  data.params.laser = 0;          % laser on
  data.params.laser_blank_only = 0;
  data.params.laser_time = 0.01;   % duration in s
  data.params.laser_mode = 'continuous';
  data.params.laser_freq = 0; % frequency
  data.params.laser_pw = 0; % pulse width
  
  data.params.laser_start = [-0.31]; % time after trial start
  data.params.perLaser = 0.3;    % percent laser trials
  data.params.noLaser = 10;        % number of no-laser trials at beginning\
     