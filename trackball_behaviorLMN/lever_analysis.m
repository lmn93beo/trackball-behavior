[files,folder] = uigetfile('*.mat','multiselect','on');
cd(folder)
if ~iscell(files); files = {files}; iFlag = 1;
else iFlag = 0; end
close all
tstart = 0;
s = 50;
first50 = nan(length(files),1);
best50 = nan(length(files),1);
overall = nan(length(files),1);
meanx = nan(length(files),1);
pushamp = cell(length(files),1);
pushtime = cell(length(files),1);
switchtrial = nan; switchday = nan;
cmap = {[0 0 0.5],[0 0 1];[0.5 0 0],[1 0 0]};
offset = 0;

for f = 1:length(files)
    %% load data
    
    load(files{f})
    
    mvmt = smooth(data.response.mvmtdata,16)./data.params.lev_cal;
    touch = data.response.touchdata/15+0.3;
    fs = data.card.ai_fs;
    t_all = (0:length(mvmt)-1)'/fs;
    
    ntrials = find(data.response.reward>0,1,'last');
    
    if ntrials > 49
        choice = (data.response.choice(1:ntrials)==2)+1;
        targ = (data.stimuli.loc(1:ntrials)==2)+1;
        if data.params.laser
            laser = (data.stimuli.laser(1:ntrials)==2)+1;
        else
            laser = ones(1,ntrials);
        end
        
        %     if isfield(data.params,'lev_cont') && length(unique(data.stimuli.sound)) > 1
        % %         cont = xor(data.stimuli.loc==2,data.stimuli.sound==14);
        %         cont = xor(data.stimuli.loc==2,data.stimuli.sound==22 | data.stimuli.sound==14);
        %         cont = cont(1:ntrials)+1;
        %         tone = (data.stimuli.sound(1:ntrials)==22 | data.stimuli.sound(1:ntrials)==14)+1;
        %     else
        cont = ones(1,ntrials);
        tone = data.stimuli.loc(1:ntrials);
        %     end
        
        %% extract/plot per trial movement data
        if iFlag
            figure(6)
        end
        dur = 2.5; n = dur*fs;
        trials = cell(2,2);
        allmvmts = nan(ntrials,n);
        
        for i = 1:ntrials
            start = data.response.samples_start{i};
            stop =  data.response.samples_stop{i};
            reward =  data.response.samples_reward{i};
            
            baseline = mvmt(start);
            nsamples = reward-start+1;
            
            x = tone(i);
            y = choice(i);
            trials{x,y} = cat(2,trials{x,y},mvmt(start:start+n-1)-baseline);
            allmvmts(i,:) = mvmt(start:start+n-1)-baseline;
            
            if iFlag
                subplot(1,2,3-tone(i))
                hold on;
                
                plot((0:nsamples-1)/fs,mvmt(start:reward)-baseline,'color',[0.7 0.7 0.7]);
                plot((stop-start)/fs,mvmt(stop)-baseline,'*','color',cmap{tone(i),choice(i)})
            end
        end
        
        % plot average responses
        if iFlag
            for x = 1:2
                subplot(1,2,3-x)
                if x == 2; title('HI tone')
                else title('LO tone'); end
                for y = 1:2
                    if ~isempty(trials{x,y})
                        h=plotSingleResp((0:n-1)/fs,trials{x,y},'cmap',cmap{x,y},'alpha');
                        set(h,'linewidth',2)
                    end
                end
                axis tight
            end
            matchAxes(get(gcf,'children'))
        end
        
        hits = choice-1;
        fas = choice-1;
        hits(tone==1) = nan;
        fas(tone==2) = nan;
        
        ucont = unique(cont);
        for i = 1:length(ucont)
            ix = find(cont==ucont(i));
            hrate = smooth(hits(ix),s); hrate(hrate<0.01) = 0.01; hrate(hrate>0.99) = 0.99;
            frate = smooth(fas(ix),s);  frate(frate<0.01) = 0.01; frate(frate>0.99) = 0.99;
            
            t = tstart+ix;
            midt = [prctile(t,25) prctile(t,75)];
            
            %% performance figure
            figure(1)
            subplot(3,1,1)
            hold on
            plot(t,hrate,'linewidth',2,'color',cmap{2,2})
            plot(t,frate,'color',cmap{1,2},'linewidth',2)
            plot(midt,[1 1]*nanmean(hits(ix)),':','color',cmap{2,2})
            plot(midt,[1 1]*nanmean(fas(ix)),':','color',cmap{1,2})
            
            subplot(3,1,2)
            hold on
            dp = norminv(hrate)-norminv(frate);
            dp(cont(ix)==2) = -dp(cont(ix)==2);
            dpmean = norminv(nanmean(hits(ix)))-norminv(nanmean(fas(ix)));
            dpmean(ucont(i)==2) = -dpmean(ucont(i)==2);
            plot(t,dp,'k','linewidth',2)
            plot(midt,[1 1]*dpmean,':k')
            
            subplot(3,1,3)
            hold on
            perf = mean([hrate,1-frate],2);
            perf(cont(ix)==2) = 1-perf(cont(ix)==2);
            pmean = mean([nanmean(hits(ix)),1-nanmean(fas(ix))]);
            pmean(ucont(i)==2) = 1-pmean(ucont(i)==2);
            plot(t,perf,'k','linewidth',2)
            plot(midt,[1 1]*pmean,':k')
            
            %% trajectory figure
            if i==2;
                offset = offset+1;
            end
            f = f+offset;
            figure(2)
            for j = 1:2
                for k = 1:2
                    if max(laser)==1
                        traj = allmvmts(intersect(ix,find(tone==j & choice==k)),:)';
                        
                        n = size(traj,1);
                        x = n*(f-1)+1:n*f;
                        x = x+(f-1)*100;
                        if ~isempty(traj)
                            h=plotSingleResp(x,traj,'cmap',cmap{j,k},'alpha');
                            set(h,'linewidth',2)
                        end
                    else
                        figure(2)
                        traj = allmvmts(intersect(ix,find(tone==j & choice==k & laser==1)),:)';
                        n = size(traj,1);
                        x = n*(f-1)+1:n*f;
                        x = x+(f-1)*100;
                        if ~isempty(traj)
                            h=plotSingleResp(x,traj,'cmap',cmap{j,k},'alpha');
                            set(h,'linewidth',2)
                        end
                        
                        figure(10)
                        traj = allmvmts(intersect(ix,find(tone==j & choice==k & laser==2)),:)';
                        if ~isempty(traj)
                            h=plotSingleResp(x,traj,'cmap',cmap{j,k},'alpha');
                            set(h,'linewidth',2)
                        end
                    end
                end
            end
            meanx(f) = mean(x);
            
            %% push statistics
            x = intersect(ix,find(targ==2 & choice==2));
            pushamp{f} = max(allmvmts(x,:),[],2)';
            pushtime{f} = cellfun(@(x) x(end),data.response.timePC(x));
            
            %% first 50, best 50
            if sum(isnan(dp))==0
                
                x = 1:49;
                first50(f) = mean([nanmean(hits(ix(x))) 1-nanmean(fas(ix(x)))]);
                
                [~,x] = max(perf);
                x = x-1;
                if x<25; x = 25; end
                if x>length(ix)-24; x = length(ix)-24; end
                x = x-24:x+24;
                
                h = nanmean(hits(ix(x))); h(h<0.01) = 0.01; h(h>0.99) = 0.99;
                fa = nanmean(fas(ix(x))); fa(fa<0.01) = 0.01; fa(f>0.99) = 0.99;
                best50(f) = mean([nanmean(hits(ix(x))) 1-nanmean(fas(ix(x)))]);
                overall(f) = pmean;
                
                if ucont(i)==2
                    first50(f) = 1-first50(f);
                    best50(f) = 1-best50(f);
                end
            end
        end
        
        if isfield(data.params,'lev_cont')
            ix = find(abs(diff(cont))>0);
            if ~isempty(ix)
                switchtrial = tstart+ix;
                switchday = f;
            elseif  isnan(switchtrial) && cont(1) == 2
                switchtrial = tstart+1;
                switchday = f;
            end
        end
        tstart = max(t);
        
    end
    
