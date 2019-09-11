% variabledel
plot_la = 0; % plot effects of laser on next trial
% analyze variable contrast data

[filename, pathname] = uigetfile('*.mat','MultiSelect','On');
if iscell(filename)
    filelen=length(filename);
else
    filelen=1;
end

clearvars hits_all fas_all dprime_all hits_all_l fas_all_l dprime_all_l ...
    hist_all_la fas_all_la dprime_all_la

for fil = 1:filelen
    
    % open current file
    if iscell(filename)
        currfile = filename{fil};
    else
        currfile = filename;
    end
    load([pathname currfile])
    
    
    % extract last lick, performance, orientation, contrast
    laststim = ceil(find(data.presentation.stim_times>max(data.response.licks),1)/3);
    if isempty(laststim)
        laststim = ceil(length(data.presentation.stim_times)/3);
    end
    perf = data.response.n_overall;
    ori = data.stimuli.orientation(3:3:end);
    con = data.stimuli.contrast(3:3:end);
    del = data.stimuli.response_delay(3:3:end);
    laststim = min(laststim,length(perf));
    
    % extract laser status
    if isfield(data.stimuli,'laser_on') && max(data.stimuli.laser_on)
        las = data.stimuli.laser_on(3:3:end);
        l_on = true;
        if data.response.n_nolaser>=80
            firststim = 1;
        else
            firststim = data.response.n_nolaser+1;
        end
    else
        las = zeros(size(con));
        l_on = false;
        firststim = 1;
    end
    
    % clip vectors to last lick
    perf = perf(firststim:laststim);
    ori = ori(firststim:laststim);
    con = con(firststim:laststim);
    las = las(firststim:laststim);
    del = del(firststim:laststim);
    
    las_after = [0, las(1:end-1)];
    
    % intialize vectors
    d = unique(del);
    d_plot = d-2;
    d_min = d_plot(1)-0.5;
    d_max = d_plot(end)+0.5;
    
    resp_all = cell(2,length(d),1+l_on+plot_la*l_on);
    for i = 1:1+l_on
        for j = 1:length(d)
            for k = 1:2
                ori_ind = (3-2*k)*(ori==90)+(k-1); % x for k=1, 1-x for k=2
                resp_all{k,j,i} = (3-2*k)*perf(ori_ind & del==d(j) & las==i-1)+(k-1);
            end
        end
    end
    if size(resp_all,3) == 3
        for j = 1:length(d)
            for k = 1:2
                ori_ind = (3-2*k)*(ori==90)+(k-1);
                resp_all{k,j,3} = (3-2*k)*perf(ori_ind & del==d(j) & las_after==1)+(k-1);
            end
        end
    end
    resp_mean = cellfun(@mean,resp_all);
    resp_mean(resp_mean>0.99) = 0.99;
    resp_mean(resp_mean<0.01) = 0.01;    
    resp_dprime = -diff(norminv(resp_mean,0,1));    
    
    
    hits = zeros(size(d));
    fas = hits;
    dprime = hits;
    if l_on
        hits_l = hits;
        fas_l = hits;
        dprime_l = hits;
        
        hits_la = hits;
        fas_la = hits;
        dprime_la = hits;
    end
    
    % calculate performance
    for i = 1:length(d)
        h = mean(perf(ori == 90 & del == d(i) & las == 0));
        f = 1-mean(perf(ori ~= 90 & del == d(i) & las == 0));
        
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
            h = mean(perf(ori == 90 & del == d(i) & las == 1));
            f = 1-mean(perf(ori ~= 90 & del == d(i) & las == 1));
            
            hits_l(i) = h;
            fas_l(i) = f;
            
            if h>0.99; h = 0.99; end
            if h<0.01; h = 0.01; end
            if f>0.99; f = 0.99; end
            if f<0.01; f = 0.01; end
            
            dprime_l(i) = norminv(h,0,1)-norminv(f,0,1);
            
            % trials immediately after laser
            h = mean(perf(ori == 90 & del == d(i) & las_after == 1));
            f = 1-mean(perf(ori ~= 90 & del == d(i) & las_after == 1));
            
            hits_la(i) = h;
            fas_la(i) = f;
            
            if h>0.99; h = 0.99; end
            if h<0.01; h = 0.01; end
            if f>0.99; f = 0.99; end
            if f<0.01; f = 0.01; end
            
            dprime_la(i) = norminv(h,0,1)-norminv(f,0,1);
        end
    end
    
    hits_all(fil,:) = hits;
    fas_all(fil,:) = fas;
    dprime_all(fil,:) = dprime;
    
    if l_on
        hits_all_l(fil,:) = hits_l;
        fas_all_l(fil,:) = fas_l;
        dprime_all_l(fil,:) = dprime_l;
        
        hits_all_la(fil,:) = hits_la;
        fas_all_la(fil,:) = fas_la;
        dprime_all_la(fil,:) = dprime_la;
    end
    
    % plot hits/FAs
    figure
    subplot(4,1,[1 2])
    hold on;
    plot(d_plot,hits,'o-b')
    plot(d_plot,fas,'o-r')
    if l_on
        plot(d_plot,hits_l,'*:b')
        plot(d_plot,fas_l,'*:r')
        if plot_la
            plot(d_plot,hits_la,'v--b')
            plot(d_plot,fas_la,'v--r')
        end
    end
    axis([d_min d_max 0 1])
    legend('Hit%','FA%','Location','SouthEast')
    title(sprintf('Mouse %2s: %8s',currfile(end-5:end-4),currfile(1:8)))
    
    % plot d-prime
    subplot(4,1,[3 4])
    hold on;
    plot(d_plot,dprime,'o-k')
    if l_on        
        plot(d_plot,dprime_l,'*:k')
        if plot_la
            plot(d_plot,dprime_la,'v--k')
            legend('Laser OFF','Laser ON','Laser AFTER','Location','NorthOutside')            
        else
            legend('Laser OFF','Laser ON','Location','NorthOutside')            
        end        
    end
    plot([d_min:d_max],zeros(1,length([d_min:d_max])),'k:')
    axis([d_min d_max -1 4])
    ylabel('D-prime')
    xlabel('Delay (sec)')
    set(gcf,'color',[1 1 1])
    pause 
