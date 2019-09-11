close all;
moviedurs = [trials.stims];
moviedurs = moviedurs(1:2:end);

correct = zeros(size(trials));
correct(moviedurs<3.5 & [trials.rewarded]) = 1;
figure; hold on;
plot(moviedurs)
plot(find(correct),3*ones(sum(correct),1),'*r')
title(sprintf('%d correct out of %d (%2.1f%%)',sum(correct),length(trials),...
    sum(correct)/length(trials)*100))

f = fieldnames(trials);
for i = 1:length(trials)
    mstop = trials(i).stims(1);    
    trials(i).start_time2 = -mstop;
    for k = 2:8
        trials(i).(strcat(f{k},'2')) = trials(i).(f{k})-mstop;
    end
end

figure; subplot(2,1,1)
blankrewards = [trials.rewards2];
hist(blankrewards,20)

subplot(2,1,2)
correctrewards = [trials(correct==1).rewards2];
hist(correctrewards,20)