end
if f > length(files)
    labels = 1:f;
    labels(switchday) = labels(switchday)-0.5;
    labels(switchday+1:end) = labels(switchday+1:end)-1;
else
    labels = 1:f;
end


figure(1)
set(gcf,'position',[1   100   560   900])
subplot(3,1,1)
title('Response rate')
h = get(gca,'children');
legend(h([end,end-1]),'HI','LO','location','southwest')
axis tight; ylim([0 1]); xlim([0 max(xlim)])
set(gca,'xticklabel',[])
% plot(switchtrial*[1 1],[0 1],':k')
x1 = switchtrial; x2 = max(xlim);
patch([x1 x1 x2 x2 x1],[0 1 1 0 0],[0 0 0],'facecolor','k','edgecolor','none','facealpha',0.1)

subplot(3,1,2)
title('D-prime')
% plot(switchtrial*[1 1],ylim,':k')
axis tight; xlim([0 max(xlim)])
set(gca,'xticklabel',[])
plot(xlim,[0 0],':k')
x1 = switchtrial; x2 = max(xlim); y1=min(ylim); y2 = max(ylim);
patch([x1 x1 x2 x2 x1],[y1 y2 y2 y1 y1],[0 0 0],'facecolor','k','edgecolor','none','facealpha',0.1)

