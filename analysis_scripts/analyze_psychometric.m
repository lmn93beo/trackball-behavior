% This script loads the data saved by running pool_data.m
% fits the psychometric curve with Palamedes,
% finds the fit parameters together with the 95% confidence interval

%% Load the data
clear all;
mouse = input('Enter mouse number: ');
xtext = 'Left - right stimulus luminance';
ytext = '% left selected';

switch getenv('computername')
    case 'DESKTOP-FN1P6HD'
        root = 'C:\Users\Sur lab\Dropbox (MIT)\trackball-behavior';
    otherwise
        root = 'C:\Users\Le\Dropbox (MIT)\trackball-behavior';
end

switch mouse
    case 91
        directory = sprintf('%s%s', root, '\Data\80_91\91_RACC\');
        load([directory '91_RACC_agg_perf.mat']);
        description = '91 Right ACC';
    case 80
        directory = sprintf('%s%s', root, '\Data\80_91\80_LACC\');
        load([directory '80_LACC_agg_perf.mat']);
        description = '80 Left ACC';
    case 89
        directory = sprintf('%s%s', root, '\Data\87_89_SC\89_LSC\');
        load([directory '89_LSC_agg_perf.mat']);
        description = '89 Left SC';
    case 87
        directory = sprintf('%s%s', root, '\Data\87_89_SC\87_RSC\');
        load([directory '87_RSC_agg_perf.mat']);
        description = '87 Right SC';
    case '13L'
        directory = sprintf('%s%s', root, '\Data\C13\laser_analys_FebMar2019_left\');
        load([directory 'C13_leftSTR_agg_perf.mat']);
        description = 'C13 Left STR';
    case '13R'
        directory = sprintf('%s%s', root, '\Data\C13\laser_analys_FebMar2019_right\');
        load([directory 'C13_rightSTR_agg_perf.mat']);
        description = 'C13 Right STR';
    case '13L_first3'
        directory = sprintf('%s%s', root, '\Data\C13\C13_leftACCSTR\');
        load([directory 'C13_leftACCSTR_combined.mat']);
        description = 'C13 Left STR';
    case '13R_first3'
        directory = sprintf('%s%s', root, '\Data\C13\C13_rightACCSTR\');
        load([directory 'C13_rightACCSTR_combined.mat']);
        description = 'C13 Right STR';
    case '13_combined'
        directory13 = sprintf('%s%s', root, '\Data\C13\');
        load([directory13 'C13_leftACCSTR\C13_leftACCSTR_combined.mat']);
        nleftNL_LSTR = nleftNL_total;
        nleftL_LSTR = nleftL_total;
        ntrialsNL_LSTR = ntrialsNL_total;
        ntrialsL_LSTR = ntrialsL_total;
        
        load([directory13 'C13_rightACCSTR\C13_rightACCSTR_combined.mat']);
        nleftNL_RSTR = nleftNL_total;
        nleftL_RSTR = nleftL_total;
        ntrialsNL_RSTR = ntrialsNL_total;
        ntrialsL_RSTR = ntrialsL_total;
        
        % Combine the two sides
        nleftNL_LSTR = flipud(ntrialsNL_LSTR - nleftNL_LSTR);
        nleftL_LSTR = flipud(ntrialsL_LSTR - nleftL_LSTR);
        ntrialsNL_LSTR = flipud(ntrialsNL_LSTR);
        ntrialsL_LSTR = flipud(ntrialsL_LSTR);
        
        nleftNL_total = nleftNL_LSTR + nleftNL_RSTR;
        nleftL_total = nleftL_LSTR + nleftL_RSTR;
        ntrialsNL_total = ntrialsNL_LSTR + ntrialsNL_RSTR;
        ntrialsL_total = ntrialsL_LSTR + ntrialsL_RSTR;
        
        description = 'RSTR + LSTR combined';
        xtext = 'Contra - Ipsi luminance';
        ytext = '%contra selected';
        
    case '91_80_combined'
        directory91 = sprintf('%s%s', root, '\Data\80_91\91_RACC\');
        load([directory91 '91_RACC_agg_perf.mat']);
        
        nleftNL_91 = nleftNL_total;
        nleftL_91 = nleftL_total;
        ntrialsNL_91 = ntrialsNL_total;
        ntrialsL_91 = ntrialsL_total;
        
        directory80 = sprintf('%s%s', root, '\Data\80_91\80_LACC\');
        load([directory80 '80_LACC_agg_perf.mat']);
        
        nleftNL_80 = nleftNL_total;
        nleftL_80 = nleftL_total;
        ntrialsNL_80 = ntrialsNL_total;
        ntrialsL_80 = ntrialsL_total;
        
        % Combine the two animals
        nleftNL_80 = flipud(ntrialsNL_80 - nleftNL_80);
        nleftL_80 = flipud(ntrialsL_80 - nleftL_80);
        ntrialsNL_80 = flipud(ntrialsNL_80);
        ntrialsL_80 = flipud(ntrialsL_80);
        
        nleftNL_total = nleftNL_80 + nleftNL_91;
        nleftL_total = nleftL_80 + nleftL_91;
        ntrialsNL_total = ntrialsNL_80 + ntrialsNL_91;
        ntrialsL_total = ntrialsL_80 + ntrialsL_91;
        
        description = '91 + 80 combined';
        xtext = 'Contra - Ipsi luminance';
        ytext = '%contra selected';
        
    otherwise
        error('Invalid mouse number');
end

%%
perfNL_total = nleftNL_total ./ ntrialsNL_total;
perfL_total = nleftL_total ./ ntrialsL_total;
colors = linspecer(2);
% Plot the aggregate performance
figure;
plot(luminanceL, perfL_total, 'o', 'Color', colors(1,:));
hold on
plot(luminanceNL, perfNL_total, 'o', 'Color', colors(2,:));



%% Do the psychometric fit
searchGrid.alpha = -1:.05:1;    %structure defining grid to
searchGrid.beta = 10.^(-1:.05:2); %search for initial values

fitlapse = 0;
if fitlapse
    % With lapse fit
    searchGrid.gamma = 0:.005:.1;
    searchGrid.lambda = 0:.005:.1;
    paramsFree = [1 1 1 1]; %[threshold slope guess lapse] 1: free, 0:fixed
    thresholdsfuller = 'unconstrained';  %Each condition gets own threshold
    slopesfuller = 'unconstrained';      %Each condition gets own slope
    guessratesfuller = 'unconstrained';          %Guess rate fixed
    lapseratesfuller = 'unconstrained';    %Common lapse rate
else
    % Without lapse
    searchGrid.gamma = 0;
    searchGrid.lambda = 0;
    paramsFree = [1 1 0 0];
    thresholdsfuller = 'unconstrained';  %Each condition gets own threshold
    slopesfuller = 'unconstrained';      %Each condition gets own slope
    guessratesfuller = 'fixed';          %Guess rate fixed
    lapseratesfuller = 'fixed';    %Common lapse rate
end

%Nelder-Mead search options
options = PAL_minimize('options');  %decrease tolerance (i.e., increase
options.TolX = 1e-09;              %precision).
options.TolFun = 1e-09;
options.MaxIter = 10000;
options.MaxFunEvals = 10000;

PF = @PAL_CumulativeNormal; % Function to fit to, can be @PAL_Logistic, @PAL_CumulativeNormal
lapseFit = 'naple';

%Fit fuller model
StimLevels = [luminanceNL; luminanceL];
NumPos = [nleftNL_total'; nleftL_total'];
OutOfNum = [ntrialsNL_total'; ntrialsL_total'];

paramsGuess = [0 2 0 0;
               -0.8 2 0 0];

[paramsFitted, LL, exitflag, ~, ~, numParamsFuller] = PAL_PFML_FitMultiple(StimLevels, NumPos, OutOfNum, ...
  paramsGuess, PF,'searchOptions',options,'lapserates',lapseratesfuller,'thresholds',thresholdsfuller,...
  'slopes',slopesfuller,'guessrates',guessratesfuller,'lapseLimits',[0 1],'lapseFit',lapseFit);

fprintf('\n');
fprintf('Thresholds: %4.3f, %4.3f\n', paramsFitted(1,1), paramsFitted(2,1));
fprintf('Slopes: %4.3f, %4.3f\n', paramsFitted(1,2), paramsFitted(2,2));
fprintf('Guess Rates: %4.3f, %4.3f\n', paramsFitted(1,3), paramsFitted(2,3));
fprintf('Lapse Rates: %4.3f, %4.3f\n', paramsFitted(1,4), paramsFitted(2,4));
fprintf('\n');
fprintf('Akaike''s Informaton Criterion: %4.3f\n', -2*LL + 2*numParamsFuller);
fprintf('Bayesian Informaton Criterion: %4.3f\n', -2*LL + log(sum(OutOfNum(:))) * numParamsFuller);
fprintf('\n');

% For single condition fit
% [paramsFittedNL, LLNL, exitflagNL] = PAL_PFML_Fit(luminanceNL, nleftNL_total', ntrialsNL_total', ...
%     searchGrid, paramsFree, PF,'lapseLimits',[0 1],'searchOptions',options,'lapseFit',lapseFit);
% 
% [paramsFittedL, LLL, exitflagL] = PAL_PFML_Fit(luminanceL, nleftL_total', ntrialsL_total', ...
%     searchGrid, paramsFree, PF,'lapseLimits',[0 1],'searchOptions',options,'lapseFit',lapseFit);

% if ~exitflagNL || ~exitflagL
%     disp('Psychometric Function Fit failed! Exiting...');
%     return
% end

l1 = plot(-1:.01:1,PF(paramsFitted(1,:),-1:.01:1),'-','color',colors(2,:),'linewidth',2);
hold on
l2 = plot(-1:.01:1,PF(paramsFitted(2,:),-1:.01:1),'-','color',colors(1,:),'linewidth',2);
legend([l1 l2], {'No laser', 'Laser'});

xlabel(xtext);
ylabel(ytext);
title(description);

ylim([0, 1])

%% Bootstrap for confidence interval
question = sprintf('\nDo you wish to perform a non-parametric bootstrap to obtain\nSEs for parameters of, say, the fuller model [y/n]? ');
wish = input(question,'s');
if strcmpi(wish,'y')
    B = input('Type desired number of simulations B (try low, things take a while): ');
    [SD, paramsSim, LLSim, converged, SDfunc, funcParamsSim] = PAL_PFML_BootstrapNonParametricMultiple(StimLevels, ...
        NumPos, OutOfNum, paramsFitted, B, PF,'searchOptions',options,'lapserates',lapseratesfuller,'thresholds',...
        thresholdsfuller,'slopes',slopesfuller,'guessrates',guessratesfuller,'lapseLimits',[0 1],'lapseFit',lapseFit);

    fprintf('SD for Thresholds: %4.3f, %4.3f\n', SD(1,1), SD(2,1));
    fprintf('SD for Slopes: %4.3f, %4.3f\n', SD(1,2), SD(2,2));
    fprintf('SD for Guess Rates: %4.3f, %4.3f\n', SD(1,3), SD(2,3));
    fprintf('SD for Lapse Rates: %4.3f, %4.3f\n', SD(1,4), SD(2,4));
end

% 95% confidence interval
% Remove trials where guess rates is <0
guessRates = squeeze(paramsSim(:,2, 3));
paramsSim_clean = paramsSim(guessRates >= 0, :, :);
for cond = 1:size(StimLevels,1)
    sim_array = squeeze(paramsSim_clean(:,cond, :));
    CIlow(cond, :) = prctile(sim_array, 2.5);
    CIhigh(cond, :) = prctile(sim_array, 97.5);
end
neg = paramsFitted - CIlow;
pos = CIhigh - paramsFitted;

%% Plot error bars
figure(5);
subplot(221)
errorbar([1 2], paramsFitted(:,1), neg(:,1), pos(:,1));
xlim([0 3]);
xticks([1 2])
xticklabels({'No laser', 'Laser'})
title('Thresholds');

subplot(222)
errorbar([1 2], paramsFitted(:,2), neg(:,2), pos(:,2));
xlim([0 3]);
xticks([1 2])
xticklabels({'No laser', 'Laser'})
title('Slopes');

subplot(223)
errorbar([1 2], paramsFitted(:,3), neg(:,3), pos(:,3));
xlim([0 3]);
xticks([1 2])
xticklabels({'No laser', 'Laser'})
title('Guess Rates');

subplot(224)
errorbar([1 2], paramsFitted(:,4), neg(:,4), pos(:,4));
xlim([0 3]);
xticks([1 2])
xticklabels({'No laser', 'Laser'})
title('Lapse Rates');