folder = 'C:\Users\Sur lab\Dropbox (MIT)\trackball-behavior\Data';
mouse_file = '96\Jan2019\20190101_trackball_0096.mat';

load(fullfile(folder, mouse_file));
mouse_data = data;

%%
[out_mouse, rt_mouse] = get_twostim_rt(mouse_data, 0);

%% Plot histogram
figure;
histogram(rt_mouse(1:2:end), 'BinWidth', 0.15, 'Normalization', 'probability');
hold on;
histogram(rt_mouse(2:2:end), 'BinWidth', 0.15, 'Normalization', 'probability');

xlabel('Reaction time (s)')
ylabel('Probability')
legend({'Right', 'Left'})


%% Separate by correct/incorrect
choiceM = mouse_data.response.choice;
locM = mouse_data.stimuli.loc(1:numel(choiceM));

plot(rt_mouse(1:2:end));
hold on
plot(rt_mouse(2:2:end));
xlabel('Trial')
ylabel('RT (s)');


%% Performance
choiceM = mouse_data.response.choice;
locM = mouse_data.stimuli.loc(1:numel(choiceM));

%L choice
perfL = sum(choiceM(1:2:end) == locM(1:2:end)) / numel(choiceM(1:2:end))
perfR = sum(choiceM(2:2:end) == locM(2:2:end)) / numel(choiceM(2:2:end))










