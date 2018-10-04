%% how to know if mouse has learned?
% blank-reward association
% lick onset histogram --> does the mouse respond with some latency to the
% end of the movie?

clear all; clc
[trials licks lickonsets] = loaddata(3);

maxmovie = 5;
minmovie = 3;
blanktime = 2;

trials2 = trials(~[trials.aborted]);
trials3 = trials([trials.aborted]);

%% plots
close all; 

% trials = trials(1:350);

% % lick-bout-interval histogram
% bouts = diff(licks);
% bouts(bouts<0.5 | bouts>20) = [];
% [n, xout] = hist(bouts,50);
% figure;
% bar(xout,n);
% [a i] = max(n(2:end));
% freq = xout(i+1);
% title(sprintf('mode = %2.2f s',freq))
% 
% % lick burst frequency histogram
% burstfreq = 1./diff(licks);
% [n, xout] = hist(burstfreq,50);
% figure;
% bar(xout,n);
% [a i] = max(n);
% freq = xout(i);
% title(sprintf('mode = %4.1f Hz',freq))

% % raster
% figure; 
% subplot(211); hold on;
% plot([trials.licks2],-[trials.trialnums],'.')
% plot([trials.lickonsets2],-[trials.trialnums2],'.r')
% plot([0 0],[-length(trials) 0],'--k');
% axis([-maxmovie blanktime -length(trials) 0]);
% subplot(212); hold on;
% plot([trials.lickonsets2],-[trials.trialnums2],'.r')
% plot([0 0],[-length(trials) 0],'--k');
% axis([-maxmovie blanktime -length(trials) 0]);

% raster
figure; 
subplot(211); hold on;
plot([trials2.licks2],-[trials2.trialnums],'.')
plot([trials2.lickonsets2],-[trials2.trialnums2],'.r')
plot([0 0],[-length(trials) 0],'--k');
axis([-maxmovie blanktime -length(trials) 0]);
subplot(212); hold on;
plot([trials2.lickonsets2],-[trials2.trialnums2],'.r')
plot([0 0],[-length(trials) 0],'--k');
axis([-maxmovie blanktime -length(trials) 0]);

% subplot(222); hold on;
% plot([trials3.licks],-[trials3.trialnums],'.')
% plot([trials3.lickonsets],-[trials3.trialnums2],'.r')
% plot([0 0],[-length(trials) 0],'--k');
% % axis([-maxmovie blanktime -length(trials) 0]);
% subplot(224); hold on;
% plot([trials3.lickonsets],-[trials3.trialnums2],'.r')
% plot([0 0],[-length(trials) 0],'--k');
% % axis([-maxmovie blanktime -length(trials) 0]);

% lick histograms
nbins = 36;
figure; 
subplot(4,2,1:2:7); hold on;
hist([trials.licks2],nbins)
title('Lick Histograms')
plot([0 0],ylim,'--r')
xlim([-maxmovie blanktime])
q = length(trials)/4;
for i = 1:4
    subplot(4,2,2*i); hold on;
    
    block = 1+round((i-1)*q):round(i*q);
    
    stimtimes = [trials2(block).stims];
    movietimes = stimtimes(1:3:end);
    blanktimes = stimtimes(2:3:end)-movietimes;
    
    blicks = [trials2(block).licks2];
    prob_m(i) = sum(blicks<0)/sum(movietimes);
    prob_b(i) = sum(blicks>=0 & blicks<=2)/sum(blanktimes);
    
    hist(blicks,nbins)
    if i == 1, axis tight; y = ylim; end;
    ylim(y)
    plot([0 0],ylim,'--r')
    xlim([-maxmovie blanktime])    
end


% lickonset histograms
nbins = 27;
figure; 
subplot(4,2,1:2:7); hold on;
hist([trials2.lickonsets2],nbins)
title('Lick Onset Histograms (Not aborted)')
plot([0 0],ylim,'--r')
xlim([-maxmovie blanktime])
q = length(trials2)/4;
for i = 1:4
    subplot(4,2,2*i); hold on;
    block = 1+round((i-1)*q):round(i*q);
    
    stimtimes = [trials2(block).stims];
    movietimes = stimtimes(1:3:end);
    blanktimes = stimtimes(2:3:end)-movietimes;
    
    blickonsets = [trials2(block).lickonsets2];
    prob_m2(i) = sum(blickonsets<0)/sum(movietimes);
    prob_b2(i) = sum(blickonsets>=0 & blickonsets<=2)/sum(blanktimes);
    
    hist(blickonsets,nbins)
    if i == 1, axis tight; y = ylim; end;
    ylim(y)
    plot([0 0],ylim,'--r')
    xlim([-maxmovie blanktime])   
        
