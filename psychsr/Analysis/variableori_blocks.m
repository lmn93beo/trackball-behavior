
clear

% user param
num_blocks=4;  % number of blocks
block_size=25;  % length of orientation blocks

% load file
savedir = pwd;
if strcmp(getenv('computername'),'ANALYSIS-2P4')
    root = 'c:\users\surlab\dropbox\mouseattention\behaviorData';
else
    root = 'c:\dropbox\mouseattention\behaviorData';
end
[files, dir] = uigetfile([root '\*.mat'],'MultiSelect','On');
if ~iscell(files); files = {files}; end
nfiles = length(files);
passive = cellfun(@(x) strcmp(x(end-4),'P'),files);
fil_count = 1;

for fil = 1:nfiles
    
    % open current file
    currfile = files{fil};
    load([dir currfile])

    % extract last lick, performance, orientation, contrast
    perf = data.response.n_overall;
    ori = data.stimuli.orientation(3:3:end);
    
    % clip vector to last trial
    ori = ori(1:length(perf));
    
    % nontarget orientation vector
    t_ori = 90;
    nt_vector = setdiff(unique(ori),t_ori);
    
    % intialize vectors
    hits = zeros(1,num_blocks);
    fas = hits;
    dprime = hits;
    
    % calculate performance
    for b=1:num_blocks
        curr_idx = (b-1)*block_size;
        curr_perf = perf(curr_idx+1:min(curr_idx+block_size,length(perf)));
        curr_ori = ori(curr_idx+1:min(curr_idx+block_size,length(perf)));
        nt_ori = setdiff(unique(curr_ori),t_ori);
        block_idx = find(nt_vector==nt_ori);

        h = mean(curr_perf(curr_ori == t_ori));
        f = 1-mean(curr_perf(curr_ori == nt_ori));
        
        hits(block_idx) = h;
        fas(block_idx) = f;
        
        if h>0.99; h = 0.99; end
        if f>0.99; f = 0.99; end
        if h<0.01; h = 0.01; end
        if f<0.01; f = 0.01; end
        
        % calculate d-prime
        dprime(block_idx) = norminv(h,0,1)-norminv(f,0,1);
        
    end
    
    % collate multiple files
    if passive(fil) == 0
        hits_all(fil_count,:) = hits;
        fas_all(fil_count,:) = fas;
        dprime_all(fil_count,:) = dprime;
        fil_count = fil_count+1;
        
        % plot hits/FAs
        figure
        subplot(4,1,[1 2])
        hold on;
        plot(90-nt_vector,hits*100,'*-b')
        plot(90-nt_vector,fas*100,'*-r')
        axis([0 90 0 100])
        legend('Hit%','FA%','Location','SouthEast')
        title(sprintf('Mouse %2s: %8s',currfile(end-8:end-7),currfile(1:8)))
        
        % plot d-prime
        subplot(4,1,[3 4])
        hold on;
        plot(90-nt_vector,dprime,'*-k')
        plot([0:90],zeros(1,91),'k:')
        axis([0 90 -1 3])
        ylabel('D-prime')
        xlabel('Orientation difference (Target - Nontarget)')
        legend('D-Prime','Location','NorthOutside')
        pause
        close
    end
end

if nfiles > 1
    % plot hits/FAs
    figure
    subplot(4,1,[1 2])
    hold on;
    plot(90-nt_vector,mean(hits_all)*100,'*-b')
    plot(90-nt_vector,mean(fas_all)*100,'*-r')
    axis([0 90 0 100])
    legend('Hit%','FA%','Location','SouthEast')
    title(sprintf('Mouse %2s: %8s - %8s',files{1}(end-8:end-7),files{1}(1:8),files{nfiles}(1:8)))
    
    % plot d-prime
    subplot(4,1,[3 4])
    hold on;
    plot(90-nt_vector,mean(dprime_all),'*-k')
    plot([0:90],zeros(1,91),'k:')
    axis([0 90 -1 3])
    ylabel('D-prime')
    xlabel('Orientation difference (Target - Nontarget)')
    legend('D-Prime','Location','NorthOutside')
    set(gcf,'color',[1 1 1])
end

