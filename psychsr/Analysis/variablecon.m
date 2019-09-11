% variablecon
blockflag =0;

% analyze variable contrast data

[file, dir] = uigetfile('*.mat','MultiSelect','On');
if iscell(file)
    filelen=length(file);
else
    filelen=1;
end
clear hits_all dprime_all fas_all hits_all_l dprime_all_l fas_all_l
hits_all = []; fas_all = []; dprime_all=[];
hits_all_l = []; fas_all_l = []; dprime_all_l=[];
hits_b = []; fas_b = []; dprime_b=[]; 

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
    con = data.stimuli.contrast(3:3:end);
    laststim=min(laststim,length(perf));
    
    % extract laser status
    if isfield(data.stimuli,'laser_on') & min(data.stimuli.laser_on)>0
        las = data.stimuli.laser_on(3:3:end);
        l_on = true;
    else
        las = zeros(size(con));
        l_on = false;
    end
    
    % clip vectors to last lick
    perf = perf(1:laststim);
    ori = ori(1:laststim);
    con = con(1:laststim);
    las = las(1:laststim);
    
    if blockflag
        las = mod(0:laststim-1,60)+1>30;
        l_on = true;        
    end
    
    % intialize vectors    
    c = unique(con);
    if fil == 1
        c_all = c;
        c_ind = 1:length(c);
    elseif length(c_all)~=length(c) || min(c_all == c) == 0
        c_old = c_all;        
        c_all = union(c_old,c);
        [x, c_ind, y] = intersect(c_all,c_old);
        hits_all(:,c_ind) = hits_all;
        hits_all(:,setxor(1:length(c_all),c_ind)) = NaN;
        fas_all(:,c_ind) = fas_all;
        fas_all(:,setxor(1:length(c_all),c_ind)) = NaN;
        dprime_all(:,c_ind) = dprime_all;        
        dprime_all(:,setxor(1:length(c_all),c_ind)) = NaN;
        [x, c_ind, y] = intersect(c_all,c);
    end
    c_plot=c*100;
    hits = zeros(size(c));
    fas = hits;
    dprime = hits;
    if l_on
        hits_l = hits;
        fas_l = hits;
        dprime_l = hits;
    end
    
    if blockflag
        blocks = ceil((1:laststim)/30);
        if sum(blocks == max(blocks))<15
            nblocks = max(blocks)-1;
        else
            nblocks = max(blocks);
        end
         
        for i = 1:nblocks
            for j = 1:3
                h = mean(perf(ori == 90 & con == c(j) & blocks == i));
                f = 1-mean(perf(ori ~= 90 & con == c(j) & blocks == i));
                hits_b(i,j) = h;
                fas_b(i,j) = f;
                
                if h>0.99; h = 0.99; end
                if h<0.01; h = 0.01; end
                if f>0.99; f = 0.99; end
                if f<0.01; f = 0.01; end
                
                % calculate d-prime
                dprime_b(i,j) = norminv(h,0,1)-norminv(f,0,1);
            end
        end
    end
    
    % calculate performance
    for i = 1:length(c)
        h = mean(perf(ori == 90 & con == c(i) & las == 0));
        f = 1-mean(perf(ori ~= 90 & con == c(i) & las == 0));
        
        hits(i) = h;
        fas(i) = f;
        
        if h>0.99; h = 0.99; end
        if h<0.01; h = 0.01; end
        if f>0.99; f = 0.99; end
        if f<0.01; f = 0.01; end
        
        % calculate d-prime
        dprime(i) = norminv(h,0,1)-norminv(f,0,1);
        
        % calculate performance and d-prime for laser trials
        if l_on
            h = mean(perf(ori == 90 & con == c(i) & las == 1));
            f = 1-mean(perf(ori ~= 90 & con == c(i) & las == 1));
            
            hits_l(i) = h;
            fas_l(i) = f;
            
            if h>0.99; h = 0.99; end
            if f<0.01; f = 0.01; end
            
            dprime_l(i) = norminv(h,0,1)-norminv(f,0,1);
        end
    end
    
    if blockflag
        hits_all = [hits_all; hits_b(1:2:end,:)];
        fas_all = [fas_all; fas_b(1:2:end,:)];
        dprime_all = [dprime_all; dprime_b(1:2:end,:)];
        
        hits_all_l = [hits_all_l; hits_b(2:2:end,:)];
        fas_all_l = [fas_all_l; fas_b(2:2:end,:)];
        dprime_all_l = [dprime_all_l; dprime_b(2:2:end,:)];
        
    else
        hits_all(fil,c_ind) = hits;
        hits_all(fil,setxor(1:length(c_all),c_ind)) = NaN;
        fas_all(fil,c_ind) = fas;
        fas_all(fil,setxor(1:length(c_all),c_ind)) = NaN;
        dprime_all(fil,c_ind) = dprime;
        dprime_all(fil,setxor(1:length(c_all),c_ind)) = NaN;
        
        if l_on
        hits_all_l(fil,c_ind) = hits_l;
        hits_all_l(fil,setxor(1:length(c_all),c_ind)) = NaN;
        fas_all_l(fil,c_ind) = fas_l;
        fas_all_l(fil,setxor(1:length(c_all),c_ind)) = NaN;
        dprime_all_l(fil,c_ind) = dprime_l;
        dprime_all_l(fil,setxor(1:length(c_all),c_ind)) = NaN;
        end
    end
    
    % plot hits/FAs
    figure
    subplot(4,1,[1 2])
    hold on;
    plot(c_plot,hits,'*:b')
    plot(c_plot,fas,'*:r')
    if l_on
        plot(c_plot,hits_l,'*-b')
        plot(c_plot,fas_l,'*-r')
    end
    axis([0 100 0 1])
    legend('Hit%','FA%','Location','SouthEast')
    title(sprintf('Mouse %2s: %8s',currfile(end-5:end-4),currfile(1:8)))
    
    % plot d-prime
    subplot(4,1,[3 4])
    hold on;
    plot(c_plot,dprime,'*:k')
    if l_on
        plot(c_plot,dprime_l,'*-k')
        legend('Laser OFF%','Laser ON%','Location','NorthOutside')
    end
    axis([0 100 -1 3])
    ylabel('D-prime')
    xlabel('Contrast')
