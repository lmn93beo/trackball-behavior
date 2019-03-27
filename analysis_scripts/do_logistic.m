folder = 'C:\Users\Sur lab\Dropbox (MIT)\trackball-behavior\Data';

%filename = '96\Oct2018\20181015_trackball_0096.mat';
filename = 'C13\FebMar2019\20190204_trackball_0013.mat';

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
currchoice = choice(2:end)';
prevchoice = choice(1:(end-1))';
x1 = stim(2:end)';
x2 = choice(1:end-1)';

y_b = currchoice(currchoice~=5 & prevchoice~=5);

X = [x1 x2];
X_b = X(currchoice~=5 & prevchoice~=5, :) * 2 - 3;
[B, dev, stats] = mnrfit(X_b, y_b);

b2 = glmfit(X_b, y_b - 1, 'binomial')

%% Test for a random matrix
Xtest = rand(95, 2) > 0.5;
ytest = ones(95, 1) - 1;
btest = glmfit(Xtest, ytest, 'binomial');