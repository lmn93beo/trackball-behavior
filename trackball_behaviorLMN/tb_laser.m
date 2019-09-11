function tb_laser(saveFlag,poolFlag,reload)
if nargin<1 || isempty(saveFlag)
    saveFlag = 0;
end
if nargin<2 || isempty(poolFlag)
    poolFlag = 2; % 1 = pool different voltages; 2 = pool voltages & mice
end
if nargin<3 || isempty(reload)
    reload = 0;
end
targFlag = 1; % only analyze the following laser targets:
targets = {'left acc','left v1'};
   
%% select files
psychsr_go_root();
cd ../behaviorData/trackball

nmice = 0;
loadFlag = 1;

biasFlag = 0; % plot performance as % leftward movements, as opposed to %correct

all_files = {};
all_paths = {};
if reload    
    disp('Load all data from one mouse at a time, click Canceled when done')
    while loadFlag == 1
        [filelist pathname] = uigetfile('MultiSelect','On');
        if isnumeric(filelist) && filelist == 0
            loadFlag = 0;
            break
        else
            nmice = nmice + 1;
        end
        if ~iscell(filelist)
            filelist = {filelist};
        end
        all_files = cat(2,all_files,filelist);
        all_paths = cat(2,all_paths,repmat({pathname},1,length(filelist)));
    end
