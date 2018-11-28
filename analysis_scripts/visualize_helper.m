clf;
choice = data.response.choice;
ntrials = numel(choice);
stim = data.stimuli.loc(1:ntrials);
trialstart = data.response.trialstart;

% First plot the time-outs
timeouts = find(choice == 5);
plot(trialstart(timeouts), stim(timeouts), 'ko', 'MarkerFaceColor', 'k');
hold on
        
% Plot the correct trials
corr = find(choice ~= 5 & stim == choice);
incorr = find(choice ~= 5 & stim ~= choice);
plot(trialstart(corr), stim(corr), 'bo', 'MarkerFaceColor', 'b');
plot(trialstart(incorr), stim(incorr), 'ro', 'MarkerFaceColor', 'r');

% Visualize the behavior
xlabel('Trial #');
set(gcf, 'Position', [200 300 1500 500])
set(gca, 'PlotBoxAspectRatio', [30 10 1]);
set(gca, 'OuterPosition', [0. 0 1 1]);
set(gca,'YTick', [1, 2])
set(gca,'YTickLabel',{'Left','Right'})