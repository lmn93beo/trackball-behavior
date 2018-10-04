files = uigetfile('*.mat','MultiSelect','On');

stim = [];
choice = [];
day = [];

for f = 1:length(files)
    load(files{f})    
    if isfield(data,'choice')
        choice = cat(2,choice,data.choice);
        ntrials = length(data.choice);
    else
        choice = cat(2,choice,data.response.choice);
        ntrials = length(data.response.choice);
    end
    stim = cat(2,stim,data.stimuli.loc(1:ntrials));
    day = cat(2,day,repmat(datenum(files{f},'yyyymmdd'),1,ntrials));
end

correct = choice==stim;
timeout = choice==5;

day_transitions = find(diff(day)>0);

close all
figure
hold on
plot(smooth(correct(~timeout),50)) % performance
axis tight
plot(xlim,[0.5 0.5],':k')
ylim([0 1])
ylabel('Performance (all trials)')
xlabel('Trials')
for i = 1:length(day_transitions)
    plot(day_transitions(i)*[1 1],ylim,'--r')
end

figure
hold on
plot(smooth(choice(~timeout)==2,50)) % bias
axis tight
plot(xlim,[0.5 0.5],':k')
ylim([0 1])
ylabel('Bias (% rightward)')
xlabel('Trials')
for i = 1:length(day_transitions)
    plot(day_transitions(i)*[1 1],ylim,'--r')
end