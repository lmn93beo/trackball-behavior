folder = 'C:\Users\Sur lab\Dropbox (MIT)\trackball-behavior\Data';
mouse_file = '96\Jan2019\20190119_trackball_0096.mat';

load(fullfile(folder, mouse_file));
mouse_data = data;

%%
[out_mouse, rt_mouse] = get_twostim_rt(mouse_data, 0);

%% Plot histogram
choice = mouse_data.response.choice;
loc = mouse_data.stimuli.loc(1:numel(choiceM));

% Performance
% 1 means contrast = 0 (go left), 2 means contrast = 1 (go right)
perf_r = sum(loc == 2 & choice == 2)/(sum(loc == 2));
    
perf_l = sum(loc == 1 & choice == 1)/(sum(loc == 1));


%% Histogram
figure;
histogram(rt_mouse(loc == 2), 'BinWidth', 0.15, 'Normalization', 'probability');
hold on;
histogram(rt_mouse(loc == 1), 'BinWidth', 0.15, 'Normalization', 'probability');

xlabel('Reaction time (s)')
ylabel('Probability')
legend({'1', '2', '3', '4'})


%% Scatter plot
rt_left = rt_mouse(loc == 2);
rt_right = rt_mouse(loc == 1);
plot(ones(1, numel(rt_left)) + 0.1 * rand(1, numel(rt_left)) - 0.05, rt_left, 'b.', ...
    'MarkerSize', 8);
hold on
plot(2 * ones(1, numel(rt_right)) + 0.1 * rand(1, numel(rt_right)) - 0.05, rt_right, 'b.',...
    'MarkerSize', 8);

xlim([0 3])
xticks(gca,[1 2 3 4 6 7 8 9])
xticklabels(gca, {'Right', 'Left'})
ylabel('Reaction time (s)')
set(gca, 'FontSize', 20)


%% Swarm plot
data = [randn(50,1);randn(50,1)+3.5]*[1 1];
catIdx = [ones(50,1);zeros(50,1);randi([0,1],[100,1])];

data = rt_mouse;
catIdx = choice;
figure
plotSpread(data,'categoryIdx',catIdx,...
    'categoryMarkers',{'o','+'},'categoryColors',{'r','b'})


%% Separate by correct/incorrect
choiceM = mouse_data.response.choice;
locM = mouse_data.stimuli.loc(1:numel(choiceM));

plot(rt_mouse(1:4:end));
hold on
plot(rt_mouse(2:4:end));
plot(rt_mouse(3:4:end));
plot(rt_mouse(4:4:end));
xlabel('Trial')
ylabel('RT (s)');
legend({'1', '2', '3', '4'});

%% Plot point distribution
first1 = rt_mouse(1:4:160);
second1 = rt_mouse(2:4:160);
third1 = rt_mouse(3:4:160);
fourth1 = rt_mouse(4:4:160);

first2 = rt_mouse(161:4:end);
second2 = rt_mouse(162:4:end);
third2 = rt_mouse(163:4:end);
fourth2 = rt_mouse(164:4:end);

plot(ones(1, numel(first1)) + 0.1 * rand(1, numel(first1)), first1, 'b.');
hold on
plot(2 * ones(1, numel(second1)) + 0.1 * rand(1, numel(second1)), second1, 'b.');
plot(3 * ones(1, numel(third1)) + 0.1 * rand(1, numel(third1)), third1, 'b.');
plot(4 * ones(1, numel(fourth1)) + 0.1 * rand(1, numel(fourth1)), fourth1, 'b.');


plot(6 * ones(1, numel(first2)) + 0.1 * rand(1, numel(first2)) - 0.05, first2, 'r.');
hold on
plot(7 * ones(1, numel(second2)) + 0.1 * rand(1, numel(second2))- 0.05, second2, 'r.');
plot(8 * ones(1, numel(third2)) + 0.1 * rand(1, numel(third2))- 0.05, third2, 'r.');
plot(9 * ones(1, numel(fourth2)) + 0.1 * rand(1, numel(fourth2)) - 0.05, fourth2, 'r.');
xticks(gca,[1 2 3 4 6 7 8 9])
xticklabels(gca, {'1', '2', '3', '4', '1', '2', '3', '4'})
ylabel('Reaction time (s)')
set(gca, 'FontSize', 20)
%% Look at mean reaction times
mean(first1)
mean(second1)
mean(third1)
mean(fourth1)

mean(first2)
mean(second2)
mean(third2)
mean(fourth2)

std(first2)
std(second2)
std(third2)
std(fourth2)



%% Now look at performance
firstChoice1 = choiceM(1:4:160);
secondChoice1 = choiceM(2:4:160);
thirdChoice1 = choiceM(3:4:160);
fourthChoice1 = choiceM(4:4:160);

