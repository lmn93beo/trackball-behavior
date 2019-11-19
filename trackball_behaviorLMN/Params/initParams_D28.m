global data
load default_params_training.mat

data.params.reward = 4.5;
data.params.contrast = 1;
data.mouse = 'D28';
data.params.training = 1;
data.params.threshold = [10 10];
data.params.trainingSide = [0.8 0.8];
data.params.blockSize = 1;
data.params.alternating = 0;
data.params.incorrSound = 0;

data.params.simultaneous = 0;
data.params.contrast_follows_loc = 0;
data.params.antibiasConsecutive = 1;
data.params.antibiasRepeat = 0.5;


data.params.responseTime = 15;
     