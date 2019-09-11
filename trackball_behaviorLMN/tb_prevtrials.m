function tb_prevtrials(files)
if nargin<1 || isempty(files)
files = uigetfile('*.mat','multiselect','on');
end
if ~iscell(files); files = {files}; end;

block_all = []; choice_all = []; reward_all = []; nrewards_all = [];
bhist_all = []; chist_all = []; rhist_all = []; session = [];

for f = 1:length(files)
    load(files{f})
    
    n = find(data.response.reward>0,1,'last');
    
    block = data.stimuli.block(1:n);
    stim = data.stimuli.loc(1:n);
    choice = data.response.choice(1:n);
    reward = data.response.reward(1:n);
    
    bad = (block==3 & stim==3) | (block~=3 & stim ~=3);
    choice(bad) = nan;
    
    blswitches = [0,find(abs(diff(block))>0)]+1;
    
    % number of rewards earned so far in block
    nrewards = cumsum([0 reward(1:end-1)]>0);
    for i = 1:length(blswitches)
        nrewards(blswitches(i):end) = nrewards(blswitches(i):end) - nrewards(blswitches(i));
    end
    
    %%
    nhist = 2; % length of history
    
    bhist = nan(n,nhist);
    rhist = nan(n,nhist);
    chist = nan(n,nhist);
    for i = 1:nhist
        bhist(i+1:end,i) = block(1:end-i);
        chist(i+1:end,i) = choice(1:end-i);
        rhist(i+1:end,i) = reward(1:end-i);
    end
    
    block_all = cat(1,block_all,block');
    choice_all = cat(1,choice_all,choice');
    reward_all = cat(1,reward_all,reward');
    nrewards_all = cat(1,nrewards_all,nrewards');
    bhist_all = cat(1,bhist_all,bhist);
    chist_all = cat(1,chist_all,chist);
    rhist_all = cat(1,rhist_all,rhist);
    session = cat(1,session,f*ones(n,1));
    
end
%% overall performance



%% given past 1 choice
prob = zeros(4,2);
prob_std = zeros(4,2);
nt = zeros(4,2);

for c = [1 2]
    for r = [1 2]
        for nr = [1 2]
            ix = chist_all(:,1)==c & sign(r-1.5)*(rhist_all(:,1)-0.5)>0 & sign(nr-1.5)*(nrewards_all-3.5)>0 &...
                bhist_all(:,1)<3 & block_all<3 & choice_all~=5;
            
%             ix = chist_all(:,1)==c & sign(r-1.5)*(rhist_all(:,1)-0.5)>0 & ...
%                 bhist_all(:,1)<3 & block_all<3 & choice_all~=5;

%             temp = unique([bhist_all(ix,1), block_all(ix)],'rows')
%             if size(temp,1)>1
%                 [c r nr]
%             end
            probs = nan(max(session),1);
            for s = 1:max(session)
                probs(s) = mean(choice_all(ix & session==s)==c);
            end
            
%             prob(c*2+r-2,nr) = mean(choice_all(ix)==c);
            prob(c*2+r-2,nr) = nanmean(probs);
            prob_std(c*2+r-2,nr) = nanstd(probs)./sqrt(sum(~isnan(probs)));
            nt(c*2+r-2,nr) = sum(ix);
            
        end
    end
end
labels = {'L0','L1','R0','R1'};

order = [1 4 3 2];
labels = labels(order);
prob_std = prob_std(order,:);
prob = prob(order,:);


figure
set(gcf,'position',[1   577   696   420])
h = barwitherr(prob_std,[1 2 3.5 4.5],prob,0.95);
for i = 1:2
    x = mean(get(get(h(i),'children'),'xdata'));
    for j = 1:4
        text(x(j),0.05,num2str(nt(j,i)),'horizontalalignment','center','color',0.5*[1 1 1])
    end
end
set(gca,'xtick',[1 2 3.5 4.5])
set(gca,'xticklabel',labels)
legend('Early in block (nr<3)','Late in block (nr>=3)','location','northeast')
ylabel('Probability of Repeating choice')
xlabel('Previous choice/outcome')
title('Choice behavior given past 1 trial')
axis([0.5 5 0 1])
hold on
plot(xlim,[0.5 0.5],':k')


%% given past 2 choices
% prob = zeros(8,1);
% prob_std = zeros(8,1);
% nt = zeros(8,1);
% for c = [1 2]
%     for r1 = [1 2]
%         for r2 = [1 2]
%             ix = chist_all(:,1)==c & sign(r1-1.5)*(rhist_all(:,1)-0.5)>0 ...
%                 & chist_all(:,2)==c & sign(r2-1.5)*(rhist_all(:,2)-0.5)>0 ...
%                 & bhist_all(:,1)<3 & bhist_all(:,2)<3 & block_all<3 & choice_all~=5;
%             
%             probs = nan(max(session),1);
%             for s = 1:max(session)
%                 probs(s) = mean(choice_all(ix & session==s)==c);
%             end
%             
% %             prob(c*4+r1*2+r2-6) = mean(choice_all(ix)==c);
%             prob(c*4+r1*2+r2-6) = nanmean(probs);
%             prob_std(c*4+r1*2+r2-6) = nanstd(probs)./sqrt(sum(~isnan(probs)));
%             nt(c*4+r1*2+r2-6) = sum(ix);
%         end
%     end
% end
% 
% labels = {'L00','L01','L10','L11','R00','R01','R10','R11'};
% 
% labels(isnan(prob))=[];
% nt(isnan(prob))=[];
% prob_std(isnan(prob))=[];
% prob(isnan(prob))=[];
% 
% figure
% set(gcf,'position',[1   577   696   420])
% barwitherr(prob_std,prob)
% for i = 1:length(nt)
%     text(i,0.05,num2str(nt(i)),'horizontalalignment','center','color',0.5*[1 1 1])
% end
% axis([0 7 0 1])
% set(gca,'xticklabel',labels)
% % legend('Early','Late','location','northwest')
% ylabel('Probability of Repeating choice')
% xlabel('Previous 2 choices/outcomes')
% title('Choice behavior given past 2 trials')
% ylim([0 1])
% hold on
% plot(xlim,[0.5 0.5],':k')