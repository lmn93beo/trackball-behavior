
clear

% load file
if strcmp(getenv('computername'),'ANALYSIS-2P4')
    root = 'c:\users\surlab\dropbox\mouseattention\behaviorData';
else
    root = 'c:\dropbox\mouseattention\behaviorData';
end
[file, dir] = uigetfile([root '\*.mat'],'MultiSelect','On');
if iscell(file)
    filelen=length(file);
else
    filelen=1;
end

for fil = 1:filelen
    
    % open current file
    if iscell(file)
        currfile = file{fil};
    else
        currfile = file;
    end
    load([dir currfile])

    % extract last lick, performance, orientation, contrast
    laststim = ceil(find(data.presentation.stim_times>max(data.response.licks),1)/3);
    perf = data.response.n_overall;
    ori = data.stimuli.orientation(3:3:end);
    
    % clip vectors to last lick
    if length(perf)<laststim
        laststim = length(perf);
    end
    perf = perf(1:laststim);
    ori = ori(1:laststim);
    
    % intialize vectors
    o = unique(ori);
    o(o==90)=[];
    o_plot=90-o;
    hits = zeros(size(o));
    fas = hits;
    dprime = hits;
    
    % calculate performance
    for i = 1:length(o)
        h = mean(perf(ori == 90));
        f = 1-mean(perf(ori == o(i)));
        
        hits(i) = h;
        fas(i) = f;
        
        if h>0.99; h = 0.99; end
        if f>0.99; f = 0.99; end
        if h<0.01; h = 0.01; end
        if f<0.01; f = 0.01; end
        
        % calculate d-prime
        dprime(i) = norminv(h,0,1)-norminv(f,0,1);
        
    end
    
    % collate multiple files
    hits_all(fil,:) = hits;
    fas_all(fil,:) = fas;
    dprime_all(fil,:) = dprime;
    
    % plot hits/FAs
    figure
    subplot(4,1,[1 2])
    hold on;
    plot(o_plot,hits*100,'*-b')
    plot(o_plot,fas*100,'*-r')
    axis([0 90 0 100])
    legend('Hit%','FA%','Location','SouthEast')
    title(sprintf('Mouse %2s: %8s',currfile(end-5:end-4),currfile(1:8)))
    
    % plot d-prime
    subplot(4,1,[3 4])
    hold on;
    plot(o_plot,dprime,'*-k')
    plot([0:90],zeros(1,91),'k:')
    axis([0 90 -1 3])
    ylabel('D-prime')
    xlabel('Orientation difference (Target - Nontarget)')
    legend('D-Prime','Location','NorthOutside')
    pause
    close
end

if filelen > 1
    % plot hits/FAs
    figure
    subplot(4,1,[1 2])
    hold on;
    plot(o_plot,mean(hits_all)*100,'*-b')
    plot(o_plot,mean(fas_all)*100,'*-r')
    axis([0 90 0 100])
    legend('Hit%','FA%','Location','SouthEast')
    title(sprintf('Mouse %2s: %8s - %8s',file{1}(end-5:end-4),file{1}(1:8),file{filelen}(1:8)))
    
    % plot d-prime
    subplot(4,1,[3 4])
    hold on;
    plot(o_plot,mean(dprime_all),'*-k')
    plot([0:90],zeros(1,91),'k:')
    axis([0 90 -1 3])
    ylabel('D-prime')
    xlabel('Orientation difference (Target - Nontarget)')
    legend('D-Prime','Location','NorthOutside')
end

