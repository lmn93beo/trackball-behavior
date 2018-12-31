global data
load default_params_training.mat

data.params.reward = 4;
data.params.contrast = [1 1];
data.mouse = 13;
data.params.training = 0;
data.params.trainingSide = [1 1];
data.params.blockSize = 2;
data.params.alternating = 1;

% Antibias
data.params.antibiasConsecutive = 0;
data.params.antibiasRepeat = 0; % probability that antibias will repeat after a wrong trial        
data.params.antibiasSwitch = 0; % probability that antibias will switch after a correct trial