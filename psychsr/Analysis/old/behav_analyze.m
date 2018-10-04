%% extract data into trials
clear all; close all; clc;
[file, dir] = uigetfile;

cd(dir)
load(file)

licks = data.response.licks;    
stims = data.presentation.stim_times;
orients = data.stimuli.orientation;
duration = data.stimuli.total_duration;
rewards = data.response.rewards;
punishs = data.response.punishs;

k = [];
for i = 1:length(rewards)
    if max(licks == rewards(i)) == 0
        k(end+1) = i;
    end
end
truerewards = rewards;
truerewards(k) = [];

% check number of licks
totaldata = data.response.totaldata;
fs = data.card.ai_fs;
templicks = (find(diff(totaldata)>1)+1)/fs;
if length(templicks)~=length(licks)
    disp('Unequal lick counts.')
end

% fix a bug
stims(stims==0) = stims(find(stims==0)+1);
orients = orients(1:length(stims));

% find lick onsets
window = 1/3; % all licks faster than 3 Hz
lickonsets = licks([true,diff(licks)>window]);

% iterate trials
trials = struct([]);
for i = 1:floor((length(stims)-1)/3)        
    trials(i).start_time = stims(3*i-2);
    trials(i).stims = stims((3*i-1):(3*i+1))-stims(3*i-2);
    trials(i).orients = orients((3*i-1):(3*i+1));
    
    trials(i).licks = licks(licks>stims(3*i-2) & licks<=stims(3*i+1));        
    trials(i).licks = trials(i).licks - stims(3*i-2);
    
    trials(i).lickonsets = lickonsets(lickonsets>stims(3*i-2) & lickonsets<=stims(3*i+1));        
    trials(i).lickonsets = trials(i).lickonsets - stims(3*i-2);                
    
    % 1 = miss, 2 = hit, 3 = false alarm, 4 = correct reject, 5 = abort
    if trials(i).orients(2) == 90
        trials(i).status = 1+max(truerewards>stims(3*i-1) & truerewards<=stims(3*i));
    else
        trials(i).status = 4-max(punishs>stims(3*i-1) & punishs<=stims(3*i));
    end
    trials(i).stim_dur = stims(3*i)-stims(3*i-1);
    
    trials(i).timeout = 2*(trials(i).orients(2) ~= 90);
    
    if str2num(file(1:8)) < 20110314
        trials(i).timeout = trials(i).timeout*sum(trials(i).licks<trials(i).stims(2)-1/40 & trials(i).licks>trials(i).stims(1)-1/120);
    end
    
    trials(i).primes = [];
end

% find abort trials
itis = diff(stims);
itis = round(itis(3:3:end)*10)/10;
longitis = find(itis>=8);
%% extract tones, restructure trials

if isfield(data.response,'tones')
    tones = data.response.tones;
else
    tones = [];
end

