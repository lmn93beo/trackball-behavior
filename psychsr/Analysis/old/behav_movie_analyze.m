%% load data
clear all; close all; clc;
[file, dir] = uigetfile;

cd(dir)
load(file)
numstims = input('Number of stims per trial: ');

licks = data.response.licks;    
stims = data.presentation.stim_times;
duration = data.stimuli.total_duration;
rewards = data.response.rewards;
punishs = data.response.punishs;
tones = data.response.tones;

% fix a bug
i_fix = find(diff(tones)<4)+1;
tones(i_fix) = tones(i_fix)+4;
  
k = [];
for i = 1:length(rewards)
    if max(licks == rewards(i)) == 0
        k(end+1) = i;
    end
end
primes = rewards(k);
truerewards = rewards;
truerewards(k) = [];

% check number of licks
totaldata = data.response.totaldata;
fs = data.card.ai_fs;
templicks = (find(diff(totaldata)>1)+1)/fs;
if length(templicks)~=length(licks)
    disp('Unequal lick counts.')
end

% find lick onsets
window = 1/3; % ignore all licks faster than 3 Hz
lickonsets = licks([true,diff(licks)>window]);

%% make trials
trials = struct([]);

for i = 1:length(tones)-1
    j = find(stims>=tones(i),1);
    trials(i).start_time = tones(i);
    
    if stims(j) == tones(i) % normal trial
        trials(i).end_time = stims(j+numstims);
        trials(i).stims = stims(j+1:j+numstims);
        if tones(i+1) < stims(j+numstims) % if next trial is abort
            trials(i).end_time = tones(i+1);
            trials(i).stims(numstims) = tones(i+1);
        end
    else % abort trial 
        trials(i).end_time = tones(i+1);
        trials(i).stims = tones(i+1);
    end
    
	trials(i).licks = licks(licks>tones(i) & licks<=max(trials(i).stims));
    trials(i).lickonsets = lickonsets(lickonsets>tones(i) & lickonsets<=max(trials(i).stims));
    trials(i).rewards = truerewards(truerewards>tones(i) & truerewards<=max(trials(i).stims));
    trials(i).primes = primes(primes>tones(i) & primes<=max(trials(i).stims));
    trials(i).punishs = punishs(punishs>tones(i) & punishs<=max(trials(i).stims));
    
    trials(i).n_licks = length(trials(i).licks);
    trials(i).n_onsets = length(trials(i).lickonsets);
    trials(i).licked = ~isempty(trials(i).licks);
    trials(i).rewarded = ~isempty(trials(i).rewards);    
    trials(i).primed = i*ones(~isempty(trials(i).primes));
    trials(i).punished = ~isempty(trials(i).punishs);    
    trials(i).aborted = (length(trials(i).stims)==1);
    if trials(i).aborted || ~isempty(trials(i).primed)
        trials(i).rewarded = NaN;
    end
    
    trials(i).trialnums = i*ones(size(trials(i).licks));
    trials(i).trialnums2 = i*ones(size(trials(i).lickonsets));
    
    % make all times relative to start
    f = fieldnames(trials);
    for k = 2:8
        trials(i).(f{k}) = trials(i).(f{k}) - tones(i);
    end    
    
end

%% plot lick burst frequency histogram
burstfreq = 1./diff(licks);
[n, xout] = hist(burstfreq,50);
figure;
bar(xout,n);
[a i] = max(n);
freq = xout(i);
title(sprintf('mode = %4.1f Hz',freq))

%% rasters

moviedur = input('Movie duration: ');

figure; subplot(211); hold on;
plot([trials.licks],-[trials.trialnums],'.')
plot([trials.lickonsets],-[trials.trialnums2],'.r')
plot([trials.end_time],-(1:length(trials)),'.g')
plot([moviedur moviedur],[-length(trials) 0],'--k');
axis([0 6 -length(trials) 0]);

subplot(212); hold on;
plot([trials.lickonsets],-[trials.trialnums2],'.r')
plot([trials.end_time],-(1:length(trials)),'.g')
plot([moviedur moviedur],[-length(trials) 0],'--k');
axis([0 6 -length(trials) 0]);

%% lick onset histogram
n = 12;
axisy = 30;

onsets = cell(15,1);
% trials = trials(1:200);

for i = 1:length(trials)
    onsets{1} = [onsets{1},trials(i).lickonsets];
    q = floor((i-1)/ceil(length(trials)/4)) + 2;
    onsets{q} = [onsets{q},trials(i).lickonsets];    
    
    if ~trials(i).aborted 
        onsets{6} = [onsets{6},trials(i).lickonsets];
        q = floor((i-1)/ceil(length(trials)/4)) + 7;
        onsets{q} = [onsets{q},trials(i).lickonsets];
    else
        onsets{11} = [onsets{11},trials(i).lickonsets];
        q = floor((i-1)/ceil(length(trials)/4)) + 12;
        onsets{q} = [onsets{q},trials(i).lickonsets];
    end