firstChoice2 = choiceM(161:4:end);
secondChoice2 = choiceM(162:4:end);
thirdChoice2 = choiceM(163:4:end);
fourthChoice2 = choiceM(164:4:end);

%% Plot performance of each
perfFirst1 = sum(firstChoice1 == 2) / numel(firstChoice1)
perfSecond1 = sum(secondChoice1 == 1) / numel(secondChoice1)
perfThird1 = sum(thirdChoice1 == 2) / numel(thirdChoice1)
perfFourth1 = sum(fourthChoice1 == 1) / numel(fourthChoice1)

perfFirst2 = sum(firstChoice2 == 2) / numel(firstChoice2)
perfSecond2 = sum(secondChoice2 == 1) / numel(secondChoice2)
perfThird2 = sum(thirdChoice2 == 2) / numel(thirdChoice2)
perfFourth2 = sum(fourthChoice2 == 1) / numel(fourthChoice2)

%% Plot rt only for correct trial
% Correct trials
first_rt_corr1 = first1(firstChoice1 == 2);
second_rt_corr1 = second1(secondChoice1 == 1);
third_rt_corr1 = third1(thirdChoice1 == 2);
fourth_rt_corr1 = fourth1(fourthChoice1 == 1);

first_rt_corr2 = first2(firstChoice2 == 2);
second_rt_corr2 = second2(secondChoice2 == 1);
third_rt_corr2 = third2(thirdChoice2 == 2);
fourth_rt_corr2 = fourth2(fourthChoice2 == 1);

plot(ones(1, numel(first_rt_corr1)) + 0.1 * rand(1, numel(first_rt_corr1)), first_rt_corr1, 'b.');
hold on
plot(2 * ones(1, numel(second_rt_corr1)) + 0.1 * rand(1, numel(second_rt_corr1)), second_rt_corr1, 'b.');
plot(3 * ones(1, numel(third_rt_corr1)) + 0.1 * rand(1, numel(third_rt_corr1)), third_rt_corr1, 'b.');
plot(4 * ones(1, numel(fourth_rt_corr1)) + 0.1 * rand(1, numel(fourth_rt_corr1)), fourth_rt_corr1, 'b.');

plot(6 * ones(1, numel(first_rt_corr2)) + 0.1 * rand(1, numel(first_rt_corr2)), first_rt_corr2, 'b.');
plot(7 * ones(1, numel(second_rt_corr2)) + 0.1 * rand(1, numel(second_rt_corr2)), second_rt_corr2, 'b.');
plot(8 * ones(1, numel(third_rt_corr2)) + 0.1 * rand(1, numel(third_rt_corr2)), third_rt_corr2, 'b.');
plot(9 * ones(1, numel(fourth_rt_corr2)) + 0.1 * rand(1, numel(fourth_rt_corr2)), fourth_rt_corr2, 'b.');


% Incorrect trials
first_rt_incorr1 = first1(firstChoice1 == 1);
second_rt_incorr1 = second1(secondChoice1 == 2);
third_rt_incorr1 = third1(thirdChoice1 == 1);
fourth_rt_incorr1 = fourth1(fourthChoice1 == 2);

first_rt_incorr2 = first2(firstChoice2 == 1);
second_rt_incorr2 = second2(secondChoice2 == 2);
third_rt_incorr2 = third2(thirdChoice2 == 1);
fourth_rt_incorr2 = fourth2(fourthChoice2 == 2);

plot(ones(1, numel(first_rt_incorr1)) + 0.1 * rand(1, numel(first_rt_incorr1)), first_rt_incorr1, 'r.');
hold on
plot(2 * ones(1, numel(second_rt_incorr1)) + 0.1 * rand(1, numel(second_rt_incorr1)), second_rt_incorr1, 'r.');
plot(3 * ones(1, numel(third_rt_incorr1)) + 0.1 * rand(1, numel(third_rt_incorr1)), third_rt_incorr1, 'r.');
plot(4 * ones(1, numel(fourth_rt_incorr1)) + 0.1 * rand(1, numel(fourth_rt_incorr1)), fourth_rt_incorr1, 'r.');

plot(6 * ones(1, numel(first_rt_incorr2)) + 0.1 * rand(1, numel(first_rt_incorr2)), first_rt_incorr2, 'r.');
plot(7 * ones(1, numel(second_rt_incorr2)) + 0.1 * rand(1, numel(second_rt_incorr2)), second_rt_incorr2, 'r.');
plot(8 * ones(1, numel(third_rt_incorr2)) + 0.1 * rand(1, numel(third_rt_incorr2)), third_rt_incorr2, 'r.');
plot(9 * ones(1, numel(fourth_rt_incorr2)) + 0.1 * rand(1, numel(fourth_rt_incorr2)), fourth_rt_incorr2, 'r.');




