% load file
[file, dir] = uigetfile('..\behaviorData\*.mat');
load([dir file])

% extract "licked" and "target" vectors
target = (data.stimuli.orientation(3:3:end) == 90);
if length(target)>length(data.response.n_overall)
    target = target(1:length(data.response.n_overall));
end
licked = ~xor(data.response.n_overall(1:length(target)),target);

figure;
subplot(2,1,1), plot(target)
subplot(2,1,2), plot(licked)

%% write your own code here
% to extract H% and FA% averaged across the whole session
avg_hits = sum(target & licked)/sum(target)

avg_fas = 

%% write your own code here
% to extract H% and FA% as a vector across trials

