[file path] = uigetfile;
load([path file])
ntrials = floor(find(data.response.licks(end) < data.stimuli.end_time,1)/3);

targ = (data.stimuli.orientation(3:3:end) == 90);
targ = targ(1:ntrials);

perf = data.response.n_overall(1:ntrials);

hit_rate = mean(perf(targ));
fa_rate = 1-mean(perf(~targ));

ind = find(~targ);
ind = ind(diff([0 ind])>1);

fa_rate_switch = 1-mean(perf(ind));

fprintf('Hit rate:       %2d%% of %d\n',round(hit_rate*100),sum(targ))
fprintf('FA rate:        %2d%% of %d\n',round(fa_rate*100),sum(~targ))
fprintf('FAs after targ: %2d%% of %d\n',round(fa_rate_switch*100),length(ind))
