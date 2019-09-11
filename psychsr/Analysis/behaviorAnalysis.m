%% select files
psychsr_go_root();
cd ../behaviorData
[filelist, folder] = uigetfile('*.mat','MultiSelect','On');
if ~iscell(filelist)
    filelist = {filelist};
end
nfiles = length(filelist);

%%
condition_flag = 'laser time'; 
% condition_flag = 'delay + laser'; nconditions = [3 2];

switch condition_flag
    case 'laser'
        nconditions = 2;
        conditions = {'OFF','ON'};
        label = 'Laser';
    case 'laser time'
        conditions = Inf;
        for f = 1:length(filelist)
            load([folder filelist{f}])
            conditions = unique([conditions data.response.laser_onset]);            
        end
        conditions = conditions*1000;
        nconditions = length(conditions);
        label = 'Laser Onset Time (ms)';
    case 'delay + laser'
    case 'contrast'
        conditions = [];
        for f = 1:length(filelist)
            load([folder filelist{f}])
            conditions = unique([conditions data.stimuli.contrast]);            
        end
        conditions(conditions ==0) = [];
        conditions = conditions*100;
        nconditions = length(conditions);
        label = 'Contrast (%)';
end


%% extract behavioral data
targ = cell([nfiles,nconditions]);
ntarg = cell([nfiles,nconditions]);

for f = 1:length(filelist)
    
    % load file
    load([folder filelist{f}])
        
    % extract last lick, performance, orientation, contrast
    laststim = ceil(find(data.presentation.stim_times>max(data.response.licks),1)/3);
    perf = data.response.n_overall;
    ori = data.stimuli.orientation(3:3:end);
    con = data.stimuli.contrast(3:3:end);
    las = data.stimuli.laser_on(3:3:end);
    laststim=min(laststim,length(perf));
    
    if ~isempty(strfind(condition_flag,'laser'))
        firststim = find(las>0,1);
    else
        firststim = 1;
    end
    
%     disp(data.response.laser_target)
    
    % clip vectors to last lick
    perf = perf(firststim:laststim);
    ori = ori(firststim:laststim);
    con = con(firststim:laststim);
    las = las(firststim:laststim);

    switch condition_flag
        case 'laser'
            for i = 1:nconditions
                targ{f,i} = perf(ori == 90 & las == i-1);
                ntarg{f,i} = 1-perf(ori ~= 90 & las == i-1);
            end
            
        case 'laser time'
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
            
        case 'delay + laser'            
            
        case 'contrast'
            for i = 1:nconditions
                x = conditions(i)/100;
                targ{f,i} = perf(ori == 90 & con == x);
                ntarg{f,i} = 1-perf(ori ~= 90 & con == x);
            end
    end       
end
%% calculate stats
hits = cellfun(@mean,targ);
fas = cellfun(@mean,ntarg);

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
remove = (dprime(:,end) < 1) | (min(cellfun(@length,targ),[],2)<10);
hits(remove,:) = [];
fas(remove,:) = [];
dprime(remove,:) = [];


%% plot
figure
subplot(2,1,1)
cla
errorbar(nanmean(hits,1),nanstd(hits,[],1)./sqrt(sum(~isnan(hits),1)),'b','LineWidth',2)
hold on
errorbar(nanmean(fas,1),nanstd(fas,[],1)./sqrt(sum(~isnan(fas),1)),'r','LineWidth',2)
ylim([0 1])
legend('Hit%','FA%','Location','SouthEast')
set(gca,'XTick',1:nconditions)
set(gca,'XTickLabel',conditions)

subplot(2,1,2)
cla
errorbar(nanmean(dprime,1),nanstd(dprime,[],1)./sqrt(sum(~isnan(dprime),1)),'k','LineWidth',2)
hold on
plot(xlim,zeros(1,2),'k:')
ylim([-1 3])
ylabel('D-prime')
set(gca,'XTick',1:nconditions)
set(gca,'XTickLabel',conditions)
xlabel(label)

%% 
% figure
% subplot(2,1,1)
% plot(hits','b')
% hold on
% plot(fas','r')
% 
% subplot(2,1,2)
% plot(dprime','k')

%%
figure
delta = dprime(:,1:end-1)-repmat(dprime(:,end),1,size(dprime,2)-1);
bar(nanmean(delta),'FaceColor',[0.7 0.7 0.7])
hold on
x = repmat(1:size(delta,2),size(delta,1),1)+0.1*randn(size(delta));
plot(x',delta','ok','MarkerFaceColor','k')
set(gca,'XTickLabel',conditions(1:end-1))
xlabel(label)
ylabel('Change in D-prime')

for i = 1:size(delta,2)
	[p h] = signrank(delta(:,i));
    if h
        text(i,max(ylim),'*','VerticalAlignment','bottom','HorizontalAlignment','center','fontsize',16,'color','b')
    end
    text(i,max(ylim),sprintf('p=%1.3f',p),'VerticalAlignment','top','HorizontalAlignment','center','fontsize',14,'color','b')
end

% figure
% subplot(2,1,1)
% plot(allhits,'b')
% hold on
% plot(allfas,'r')
% xlim([0.5 nconditions+0.5])
% ylim([0 1])
% legend('Hit%','FA%','Location','SouthEast')
% set(gca,'XTick',1:nconditions)
% set(gca,'XTickLabel',conditions)
% 
% subplot(2,1,2)
% plot(alldprime,'k')
% xlim([0.5 nconditions+0.5])
% hold on
% plot(xlim,zeros(1,2),'k:')
% ylim([-1 3])
% set(gca,'XTick',1:nconditions)
% set(gca,'XTickLabel',conditions)
% xlabel(label)