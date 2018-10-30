folder = 'C:\Users\Sur lab\Dropbox (MIT)\trackball-behavior\Data';

filename = '96\Oct2018\20181015_trackball_0096.mat';

load(fullfile(folder, filename));
choice = data.response.choice;
ntrials = numel(choice);
stim = data.stimuli.loc(1:ntrials);

%% Find the relevant trials
timeouts = find(choice == 5);
corr = find(choice ~= 5 & stim == choice);
incorr = find(choice ~= 5 & stim ~= choice);
left = find(stim == 1);
right = find(stim == 2);

%% Make a design matrix
y = choice(2:end)';
x1 = stim(2:end)';
x2 = choice(1:end-1)';

y_b = y(y~=5);

X = [x1 x2];
X_b = X(y~=5, :);
[B, dev, stats] = mnrfit(X(y ~= 5,:), y(y ~= 5));

b2 = glmfit(X_b, y_b - 1, 'binomial');