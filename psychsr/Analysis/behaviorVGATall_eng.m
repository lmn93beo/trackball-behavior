function [P,all_mice,all_dprime,all_hit,all_fa] = behaviorVGATall_eng(autoLoad)
if nargin<1
    autoLoad = 1;
end
%% parameters
performance_threshold = 1;
difference_threshold = 0.3;
n_hit_threshold = 10; % min # of trials per session
n_fa_threshold = 10; 
plotAllEpoch = 0;
plotMeanPerf = 0;
plotLickRate = 1;
% autoLoad = 0;
trimBlocks = 1;

if autoLoad
%     cd('C:\Users\mikeg\Dropbox\MouseAttention\behaviorData\Eng Behavior'); root=pwd;
    psychsr_go_root;  cd('..\behaviorData\Eng VGAT\'); root = pwd;
    all_paths = dir('mouse*');
    all_paths = cellfun(@(x) {[root '\' x '\']},{all_paths(:).name});
end

%% load files
% try
%     cd('C:\Dropbox\MouseAttention\behaviorData')
% catch
%     cd('C:\Users\mikeg\Dropbox\MouseAttention\behaviorData')
% end
nmice = 0;
loadFlag = 1;
all_files = {};
if autoLoad
    nmice = length(all_paths);
    for i = 1:nmice
        cd(all_paths{i})
        filelist = dir('*.mat');
        filelist = sort({filelist(:).name});
        all_files{i} = filelist;
    end
else
    all_paths = {};
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
        all_files{nmice} = filelist;
        all_paths{nmice} = pathname;
    end
end
mice = cellfun(@(x) str2double(x(end-4:end-1)),all_paths);
%% extract responses
targets = {'Bilateral V1','Bilateral PPC'};
epochs = {'stim','resp'};

% initialize cell array of structures
all_blocks = cell(length(targets),length(epochs));
all_hit = all_blocks;
all_fa = all_blocks;
all_dprime = all_blocks;
all_perf = all_blocks;
all_lick = all_blocks;
all_mice = all_blocks;
all_lickpsth = all_blocks;
all_rt = all_blocks;
per_las = [];

for m = 1:nmice
    pathname = all_paths{m};
    filelist = all_files{m};
    for f = 1:length(filelist)
        load([pathname filelist{f}]) 
        laststim = ceil(find(data.presentation.stim_times>max(data.response.licks),1)/3);
        if isempty(laststim)
            laststim = ceil(length(data.presentation.stim_times)/3);
        end
        perf = data.response.n_overall;
        ori = data.stimuli.orientation(3:3:end);
        del = data.stimuli.response_delay(3:3:end);
        laststim = min(laststim,length(perf));
        licks = data.response.licks;
        
        % extract laser status
        if isfield(data.stimuli,'laser_on') && max(data.stimuli.laser_on)
            las = data.stimuli.laser_on(3:3:end);
            l_on = true;
            firststim = data.response.n_nolaser+1;
        else
            las = zeros(size(perf));
            l_on = false;
            firststim = 1;
        end
        
        if ~l_on || ~isfield(data.response,'laser_target')
            fprintf('Skipped %s: No Laser.\n',filelist{f})
            continue;
        end
        
        trials = 1:length(perf);
        
        trimCtr = 1;                
        while trimCtr == 1 || (trimBlocks && ~fewTrials && lowPerf)
            if trimCtr > 1
                firststim = 2;
                laststim = length(perf);
                if trimCtr == 2
                    fprintf('Trimming %s due to low performance...\n',filelist{f})
                end
            end
            trimCtr = trimCtr+1;
            
            % clip vectors to last lick
            perf = perf(firststim:laststim);
            ori = ori(firststim:laststim);
            las = las(firststim:laststim);
            del = del(firststim:laststim);
            trials = trials(firststim:laststim);
            d = unique(del);
            
            mean_perf = zeros(length(d),length(unique(las)));
            resp_all = cell(2,length(d),length(unique(las)));
            for i = 1:length(unique(las))
                for j = 1:length(d)
                    for k = 1:2
                        ori_ind = (3-2*k)*(ori==90)+(k-1); % x for k=1, 1-x for k=2
                        resp_all{k,j,i} = (3-2*k)*perf(ori_ind & del==d(j) & las==i-1)+(k-1);
                    end
                    mean_perf(j,i) = mean(perf(del == d(j) & las==i-1));
                end
            end
            ntrials = cellfun(@length,resp_all);
            resp_mean = cellfun(@mean,resp_all);
            resp_mean(resp_mean>0.99) = 0.99;
            resp_mean(resp_mean<0.01) = 0.01;
            resp_dprime = -diff(norminv(resp_mean,0,1));
                        
            clear lick_rate
            for i = 1:length(unique(las))
                lick_rate(i) = mean([resp_all{:,1,i}]);
            end
            
            % lick PSTH
            reactiontimes = cell(2,length(d),length(unique(las)));
            licktimes = cell(2,length(d),length(unique(las)));
            licktrials = cell(2,length(d),length(unique(las)));
            licknumtrials = zeros(size(licktimes));
            
            test = nan(length(trials),2);
            for t = 1:length(trials)                
                start = data.presentation.stim_times(trials(t)*3-1);
                stop = data.presentation.stim_times(trials(t)*3+1);
                extend = data.response.extends(find(data.response.extends>start,1));
                retract = data.response.retracts(find(data.response.retracts>start,1));
                
                test(t,1) = extend-start;
                test(t,2) = retract-start;
                
                tlicks = licks(licks>start & licks<stop) - start;
                
                if ~isempty(tlicks)
                    k = (ori(t)==90)+1;
                    j = find(del(t)==d);
                    
                    i = las(t)+1;
                    n = licknumtrials(k,j,i) + 1;
                    reactiontimes{k,j,i} = cat(1,reactiontimes{k,j,i},min(tlicks));
                    licktimes{k,j,i} = cat(1,licktimes{k,j,i},tlicks);
                    licktrials{k,j,i} = cat(1,licktrials{k,j,i},n*ones(size(tlicks)));
                    licknumtrials(k,j,i) = n;
                end
            end
            time_vec = linspace(-0.8,6.6,38)';
            lickpsth = zeros(2,size(licktimes,3),length(time_vec));            
            for i = 1:2
                for j = 1:size(licktimes,3)
                    lickpsth(i,j,:) = hist(licktimes{i,1,j},time_vec)/licknumtrials(i,1,j)*5;
                end
            end
            
            % lick_rate = squeeze(meanresp_mean(:,3,:)))';
            
            behav_mat = [squeeze([resp_mean(:,1,:); resp_dprime(:,1,:)]); ...
                mean_perf(end,:); lick_rate];
            % rows = hits, FA, dprime, mean performance, lick rate
            % cols = las off, las on
            
            fewTrials = min(ntrials(1,1,:))< n_hit_threshold || min(ntrials(2,1,:))< n_fa_threshold;
            lowPerf = behav_mat(3,1) < performance_threshold || (behav_mat(1,1)-behav_mat(2,1)) < difference_threshold;
        end
        
        if trimBlocks && trimCtr > 2 && ~fewTrials
            fprintf('Trimmed %d trials, using %d trials from %s.\n',(trimCtr-2)*5,length(perf),filelist{f})
            fprintf('   Baseline Hit trials = %d\n',ntrials(1,3,1));            
            fprintf('   Laser Hit trials    = %d\n',ntrials(1,3,2));    
            fprintf('   Baseline Fas trials = %d\n',ntrials(2,3,1));  
            fprintf('   Laser Fas trials    = %d\n',ntrials(2,3,2));  
        end

        laser_target = data.response.laser_target;
        if length(data.response.laser_onset) > 1
            % multiple  
            laser_epoch = {'stim', 'resp'};
        elseif isfield(data.response,'laser_epoch')
            laser_epoch = data.response.laser_epoch;        
        elseif data.response.laser_onset == -0.1 
            if data.response.laser_time == 2.2;
                laser_epoch = 'stim';
            else
                laser_epoch = 'all';
            end
        elseif data.response.laser_onset == 2.9
            laser_epoch = 'delay';
        else
            laser_epoch = 'resp';
        end
        laser_power = data.response.laser_power;        
%         disp(filelist{f})
%         disp(laser_power)
        mouse = data.mouse;
        
        temp_struct = struct_zip(mouse,laser_target,laser_epoch,laser_power,behav_mat);
        
        x = find(strcmpi(laser_target,targets));
        y = find(strcmpi(laser_epoch,epochs));
        
        while isempty(x)
            fprintf('Invalid laser target for file %s\n',filelist{f})
            laser_target = input('Reinput laser target: ','s');
            data.response.laser_target = laser_target;
            save([pathname filelist{f}],'data')
            fprintf('Resaved file %s\n',filelist{f})
            x = find(strcmpi(laser_target,targets));
        end 
        
        if fewTrials
            fprintf('Skipped %s due to too few trials.\n',filelist{f})
            fprintf('   Baseline Hit trials = %d\n',ntrials(1,3,1));            
            fprintf('   Laser Hit trials    = %d\n',ntrials(1,3,2));    
            fprintf('   Baseline Fas trials = %d\n',ntrials(2,3,1));  
            fprintf('   Laser Fas trials    = %d\n',ntrials(2,3,2));  
        elseif lowPerf
            fprintf('Skipped %s due to low performance.\n',filelist{f})
            fprintf('   Baseline d-prime = %1.2f\n',behav_mat(3,1));            
            fprintf('   Baseline Hits    = %1.2f\n',behav_mat(1,1)*100);    
            fprintf('   Baseline Fas     = %1.2f\n',behav_mat(2,1)*100);  
        elseif length(y) > 1
            for i = 1:length(y)
                all_blocks{x,y(i)}(end+1) = temp_struct;
                all_hit{x,y(i)}(:,end+1) = behav_mat(1,[1 i+1]);
                all_fa{x,y(i)}(:,end+1) = behav_mat(2,[1 i+1]);
                all_dprime{x,y(i)}(:,end+1) = behav_mat(3,[1 i+1]);
                all_perf{x,y(i)}(:,end+1) = behav_mat(4,[1 i+1]);
                all_lick{x,y(i)}(:,end+1) = behav_mat(5,[1 i+1]);
                all_mice{x,y(i)}(end+1) = mouse;
                
                all_lickpsth{x,y(i)}(:,:,:,end+1) = lickpsth(:,[1 i+1],:);
                all_rt{x,y(i)}(:,:,end+1) = squeeze(reactiontimes(:,1,[1 i+1]));
            end
            
        elseif isempty(y)
            fprintf('Skipped %s: invalid epoch %s.\n',filelist{f},laser_epoch);
        else
            % x = target index
            % y = epoch index
            all_blocks{x,y}(end+1) = temp_struct;
            all_hit{x,y}(:,end+1) = behav_mat(1,:);
            all_fa{x,y}(:,end+1) = behav_mat(2,:);
            all_dprime{x,y}(:,end+1) = behav_mat(3,:);
            all_perf{x,y}(:,end+1) = behav_mat(4,:);
            all_lick{x,y}(:,end+1) = behav_mat(5,:);
            all_mice{x,y}(end+1) = mouse;
                        
            all_lickpsth{x,y}(:,:,:,end+1) = lickpsth;            
            all_rt{x,y}(:,:,end+1) = squeeze(reactiontimes(:,1,:));
            
            fprintf('Laser on %2.0f%% of trials\n',100*mean(las==1))
            per_las(end+1) = mean(las==1);
        end
    end
end
fprintf('AVG Laser on %2.0f%% of trials\n',100*mean(per_las))

%% plot
close all

markers = {'o','s','v','d','h'};
for x = 1:length(targets)
    if ~isempty([all_hit{x,:}])
        figure
        for y = 1:length(epochs)+plotAllEpoch
            if ~isempty(all_hit{x,y})
                ddprime = diff(all_dprime{x,y});
                for m = 1:nmice
                    m_ind = all_mice{x,y} == mice(m);
                    if sum(m_ind)>0
                        subplot(3,1,1)
                        hold on
                        plot([-1 0]+2*y,all_hit{x,y}(:,m_ind),[':b' markers{m}])
                        plot([-1 0]+2*y,all_fa{x,y}(:,m_ind),[':r' markers{m}])
                        if plotMeanPerf
                            plot([-1 0]+2*y,all_perf{x,y}(:,m_ind),[':k' markers{m}])
                        end
                        
                        subplot(3,1,2)
                        hold on
                        plot([-1 0]+2*y,all_dprime{x,y}(:,m_ind),[':k' markers{m}])
                        
                        subplot(3,1,3)
                        hold on
                        if plotLickRate
                            plot([-1 0]+2*y,all_lick{x,y}(:,m_ind),[':k' markers{m}])
                        else
                            plot(y+randn(1,sum(m_ind))/15,ddprime(m_ind),['k' markers{m}])
                        end
                    end
                end
                % means
                subplot(3,1,1)
                plot([-1 0]+2*y,mean(all_hit{x,y},2),'b','LineWidth',3)
                plot([-1 0]+2*y,mean(all_fa{x,y},2),'r','LineWidth',3)
                if plotMeanPerf
                    plot([-1 0]+2*y,mean(all_perf{x,y},2),'k','LineWidth',3)
                end
                subplot(3,1,2)
                plot([-1 0]+2*y,mean(all_dprime{x,y},2),'k','LineWidth',3)
                subplot(3,1,3)
                if plotLickRate
                    plot([-1 0]+2*y,mean(all_lick{x,y},2),'k','LineWidth',3)
                else
                    plot([-0.2 0.2]+y,mean(ddprime)*ones(1,2),'k','LineWidth',3)
                end
            end
        end
        %     nconditions = sum(~cellfun(@isempty,all_hit(x,:)));
        %     if nconditions == 4 && plotAllEpoch == 0
        %         nconditions = 3;
        %     end
        nconditions = 2+plotAllEpoch;
        
        subplot(3,1,1)
        title(targets{x})
        ylabel('Hit/FA rate %')
        set(gca,'XTick',0.5+(1:2:nconditions*2))
        set(gca,'XTickLabel',epochs(1:nconditions))
        xlim([0.5 nconditions*2+0.5]);
        ylim([0 1])
        h=get(gca,'Children');
        if plotMeanPerf
            plot(xlim,0.5*ones(2,1),':k')
            legend(h([3 2 1]),'Hit%','FA%','Perf%','Location','SouthEast')
        else
            legend(h([2 1]),'Hit%','FA%','Location','SouthEast')
        end
        
        subplot(3,1,2)
        ylabel('Dprime')
        set(gca,'XTick',0.5+(1:2:nconditions*2))
        set(gca,'XTickLabel',epochs(1:nconditions))
        xlim([0.5 nconditions*2+0.5]);
        plot(xlim,zeros(1,2),':k')
        ylim([-1 4])
        
        subplot(3,1,3)                
        if plotLickRate
            ylabel('Lick%')
            set(gca,'XTick',0.5+(1:2:nconditions*2))
            set(gca,'XTickLabel',epochs(1:nconditions))
            xlim([0.5 nconditions*2+0.5]);
            ylim([0 1])
        else
            ylabel('\DeltaDprime')
            set(gca,'XTick',1:nconditions)
            set(gca,'XTickLabel',epochs(1:nconditions))
            xlim([0.5 nconditions+0.5]);
            plot(xlim,zeros(1,2),':k')
            legend(cellfun(@(x) {num2str(x)},num2cell(unique([all_mice{x,:}]))))
        end
        
        pos = get(0,'screensize');
        pos(2) = 40; pos(4) = pos(4) - pos(2);
        pos(3) = pos(3)/length(targets);
        pos(1) = pos(1) + pos(3)*(x-1);
        set(gcf,'OuterPosition',pos)
        set(gcf,'color',[1 1 1])
    end
end

n = 4;
alpha = 0.05/n;
H = zeros(length(targets),length(epochs));
P = zeros(length(targets),length(epochs));
for x = 1:length(targets)
    for y = 1:length(epochs)
        [H(x,y),P(x,y)] = ttest(all_dprime{x,y}(1,:),all_dprime{x,y}(2,:),alpha);
    end
end

%%
close all
figure
for x = 1:length(targets)       
    for y = 1:length(epochs)        
        subplot(2,4,y+x*4-4)
        means = mean(all_dprime{x,y},2);
        errs = std(all_dprime{x,y},[],2)/sqrt(size(all_dprime{x,y},2));
        
        barwitherr(errs(2),means(2),'FaceColor',[0.2 0.7 1]);
        h = get(gca,'Children');
        set(h(1:2),'XData',2); hold on
        h = barwitherr(errs(1),means(1),'FaceColor',[0.7 0.7 0.7]);
        set(gca,'xtick',[])
        axis([0 3 0 3.1])
        box off
        
        subplot(2,4,x*4-2+(1:2))
        hold on
        plot([-1 0]+1.5*y,all_hit{x,y},'Color',[0.5 0.5 1])
        plot([-1 0]+1.5*y,all_fa{x,y},'Color',[1 0.5 0.5])
        plot([-1 0]+1.5*y,mean(all_hit{x,y},2),'-ob','LineWidth',3,'MarkerFaceColor','b','MarkerSize',3)
        plot([-1 0]+1.5*y,mean(all_fa{x,y},2),'-or','LineWidth',3,'MarkerFaceColor','r','MarkerSize',3)
        axis([0.25 3.25 0 1])
        set(gca,'Xtick',[])
        set(gca,'Yaxislocation','right')
        set(gca,'xcolor',[1 1 1])
        
    end
end

figure
for x = 1:length(targets)       
    for y = 1:length(epochs)        
        subplot(2,2,y+x*2-2)
        plot(all_dprime{x,y},'color',[0.2 0.2 0.2])
        axis([0 3 -0.6 5])
        
        hold on
        plot(xlim,[0 0],':k')
        set(gca,'xtick',[])
        ylabel('D-prime')
    end
end

figure
for x = 1:length(targets)       
    subplot(2,1,x)
    hold on
    for y = 1:length(epochs)        
        plot(y+0.1*randn(1,size(all_dprime{x,y},2)),diff(all_dprime{x,y}),'o','color',[0.2 0.2 0.2])
        axis([0 3 -4 2])
        
        plot(y+[-0.2 0.2],mean(diff(all_dprime{x,y}))*ones(1,2),'r','linewidth',2)
        
    end
    plot(xlim,[0 0],':k')
    set(gca,'xtick',[])
    ylabel('\Delta D-prime')
end


%% per mouse
figure

for x = 1:length(targets)       
    for y = 1:length(epochs)      
        mperf = nan(2,nmice);
        mhit = nan(2,nmice);
        mfa = nan(2,nmice);
        for m = 1:nmice
            m_ind = all_mice{x,y} == mice(m);
            mperf(:,m) = mean(all_dprime{x,y}(:,m_ind),2);
            mhit(:,m) = mean(all_hit{x,y}(:,m_ind),2);
            mfa(:,m) = mean(all_fa{x,y}(:,m_ind),2);
        end
        
        subplot(2,4,y+x*4-4)
        means = nanmean(mperf,2);
        errs = nanstd(mperf,[],2)/sqrt(sum(~isnan(mperf(1,:))));        
        barwitherr(errs(2),means(2),'FaceColor',[0.2 0.7 1]);
        h = get(gca,'Children');
        set(h(1:2),'XData',2); hold on
        h = barwitherr(errs(1),means(1),'FaceColor',[0.7 0.7 0.7]);
        set(gca,'xtick',[])
        axis([0 3 0 3.1])
        box off
        if H(x,y)
            s = 'p<0.01';
            text(2,errs(2)+means(2)+0.1,'*','HorizontalAlignment','center','VerticalAlignment','bottom'); 
        else
            s = '';            
        end
        
        text(1.5,3.3,sprintf('n=%d\n%s',sum(~isnan(mperf(1,:))),s),...
            'HorizontalAlignment','center','VerticalAlignment','top','FontSize',12)
        
        subplot(2,4,x*4-2+(1:2))
        hold on
        plot([-1 0]+1.5*y,mhit,'Color',[0.5 0.5 1])
        plot([-1 0]+1.5*y,mfa,'Color',[1 0.5 0.5])
        plot([-1 0]+1.5*y,nanmean(mhit,2),'-ob','LineWidth',3,'MarkerFaceColor','b','MarkerSize',3)
        plot([-1 0]+1.5*y,nanmean(mfa,2),'-or','LineWidth',3,'MarkerFaceColor','r','MarkerSize',3)
        axis([0.25 3.25 0 1])
        set(gca,'Xtick',[])
        set(gca,'Yaxislocation','right')
        set(gca,'xcolor',[1 1 1])
    end
end

%% lick psth
cmap = [0 0 0; 0.2 0.7 1];
figure
for x = 1:2
    for y = 1:2
        subplot(2,2,y+x*2-2)
        hold on
        licks = all_lickpsth{x,y};
        for t = 1:2
            for l = 1:2                
                h1 = plotSingleResp(time_vec,sign(t-1.5)*squeeze(licks(t,l,:,:)),'alpha','cmap',cmap(l,:));
                set(h1,'linewidth',2)
                if t == 1
                    set(h1,'linestyle','--')
                end
            end
        end
        axis tight
        ylim([-6 8])
        patch([0 0 2 2 0],min(ylim)+range(ylim)*[0 1 1 0 0],[0.7 0.7 0.7],'edgecolor','none','FaceAlpha',0.5)
    end
end
%%
figure

x = 2; y = 1;
licks = all_lickpsth{x,y};
for i = 1:length(all_mice{x,y})
    clf
    
    for t = 1:2
        for l = 1:2
            subplot(1,2,1)
            hold on
            plot(time_vec,sign(t-1.5)*squeeze(licks(t,l,:,i+1)),'color',cmap(l,:))
                        
            subplot(1,2,2)
            hold on
            rt = all_rt{x,y}{t,l,i+1};
            if ~isempty(rt)
                bins = linspace(0,1.5,41);
                n = hist(rt-2,bins);
                plot(bins,n*sign(t-1.5),'color',cmap(l,:))
            end
        end
    end    
    subplot(1,2,1)
    title(sprintf('%d - Mouse %d',i,all_mice{x,y}(i)))
    axis tight
    
    subplot(1,2,2)
    axis tight
    shg
%     pause
end
