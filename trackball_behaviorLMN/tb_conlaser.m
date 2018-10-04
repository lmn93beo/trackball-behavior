conthresh = 0.1;
[files folder] = uigetfile('*.mat','multiselect','on');
cd(folder)
if ~iscell(files); files = {files}; end

alldata = zeros(2,11,4);
allpooled = zeros(2,3,4);
%% load data
for f = 1:length(files)
    
    load(files{f})
    
    n = find(data.response.reward>0,1,'last');
    choice = data.response.choice(1:n);
    loc = data.stimuli.loc(1:n);
    contrast = data.stimuli.contrast(1:n);
    laser = data.stimuli.laser(1:n);
    
    ucon = unique(contrast);
    ncons = length(ucon);
    target = lower(data.params.laser_target);  
    voltage = data.params.laser_amp;
    
    if length(unique(laser))==2 && ~isempty(strfind(target,'acc')) && ncons == 6 
        disp(files{f})
%         disp(voltage)
        perf = nan(2,2,ncons); % laser x stim x contrast
        miss = nan(2,2,ncons);
        n_tot = nan(2,2,ncons);
        n_go = nan(2,2,ncons);
        
        % pooling across contrasts >10%
        perf_pooled = nan(2,3); % laser x stim
        miss_pooled = nan(2,3);
        n_tot_pooled = nan(2,3);
        n_go_pooled = nan(2,3);
        
        for l = 1:2
            for s = 1:2
                for c = 1:ncons
                    ix = laser==l & contrast==ucon(c);
                    if ucon(c)>0
                        ix = ix & loc == s;
                    end
                    miss(l,s,c) = mean(choice(ix)==5);
                    n_tot(l,s,c) = sum(ix);
                    
                    ix = ix & choice < 5;
                    perf(l,s,c) = mean(choice(ix)==1);
                    n_go(l,s,c) = sum(ix);
                end
                
                % pooled across contrasts
                ix = laser==l & loc==s & contrast>=conthresh;
                miss_pooled(l,3-s) = mean(choice(ix)==5);
                n_tot_pooled(l,3-s) = sum(ix);
                
                ix = ix & choice < 5;
                perf_pooled(l,3-s) = mean(choice(ix)==1);
                n_go_pooled(l,3-s) = sum(ix);
            end
        end
        perf_pooled(:,3) = perf_pooled(:,2);
        miss_pooled(:,3) = miss_pooled(:,2);
        n_tot_pooled(:,3) = n_tot_pooled(:,2);
        n_go_pooled(:,3) = n_go_pooled(:,2);
        
        % low contrast
        for l = 1:2
            ix = laser==l & contrast<conthresh;
            miss_pooled(l,2) = mean(choice(ix)==5);
            n_tot_pooled(l,2) = sum(ix);
            ix = ix & choice < 5;
            perf_pooled(l,2) = mean(choice(ix)==1);
            n_go_pooled(l,2) = sum(ix);
        end
        
        
        perf2 = squeeze(cat(3,perf(:,2,ncons:-1:1),perf(:,1,2:ncons)));
        miss2 = squeeze(cat(3,miss(:,2,ncons:-1:1),miss(:,1,2:ncons)));
        n_tot2 = squeeze(cat(3,n_tot(:,2,ncons:-1:1),n_tot(:,1,2:ncons)));
        n_go2 = squeeze(cat(3,n_go(:,2,ncons:-1:1),n_go(:,1,2:ncons)));
        cons = ucon([ncons:-1:1,2:ncons])*100;
        cons(1:ncons-1) = -cons(1:ncons-1);
        
        
        alldata = alldata + cat(3,round(perf2.*n_go2),n_go2,round(miss2.*n_tot2),n_tot2);        
        allpooled = allpooled + cat(3,round(perf_pooled.*n_go_pooled),n_go_pooled,round(miss_pooled.*n_tot_pooled),n_tot_pooled);
    end
    perf2 = alldata(:,:,1)./alldata(:,:,2);
    n_go2 = alldata(:,:,2);
    miss2 = alldata(:,:,3)./alldata(:,:,4);
    n_tot2 = alldata(:,:,4);
    
    perf_pooled = allpooled(:,:,1)./allpooled(:,:,2);
    n_go_pooled = allpooled(:,:,2);
    miss_pooled = allpooled(:,:,3)./allpooled(:,:,4);
    n_tot_pooled = allpooled(:,:,4);
end

    
    
%%
perf2_se = zeros([size(perf2), 2]);
miss2_se = zeros([size(perf2), 2]);
for l = 1:2
    for c = 1:length(cons)
        [~,ci] = binofit(perf2(l,c)*n_go2(l,c),n_go2(l,c));
        perf2_se(l,c,:) = abs(ci-perf2(l,c));
        
        [~,ci] = binofit(miss2(l,c)*n_tot2(l,c),n_tot2(l,c));
        miss2_se(l,c,:) = abs(ci-miss2(l,c));
    end
