%% parameters
performance_threshold = 1;
difference_threshold = 0.3;
n_hit_threshold = 3; % min # of trials per session
n_fa_threshold = 3; 
plotAllEpoch = 0;
plotMeanPerf = 0;
plotLickRate = 1;
autoLoad = 0;
trimBlocks = 1;

if autoLoad
    all_paths = {'C:\Dropbox\MouseAttention\behaviorData\mouse 0088\',...
        'C:\Dropbox\MouseAttention\behaviorData\mouse 0089\'};
    first_files = {'20131007_discrim_0088_bV1_Stim_begin28mW.mat',...
        '20131006_discrim_0089_bV1_Stim.mat'};
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
        idx = find(strcmpi(filelist,first_files{i}));
        all_files{i} = filelist(idx:end);
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
targets = {'Bilateral V1','Bilateral PPC','Bilateral M2'};
epochs = {'stim','delay','resp','all'};

% initialize cell array of structures
all_blocks = cell(length(targets),length(epochs));
all_hit = all_blocks;
all_fa = all_blocks;
all_dprime = all_blocks;
all_perf = all_blocks;
all_lick = all_blocks;
all_mice = all_blocks;

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
        
        % extract laser status
        if isfield(data.stimuli,'laser_on') && max(data.stimuli.laser_on)
            las = data.stimuli.laser_on(3:3:end);
            l_on = true;
            if data.response.n_nolaser>100
                firststim = 1;
            else
                firststim = data.response.n_nolaser+1;
            end
        else
            las = zeros(size(perf));
            l_on = false;
            firststim = 1;
        end
        
        if ~l_on || ~isfield(data.response,'laser_target')
            fprintf('Skipped %s: No Laser.\n',filelist{f})
            continue;
        end
        
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
            d = unique(del);
            
            mean_perf = zeros(length(d),1+l_on);
            resp_all = cell(2,length(d),1+l_on);
            for i = 1:1+l_on
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
            lick_rate(1) = mean([resp_all{:,3,1}]);
            lick_rate(2) = mean([resp_all{:,3,2}]);
            % lick_rate = squeeze(meanresp_mean(:,3,:)))';
            
            behav_mat = [squeeze([resp_mean(:,3,:); resp_dprime(:,3,:)]); ...
                mean_perf(3,:); lick_rate];
            % rows = hits, FA, dprime, mean performance, lick rate
            % cols = las off, las on
            
            fewTrials = min(ntrials(1,3,:))< n_hit_threshold || min(ntrials(2,3,:))< n_fa_threshold;
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
%         if isfield(data.response,'laser_epoch')
%             laser_epoch = data.response.laser_epoch;
        if data.response.laser_onset == -0.1 
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
        end
    end
end

%% plot
close all

markers = {'o','s','v','d','h'};
for x = 1:length(targets)
    if ~isempty([all_hit{x,:}])
        figure
        for y = 1:length(epochs)-1+plotAllEpoch
            if ~isempty(all_hit{x,y})
                ddprime = diff(all_dprime{x,y});
                for m = 1:nmice
                    m_ind = all_mice{x,y} == mice(m);
                    if sum(m_ind)>0
                        subplot(3,1,1)
                        hold on
                        plot([-1 0]+2*y,all_hit{x,y}(:,m_ind),':bo')
                        plot([-1 0]+2*y,all_fa{x,y}(:,m_ind),':ro')
                        if plotMeanPerf
                            plot([-1 0]+2*y,all_perf{x,y}(:,m_ind),':ko')
                        end
                        
                        subplot(3,1,2)
                        hold on
                        plot([-1 0]+2*y,all_dprime{x,y}(:,m_ind),':ko')
                        
                        subplot(3,1,3)
                        hold on
                        if plotLickRate
                            plot([-1 0]+2*y,all_lick{x,y}(:,m_ind),':ko')
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
        nconditions = 3+plotAllEpoch;
        
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

alpha = 0.05/9;
[H,P] = ttest(all_dprime{1,1}(1,:),all_dprime{1,1}(2,:),alpha);
disp(['V1 stim: H = ' num2str(H) ' P = ' num2str(P*9)])
[H,P] = ttest(all_dprime{1,2}(1,:),all_dprime{1,2}(2,:),alpha);
disp(['V1 delay: H = ' num2str(H) ' P = ' num2str(P*9)])
[H,P] = ttest(all_dprime{1,3}(1,:),all_dprime{1,3}(2,:),alpha);
disp(['V1 resp: H = ' num2str(H) ' P = ' num2str(P*9)])
[H,P] = ttest(all_dprime{2,1}(1,:),all_dprime{2,1}(2,:),alpha);
disp(['PPC stim: H = ' num2str(H) ' P = ' num2str(P*9)])
[H,P] = ttest(all_dprime{2,2}(1,:),all_dprime{2,2}(2,:),alpha);
disp(['PPC delay: H = ' num2str(H) ' P = ' num2str(P*9)])
[H,P] = ttest(all_dprime{2,3}(1,:),all_dprime{2,3}(2,:),alpha);
disp(['PPC resp: H = ' num2str(H) ' P = ' num2str(P*9)])
[H,P] = ttest(all_dprime{3,1}(1,:),all_dprime{3,1}(2,:),alpha);
disp(['fMC stim: H = ' num2str(H) ' P = ' num2str(P*9)])
[H,P] = ttest(all_dprime{3,2}(1,:),all_dprime{3,2}(2,:),alpha);
disp(['fMC delay: H = ' num2str(H) ' P = ' num2str(P*9)])
[H,P] = ttest(all_dprime{3,3}(1,:),all_dprime{3,3}(2,:),alpha);
disp(['fMC resp: H = ' num2str(H) ' P = ' num2str(P*9)])