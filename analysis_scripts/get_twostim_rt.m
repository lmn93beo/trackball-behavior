% Input the data structure and the contrast for perf
% Column order: contrast, perf on left stim, perf on right stim

function [output, rts] = get_twostim_rt(data,laser_arg); %l and r here refer to stimulus location

choice = data.response.choice;
ntrials = numel(choice);

timePC = data.response.timePC;

% Compile the reaction times
rts = zeros(1, ntrials);
for i = 1:ntrials
    rts(i) = timePC{i}(end);
end

output = [];
    
if isfield(data.stimuli, 'opp_contrast')
    curr_con = unique(data.params.opp_contrast)';
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
        rts_l = rts(loc == 2 & cons == curr_con(i) & laser == laser_idx);
        rts_r = rts(loc == 1 & cons == curr_con(i) & laser == laser_idx);

        rt_l(i, 1) = mean(rts_l(rts_l < 2));
        rt_r(i, 1) = mean(rts_r(rts_r < 2));
    %     perf_l(i,1) = sum(loc == 2 & choice == 2 & cons == curr_con(i) & laser == laser_idx)/...
    %         (sum(loc == 2 & cons == curr_con(i) & laser == laser_idx) - sum(loc == 2 & cons == curr_con(i) & choice == 5 & laser == laser_idx));
    %     
    %     perf_r(i,1) = sum(loc == 1 & choice == 1 & cons == curr_con(i) & laser == laser_idx)/...
    %         (sum(loc == 1 & cons == curr_con(i) & laser == laser_idx) - sum(loc == 1 & cons == curr_con(i) & choice == 5 & laser == laser_idx));
    end

    output = [curr_con rt_l rt_r];
    
end


