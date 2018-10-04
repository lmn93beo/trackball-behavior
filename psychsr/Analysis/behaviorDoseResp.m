lick = data.response.n_hits;
laser = double(data.stimuli.laser_on(3:3:end)>0);

ntrials = max([length(lick), length(laser)]);
lick = lick(1:ntrials);
laser = laser(1:ntrials);

ctr = 1;
for i = 1:ntrials
    if laser(i) > 0
        laser(i)= mod(ctr-1,5)+1;
        ctr = ctr+1;
    end
end

perf = zeros(1,6);
for i = 1:6
    perf(i) = mean(lick(laser == i-1));
end

plot(perf)
ylim([0,1])
set(gca,'XTick',1:6)
set(gca,'XTickLabel',{'0','4','8','16','32','64'})