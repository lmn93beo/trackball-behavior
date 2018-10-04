%% extract lick data
clear all;close all; clc;
[files, dir] = uigetfile('MultiSelect','On');

% for i = 1:length(files)
%     cd(dir)
%     if iscell(files) 
%         load(files{i})
%     else
%         load(files)
%     end
    cd(dir)
    load(files)
       
    licks = data.response.licks;    
    stims = data.presentation.stim_times;
    orients = data.stimuli.orientation;
    duration = data.stimuli.total_duration;
    
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
        trials(i).stim_dur = stims(3*i)-stims(3*i-1);
        trials(i).trialnums = -i*ones(size(trials(i).licks));
        trials(i).trialnums2 = -i*ones(size(trials(i).lickonsets));
        % align to t = 0        
    end
    
%% plot lick burst frequency histogram
burstfreq = 1./diff(licks);
[n, xout] = hist(burstfreq,50);
figure(1);
bar(xout,n);
[a i] = max(n);
freq = xout(i);
title(sprintf('mode = %4.1f Hz',freq))
    

%% rasters 
% plot raster
figure; hold on;
plot([trials.licks],[trials.trialnums],'.')
plot([trials.lickonsets],[trials.trialnums2],'.r')
axis([0 10 -length(trials) 0]);
plot([2 2],[-length(trials) 0],'--r');    

% plot raster sorted by stim_dur
[x,i_sort] = sort([trials.stim_dur]);
trials_sorted = trials(i_sort);
for i = 1:length(trials_sorted)
    trials_sorted(i).trialnums = -i*ones(size(trials_sorted(i).licks));
    trials_sorted(i).trialnums2 = -i*ones(size(trials_sorted(i).lickonsets));
end
figure; hold on;
plot([trials_sorted.licks],[trials_sorted.trialnums],'.')
plot([trials_sorted.lickonsets],[trials_sorted.trialnums2],'.k')
axis([0 10 -length(trials) 0]);
plot([2 2],[-length(trials) 0],'--r');  



% full lick onset histogram
figure
hist([trials.lickonsets],20)


% stimulus duration histogram
figure;
hist([trials.stim_dur],20)


%% before stimulus histogram
stim_on = [trials.stims];
stim_on = stim_on(2:3:end);
prestim_licks = [];
for i = 1:length(trials)
    temp = trials(i).licks(trials(i).licks<stim_on(i));
    prestim_licks = [prestim_licks,temp];
end
[n xout] = hist(prestim_licks,24);
binsize = mean(diff(xout));
% normalize to number of trials
c = zeros(size(xout));
for i = 1:length(xout)
    c(i) = length(find(stim_on >= xout(i)-binsize/2));
end
figure; 
subplot(2,1,1), hold on;
bar(xout,n)
title('Lick histogram')
plot([2 2],ylim,'--r');
subplot(2,1,2), hold on;
bar(xout,n./c)
title('Normalized to trials')
plot([2 2],ylim,'--r'); 

%% before stimulus -- lick onsets
stim_on = [trials.stims];
stim_on = stim_on(2:3:end);
prestim_licks = [];
for i = 1:length(trials)
    temp = trials(i).lickonsets(trials(i).lickonsets<stim_on(i));
    prestim_licks = [prestim_licks,temp];
end
[n xout] = hist(prestim_licks,24);
binsize = mean(diff(xout));
% normalize to number of trials
c = zeros(size(xout));
for i = 1:length(xout)
    c(i) = length(find(stim_on >= xout(i)-binsize/2));
end
figure; 
subplot(2,1,1), hold on;
bar(xout,n)
title('Lick Onset Histogram')
plot([2 2],ylim,'--r'); 
subplot(2,1,2), hold on;
bar(xout,n./c)
title('Normalized to trials')
plot([2 2],ylim,'--r'); 

%% after reward histogram
for i = 1:length(trials)
    trials(i).licks2 = trials(i).licks - trials(i).stims(2) + 0.3;    
end
   
figure
d = [trials.licks2];
% d(d<0)=[];
hist(d,50);

