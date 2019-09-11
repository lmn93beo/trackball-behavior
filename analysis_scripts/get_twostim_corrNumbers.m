% Input the data structure and the contrast for perf
% Column order: contrast, perf on left stim, perf on right stim

function [output] = get_twostim_perf(data,laser_arg); %l and r here refer to stimulus location

curr_con = unique(data.params.opp_contrast)';

choice = data.response.choice;
ntrials = numel(choice);
loc = data.stimuli.loc(1:ntrials);
cons = data.stimuli.opp_contrast(1:ntrials);
% Get rid of all trials with less than 8% contrast


try
    laser = data.stimuli.laser(1:ntrials);
catch
    laser(1:ntrials) = 1;
end

if ~laser_arg
    laser_idx = 1;
else
    laser_idx = 2;
end

for i = 1:numel(curr_con)
    corr_l(i) = sum(loc == 2 & choice == 2 & cons == curr_con(i));
    incorr_l(i) = sum(loc == 2 & choice == 1 & cons == curr_con(i));
    
    corr_r(i) = sum(loc == 1 & choice == 1 & cons == curr_con(i));
    incorr_r(i) = sum(loc == 1 & choice == 2 & cons == curr_con(i));
end

output = [curr_con corr_l' incorr_l' corr_r' incorr_r'];

end