for i = 1:length(longitis)
    j = longitis(i);
    n = itis(j);
    x = [];
    
    if isempty(tones)
        endtime = max(trials(j).stims)+trials(j).start_time;
        endtime = data.stimuli.end_time(abs(data.stimuli.end_time-endtime)<1);

        tonecheck = trials(j).stims(2)+4+trials(j).timeout+trials(j).start_time;
        tonecheck = round(tonecheck-endtime+floor(endtime))+endtime-floor(endtime);

        while round(endtime-tonecheck) >= 4
            trueend = data.presentation.flip_times(find(data.presentation.flip_times>tonecheck-2.5*data.screen.flip_int*data.presentation.wait_frames,1));
            trueend = trueend-trials(j).start_time;

            % if no licks in 1 sec interval        
            if max(trials(j).licks > trueend-1 & trials(j).licks <= trueend) == 0
                tones(end+1) = data.presentation.flip_times(abs(tonecheck-data.presentation.flip_times)<1/120);
                x(end+1) = tones(end);
                tonecheck = tonecheck+4;            
            else
                tonecheck = tonecheck+1;
            end       
        end 
    else
        x = tones(tones>trials(j).start_time & tones<trials(j).start_time+trials(j).stims(3));
    end
    
    x(end+1) = max(trials(j).stims)+trials(j).start_time;    

    for k = 1:length(x)-1
        trials(end+1).start_time = x(k);
        trials(end).stims = x(k+1)-x(k);
        trials(end).orients = NaN;
        trials(end).licks = licks(licks>x(k) & licks<=x(k+1));
        trials(end).licks = trials(end).licks - x(k);
        trials(end).lickonsets = lickonsets(lickonsets>x(k) & lickonsets<=x(k+1));
        trials(end).lickonsets = trials(end).lickonsets - x(k);
        trials(end).status = 5;
        trials(end).stim_dur = 0;
        trials(end).timeout = 0;
        
        trials(end).primes = [];       
    end
    
    trials(j).stims(3) = x(1)-trials(j).start_time;
    trials(j).licks(trials(j).licks>x(1)-trials(j).start_time) = [];
    trials(j).lickonsets(trials(j).lickonsets>x(1)-trials(j).start_time) = [];
end

[x, i] = sort([trials.start_time]);
trials = trials(i);

for i = 1:length(rewards)
    if max(licks == rewards(i)) == 0
        j = find([trials.start_time] <= rewards(i),1,'last');
        trials(j).primes(end+1) = rewards(i)-trials(j).start_time;
    end
end

for i = 1:length(trials)
	trials(i).trialnums = -i*ones(size(trials(i).licks));
    trials(i).trialnums2 = -i*ones(size(trials(i).lickonsets));
    trials(i).trialnums3 = -i*ones(size(trials(i).stims));
%     trials(i).trialnums4 = -i*ones(size(trials(i).primes));
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
% plot raster
figure; subplot(211); hold on;
plot([trials.licks],[trials.trialnums],'.')
plot([trials.lickonsets],[trials.trialnums2],'.r')
plot([trials.stims],[trials.trialnums3],'.g')
% axis([0 10 -length(trials) 0]);
% plot([trials.primes],[trials.trialnums4],'.c')
subplot(212); hold on;
plot([trials.lickonsets],[trials.trialnums2],'.r')
plot([trials.stims],[trials.trialnums3],'.g')
% plot([trials.primes],[trials.trialnums4],'.c')

% plot raster sorted by stim_dur
[x,i_sort] = sort([trials.stim_dur]);
[x,i2] = sort([trials([trials.stim_dur]==0).stims]);
i_sort(1:max(i2)) = i_sort(i2);

x = zeros(size(trials));
for j = 1:length(trials)
    x(j) = trials(j).stims(end);
end
[x, i_sort(2,:)] = sort(x);

for j = 1:1
trials_sorted = trials(i_sort(j,:));
for i = 1:length(trials_sorted)
    trials_sorted(i).trialnums = -i*ones(size(trials_sorted(i).licks));
    trials_sorted(i).trialnums2 = -i*ones(size(trials_sorted(i).lickonsets));
    trials_sorted(i).trialnums3 = -i*ones(size(trials_sorted(i).stims));
%     trials_sorted(i).trialnums4 = -i*ones(size(trials_sorted(i).primes));
end
figure; subplot(211), hold on;
plot([trials_sorted.licks],[trials_sorted.trialnums],'.')
plot([trials_sorted.lickonsets],[trials_sorted.trialnums2],'.r')
plot([trials_sorted.stims],[trials_sorted.trialnums3],'.g')
% axis([0 10 -length(trials) 0]);
% plot([trials_sorted.primes],[trials_sorted.trialnums4],'.c')
subplot(212); hold on;
plot([trials_sorted.lickonsets],[trials_sorted.trialnums2],'.r')
plot([trials_sorted.stims],[trials_sorted.trialnums3],'.g')
% plot([trials_sorted.primes],[trials_sorted.trialnums4],'.c')
plot([2 2],[-length(trials) 0],'--r');
end