end

figure
for i = 1%:3
    %subplot(6,3,[i i+3])
    subplot(4,2,[1 3 5 7])
    hold on
    x = onsets{i*5-4}(onsets{i*5-4}<=6);
    hist(x,n)
    plot([moviedur moviedur],ylim,'--r');
%     plot([4 4],ylim,'--r');
    xlim([0 6])
    title(sum(onsets{i*5-4}>=moviedur & onsets{i*5-4}<6)/sum(onsets{i*5-4}<moviedur)*(6-moviedur)/moviedur)
end

k = 7;
for i = 1:4
    for j = 1%:3
        %subplot(6,3,k)
        subplot(4,2,i*2)
        hold on
        k = k+1;
        x = onsets{j*5+i-4}(onsets{j*5+i-4}<=6);
        hist(x,n), axis([0 6 0 axisy])
        plot([moviedur moviedur],ylim,'--r');
%         plot([4 4],ylim,'--r');
        xlim([0 6])
        
        title(sum(onsets{j*5+i-4}>=moviedur & onsets{j*5+i-4}<6)/sum(onsets{j*5+i-4}<moviedur)*(6-moviedur)/moviedur)
    end
end

% figure
% subplot(2,1,1)
% hist(onsets{1}(onsets{1}<2),40)
% subplot(2,1,2)
% hist(onsets{1}(onsets{1}>2 & onsets{1}<4),40)

%% licks

n = 36;
axisy = 90;

onsets = cell(15,1);
for i = 1:length(trials)
    onsets{1} = [onsets{1},trials(i).licks];
    q = floor((i-1)/ceil(length(trials)/4)) + 2;
    onsets{q} = [onsets{q},trials(i).licks];    
    
    if ~trials(i).aborted 
        onsets{6} = [onsets{6},trials(i).licks];
        q = floor((i-1)/ceil(length(trials)/4)) + 7;
        onsets{q} = [onsets{q},trials(i).licks];
    else
        onsets{11} = [onsets{11},trials(i).licks];
        q = floor((i-1)/ceil(length(trials)/4)) + 12;
        onsets{q} = [onsets{q},trials(i).licks];
    end
end

figure
for i = 1%:3
    %subplot(6,3,[i i+3])
    subplot(4,2,[1 3 5 7])
    hold on
    x = onsets{i*5-4}(onsets{i*5-4}<=6);
    hist(x,n), %axis tight
    plot([moviedur moviedur],ylim,'--r');
%     plot([4 4],ylim,'--r');
    xlim([0 6])

    title(sum(onsets{i*5-4}>=moviedur & onsets{i*5-4}<6)/sum(onsets{i*5-4}<moviedur)*(6-moviedur)/moviedur)
end

k = 7;
for i = 1:4
    for j = 1%:3
        %subplot(6,3,k)
        subplot(4,2,i*2)
        hold on
        k = k+1;
        x = onsets{j*5+i-4}(onsets{j*5+i-4}<=6);
        hist(x,n), axis([0 6 0 axisy])
        plot([moviedur moviedur],ylim,'--r');
%         plot([4 4],ylim,'--r');        
        title(sum(onsets{j*5+i-4}>=moviedur & onsets{j*5+i-4}<6)/sum(onsets{j*5+i-4}<moviedur)*(6-moviedur)/moviedur)
    end
end

%% performance over time
% figure
% n = 20;
% 
% % fix reward percentage
% rew = [trials.rewarded];
% rew = smooth(rew(~isnan(rew)),n);
% ab = sort(union(find([trials.aborted]),find([trials.primed])));
% for i = 1:length(ab)
%     rew(ab(i):end+1) = [rew(ab(i));rew(ab(i):end)];
% end
% 
% % remove trials that were also punished
% rew2 = [trials.rewarded];
% rewpun = find(rew2.*[trials.punished]);
% rew2(rewpun) = 0;
% rew2 = smooth(rew2(~isnan(rew2)),n);
% for i = 1:length(ab)
%     rew2(ab(i):end+1) = [rew2(ab(i));rew2(ab(i):end)];
% end
% 
% subplot(4,1,[1 2])
% plot(smooth([trials.licked],n),':k')
% hold all, axis tight
% plot(rew)
% plot(rew2)
% plot(smooth([trials.punished],n))
% plot(smooth([trials.aborted],n))
% plot([trials.primed],0.5*ones(size([trials.primed])),'.')
% legend('Lick%','Reward %','True Reward %','Punish %','Abort %','Primes')
% 
% subplot(4,1,3); hold on;
% plot(smooth([trials.n_licks],n),'k'), axis tight
% plot([trials.primed],mean(ylim)*ones(size([trials.primed])),'.g')
% 
% subplot(4,1,4); hold on;
% plot(smooth([trials.n_onsets],n),'k'), axis tight
% plot([trials.primed],mean(ylim)*ones(size([trials.primed])),'.g')
