% convert parameters to allow analysis of non-interleaved laser stim behavioral data
% (used for motor inactivaiton when suppressing movement inhibits behavior)

clear

[filename, pathname] = uigetfile('*.mat');

load(filename)
data.stimuli.response_delay(6) = 2; 
data.response.n_nolaser = 1;

save(filename,'data')
disp('done.')