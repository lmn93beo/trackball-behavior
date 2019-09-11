folder = 'C:\Users\Sur lab\Dropbox (MIT)\trackball-behavior\Data';
mouse_file = '96\Jan2019\20190124_trackball_0096.mat';

load(fullfile(folder, mouse_file));
mouse_data = data;

%%
[out_mouse, rt_mouse] = get_twostim_rt(mouse_data, 0);

%% Plot histogram
figure;
histogram(rt_mouse(1:4:end), 'BinWidth', 0.15, 'Normalization', 'probability');
hold on;
histogram(rt_mouse(2:4:end), 'BinWidth', 0.15, 'Normalization', 'probability');
histogram(rt_mouse(3:4:end), 'BinWidth', 0.15, 'Normalization', 'probability');
histogram(rt_mouse(4:4:end), 'BinWidth', 0.15, 'Normalization', 'probability');



xlabel('Reaction time (s)')
ylabel('Probability')
legend({'1', '2', '3', '4'})


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
partition = 100;

first1 = rt_mouse(1:4:partition);
second1 = rt_mouse(2:4:partition);
third1 = rt_mouse(3:4:partition);
fourth1 = rt_mouse(4:4:partition);

first2 = rt_mouse((partition + 1):4:end);
second2 = rt_mouse((partition + 2):4:end);
third2 = rt_mouse((partition + 3):4:end);
fourth2 = rt_mouse((partition + 4):4:end);

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
firstChoice1 = choiceM(1:4:partition);
secondChoice1 = choiceM(2:4:partition);
thirdChoice1 = choiceM(3:4:partition);
fourthChoice1 = choiceM(4:4:partition);

firstChoice2 = choiceM((partition + 1):4:end);
secondChoice2 = choiceM((partition + 2):4:end);
thirdChoice2 = choiceM((partition + 3):4:end);
fourthChoice2 = choiceM((partition + 4):4:end);

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




