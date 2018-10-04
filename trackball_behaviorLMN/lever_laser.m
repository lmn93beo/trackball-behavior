files = {'20150916_trackball_1001_gonogo_inact.mat',...
    '20150917_trackball_1001gonogo_inact.mat'};
files = {'20150921_trackball_1001_gonogo_chirap_inact.mat',...
    '20150923_trackball_1001_gonogo_chirap_inact.mat'};

perf = zeros(2,2,length(files)); % laser x stim x file

for f = 1:length(files)
    load(files{f})
    
    ntrials = find(data.response.reward>0,1,'last');
    choice = (data.response.choice(1:ntrials)==2)+1;
    targ = data.stimuli.loc(1:ntrials);
    laser = data.stimuli.laser(1:ntrials);
    
    for l = 1:2
        for s = 1:2
            ix = targ==s & laser ==l;
            perf(l,s,f) = mean(choice(ix)==2);
        end
    end
    
end

temp = perf; temp(temp<0.01) = 0.01; temp(temp>0.99) = 0.99;
dprime = squeeze(norminv(perf(:,2,:),0,1) - norminv(perf(:,1,:),0,1));


%%
cmap = [0.7 0.7 0.7; 0.2 0.7 1];
x = [4 5 1 2];
ix = 1:length(files);

close all
figure
% subplot(1,3,[1 2])
data = perf*100;

mdata = reshape(nanmean(data(:,:,ix),3),1,4);
sdata = reshape(nanstd(data(:,:,ix),[],3)/sqrt(length(ix)),1,4);
for i = 1:4
%     if mod(i,2)==1
    
    [h1,h2] = barwitherr(sdata(i),mdata(i));
    set(h1,'xdata',x(i),'facecolor',cmap(mod(i+1,2)+1,:))
    set(h2,'xdata',x(i),'linewidth',2)
    hold on
%     end
end

for f = 1:length(ix)
    plot(x(1:2),data(:,1,ix(f)),'color',[0.5 0.5 0.5])
    plot(x(3:4),data(:,2,ix(f)),'color',[0.5 0.5 0.5])
    hold on
end

axis([0 6 0 100]);
set(gca,'ytick',0:25:100)

set(gca,'xtick',[1.5 4.5])
set(gca,'xticklabel','')
h = get(gca,'children');
xlabel('Stimulus')
ylabel('Response rate (%)')


% subplot(1,3,3)
% mdata = mean(dprime,2);
% sdata = std(dprime,[],2)/sqrt(length(ix));
% for i = 1:2
%     [h1,h2] = barwitherr(sdata(i),mdata(i));
%     set(h1,'xdata',i,'facecolor',cmap(mod(i+1,2)+1,:))
%     set(h2,'xdata',i,'linewidth',2)
%     hold on
% end
% for f = 1:length(ix)
%     plot(1:2,dprime(:,ix(f)),'color',[0.5 0.5 0.5])
%     hold on
% end
% axis([0 3 0 3]);
% ylabel('D-prime')
% set(gca,'xtick',1.5)
% set(gca,'xticklabel','')
