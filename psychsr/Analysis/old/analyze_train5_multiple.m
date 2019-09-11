clear all; clc; close all; 
%% load files
[files, dir] = uigetfile('MultiSelect','On');
cd(dir);
if ~iscell(files) 
    files = {files};
end

%% parameters
maxmovie = 5;
minmovie = 3;
blanktime = 2;

o = []; p = []; h = []; f = []; fa = []; d = []; t=[]; m=[]; g=[]; iti=[];
nt = 0;

for j = 1:length(files)    
    trials = loaddata(3,files{j});    
%     trials([trials.n_licks]==0)=[]; % remove no-lick trials    

    n = 50;
    for i = 1:length(trials)     
        trials(i).delay = ~isempty(find(trials(i).licks2>=-blanktime & trials(i).licks2<0,1));                
        
        block = i-n/2:i+n/2-1;
        if min(block)>0 && max(block)<length(trials)
            stimtimes = [trials(block).stims];
            movietimes = stimtimes(1:3:end);
            blanktimes = stimtimes(2:3:end)-movietimes;
            ititimes = stimtimes(3:3:end)-stimtimes(2:3:end);
            blockonsets = [trials(block).lickonsets2];
            
            trials(i).probm = sum(blockonsets<0)/sum(movietimes);
            trials(i).probg = sum(blockonsets>=0 & blockonsets<=blanktime)/sum(blanktimes);
            trials(i).probi = sum(blockonsets>blanktime)/sum(ititimes);
        end
    end
    
    onset = smooth([trials.onset],n);
    onset = onset(n/2+1:end-n/2);
    
    primed = smooth([trials.primed],n);
    primed = primed(n/2+1:end-n/2);
    
    hits = [trials.rewarded];
    hits = hits(~isnan(hits));
    hits = smooth(hits,n);
    ntar = sort(union(find(~[trials.target]),find([trials.primed])));
    for i = 1:length(ntar)
        if ntar(i)<length(hits)
            hits(ntar(i):end+1) = [hits(ntar(i));hits(ntar(i):end)];
        else
            hits(end+1) = hits(end);
        end
    end    
    hits = hits(n/2+1:end-n/2);
    hits(hits>0.99)=0.99;
    hits(hits<0.01)=0.01;
    
    falarm = [trials.punished];
    falarm = falarm(~isnan(falarm));
    falarm = smooth(falarm,n);
    tar = find([trials.target]);
    for i = 1:length(tar)
        if isempty(falarm)
            falarm = NaN*ones(size(trials))';
            break;
        elseif tar(i)<length(falarm)
            falarm(tar(i):end+1) = [falarm(tar(i));falarm(tar(i):end)];        
        else
            falarm(end+1) = falarm(end);
        end
    end    
    falarm = falarm(n/2+1:end-n/2);
    falarm(falarm>0.99)=0.99;
    falarm(falarm<0.01)=0.01;    
    
    delay = smooth([trials.delay],n);
    delay = delay(n/2+1:end-n/2);
    delay(delay>0.99)=0.99;
    delay(delay<0.01)=0.01;
    if sum(isnan(falarm))>0
        dprime = norminv(hits,0,1)-norminv(delay,0,1);
    else
        dprime = norminv(hits,0,1)-norminv(falarm,0,1);
    end
    dprime = smooth(dprime);
    probm = [trials.probm]';
    probg = [trials.probg]';
    probi = [trials.probi]';
    
    o = [o;onset];
    p = [p;primed];
    h = [h;hits];
    fa = [fa;falarm];
    f = [f;delay];
    d = [d;dprime];
    m = [m;probm];
    g = [g;probg];
    iti = [iti;probi];
    
    t = [t;[nt+1:nt+length(onset)]'];
    
    if j<length(files)
        days = datenum(files{j+1}(1:8),'yyyymmdd')-datenum(files{j}(1:8),'yyyymmdd');
        days = (days-1)*(days>1);
        nt = max(t)+50+days*100;
    end
    
    fprintf('Completed %d of %d\n',j,length(files))
end

figure; subplot(4,1,1); hold on;
plot(t,f,'b.'); plot(t,fa,'r.'); plot(t,h,'g.'); 
xlim([1 1.3*max(t)]); ylim([0 1]);
ylabel('Hits/FAs/Early')
title(sprintf('%s: %s-%s',dir(end-10:end-1),files{1}(5:8),files{end}(5:8)))
legend('Mov%','FA%','Hit%','Location','SouthEast')

subplot(4,1,2); hold on;
plot(t,o,'b.'); plot(t,p,'c.');
xlim([1 1.3*max(t)]); ylim([0 1]);
ylabel('Onsets/Primes')
legend('Ons%','Pri%')

subplot(4,1,3); hold on;
plot(t,d,'.k'); 
plot([1 1.3*max(t)],[0 0],'--k')
xlim([1 1.3*max(t)]); ylim([min(d) 3])
ylabel('D-prime')

subplot(4,1,4);hold on;
plot(t,iti,'c.'); plot(t,m,'r.'); plot(t,g,'g.'); 
xlim([1 1.3*max(t)]); ylim([0 max([m;g;iti])])
ylabel('Lickonsets/sec')
legend('ITI','Mov','Grat','Location','SouthEast')
