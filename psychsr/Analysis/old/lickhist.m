%% extract lick data
close all; clc;
[files, dir] = uigetfile('MultiSelect','On');

licks = [];
orients = [];
ntrials = 0;

for i = 1:length(files)
    cd(dir)
    if iscell(files) 
        load(files{i})
    else
        load(files)
    end
    
    totaldata = data.response.totaldata;
    fs = data.card.ai_fs;
    t = 0:1/fs:length(totaldata)/fs-1/fs;
    
    threshold = 1;
    templicks = (find(diff(totaldata)>threshold)+1)/fs;
    
    temptrials = floor(max(t)/10);
    
    % remove licks from last trial if incomplete
    templicks(templicks>temptrials*10)=[];    
    
    licks = [licks;templicks+ntrials*10];
    ntrials = ntrials + temptrials;
    orients = [orients, data.stimuli.orientation(3:3:temptrials*3)];    
    
    if ~iscell(files)
        break
    end
end

licks = licks + 6; % shift so that tone is at t=0
ntrials = ntrials - 1; % remove last trial

%% plot lick burst frequency histogram

burstfreq = 1./diff(licks);

[n, xout] = hist(burstfreq,50);
figure(1);
bar(xout,n);
[a i] = max(n);
freq = xout(i);
title(sprintf('mode = %4.1f Hz',freq))

%% plot trial histograms
% separate target and nontarget trials

tlicks = cell(1,2); % cell 1 = target, cell 2 = target
ttrials = cell(1,2);
xdata = cell(1,2);
ydata = cell(1,2);
for i = 1:ntrials
    trial = licks((licks>10*(i)) & (licks<=10*(i+1)));
    tlicks{(orients(i)~=90)+1} = [tlicks{(orients(i)~=90)+1}; trial];
    ttrials{(orients(i)~=90)+1} = [ttrials{(orients(i)~=90)+1}; i];
    
    xdata{(orients(i)~=90)+1} = [xdata{(orients(i)~=90)+1};mod(trial,10)];
    ydata{(orients(i)~=90)+1} = [ydata{(orients(i)~=90)+1};-i*ones(size(trial))];    
end    
figure(2); axis([0 10 -ntrials 0]); hold on;
plot(xdata{1},ydata{1},'.')
plot([2 2],[-ntrials 0],'--r');
plot([6 6],[-ntrials 0],'--r'); 
figure(3); axis([0 10 -ntrials 0]); hold on;
plot(xdata{2},ydata{2},'.')
plot([2 2],[-ntrials 0],'--r');
plot([6 6],[-ntrials 0],'--r'); 


a = floor(ntrials.*(0:.25:1));

bounds1 = [0 2];
bounds2 = [0 2];
s = {'target','nontarget'};

for i = 1:2
    figure
    subplot(4,2,1:2:7)
    [n xout] = hist(mod(tlicks{i},10),50);
    bar(xout,n/length(ttrials{i}));
    hold on; plot([2 2],bounds1,'--r');
    plot([6 6],bounds1,'--r'); hold off;
    title(sprintf('All %s trials (%d of %d)',s{i},length(ttrials{i}),ntrials));
    ylim(bounds1)
    
    for j = 1:4
        subplot(4,2,j*2)
        x = tlicks{i};
        y = length(find((ttrials{i}>a(j)) & (ttrials{i}<=a(j+1))));
        [n xout] = hist(mod(x((x>a(j)*10+6) & (x<=a(j+1)*10+6)),10),50);
        bar(xout,n/y);
        hold on; plot([2 2],bounds2,'--r');
        plot([6 6],bounds2,'--r'); hold off;        
        title(sprintf('Quartile %d: %d %s trials',j,y,s{i}));
        ylim(bounds2)        
    end
end

%% lick onsets
window = 1/(mean(burstfreq)-1*std(burstfreq));

% only include licks that occurred after a certain time window
lickonsets = licks([true;diff(licks)>window]);

tlicks = cell(1,2); % cell 1 = target, cell 2 = target
ttrials = cell(1,2);
for i = 1:ntrials 
    trial = lickonsets((lickonsets>10*(i)) & (lickonsets<=10*(i+1)));
    tlicks{(orients(i)~=90)+1} = [tlicks{(orients(i)~=90)+1}; trial];
    ttrials{(orients(i)~=90)+1} = [ttrials{(orients(i)~=90)+1}; i];
end    

a = floor(ntrials.*(0:.25:1));

bounds1 = [0 40];
bounds2 = [0 20];
s = {'target','nontarget'};

for i = 1:2
    figure    
    subplot(4,2,1:2:7)
    hist(mod(tlicks{i},10),20)    
    hold on; plot([2 2],bounds1,'--r');
    plot([6 6],bounds1,'--r'); hold off;
    title(sprintf('All %s trials (%d of %d)',s{i},length(ttrials{i}),ntrials));
    ylim(bounds1)
    
    for j = 1:4
        subplot(4,2,j*2)
        x = tlicks{i};
        y = length(find((ttrials{i}>a(j)) & (ttrials{i}<=a(j+1))));
        hist(mod(x((x>a(j)*10+6) & (x<=a(j+1)*10+6)),10),20)
        hold on; plot([2 2],bounds2,'--r');
        plot([6 6],bounds2,'--r'); hold off;        
        title(sprintf('Quartile %d: %d %s trials',j,y,s{i}));
        ylim(bounds2)        
    end
end
