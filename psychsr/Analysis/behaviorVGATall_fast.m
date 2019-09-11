mintrials = 0;
dthresh = 0.9;

%% select files
% psychsr_go_root();
% cd ../behaviorData
[filelist, folder] = uigetfile('*.mat','MultiSelect','On');
if ~iscell(filelist)
    filelist = {filelist};
end
nfiles = length(filelist);

targets = {'Bilateral V1','Bilateral PPC','Bilateral M2'};

%% conditions
conditions = Inf;
for f = 1:length(filelist)
    load([folder filelist{f}])
    conditions = unique([conditions data.response.laser_onset]);
end
conditions = conditions*1000;
nconditions = length(conditions);
label = 'Laser Onset Time (ms)';

%% extract behavioral data

targ = cell([nfiles,nconditions]);
ntarg = cell([nfiles,nconditions]);
areas = zeros(nfiles,1);

for f = 1:length(filelist)
    
    % load file
    load([folder filelist{f}])
        
    % identify laser target
    laser_target = data.response.laser_target;
    x = find(strcmpi(laser_target,targets));
    while isempty(x)
        fprintf('Invalid laser target for file %s: %s\n',filelist{f},laser_target)
        laser_target = input('Reinput laser target: ','s');
        data.response.laser_target = laser_target;
        save([pathname filelist{f}],'data')
        fprintf('Resaved file %s\n',filelist{f})
        x = find(strcmpi(laser_target,targets));
    end
    areas(f) = x;
    
    % extract last lick, performance, orientation, contrast
    laststim = ceil(find(data.presentation.stim_times>max(data.response.licks),1)/3);
    perf = data.response.n_overall;
    ori = data.stimuli.orientation(3:3:end);
    con = data.stimuli.contrast(3:3:end);
    las = data.stimuli.laser_on(3:3:end);
    laststim=min(laststim,length(perf));
        
    firststim = find(las>0,1);
    
%     disp(data.response.laser_target)
    
    % clip vectors to last lick
    perf = perf(firststim:laststim);
    ori = ori(firststim:laststim);
    con = con(firststim:laststim);
    las = las(firststim:laststim);
   
    for i = 1:nconditions
        x = find(conditions(i)/1000 == data.response.laser_onset);
        if conditions(i) == Inf
            x = 0;
        elseif isempty(x)
            x = NaN;
        end
        targ{f,i} = perf(ori == 90 & las == x);
        ntarg{f,i} = 1-perf(ori ~= 90 & las == x);
    end
    
end
%% calculate stats
hits = cellfun(@mean,targ);
fas = cellfun(@mean,ntarg);
ntrials = min([cellfun(@length,targ),cellfun(@length,ntarg)],[],2);

h = hits; h(h>0.99) = 0.99; h(h<0.01) = 0.01;
f = fas; f(f>0.99) = 0.99; f(f<0.01) = 0.01;
dprime = norminv(h,0,1)-norminv(f,0,1);

avg = cellfun(@mean,cat_cell(targ,[cellfun(@(x) {1-x},ntarg)]));
% avg = mean(cat(3,hits,1-fas),3);

for i = 1:nconditions
    allhits(i) = mean([targ{:,i}]);
    allfas(i) = mean([ntarg{:,i}]);
end
h = allhits; h(h>0.99) = 0.99; h(h<0.01) = 0.01;
f = allfas; f(f>0.99) = 0.99; f(f<0.01) = 0.01;
alldprime = norminv(h,0,1)-norminv(f,0,1);

%% remove data sets
remove = (dprime(:,end) < dthresh) | (ntrials<mintrials);
hits(remove,:) = [];
fas(remove,:) = [];
dprime(remove,:) = [];
areas(remove,:) = [];
ntrials(remove,:) = [];

%% remove conditions
cond_include = [0 250 500 Inf];
hits = hits(:,ismember(conditions,cond_include));
fas = fas(:,ismember(conditions,cond_include));
dprime = dprime(:,ismember(conditions,cond_include));
conditions = conditions(ismember(conditions,cond_include));
nconditions = length(conditions);

%% plot
for a = 1:length(targets)
    if sum(areas == a) > 0
    figure
    setFigSize(3,a)
    
    subplot(3,1,1)
    cla
    errorbar(nanmean(hits(areas==a,:),1),nanstd(hits(areas==a,:),[],1)./sqrt(sum(~isnan(hits(areas==a,:)),1)),'b','LineWidth',2)
    hold on
    errorbar(nanmean(fas(areas==a,:),1),nanstd(fas(areas==a,:),[],1)./sqrt(sum(~isnan(fas(areas==a,:)),1)),'r','LineWidth',2)
    ylim([0 1])
    legend('Hit%','FA%','Location','SouthEast')
    set(gca,'XTick',1:nconditions)
    set(gca,'XTickLabel',conditions)
    title(targets{a})
    
    subplot(3,1,2)
    cla
    errorbar(nanmean(dprime(areas==a,:),1),nanstd(dprime(areas==a,:),[],1)./sqrt(sum(~isnan(dprime(areas==a,:)),1)),'k','LineWidth',2)
    hold on
    plot(xlim,zeros(1,2),'k:')
    ylim([-1 3])
    ylabel('D-prime')
    set(gca,'XTick',1:nconditions)
    set(gca,'XTickLabel',conditions)
    xlabel(label)
    
    subplot(3,1,3)
    delta = dprime(areas==a,1:end-1)-repmat(dprime(areas==a,end),1,size(dprime,2)-1);
    bar(nanmean(delta,1),'FaceColor',[0.7 0.7 0.7])
    hold on
    x = repmat(1:size(delta,2),size(delta,1),1)+0.1*randn(size(delta));
    plot(x',delta','ok','MarkerFaceColor','k')
    set(gca,'XTickLabel',conditions(1:end-1))
    xlabel(label)
    ylabel('Change in D-prime')
    
    for i = 1:size(delta,2)
        if sum(~isnan(delta(:,i)))>1
            [p h] = signrank(delta(:,i));
            if h
                text(i,max(ylim),'*','VerticalAlignment','bottom','HorizontalAlignment','center','fontsize',16,'color','b')
            end
            text(i,max(ylim),sprintf('p=%1.3f',p),'VerticalAlignment','top','HorizontalAlignment','center','fontsize',14,'color','b')
        end
    end
    end    
end
