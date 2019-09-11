%% Generate some data
% StimLevels = [-0.64 -0.48 -0.32 -0.16 0.16 0.32 0.48 0.64]; % contrast difference
% OutOfNum = [103 100 101 103 98 99 101 99]; % Total number of trials
% NumPos = [1 3 10 20 82 90 98 99]; % Number of correct trials
StimLevels = luminanceL;
OutOfNum = ntrialsL_total';
NumPos = nleftL_total';


% Plot data
plot(StimLevels, NumPos ./ OutOfNum, 'o');
hold on;


%% Do fitting
searchGrid.alpha = -1:.05:1;    %structure defining grid to
searchGrid.beta = 10.^(-1:.05:2); %search for initial values

fitlapse = input('Do you want to fit lapse? Yes (1) No (0): ');
if fitlapse
    searchGrid.gamma = 0:.005:.8;
    searchGrid.lambda = 0:.005:.8;
    paramsFree = [1 1 1 1]; %[threshold slope guess lapse] 1: free, 0:fixed
else
    searchGrid.gamma = 0;
    searchGrid.lambda = 0;
    paramsFree = [1 1 0 0];
end

%Nelder-Mead search options
options = PAL_minimize('options');  %decrease tolerance (i.e., increase
options.TolX = 1e-09;              %precision).
options.TolFun = 1e-09;
options.MaxIter = 10000;
options.MaxFunEvals = 10000;

PF = @PAL_Logistic; % Function to fit to, can be @PAL_Logistic, @PAL_CumulativeNormal
lapseFit = 'naple';

[paramsFitted LL exitflag] = PAL_PFML_Fit(StimLevels, NumPos, OutOfNum, ...
    searchGrid, paramsFree, PF,'lapseLimits',[0 1],'searchOptions',options,'lapseFit',lapseFit);

if ~exitflag
    disp('Psychometric Function Fit failed! Exiting...');
    return
end


plot(-1:.01:1,PF(paramsFitted,-1:.01:1),'-','color',[0 .7 0],'linewidth',2);