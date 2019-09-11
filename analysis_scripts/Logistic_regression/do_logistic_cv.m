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





%% Five-fold cross-validation
x_left = left_contrast(goodtrials)';
x_right = right_contrast(goodtrials)';
x_prev_stim = prev_stim(goodtrials)';


y = choice(goodtrials)' - 1;
X = [ones(numel(y), 1) x_left];

rng(123);
N_cv = 1000; % Repetitions of cross-validation
nfold = 5;
[B_cv, CVs_cv] = get_multiple_cv_logistic(X, y, N_cv, nfold, 1);
fprintf('Mean of CVs = %.4f\n', mean(CVs_cv(:)));




function C = find_cost_helper(params, X, y)
    B = params;
    C = - find_log_likelihood(X, B, y);
end

function C = find_cost_helper_with_lapse(params, X, y)
    lapse = params(1);
    B = params(2:end);
    C = - find_log_likelihood_with_lapse(X, B, y, lapse);
end


function [B_cv, CVs_cv] = get_multiple_cv_logistic(X, y, N_cv, nfold, use_lapse)
    m = size(X, 2);
    B_cv = zeros(N_cv, m);
    CVs_cv = zeros(N_cv, nfold);

    for i = 1:N_cv
        [Bs, lls, ll0s, CVs] = get_cv_logistic(X, y, nfold, use_lapse);
        B_cv(i,:) = mean(Bs, 1);
        CVs_cv(i,:) = CVs;
    end
end


function [Bs, lls, ll0s, CVs] = get_cv_logistic(X, y, nfold, use_lapse)
    % Bs: coefficients
    % lls: log-likelihood
    % ll0s: baseline log-likelihood
    % CVs: cross-validated bit/trial

    % Five-fold splits
    m = size(X, 2);
    order = randperm(numel(y));
    N = numel(y);
    nset = floor(N/5);
    nleft = mod(N, nfold);
    partition = mat2cell(order, 1, [ones(1, nfold - 1) * nset nset + nleft]);

    lls = zeros(nfold, 1);
    ll0s = zeros(nfold, 1);
    CVs = zeros(nfold, 1);
    Bs = zeros(nfold, m);
    for i = 1:nfold
       test = partition{i};
       train = setdiff(order, test);
       Xtrain = X(train, :);
       ytrain = y(train, :);
       Xtest = X(test, :);
       ytest = y(test, :);
       [B, ll] = get_ll_logistic(Xtrain, ytrain, Xtest, ytest, use_lapse);

       % Baseline model
       ll0 = find_log_likelihood_baseline(ytest);
       CV = (ll - ll0) / numel(ytest) / log(2);

       lls(i) = ll;
       ll0s(i) = ll0;
       CVs(i) = CV;
       Bs(i, :) = B';
    end

end

function [B, ll] = get_ll_logistic(Xtrain, ytrain, Xtest, ytest, use_lapse)
    % If lapse = 1, will fit with lapse
    if use_lapse
        niter = 1000;
        exitflag = 0;
        fun = @(params) find_cost_helper_with_lapse(params, Xtrain, ytrain);
        x0 = zeros(size(Xtrain, 2) + 1, 1);
        if ~exitflag && niter < 10000
            options = optimset('MaxFunEvals', niter, 'Display', 'off');
            [B, ~, exitflag] = fminsearch(fun, x0, options);
            niter = niter * 2;
        end
    else
        fun = @(params) find_cost_helper(params, Xtrain, ytrain);
        x0 = zeros(size(Xtrain, 2), 1);
        B = fminsearch(fun, x0);
    end
    
    
    % Log-likelihood
    if use_lapse
        lapse = B(1);
        B = B(2:end);
        ll = find_log_likelihood_with_lapse(Xtest, B, ytest, lapse);
    else
        ll = find_log_likelihood(Xtest, B, ytest);
    end
end


% function [B, ll] = get_ll_logistic(Xtrain, ytrain, Xtest, ytest)
%     %[B, ~, ~] = glmfit(Xtrain, ytrain, 'binomial', 'constant', 'off');
%     fun = @(params) find_cost_helper(params, Xtrain, ytrain);
%     x0 = zeros(size(Xtrain, 2), 1);
%     B = fminsearch(fun, x0);
%     
%     % Alternative way to do logistic
%     %[B, dev, stats] = mnrfit(X, y);
% 
%     % Log-likelihood
%     ll = find_log_likelihood(Xtest, B, ytest);
% end


function s = sigmoid(x)
    s = 1 ./ (1 + exp(-x));
end

function ll = find_log_likelihood(X, B, y)
    prob = sigmoid(X * B);
    ll = sum(y .* log(prob) + (1 - y) .* log(1 - prob));
end

function ll = find_log_likelihood_with_lapse(X, B, y, lapse)
    prob = lapse + (1 - 2 * lapse) ./ (1 + exp(-X * B));
    ll = sum(y .* log(prob) + (1 - y) .* log(1 - prob));
end

function ll = find_log_likelihood_baseline(y)
    p = mean(y);
    ll = sum(y * log(p) + (1 - y) * log(1 - p));
end

function tests(X, y)
% Some sanity checks
% Find B using fminsearch
B1 = glmfit(X, y, 'binomial', 'constant', 'off');
fun = @(params) find_cost_helper(params, X, y);
x0 = [0 0 0 0]';
B2 = fminsearch(fun, x0);
assert(max(B1 - B2) < 1e-4);

% With lapse
options = optimset('MaxFunEvals', 2000);
fun2 = @(params) find_cost_helper_with_lapse(params, X, y);
x0 = [0 0 0 0 0]';
Blapse = fminsearch(fun2, x0, options);

%% Check find_log_likelihood_with_lapse
a = find_log_likelihood(X, B1, y);
b = find_log_likelihood_with_lapse(X, B1, y, 0);
assert(a == b);
end