%% hit/miss/etc.
n_targets = 0;
n_non = 0;
n_total = 0;
n_hits = 0;
n_false = 0;
n_abort = 0;

for i = 1:length(trials)    
    n_total = n_total+1;
    if trials(i).status < 3
        n_targets = n_targets + 1;
    elseif trials(i).status == 5
        n_abort = n_abort + 1;
    else
        n_non = n_non+1;
    end    
    if trials(i).status == 2
        n_hits = n_hits + 1;            
    elseif trials(i).status == 3
        n_false = n_false + 1;
    end
    per_hit(i) = n_hits/n_targets;
    per_false(i) = n_false/n_non;
    per_abort(i) =  n_abort/n_total;
    per_lick(i) = (n_hits+n_false)/(n_targets+n_non);
end
per_hit(isnan(per_hit))=0.5;
per_false(isnan(per_false))=0.5;
per_lick(isnan(per_lick))=0.5;

figure; hold all;
plot(per_hit)
plot(per_false)
plot(per_abort)
plot(per_lick)
legend('Hit %','False+ %','Abort %','Lick %')

n_total = 20;
for i = 1:length(trials)-n_total+1
    n = [trials(i:i+n_total-1).status];
    
    n_hits = sum(n==2);
    n_targets = sum(n<3);
    n_false = sum(n==3);
    n_abort = sum(n==5);
    n_non = n_total-n_targets-n_abort;
    fprintf('%2d %2d %2d\n',n_targets,n_non,n_abort)
    per_hit2(i) = n_hits/n_targets;
    per_false2(i) = n_false/n_non;
    per_abort2(i) =  n_abort/n_total;
    per_lick2(i) = (n_hits+n_false)/(n_targets+n_non);
end
trial_num = n_total/2+0.5:length(trials)-n_total/2+0.5;

primes = [];
for i = 1:length(trials)
    if ~isempty([trials(i).primes])
        primes(end+1) = i;
    end
end

figure; subplot(3,1,[1 2]), hold all;
plot(trial_num,per_hit2)
plot(trial_num,per_false2)
plot(trial_num,per_abort2)
plot(trial_num,per_lick2)
plot(primes,0.5*ones(size(primes)),'.')
title(sprintf('Moving window of %d trials',n_total))
legend('Hit %','False+ %','Abort %','Lick %', 'Primes')

per_hit2(per_hit2>0.99)=0.99;
per_hit2(per_hit2<0.01)=0.01;
per_false2(per_false2>0.99)=0.99;
per_false2(per_false<0.01)=0.01;

d_prime = norminv(per_hit2,0,1)-norminv(per_false2,0,1);

subplot(3,1,3), plot(trial_num,d_prime,'k')
legend('d-prime')

%% before stimulus -- lick onsets
% for j = 1:length(trials)
%     x(j) = trials(j).stims(end);
% end
% stim_on = [trials.stims];
% stim_on = stim_on(2:3:end);
% 
% 
% prestim_licks = [];
% for i = 1:length(trials)
%     temp = trials(i).lickonsets(trials(i).lickonsets<stim_on(i));
%     prestim_licks = [prestim_licks,temp];
% end
% [n xout] = hist(prestim_licks,24);
% binsize = mean(diff(xout));
% % normalize to number of trials
% c = zeros(size(xout));
% for i = 1:length(xout)
%     c(i) = length(find(stim_on >= xout(i)-binsize/2));
% end
% figure; 
% subplot(2,1,1), hold on;
% bar(xout,n)
% title('Lick Onset Histogram')
% plot([2 2],ylim,'--r'); 
% subplot(2,1,2), hold on;
% bar(xout,n./c)
% title('Normalized to trials')
% plot([2 2],ylim,'--r'); 