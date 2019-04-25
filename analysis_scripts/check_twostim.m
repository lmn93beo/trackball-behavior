function [output, output_details] = check_twostim(data);

% check for multiple non-zero contrasts
all_cons = unique(data.params.opp_contrast);
con_check = sum(all_cons > 0) > 1;  

% ... antibias off
anti_check = data.params.antibiasConsecutive == 0; %<<<<CHANGE BACK TO 0

% ... multiple stim durations
try
    stim_check = ~data.params.flashStim | numel(unique(data.response.stimdur)) < 2; %If flash stim is off, no issue with duration
catch
    stim_check = true;
end

% ... performance check
ntrials = numel(data.response.choice);
choice = data.response.choice(1:ntrials);
loc = data.stimuli.loc(1:ntrials);
con = data.stimuli.opp_contrast(1:ntrials);
target_con = data.stimuli.contrast(1:ntrials);
try
    laser = data.stimuli.laser(1:ntrials);
catch
    laser(1:ntrials) = 1;
end

min_con = min(con);
perf_l = sum(loc == 1 & choice == 1 & con == min_con & laser == 1)/...
    (sum(loc == 1 & con == min_con & laser == 1) - sum(loc == 1 & con == min_con & choice == 5 & laser == 1));
perf_r = sum(loc == 2 & choice == 2 & con == min_con & laser == 1)/...
    (sum(loc == 2 & con == min_con & laser == 1) - sum(loc == 2 & con == min_con & choice == 5 & laser == 1));

perf_check = (perf_l >= 0.7 & perf_r >= 0.7);
target_con_check = numel(unique(target_con)) == 1 & sum(unique(target_con) == 0.64) == 1;
num_target_con_check = numel(unique(data.stimuli.contrast)) == 1;
% ... number of trials for each contrast (at least 10)
temp = [];
for i = 1:numel(all_cons)
    temp = [temp sum(loc == 1 & ~(choice == 5) & con == all_cons(i))];
end
ncon_check = sum(temp > 9) == numel(all_cons);

% ... check for simultaneous
simul_check = data.params.simultaneous;

output = con_check & anti_check & stim_check & perf_check & ncon_check & simul_check & target_con_check & num_target_con_check;
output_details = [con_check anti_check stim_check perf_check ncon_check simul_check target_con_check num_target_con_check];