else    
    paths = dir('Trackball Laser\mouse*');    
    for p = 1:length(paths)
        files = dir(['Trackball Laser\' paths(p).name '\*.mat']);
        all_files = cat(2,all_files,{files.name});
        all_paths = cat(2,all_paths,repmat({[pwd '\Trackball Laser\' paths(p).name '\']},1,length(files)));
    end
    
end
mice = cellfun(@(x) str2double(x(end-4:end-1)),all_paths);

%%

target = cell(size(all_files));
voltage = zeros(size(all_files));

perf = nan(2,2,length(all_files)); % laser x stimulus x file
miss = nan(2,2,length(all_files));
rt_all = nan(2,2,length(all_files));
ntrials = nan(2,2,length(all_files));

mvmts_all = cell(2,2,3,length(all_files));
nmvmts_all = cell(2,2,3,length(all_files));
tdur_all = cell(2,2,3,length(all_files));
thresh_all = nan(length(all_files),2);
exclude = false(size(all_files));

for f = 1:length(all_files)
    load([all_paths{f} all_files{f}])
    if data.params.laser
        disp(all_files{f})
        target{f} = lower(data.params.laser_target);
        voltage(f) = data.params.laser_amp;

        % extract variables
        n = find(data.response.reward>0,1,'last');
        choice = data.response.choice(1:n);
        loc = data.stimuli.loc(1:n);
        contrast = data.stimuli.contrast(1:n);        
        rt = cellfun(@(x) x(end),data.response.timePC(1:n));  
  
        mvmts = cell(1,n); % columns: time, position, velocity (smoothed)
        nmvmts = cell(1,n); % latency, and peak velocity of each "movement"
        time = data.response.mvmtdata(:,2);
        neg = find(diff(time)<-1000,1);
        while ~isempty(neg)
            time(neg+1:end,1) = time(neg+1:end,1) + 2^16;
            neg = find(diff(time)<-1000,1);
        end
        time = time/1000;
        thresh_all(f,:) = data.params.threshold;
        
        % movement variables
        for i = 1:n
            if i == 1
                ix = 1:data.response.samples_reward{i};
            else
                ix = data.response.samples_reward{i-1}:data.response.samples_reward{i};
            end
            
            % extract timepoints
            t = time(ix);
            m = cumsum(data.response.mvmt_degrees_per_pixel*data.response.mvmtdata(ix,1));
            t_pc = data.response.timePC{i}(find(data.response.samps{i}~=0,1,'last'));
            t_ard = t(data.response.samples_stop{i}-min(ix)+1); t = t-t_ard+t_pc;
            m = m-m(data.response.samples_start{i}-min(ix)+1);
            
            % interpolate to get 1kHz
            m(find(diff(t)==0))=[]; t(find(diff(t)==0)) = [];
            t2 = (-0.5:0.001:max(t))';
            m2 = interp1(t,m,t2);
            v2 = smooth([0;diff(m2)],21); % smoothed velocity (20ms)
            mvmts{i} = [t2, m2, v2];
            
            % number of movements
            v3 = v2(t2>0 & t2<rt(i));
            ix = find(t2>0,1);
            start = find(abs(v3)>0.02,1); % start: vel cross 0.02 threshold
            
            while ~isempty(start)
                x = sign(v3(start));
                % stop: vel cross 0.005 threshold
                if x>0; stop = find(v3(start:end)<0.005,1)+start-1;
                else stop = find(v3(start:end)>-0.005,1)+start-1; end;
                if isempty(stop); stop = length(v3); end
                
                latency = t2(ix+start-1); % latency to start
                peakvel = max(abs(v3(start:stop)))*x; % peak velocity
                nmvmts{i}(end+1,:) = [latency, peakvel];
                
                v3 = v3(stop+1:end);
                ix = ix+stop+1;
                start = find(abs(v3)>0.02,1);
            end
        end
        
        laser = data.stimuli.laser(1:n);
                
        for l = 1:2
            for s = 1:2
                % performance on all non-miss, non-blank trials
                ix = laser==l & loc==s & choice<5 & contrast>0;                                
                perf(l,s,f) = mean(choice(ix)==1);                
                ntrials(l,s,f) = sum(ix);
                % rt for correct trials only
                rt_all(l,s,f) = mean(rt(ix & choice==s));        
                
                % miss rate on all non-blank trials
                ix = laser==l & loc==s & contrast>0;
                miss(l,s,f) = mean(choice(ix)==5);
                
                for c = 1:3                    
                    ix = laser==l & loc==s & contrast>0;
                    if c>2; ix = ix & choice==5;
                    else ix = ix & choice==c; end                        
                    mvmts_all{l,s,c,f} = mvmts(ix);
                    nmvmts_all{l,s,c,f} = nmvmts(ix);
                    tdur_all{l,s,c,f} = rt(ix);
                end
            end
        end

        if min(min(ntrials(:,:,f))) < 10
            exclude(f) = true;
        end
        if perf(1,1,f)<0.5 || perf(1,2,f)>0.5
            exclude(f) = true;
        end        
        if length(unique(contrast))>2 % exclude variable contrast
            exclude(f) = true;
        end
        if targFlag && max(strcmpi(targets,target{f}))==0
            exclude(f) = true;
        end
        
%         if ~exclude(f)
%            
%         end
        
    else
        exclude(f) = true;
    end
end

if poolFlag>0
    dates = cellfun(@(x) datenum(x(1:8),'yyyymmdd'),all_files);
    
    % special exclusion rules for different mice
    exclude(mice==3 & strcmp(target,'left acc') & dates>=736217 & voltage==5) = true; 
    exclude(mice==4 & strcmp(target,'left acc') & voltage>=2.5) = true;
    exclude(mice==4 & strcmp(target,'right acc') & voltage>=2.5) = true;
    
    voltage(:) = 5;
    
    if poolFlag > 1
        mice(:) = max(mice);
    end
end


% remove excluded files
all_files(exclude) = [];
all_paths(exclude) = [];
mice(exclude) = [];
perf(:,:,exclude) = [];
ntrials(:,:,exclude) = [];
miss(:,:,exclude) = [];
rt_all(:,:,exclude) = [];
target(exclude) = [];
voltage(exclude) = [];
mvmts_all(:,:,:,exclude) = [];
nmvmts_all(:,:,:,exclude) = [];
tdur_all(:,:,:,exclude) = [];
thresh_all(exclude,:) = [];

cmap = [0.7 0.7 0.7; 0.2 0.7 1];
x = [1 2 4 5];

umice = unique(mice);
utarg = unique(target);
uvolt = unique(voltage);

% convert to percent correct
if ~biasFlag
    perf(:,2,:) = 1-perf(:,2,:);
end

%% performance
close all
if saveFlag
    cd figures
end
labels = {'Performance','Miss rate','Reaction time'};
for t = 1:length(utarg)
    for m = 1:length(umice)
        for v = 1:length(uvolt)
            ix = find(strcmp(utarg(t),target) & voltage==uvolt(v) & mice==umice(m));
            
            if ~isempty(ix)
                str = utarg{t};
                str(1) = upper(str(1));
                str(strfind(str,' '):end) = upper(str(strfind(str,' '):end));                
                if poolFlag==2
                    str =sprintf('%s',str);
                elseif poolFlag == 1
                    str =sprintf('%s (M%03d)',str,umice(m));
                else
                    str =sprintf('%s (M%03d, %1.1fV)',str,umice(m),uvolt(v));
                end
                                
                figure
%                 set(gcf,'position',[ 1   100   376   840])
                set(gcf,'position',[1 577 1131 363])
                
                for p = 1:3
                    subplot(1,3,p)
                    if p == 1; data = perf*100;
                    elseif p == 2; data = miss*100;
                    else data = rt_all*1000; end
                        
                    mdata = reshape(nanmean(data(:,:,ix),3),1,4);
                    sdata = reshape(nanstd(data(:,:,ix),[],3)/sqrt(length(ix)),1,4);
                    for i = 1:4                    
                        [h1,h2] = barwitherr(sdata(i),mdata(i));
                        set(h1,'xdata',x(i),'facecolor',cmap(mod(i+1,2)+1,:))
                        set(h2,'xdata',x(i),'linewidth',2)
                        hold on
                    end
                    for f = 1:length(ix)
                        plot(x(1:2),data(:,1,ix(f)),'color',[0.5 0.5 0.5])
                        plot(x(3:4),data(:,2,ix(f)),'color',[0.5 0.5 0.5])
                        hold on
                    end
                    
                    if p < 3
                        axis([0 6 0 100]);
                        set(gca,'ytick',0:25:100)
                    else
                        axis([0 6 0 1000])
                        set(gca,'ytick',0:250:1000)
                    end
                        
                    set(gca,'xtick',[1.5 4.5])
                    set(gca,'xticklabel','')
                    h = get(gca,'children');
    %                 legend(h([end,end-2]),'Laser OFF','Laser ON')
                    xlabel('Stimulus')
                    if p == 1 
                        if biasFlag; ylabel('% Leftward Movements')
                        else ylabel('% Correct'); end
                    elseif p == 2
                        ylabel('% Timeout Trials')
                    else
                        ylabel('Reaction Time (ms)')
                    end        
                    title([str ' - ' labels{p}])                    
                    
                    if p == 1; plot(xlim,[50 50],'--k'); end
                    if length(ix) > 1                    
                        fprintf('\n%s (#%03d, %1.1fV) - %s (n = %d)\n',str,umice(m),uvolt(v),labels{p},length(ix))
                        [h,p]=ttest(data(1,1,ix),data(2,1,ix));
                        fprintf('Effect on left : p = %1.4f\n',p)
                        text(1.5,0,sprintf('p=%1.3f',p),'horizontalalignment','center','verticalalignment','bottom')
                        [h,p]=ttest(data(1,2,ix),data(2,2,ix));
                        fprintf('Effect on right: p = %1.4f\n',p)
                        text(4.5,0,sprintf('p=%1.3f',p),'horizontalalignment','center','verticalalignment','bottom')
                    end
                end                
                
                % save figures
                if saveFlag && poolFlag > 0
%                     saveas(gcf,sprintf('%s %s.fig',datestr(today,'yymmdd'),str))
                    saved = false;
                    while ~saved
                        try
                            saveas(gcf,sprintf('%s %s.fig',datestr(today,'yymmdd'),str))
                            saveas(gcf,sprintf('%s %s.eps',datestr(today,'yymmdd'),str))
                            saveas(gcf,sprintf('%s %s.tif',datestr(today,'yymmdd'),str))
                            saved = true;
                        catch  
                            disp('retry...')
                            pause(1)
                        end
                    end
                end
                
                %% plot mvmt trajectories
                figure    
                setFigSize(1,1)
                latency1 = []; peakvel1 = []; G1 = []; 
                latency2 = []; peakvel2 = []; G2 = []; 
                for l = 1:2
                    for s = 1:2
                        
                        mvmts = cat(2,mvmts_all{l,:,s,ix});
                        nmvmts = cat(2,nmvmts_all{l,:,s,ix});
                        rt = cat(2,tdur_all{l,:,s,ix});                        
                        n = cellfun(@(x) size(x,1),nmvmts);                        
                        latency1 = cat(2,latency1,cellfun(@(x) x(1,1),nmvmts(n==1)));
                        peakvel1 = cat(2,peakvel1,abs(cellfun(@(x) x(1,2),nmvmts(n==1))));
                        G1 = cat(2,G1,(2*s+l-2)*ones(1,sum(n==1)));
                        
                        subplot(2,4,1)
                        hold on
                        h = bar(mean(n==1));
                        set(h,'xdata',2*s+l-2)
                        set(h,'facecolor',cmap(l,:))
                        title('% 1-mvmt out of correct trials')
                        text(2*s+l-2,0,sprintf('%d/\n%d',sum(n==1),length(n)),'horizontalalignment','center',...
                            'verticalalignment','bottom')
                        xlim([0 5])
                        set(gca,'xtick',1:4)
                        
                        subplot(2,4,4)
                        hold on
                        trials = find(n==1);
                        trials = trials(randperm(length(trials),min([5 length(trials)])));
                        for i = 1:length(trials)
                            j = trials(i);
                            samps = mvmts{j}(:,1)<rt(j);
                            plot(mvmts{j}(samps,1),mvmts{j}(samps,2),'color',cmap(l,:))                            
                        end
                        axis([-1 3 -25 25])
                                                
                        mvmts = cat(2,mvmts_all{l,s,[1 2],ix});
                        nmvmts = cat(2,nmvmts_all{l,s,[1 2],ix});
                        rt = cat(2,tdur_all{l,s,[1 2],ix});
                        com = cellfun(@(x) min(x(:,2))<-0.1 & max(x(:,2))>0.1,nmvmts);
                        latency2 = cat(2,latency2,cellfun(@(x) x(1,1),nmvmts(com)));
                        peakvel2 = cat(2,peakvel2,cellfun(@(x) max(abs(x(:,2))),nmvmts(com)));
                        G2 = cat(2,G2,(2*s+l-2)*ones(1,sum(com)));
                                                
                        subplot(2,4,5)
                        hold on
                        h = bar(mean(com));
                        set(h,'xdata',2*s+l-2)
                        set(h,'facecolor',cmap(l,:))
                        title('% Change-of-mind')
                        text(2*s+l-2,0,sprintf('%d/\n%d',sum(com),length(com)),'horizontalalignment','center',...
                            'verticalalignment','bottom')
                        xlim([0 5])
                        set(gca,'xtick',1:4)
                       
                        subplot(2,4,8)
                        hold on
                        trials = find(com);
                        trials = trials(randperm(length(trials),min([5 length(trials)])));
                        for i = 1:length(trials)
                            j = trials(i);
                            samps = mvmts{j}(:,1)<rt(j);
                            plot(mvmts{j}(samps,1),mvmts{j}(samps,2),'color',cmap(l,:))                            
                        end
                        axis([-1 3 -25 25])
                    end
                end
                          
                subplot(2,4,2)         
                h=boxplot(latency1,G1,'boxstyle','filled','symbol','');
                for i = 1:size(h,2)                    
                    set(h(:,i),'color',cmap(mod(i+1,2)+1,:))
                end
                axis([0 5 0 0.3])
                [h,p] = ttest2(latency1(G1==1),latency1(G1==2));
                if h; text(1.5,0.3,sprintf('*\np=%1.3f',p),'horizontalalignment',...
                        'center','verticalalignment','top');  end
                [h,p] = ttest2(latency1(G1==3),latency1(G1==4));
                if h; text(3.5,0.3,sprintf('*\np=%1.3f',p),'horizontalalignment',...
                        'center','verticalalignment','top');  end
                title('Latency (1 mvmt)')
                set(gca,'xtick',1:4)
                
                subplot(2,4,3)    
%                 hold on
%                 [fr,x] = ksdensity(peakvel1(G1==1));
%                 plot(x,fr,'color',cmap(1,:))
%                 [fr,x] = ksdensity(peakvel1(G1==2));
%                 plot(x,fr,'color',cmap(2,:))
%                 
%                 [fr,x] = ksdensity(peakvel1(G1==3));
%                 plot(x,-fr,'color',cmap(1,:))
%                 [fr,x] = ksdensity(peakvel1(G1==4));
%                 plot(x,-fr,'color',cmap(2,:))
%                 xlim([0 1])
                h=boxplot(peakvel1,G1,'boxstyle','filled','symbol','');
                for i = 1:size(h,2)                    
                    set(h(:,i),'color',cmap(mod(i+1,2)+1,:))
                end
                axis([0 5 0 1])
                [h,p] = ttest2(peakvel1(G1==1),peakvel1(G1==2));
                if h; text(1.5,1,sprintf('*\np=%1.3f',p),'horizontalalignment',...
                        'center','verticalalignment','top');  end
                [h,p] = ttest2(peakvel1(G1==3),peakvel1(G1==4));
                if h; text(3.5,1,sprintf('*\np=%1.3f',p),'horizontalalignment',...
                        'center','verticalalignment','top');  end

                title('Peak Velocity (1 mvmt)')
                set(gca,'xtick',1:4)
                text(-1,1.15,str,'horizontalalignment','center')
                
                
                subplot(2,4,6)         
                h=boxplot(latency2,G2,'boxstyle','filled','symbol','');
                for i = 1:size(h,2)                    
                    set(h(:,i),'color',cmap(mod(i+1,2)+1,:))
                end
                axis([0 5 0 0.3])
                title('Latency (COM)')
                set(gca,'xtick',1:4)
                
                subplot(2,4,7)                
                h=boxplot(peakvel2,G2,'boxstyle','filled','symbol','');
                for i = 1:size(h,2)                    
                    set(h(:,i),'color',cmap(mod(i+1,2)+1,:))
                end
                axis([0 5 0 1])
                title('Peak Velocity (COM)')
                set(gca,'xtick',1:4)
            end
        end
    end
end


%% voltage dependent effects
if poolFlag == 0
    perf2 = perf;
    if biasFlag
        perf2(:,2,:) = 1-perf2(:,2,:);
    end
    
    for m = 1:length(umice)
        for t = 1:length(utarg)
            
            ix = find(strcmp(utarg(t),target) & mice==umice(m));
            
            uvolt = unique(voltage(ix));
            
            if length(uvolt)>1
                volts = zeros(size(ix));
                for i = 1:length(ix)
                    volts(i) = find(voltage(ix(i))==uvolt);
                end
                
                figure
                set(gcf,'position',[1 393 1131 547])
                str = utarg{t};
                str(1) = upper(str(1));
                str(strfind(str,' '):end) = upper(str(strfind(str,' '):end));
                str = sprintf('%s (M%03d)',str,umice(m));
                
                for s = 1:2
                    for p = 1:3
                        subplot(2,3,3*s+p-3)
                        if p == 1; data = perf2*100;
                        elseif p == 2; data = miss*100;
                        else data = rt_all*1000; end
                        
                        for i = 1:length(uvolt)
                            mdata = mean(diff(data(:,s,ix(volts==i))),3);
                            sdata = std(diff(data(:,s,ix(volts==i))),[],3);
                            [h1,h2] = barwitherr(sdata,mdata);
                            set(h1,'xdata',i,'facecolor',cmap(1,:))
                            set(h2,'xdata',i,'linewidth',2)
                            hold on
                        end
                        plot(volts,squeeze(diff(data(:,s,ix))),'ok')
                        set(gca,'xtick',1:length(uvolt))
                        set(gca,'xticklabel',uvolt)
                        axis tight
                        xlim([0 length(uvolt)+1])
                        ylabel(['\Delta ' labels{p}])
                        if s==1
                            title([str ' - R stim']);
                        else
                            title([str ' - L stim']);
                        end
                    end
                end
                matchAxes([subplot(2,3,1) subplot(2,3,4)])
                matchAxes([subplot(2,3,2) subplot(2,3,5)])
                matchAxes([subplot(2,3,3) subplot(2,3,6)])
                
                if saveFlag
                    saved = false;
                    while ~saved
                        try
                            saveas(gcf,sprintf('%s %s volt-dep.fig',datestr(today,'yymmdd'),str))
                            saveas(gcf,sprintf('%s %s volt-dep.eps',datestr(today,'yymmdd'),str))
                            saveas(gcf,sprintf('%s %s volt-dep.tif',datestr(today,'yymmdd'),str))
                            saved = true;
                        catch
                            disp('retry...')
                            pause(1)
                        end
                    end
                end
                
            end
            
        end
    end
end