end

figure; hold all;
title('Licks per second')
xlabel('Quartile of Trials')
plot(prob_m,'*-')
plot(prob_b,'*-')
legend('Movie','Grating')


figure; hold all;
title('Lickonsets per second')
xlabel('Quartile of Trials')
plot(prob_m2,'*-')
plot(prob_b2,'*-')
legend('Movie','Grating')

% nbins = 27;
% figure; 
% subplot(4,2,1:2:7); hold on;
% hist([trials3.lickonsets],nbins)
% title('Lick Onset Histograms (Aborted)')
% plot([0 0],ylim,'--r')
% % xlim([-maxmovie blanktime])
% q = length(trials3)/4;
% for i = 1:4
%     subplot(4,2,2*i); hold on;
%     hist([trials3(1+round((i-1)*q):round(i*q)).lickonsets],nbins)
%     if i == 1, axis tight; y = ylim; end;
%     ylim(y)
%     plot([0 0],ylim,'--r')
% %     xlim([-maxmovie blanktime])   
%         
% end

% % lick histograms (aligned to movie onset)
% nbins = 36;
% figure; 
% subplot(4,2,1:2:7); hold on;
% hist([trials.licks],nbins)
% title('Lick Histograms')
% plot([0 0],ylim,'--r')
% xlim([0 minmovie])
% q = length(trials)/4;
% for i = 1:4
%     subplot(4,2,2*i); hold on;
%     hist([trials(1+round((i-1)*q):round(i*q)).licks],nbins)
%     if i == 1, axis tight; y = ylim; end;
%     ylim(y)
%     plot([0 0],ylim,'--r')
%     xlim([0 minmovie])    
% end
% 
% % lickonset histograms (aligned to movie onset)
% nbins = 27;
% figure; 
% subplot(4,2,1:2:7); hold on;
% hist([trials.lickonsets],nbins)
% title('Lick Onset Histograms')
% plot([0 0],ylim,'--r')
% xlim([0 minmovie])
% q = length(trials)/4;
% for i = 1:4
%     subplot(4,2,2*i); hold on;
%     hist([trials(1+round((i-1)*q):round(i*q)).lickonsets],nbins)
%     if i == 1, axis tight; y = ylim; end;
%     ylim(y)
%     plot([0 0],ylim,'--r')
%     xlim([0 minmovie])    
% end

% count licks during delay period
for i = 1:length(trials)
    % licked in the first second of movie?
    trials(i).delay1 = ~isempty(find(trials(i).licks<=blanktime,1));
    
    % licked in the last second of movie?
    trials(i).delay2 = ~isempty(find(trials(i).licks2>=-blanktime & trials(i).licks2<0,1));
    
    % licked in the movie?
    trials(i).delay3 = ~isempty(find(trials(i).licks2<0,1));
    
    trials(i).correct1 = ~trials(i).delay1 && trials(i).rewarded == 1;
    trials(i).correct2 = ~trials(i).delay2 && trials(i).rewarded == 1;;
    trials(i).correct3 = ~trials(i).delay3 && trials(i).rewarded == 1;
end

% fix reward percentage
n = 50;
hits = [trials.rewarded];
hits = hits(~isnan(hits));
rew = smooth(hits,n);
ab = find([trials.aborted]);
% ab = sort(union(find([trials.aborted]),find([trials.primed])));
for i = 1:length(ab)
    if ab(i)<length(rew)
        rew(ab(i):end+1) = [rew(ab(i));rew(ab(i):end)];
    else
        rew(end+1) = rew(end);
    end
end

% plot reward, lick, correct percentages
titles = {'first 2s','last 2s','whole movie'};
for i = 2 %1:3
    delay = [trials.(sprintf('delay%d',i))];
    correct = [trials.(sprintf('correct%d',i))];
    figure; 
    hold all;  
    plot(smooth([trials.onset],n))
    plot(rew)
    plot(smooth(delay,n))
    plot(smooth(correct,n))
    plot([trials.primetrials],0.5*ones(size([trials.primetrials])),'.')
    title(sprintf('Smoothed over %d trials (FP in %s)',n,titles{i}))
    legend(sprintf('Onset: %2d%%',round(100*sum([trials.onset])/length(trials))),...
        sprintf('Hit: %2d%%',round(100*sum(hits)/length(hits))),...
        sprintf('FP: %2d%%',round(100*sum(delay)/length(trials))),...
        sprintf('Correct: %2d%%',round(100*sum(correct)/length(trials))))
    ylim([0 1])
end
