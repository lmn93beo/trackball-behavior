% % function tb_learningcurve(saveFlag,reload)
% if nargin<1 || isempty(saveFlag)
%     saveFlag = 0;
% end
% if nargin<2 || isempty(reload)
%     reload = 0;
% end

psychsr_go_root;
cd ../behaviorData/trackball
home = pwd;

if ~exist('learningcurves.mat','file')
    reload = 0;
end

reload = 1;
if ~reload
    load('learningcurves.mat')
else
    
%     mice = [115,1,2,3,4];
%     maxdate = [30, 31,43,34,42] ;
    
    mice = [46]; %[3,4,12,17,18,19,20,24,26,28,30,31,38,29]; %3,4, 7,8,9
    maxdate = [33]; %[100 100 100 100 100 100 100 100 100 100 100 100 100] ;
%     maxdate = maxdate - 10;
    
    dates_all = cell(size(mice));
    trials_all = cell(size(mice));
    perf_all = cell(size(mice));
    %% notes about old mice (115, 001, 002)
    for m = 1:length(mice)
        cd(home)
        cd(sprintf('mouse %04d',mice(m)))
        fprintf('loading data from mouse %04d...\n',mice(m))
        files = dir('*.mat');
        alldates = cellfun(@(x) datenum(x(1:8),'yyyymmdd'),{files.name});
        
        dates = unique(alldates);
        perf = nan(length(dates),2,3);
        for d = 1:length(dates)
            dfiles = files(alldates==dates(d));
            [~,ix]=sort(cellfun(@(x) datenum(x,'dd-mmm-yyyy HH:MM:SS'),{dfiles.date}));
            dfiles = dfiles(ix);
            
            dloc = []; dchoice = [];
            for f = 1:length(dfiles)
                load(dfiles(f).name)
                
                % extract stimulus location and choice
                loc = []; choice = [];
                if isfield(data,'stimuli') && isfield(data.stimuli,'loc')
                    loc = data.stimuli.loc;
                elseif isfield (data,'stims')
                    loc = data.stims;
                end
                
                if isfield(data.response,'choice')
                    choice = data.response.choice;
                elseif isfield(data,'choice')
                    choice = data.choice;
                end
                
                if isfield(data.response,'reward')
                    n = find(data.response.reward>0,1,'last');
                else
                    if isfield(data.response,'n_left')
                        n = length(data.response.n_left) + length(data.response.n_right);
                        choice(n+1:end) = [];
                    end
                    n = find(choice<5,1,'last');
                end
                
                
                % exclude if non forced choice trials included
                if min(loc == 1 | loc == 2) == 0
                    continue;
                end
                if min(choice == 1 | choice == 2 | choice == 5) == 0
                    continue;
                end
                if isfield(data,'params') && isfield(data.params,'lever') && data.params.lever
                    continue;
                end
                if isfield(data,'params') && isfield(data.params,'laser') && data.params.laser
                    continue;
                end
                
                %         fprintf('%s: %1.2f %1.2f %d\n',dfiles(f).name,mean(choice==1),mean(choice==2),n)
                dloc = cat(2,dloc,loc(1:n));
                dchoice = cat(2,dchoice,choice(1:n));
                
            end
            if length(dloc) > 20 && dates(d) > 736053
                for s = 1:2
                    for c = 1:2
                        perf(d,s,c) = sum(dchoice(dloc==s)==c);
                    end
                    perf(d,s,3) = sum(dchoice(dloc==s)==5);
                end
            end
            
        end
        dates(isnan(perf(:,1,1))) = [];
        perf(isnan(perf(:,1,1)),:,:) = [];
        
        
        dates = dates-dates(1)+1;
        perfmean = mean([perf(:,1,1)./sum(perf(:,1,1:2),3), ...
            perf(:,2,2)./sum(perf(:,2,1:2),3)],2);
        perf_all{m} = perfmean;
        dates_all{m} = dates;
        trials_all{m} = cumsum(sum(sum(perf(:,2,1:2),3),2));
    end
    disp('Done.')
    cd(home)
    save('learningcurves.mat')
    
end
%% plots
figure
set(gcf,'position',[1   577   863   420])
subplot(1,4,1:3)
newmax = cellfun(@max,dates_all);
maxdate(maxdate>newmax) = newmax(maxdate>newmax);

meancurve = nan(length(mice),max(maxdate));
thresh = nan(length(mice),1);
for m = 1:length(mice)
    hold all
    ix = dates_all{m}<=maxdate(m);
    ix(ix(1:10)) = 0; 
    temp = dates_all{m}(find(perf_all{m}(ix)>0.70,1)+10);
    if ~isempty(temp)
        thresh(m) = temp;
    end
    
    dum = interp1(dates_all{m}(ix),perf_all{m}(ix),1:max(dates_all{m}(ix)));
    meancurve(m,1:numel(dum)) = dum;
    
    plot(dates_all{m}(ix),perf_all{m}(ix)*100)%,'color',[0.7 0.7 0.7])
end
axis tight;
ylim([floor(min(ylim)/10)*10,100])
plot(smooth(nanmean(meancurve))*100,'k','linewidth',3)
plot(xlim,[0.5 0.5]*100,':k')
xlabel('Days')
ylabel('Performance (%)')
title('Learning curve')
legend(cellfun(@num2str,num2cell(mice),'uniformoutput',0),'location','best')

subplot(1,4,4)
for m = 1:length(mice)
    hold all
    scatter(1,thresh(m),'o','filled')
end
plot([0.5 1.5],mean(thresh)*[1 1],'k','linewidth',2)
axis([0 2 0, max(ylim)])
set(gca,'xtick',1)
set(gca,'ytick',0:10:max(ylim))
title(sprintf('Days to criterion'))
set(gca,'xticklabel',[])

if saveFlag
cd figures
saveas(gcf,sprintf('%slearningcurves.fig',datestr(today,'yymmdd')))
saveas(gcf,sprintf('%slearningcurves.eps',datestr(today,'yymmdd')))
saveas(gcf,sprintf('%slearningcurves.tif',datestr(today,'yymmdd')))
end