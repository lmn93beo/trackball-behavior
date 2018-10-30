folder = 'C:\Users\Sur lab\Dropbox (MIT)\trackball-behavior\Data';
mouse_file = '96\Oct2018\20181020_trackball_0096b.mat';
%mouse_file = '96\Sep2018\20180903_trackball_0096.mat';
%mouse_file = '96\Oct2018_noantibias\20181011_trackball_0096.mat';
%mouse_file = '102\20181018_trackball_0102.mat';

%human_file = '96\102318_to_102518_analysis_reward0-4\20181025_trackball_0096.mat';
mouse_file = '97\Oct2018\20181025_trackball_0097.mat';
%mouse_file = human_file;
%mouse_file = 'LMN\20181011_trackball_LMN.mat';

load(fullfile(folder, mouse_file));
mouse_data = data;
load(fullfile(folder, human_file));
human_data = data;

%%
[out_mouse, rt_mouse] = get_twostim_rt(mouse_data, 0);
[out_human, rt_human] = get_twostim_rt(human_data, 0);

%% Plot histogram
figure;
histogram(rt_mouse, 'BinWidth', 0.05, 'Normalization', 'probability');
hold on;


rt_human_short = rt_human(1:100);
histogram(rt_human, 'BinWidth', 0.05, 'Normalization', 'probability');
xlabel('Reaction time (s)')
ylabel('Probability')
legend({'Mouse', 'Human'})


%% Separate by correct/incorrect
choiceM = mouse_data.response.choice;
locM = data.stimuli.loc(1:numel(choiceM));

choiceH = human_data.response.choice;
locH = human_data.stimuli.loc(1:numel(choiceH));
correctH = choiceH == locH;
rt_corrH = rt_human(correctH);
rt_incorrH = rt_human(~correctH);

choiceM = mouse_data.response.choice;
locM = mouse_data.stimuli.loc(1:numel(choiceM));
correctM = choiceM == locM;
rt_corrM = rt_mouse(correctM);
rt_incorrM = rt_mouse(~correctM);
reward = mouse_data.response.reward;
rt_rew = rt_mouse(reward > 0);

choiceMgood = choiceM(choiceM ~= 6);
locMgood = locM(choiceM ~= 6);

choiceMbad = choiceM(choiceM == 6);
locMbad = locM(choiceM == 6);


figure;
[f1, x1] = ecdf(rt_corrM(rt_corrM < 2));
[f2, x2] = ecdf(rt_incorrM(rt_incorrM < 2));
histogram(rt_incorrM, 'BinWidth', 0.05, 'Normalization', 'probability');
hold on;
histogram(rt_rew, 'BinWidth', 0.05, 'Normalization', 'probability');
xlabel('Reaction time (s)');
legend({'Correct', 'Incorrect'});


% plot(x1, f1);
% hold on;
% plot(x2, f2);

%% Look at reaction times for each condition
ntrials = numel(mouse_data.response.choice);
conds = data.stimuli.opp_contrast(1:ntrials);
rt_mouse_a = rt_mouse(conds == 0);
rt_mouse_b = rt_mouse(conds == 0.16);
rt_mouse_c = rt_mouse(conds == 0.32);
rt_mouse_d = rt_mouse(conds == 0.48);

[f1, x1] = ecdf(rt_mouse_a);
[f2, x2] = ecdf(rt_mouse_b);
[f3, x3] = ecdf(rt_mouse_c);
[f4, x4] = ecdf(rt_mouse_d);

figure;
plot(x1, f1);
hold on;
plot(x2, f2);
plot(x3, f3);
plot(x4, f4);
xlabel('Reaction time (s)')
ylabel('Probability')
legend()


%% Mouse vs human ecdf, again
[fmouse, xmouse] = ecdf(rt_mouse(rt_mouse < 2));
[fhuman, xhuman] = ecdf(rt_human(rt_human < 2));
figure;
plot(xmouse, fmouse);
hold on;
plot(xhuman, fhuman);











