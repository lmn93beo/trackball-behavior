global data
load default_params_training.mat

data.params.reward = 6;
data.params.contrast = 1;
data.mouse = 'D28';
data.params.training = 1;
data.params.threshold = [10 10];
data.params.trainingSide = [1 1];
data.params.blockSize = 1;
data.params.alternating = 0;
data.params.incorrSound = 1;

data.params.switchBlock = 0;
data.params.switchBlockExp = 1;
data.params.perRight = 1;

data.params.simultaneous = 0;
data.params.contrast_follows_loc = 0;
data.params.antibiasConsecutive = 0;
data.params.antibiasRepeat = 0;


data.params.responseTime = 15;
     