subplot(3,1,3)
title('Overall Performance')
xlabel('# of trials')
axis tight; ylim([0 1]); xlim([0 max(xlim)])
plot(xlim,[0.5 0.5],':k')
% plot(switchtrial*[1 1],[0 1],':k')
x1 = switchtrial; x2 = max(xlim);
patch([x1 x1 x2 x2 x1],[0 1 1 0 0],[0 0 0],'facecolor','k','edgecolor','none','facealpha',0.1)

figure(2)
set(gcf,'position',[580   580   560   420])
axis tight
ylim([floor(min(ylim)*10)/10 ceil(max(ylim)*10)/10])
plot(xlim,[0 0],':k')
set(gca,'xtick',meanx(~isnan(meanx)))
set(gca,'xticklabel',labels(~isnan(meanx)))
title('Average Lever Trajectory')
h = get(gca,'children');
legend(h(2:2:8),'HI: go','HI: ng','LO: go','LO: ng','location','best')
x1 = (switchday-1)*n+(switchday-2)*100+50; x2 = max(xlim);
y1=min(ylim); y2 = max(ylim);
patch([x1 x1 x2 x2 x1],[y1 y2 y2 y1 y1],[0 0 0],'facecolor','k','edgecolor','none','facealpha',0.1)

figure(3)
set(gcf,'position',[1150   580   560   420])
hold on
plot(first50,'-*b')
plot(best50,'-*r')
plot(overall,'-*k')
xlim([0 length(overall)+1])
legend('First 50','Best 50','All trials','location','best')
xlabel('Days')
ylabel('Performance')
plot(xlim,[0.5 0.5],':k')
set(gca,'xtick',1:f);
set(gca,'xticklabel',labels(~isnan(meanx)))
xlabel('Days')
x1 = switchday-0.5; x2 = max(xlim);
y1=min(ylim); y2 = max(ylim);
patch([x1 x1 x2 x2 x1],[y1 y2 y2 y1 y1],[0 0 0],'facecolor','k','edgecolor','none','facealpha',0.1)

G = [];
C = [];
for i = 1:length(pushamp)
    G = cat(2,G,i*ones(size(pushamp{i})));
    C = cat(2,C,((i>=switchday)+1)*ones(size(pushamp{i})));
end

figure(4)
set(gcf,'position',[580   70   560   420])
subplot(2,1,1)
errorbar(cellfun(@mean,pushamp),cellfun(@std,pushamp),'o','markersize',10)
% boxplot(cat(2,pushamp{:}),G,'boxstyle','filled','symbol','','colorgroup',C,'colors','rb')
ylim([min([0 min(ylim)]) ceil(max(ylim)*10)/10])
xlim([0 max(xlim)])
title('Push Amplitude')
set(gca,'xtick',1:f);
set(gca,'xticklabel',labels(~isnan(meanx)))
x1 = switchday-0.5; x2 = max(xlim);
y1=min(ylim); y2 = max(ylim);
patch([x1 x1 x2 x2 x1],[y1 y2 y2 y1 y1],[0 0 0],'facecolor','k','edgecolor','none','facealpha',0.1)
box off

subplot(2,1,2)
errorbar(cellfun(@mean,pushtime),cellfun(@std,pushtime),'o','markersize',10)
% boxplot(cat(2,pushtime{:}),G,'boxstyle','filled','symbol','','colorgroup',C,'colors','rb')
ylim([min([0 min(ylim)]) max(ylim)])
xlim([0 max(xlim)])
title('Push Latency')
xlabel('Days')
set(gca,'xtick',1:f);
set(gca,'xticklabel',labels(~isnan(meanx)))
x1 = switchday-0.5; x2 = max(xlim);
y1=min(ylim); y2 = max(ylim);
patch([x1 x1 x2 x2 x1],[y1 y2 y2 y1 y1],[0 0 0],'facecolor','k','edgecolor','none','facealpha',0.1)
box off

%% individual session plots
if iFlag
    figure(5)
    plot(t_all,mvmt,'k')
    hold on
    y1 = min(ylim); y2 = max(ylim);
    
    for i = 1:length(choice)
        start = t_all(data.response.samples_start{i});
        stop = data.response.samples_stop{i};
        reward =  t_all(data.response.samples_reward{i});
        
        patch([start start start+2 start+2 start],[y1 y2 y2 y1 y1],1-0.3*(1-cmap{tone(i),2}),'edgecolor','none','FaceAlpha',0.5)
        plot([start start+2],mvmt(data.response.samples_start{i})+[0.3 0.3],':k')
        %         if data.response.choice(i) == 2
        %             plot(t_all(stop),mvmt(stop),'*g')
        %         else
        %             plot(t_all(stop),mvmt(stop),'*r')
        %         end
    end
    xlim([796 828])
    set(gca,'xtick',min(xlim):5:max(xlim))
    set(gca,'xticklabel',0:5:floor(range(xlim)/5)*5)
end
