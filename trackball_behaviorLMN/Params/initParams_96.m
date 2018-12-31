global data

load default_params_training.mat
data.params.reward = 6;
data.params.contrast = [1 0.2];
data.mouse = 96;
data.params.training = 0;
data.params.trainingSide = [1 1];
data.params.blockSize = 1;
data.params.alternating = 1;

% Antibias
data.params.antibiasConsecutive = 0;
data.params.antibiasRepeat = 0; % probability that antibias will repeat after a wrong trial        
data.params.antibiasSwitch = 0; % probability that antibias will switch after a correct trial