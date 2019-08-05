global data

load default_params_training.mat
data.params.reward = 5;

% build contrast list
contrast = [1 0.0 0.0 0.0];
%contrast = repmat(contrast, [1 100]);
%contrast(3:4:160) = 0.1 * 0.97 .^ (1:40);
data.params.contrast = contrast;
data.params.contrast_follows_loc = 0;


%data.mouse = 96;
data.params.training = 0;
data.params.trainingSide = [1 1];
data.params.blockSize = 1;
data.params.alternating = 1;
data.params.flashStim = 0.2;

% Antibias
data.params.antibiasConsecutive = 0;
data.params.antibiasRepeat = 0; % probability that antibias will repeat after a wrong trial        
data.params.antibiasSwitch = 0; % probability that antibias will switch after a correct trial