end

if filelen > 1
    % plot hits/FAs
    figure
    subplot(4,1,[1 2])
    hold on;
%     plot(c_all*100,nanmean(hits_all)*100,'*-b')
%     plot(c_all*100,nanmean(fas_all)*100,'*-r')
    errorbar(c_all*100,nanmean(hits_all)*100,nanstd(hits_all)*100./sqrt(sum(~isnan(hits_all))),'*-b')
    errorbar(c_all*100,nanmean(fas_all)*100,nanstd(hits_all)*100./sqrt(sum(~isnan(fas_all))),'*-r')
    if l_on
        errorbar(c_all*100,nanmean(hits_all_l)*100,nanstd(hits_all_l)*100./sqrt(sum(~isnan(hits_all_l))),'*:b')
        errorbar(c_all*100,nanmean(fas_all_l)*100,nanstd(hits_all_l)*100./sqrt(sum(~isnan(fas_all_l))),'*:r')
    end
        
    axis([0 100 0 100])
%     legend('Hit%','FA%','Location','SouthEast')
    title(sprintf('Mouse %2s: %8s - %8s',file{1}(end-5:end-4),file{1}(1:8),file{filelen}(1:8)))
    
    % plot d-prime
    subplot(4,1,[3 4])
    hold on;
%     plot(c_all*100,nanmean(dprime_all),'*-k')
    errorbar(c_all*100,nanmean(dprime_all),nanstd(dprime_all)./sqrt(sum(~isnan(dprime_all))),'*-k')
    if l_on
        errorbar(c_all*100,nanmean(dprime_all_l),nanstd(dprime_all_l)./sqrt(sum(~isnan(dprime_all_l))),'*:k')
        if blockflag
            legend('HIGH contrast','LOW contrast','Location','NorthOutside')
        else
            legend('Laser OFF%','Laser ON%','Location','NorthOutside')
        end
    end    
    plot([0:100],zeros(1,101),'k:')
    axis([0 100 -1 3])    
    ylabel('D-prime')
    xlabel('Contrast')
%     legend('D-Prime','Location','NorthOutside')
end