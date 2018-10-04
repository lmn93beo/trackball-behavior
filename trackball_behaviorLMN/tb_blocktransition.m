n = find(data.response.reward>0,1,'last');

block = data.stimuli.block(1:n);
stim = data.stimuli.loc(1:n);
choice = data.response.choice(1:n);

bad = (block==3 & stim==3) | (block~=3 & stim ~=3);

choice(bad) = nan;

blswitches = [0,find(abs(diff(block))>0)]+1;
id = find(stim==3 & choice ~= 5);
bl = block(blswitches);

%% 1 to 2 transition
bins = -8:1:12;
lrFlag = 1;

relpos_all = [];
choice_all = [];
block_all = [];

for b = 2:length(blswitches)
    relpos = id-blswitches(b);    
    if bl(b) == 2 && bl(b-1) == 1 % transition from 1 to 2
        
        ix = (relpos>=min(bins) & relpos<0 & block(id)==1) | ...
            (relpos>= 0 & relpos <= max(bins) & block(id)==2);
        relpos_all = cat(2,relpos_all,relpos(ix));
        choice_all = cat(2,choice_all,choice(id(ix))==1);
        block_all = cat(2,block_all,2*ones(1,sum(ix)));
    elseif bl(b) == 1 && bl(b-1) == 2 % transition from 2 to 1
        
        ix = (relpos>=min(bins) & relpos<0 & block(id)==2) | ...
            (relpos>= 0 & relpos <= max(bins) & block(id)==1);
        relpos_all = cat(2,relpos_all,relpos(ix));
        choice_all = cat(2,choice_all,choice(id(ix))==2);
        block_all = cat(2,block_all,ones(1,sum(ix)));
    end
end

figure

[~,ix]=histc(relpos_all,bins);

bins2 = bins(1:end-1)+(diff(bins)-1)/2;
choice_mean = zeros(size(bins2)); 
choice_std = zeros(size(bins2));
left_mean = zeros(size(bins2)); 
left_std = zeros(size(bins2));
right_mean = zeros(size(bins2)); 
right_std = zeros(size(bins2));

for i = 1:length(bins2)
    choice_mean(i) = mean(choice_all(ix == i));
    choice_std(i) = std(choice_all(ix == i))/sqrt(sum(ix==i));
    
    idx = ix == i & block_all == 2;
    left_mean(i) = 1-mean(choice_all(idx));
    left_std(i) = std(1-choice_all(idx))/sqrt(sum(idx));
    
    idx = ix == i & block_all == 1;
    right_mean(i) = mean(choice_all(idx));
    right_std(i) = std(choice_all(idx))/sqrt(sum(idx));
end

subplot(3,1,3)
if lrFlag
    n = hist(relpos_all(block_all==2),min(bins):max(bins));
    n2 = hist(relpos_all(block_all==1),min(bins):max(bins));
    bar(min(bins):max(bins),[n;n2]','stacked')
else
    n = hist(relpos_all,min(bins):max(bins));
    bar(min(bins):max(bins),n,'k')
end
hold on
axis tight
plot([0 0],ylim,':w')
xlim([min(bins)-0.5,max(bins)-0.5])
xlabel('Trials after block transition')
ylabel('# trials')
box off

subplot(3,1,[1 2])
hold on
if lrFlag
    boundedline(bins2,left_mean,left_std,'*-','alpha')
    boundedline(bins2,right_mean,right_std,'*-r','alpha')
    ylabel('P(rightward choice)')
else
    boundedline(bins2,choice_mean,choice_std,'*-k','alpha')
    ylabel('P(correct choice)')
end
plot([0 0],[0 1],':k')

title('Choice probability on Free Choice')
xlim([min(bins)-0.5,max(bins)-0.5])

