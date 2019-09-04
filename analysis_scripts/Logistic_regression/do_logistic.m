folder = 'C:\Users\Sur lab\Dropbox (MIT)\trackball-behavior\Data';

%filename = '96\Oct2018\20181015_trackball_0096.mat';
filename = 'ACC Mice\mouse 0111\20190212_trackball_0111.mat';

% left = 1, right = 2
% Set up regressors
load(fullfile(folder, filename));
choice = data.response.choice;
ntrials = numel(choice);
stim = data.stimuli.loc(1:ntrials);
opp_contrast = data.stimuli.opp_contrast(1:ntrials);
contrast = data.stimuli.contrast(1:ntrials);

left_contrast = (stim == 2) .* opp_contrast;
right_contrast = (stim == 1) .* opp_contrast;
left_contrast(stim == 1) = contrast(1);
right_contrast(stim == 2) = contrast(1);

% left = 1, right = -1
prev_stim = [nan stim(1:end-1) * 2 - 3];
prev_choice = [nan choice(1:end-1)];

% Filter the trials
goodtrials = find(~isnan(prev_stim) & choice ~= 5 & prev_choice ~= 5);


%% Make a design matrix
x_left = left_contrast(goodtrials)';
x_right = right_contrast(goodtrials)';
x_prev_stim = prev_stim(goodtrials)';

X = [x_left x_right x_prev_stim];
y = choice(goodtrials)' - 1;
[B, dev, stats] = glmfit(X, y, 'binomial');

% Alternative way to do logistic
%[B, dev, stats] = mnrfit(X, y);

% Log-likelihood
ll = find_log_likelihood(X, B, y)
scatter(prob, y + rand(numel(y), 1) * 0.1);


function s = sigmoid(x)
s = 1 ./ (1 + exp(-x));
end

function ll = find_log_likelihood(X, B, y)
prob = sigmoid(X * B(2:end,:) + B(1));
ll = sum(y .* log(prob) + (1 - y) .* log(1 - prob));
end