%     keyboard
    close
end

if filelen > 1
    % plot hits/FAs
    figure
    subplot(4,1,[1 2])
    hold on;
    plot(d_plot,mean(hits_all)*100,'o-b')
    plot(d_plot,mean(fas_all)*100,'o-r')
    if l_on        
        plot(d_plot,mean(hits_all_l)*100,'*:b')
        plot(d_plot,mean(fas_all_l)*100,'*:r')
        if plot_la
            plot(d_plot,mean(hits_all_la)*100,'v--b')
            plot(d_plot,mean(fas_all_la)*100,'v--r')
        end        
    end
    axis([d_min d_max 0 100])
    legend('Hit%','FA%','Location','SouthEast')
    title(sprintf('Mouse %2s: %8s - %8s',filename{1}(end-5:end-4),filename{1}(1:8),filename{filelen}(1:8)))
    
    % plot d-prime
    dprime_all(i) = norminv(h,0,1)-norminv(f,0,1);
    subplot(4,1,[3 4])
    hold on;
    plot(d_plot,mean(dprime_all),'o-k')
    if l_on                
        plot(d_plot,mean(dprime_all_l),'*:k')
        if plot_la
            plot(d_plot,mean(dprime_all_la),'v--k')
            legend('Laser OFF','Laser ON','Laser AFTER','Location','NorthOutside')            
        else
            legend('Laser OFF','Laser ON','Location','NorthOutside')            
        end                      
    end        
    plot([d_min:d_max],zeros(1,length([d_min:d_max])),'k:')
    axis([d_min d_max -1 4])
    ylabel('D-prime')
    xlabel('Delay (sec)')
%     legend('D-Prime','Location','NorthOutside')
    set(gcf,'color',[1 1 1])
end