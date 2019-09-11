% logistic regression
%% load data
clear all; close all; clc;
cd('H:\Dropbox (MIT)\MouseAttention\behaviorData\trackball\mouse 0115')
load('20150501_trackball_0115b.mat')

choice = data.response.choice; 
choice(choice == 5) = 0;
choice(find(choice>0,1,'last')+1:end) = [];

n = length(choice);

stim = data.stimuli.loc(1:n);
block = data.stimuli.block(1:n);

if ~isfield(data.response,'reward')
    reward = zeros(size(stim));
    reward(choice == stim) = data.params.reward(xor(choice(choice==stim)-1,block(choice==stim)-1)+1);
    reward(stim == 3 & choice > 0) = data.params.reward(choice(stim == 3 & choice > 0));
else
    reward = data.response.reward(1:n);
end

choice(choice == 1) = -1;
choice(choice == 2) = 1;
reward(choice == -1) = -reward(choice == -1);

%% plot block transition data
blswitches = [0,find(abs(diff(block))>0)]+1;
id = find(stim==3 & choice ~= 0);
free = choice(id)>0;

relpos_all = [];
choice_all = [];

% bins = -9:3:39;
bins = -10:2:15;

for b = 2:length(blswitches)
    relpos = id-blswitches(b);
    ix = relpos>=min(bins) & relpos <= max(bins);
    relpos_all = cat(2,relpos_all,relpos(ix));
    choice_all = cat(2,choice_all,~xor(mod(b,2),free(ix)));
end

[~,ix]=histc(relpos_all,bins);

choice_mean = zeros(size(bins));
choice_std = zeros(size(bins));
for i = 1:length(bins)
    choice_mean(i) = mean(choice_all(ix == i));
    choice_std(i) = std(choice_all(ix == i))/sqrt(sum(ix==i));
end
figure
boundedline(bins,choice_mean,choice_std,'*-','alpha')
hold on
plot([0 0],[0 1],':r')
xlabel('Trials after block transition')
ylabel('P(high reward choice)')
title('Choice probability on Free Choice')

%% arrange regressors

nhist = 5; % length of history
cFlag = 0; % use choice history?
rFlag = 2; % 1:use rewards, 2:separate reward history into high/low
            % 3: separate into Yes/No


rhist1 = zeros(n-nhist,nhist);
chist = zeros(n-nhist,nhist);
for i = 1:nhist
    rhist1(:,i) = reward(i:end-nhist+i-1);
    chist(:,i) = choice(i:end-nhist+i-1);
end
if rFlag>1
    rhist2 = zeros(size(rhist1));
    i = abs(rhist1)==max(data.params.reward);
    rhist2(i) = sign(rhist1(i));
    rhist1(i) = 0;
end
    
s = (stim(nhist+1:end)'==2) - (stim(nhist+1:end)'==1);

y = choice(nhist+1:end)';
x = [];
if rFlag>0
    x = cat(2,x,rhist1);
end
if rFlag>1
    x = cat(2,x,rhist2);
end
if cFlag
    x = cat(2,x,chist);
end

% remove aborted trials
aborted = y==0;
yall = y; xall = x;
x(aborted,:) = [];
y(aborted) = [];
y = y>0;

b = glmfit(x,y,'binomial');
yfit = glmval(b,xall,'logit');
%% plot paramters

figure
set(gcf,'position',[1   151   560   846])
subplot(3,1,1)
i = 1:size(s,2)+1;
stem(b(i))
set(gca,'xtick',1:length(i))
set(gca,'xticklabel',{'Bias','Stim Loc'})
xlim([0 length(i)+1])
ylabel('\Delta log prob')
box off

if rFlag > 0
    subplot(3,1,2)
    hold on
    i = size(s,2)+2:size(s,2)+1+nhist;
    if rFlag > 1
        plot(-nhist:-1,b(i),'b')
        plot(-nhist:-1,b(i+nhist),'r')
    else
        stem(-nhist:-1,b(i))
    end
    set(gca,'xtick',-nhist:-1)
    xlim([-nhist-1 0])
    plot(xlim,[0 0],':k')
    title('Reward history')
    xlabel('Past trials')
    if rFlag > 1
        ylabel('\Delta log prob')
        legend('Lo','Hi','location','best')
    else
        ylabel('\Delta log prob / \mu L')
    end
end


if cFlag
subplot(3,1,3)
i = size(x,2)-nhist+1:size(x,2);
stem(-nhist:-1,b(i))
set(gca,'xtick',-nhist:-1)
xlim([-nhist-1 0])
xlabel('Past trials')
title('Choice history')
ylabel('\Delta log prob')
box off
end

%%
bl = block(nhist+1:end);
blswitches = find(abs(diff(bl))>0)+0.5;
blswitches(end+1) = length(yfit);

figure
subplot(2,1,1)
hold on;
i = xall(:,1)==0;
freetrials = find(i);
stem(freetrials,yfit(i))
ylabel('p(right)')
for j = 1:length(blswitches)
    i = freetrials<blswitches(j);
    plot(freetrials(i),ones(sum(i),1)*mean(yfit(freetrials(i))),'b','linewidth',3)
    y = yall(freetrials(i)); y(y == 0) = [];
    plot(freetrials(i),ones(sum(i),1)*mean(y>0),'r','linewidth',3)
    
    if j < length(blswitches)
        plot(blswitches(j)*[1 1],[0 1],':r')
        freetrials(i) = [];
    end
end    
axis([1 length(yfit) 0 1])

subplot(2,1,2)
hold on
xall2 = xall;
xall2(:,1) = 0;
yfit2 = glmval(b,xall2,'logit');
plot(yfit2)
xlabel('Trial #')
ylabel('p(right)')
for j = 1:length(blswitches)-1 
    plot(blswitches(j)*[1 1],[0 1],':r')
end
axis([1 length(yfit) 0 1])