end

perf_pooled_se = zeros([size(perf_pooled), 2]);
miss_pooled_se = zeros([size(perf_pooled), 2]);
for l = 1:2
    for s = 1:3
        [~,ci] = binofit(perf_pooled(l,s)*n_go_pooled(l,s),n_go_pooled(l,s));
        perf_pooled_se(l,s,:) = abs(ci-perf_pooled(l,s));
        
        [~,ci] = binofit(miss_pooled(l,s)*n_tot_pooled(l,s),n_tot_pooled(l,s));
        miss_pooled_se(l,s,:) = abs(ci-miss_pooled(l,s));
    end
end


%% 
close all
figure
set(gcf,'position',[9   169   651   948])
subplot(2,1,1)
hold on
boundedline(1:length(cons),perf2(1,:)*100,squeeze(perf2_se(1,:,:))*100,'-*','cmap',[0.7 0.7 0.7],'alpha')
boundedline(1:length(cons),perf2(2,:)*100,squeeze(perf2_se(2,:,:))*100,'-*','cmap',[0.2 0.7 1],'alpha')
set(gca,'xtick',1:length(cons))
set(gca,'xticklabel',cons)
xlabel('R Contrast - L Contrast')
ylabel('% Leftward movements')
plot(xlim,[50 50],':k')
plot(ncons,[0 100],':k')
axis([0.5,length(cons)+0.5,0,100])
for i = 1:length(n_go2)    
    text(i,0,num2str(n_go2(1,i)),'horizontalalignment','center','verticalalignment','bottom','color',[0.7 0.7 0.7])
    text(i,5,num2str(n_go2(2,i)),'horizontalalignment','center','verticalalignment','bottom','color',[0.2 0.7 1])
end
title('Performance')

subplot(2,1,2)
hold on
boundedline(1:length(cons),miss2(1,:)*100,squeeze(miss2_se(1,:,:))*100,'-*','cmap',[0.7 0.7 0.7],'alpha')
boundedline(1:length(cons),miss2(2,:)*100,squeeze(miss2_se(2,:,:))*100,'-*','cmap',[0.2 0.7 1],'alpha')
set(gca,'xtick',1:length(cons))
set(gca,'xticklabel',cons)
xlabel('R Contrast - L Contrast')
ylabel('% Timeout trials')
plot(ncons,[0 100],':k')
axis([0.5,length(cons)+0.5,0,100])
for i = 1:length(n_go2)    
    text(i,0,num2str(n_tot2(1,i)),'horizontalalignment','center','verticalalignment','bottom','color',[0.7 0.7 0.7])
    text(i,5,num2str(n_tot2(2,i)),'horizontalalignment','center','verticalalignment','bottom','color',[0.2 0.7 1])
end
title('Miss Rate')

%% pooled
% close all
figure
set(gcf,'position',[9   169   651   948])
subplot(2,1,1)
hold on
boundedline(1:3,perf_pooled(1,:)*100,squeeze(perf_pooled_se(1,:,:))*100,'-*','cmap',[0.7 0.7 0.7],'alpha')
boundedline(1:3,perf_pooled(2,:)*100,squeeze(perf_pooled_se(2,:,:))*100,'-*','cmap',[0.2 0.7 1],'alpha')
set(gca,'xtick',1:3)
set(gca,'xticklabel',{'Left Stim','Low Con','Right Stim'})
% xlabel('R Contrast - L Contrast')
ylabel('% Leftward movements')
axis([0.5,3.5,0,100])
plot(xlim,[50 50],':k')
for i = 1:3    
    text(i,0,num2str(n_go_pooled(1,i)),'horizontalalignment','center','verticalalignment','bottom','color',[0.7 0.7 0.7])
    text(i,5,num2str(n_go_pooled(2,i)),'horizontalalignment','center','verticalalignment','bottom','color',[0.2 0.7 1])
end
title('Performance')

subplot(2,1,2)
hold on
boundedline(1:3,miss_pooled(1,:)*100,squeeze(miss_pooled_se(1,:,:))*100,'-*','cmap',[0.7 0.7 0.7],'alpha')
boundedline(1:3,miss_pooled(2,:)*100,squeeze(miss_pooled_se(2,:,:))*100,'-*','cmap',[0.2 0.7 1],'alpha')
set(gca,'xtick',1:3)
set(gca,'xticklabel',{'Left Stim','Low Con','Right Stim'})
% xlabel('R Contrast - L Contrast')
ylabel('% Timeout trials')
axis([0.5,3.5,0,100])
for i = 1:3 
    text(i,0,num2str(n_tot_pooled(1,i)),'horizontalalignment','center','verticalalignment','bottom','color',[0.7 0.7 0.7])
    text(i,5,num2str(n_tot_pooled(2,i)),'horizontalalignment','center','verticalalignment','bottom','color',[0.2 0.7 1])
end
title('Miss Rate')