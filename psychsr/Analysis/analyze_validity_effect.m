% analyze_validity_effect
[files, dir] = uigetfile('..\behaviorData\*.mat','MultiSelect','On');
% cd(dir);
if ~iscell(files) 
    files = {files};
end

vars = {'vhits','ihits','nhits','vfalarm','ifalarm','nfalarm','vRT','iRT',...
    'nRT','vhits2','ihits2','nhits2','vfalarm2','ifalarm2','nfalarm2',...
    'all_rt','all_cue','all_soa','all_n'};
cell_vars = {'vhits3','ihits3','nhits3','vRT3','iRT3','nRT3','vfalarm3',...
    'ifalarm3','nfalarm3'};
soa = 0.5:0.5:3.5;
% soa = [0.1 0.3 0.6 1.4 2.2];
for i = 1:length(vars)
    eval(sprintf('%s = [];',vars{i}));
end
for i = 1:length(cell_vars)
    eval(sprintf('%s = cell(1,%d);',cell_vars{i},length(soa)-1));
end

for i = 1:length(files) 
    load([dir, files{i}]);  
    if ~isfield(data,'analysis')
        make_trials(files{i},dir,1);
    elseif ~isfield(data.analysis.trials,'rt')
        make_trials(files{i},dir,1);
    end
    load([dir, files{i}]);    
    trials = data.analysis.trials;
% moving window performance
% n=20;
% vhits = movingwindow([trials.rewarded],strcmp([trials.cue_type],'valid'),n);
% ihits = movingwindow([trials.rewarded],strcmp([trials.cue_type],'invalid'),n);
% nhits = movingwindow([trials.rewarded],strcmp([trials.cue_type],'neutral'),n);
% vfalarm = movingwindow([trials.punished],strcmp([trials.cue_type],'valid'),n);
% ifalarm = movingwindow([trials.punished],strcmp([trials.cue_type],'invalid'),n);
% nfalarm = movingwindow([trials.punished],strcmp([trials.cue_type],'neutral'),n);
% % vdelay = movingwindow([trials.delay],strcmp([trials.cue_type],'valid'),n);
% % idelay = movingwindow([trials.delay],strcmp([trials.cue_type],'invalid'),n);
% % ndelay = movingwindow([trials.delay],strcmp([trials.cue_type],'neutral'),n);
% vdprime = norminv(vhits,0,1)-norminv(vfalarm,0,1);
% idprime = norminv(ihits,0,1)-norminv(ifalarm,0,1);
% ndprime = norminv(nhits,0,1)-norminv(nfalarm,0,1);
% 
% figure
% subplot(3,1,1)
% hold all;
% plot(vhits)
% plot(nhits)
% plot(ihits)
% 
% subplot(3,1,2)
% hold all;
% plot(vfalarm)
% plot(nfalarm)
% plot(ifalarm)
% 
% subplot(3,1,3)
% hold all;
% plot(vdprime)
% plot(ndprime)
% plot(idprime)

% actual performance
vhits = [vhits, trials(strcmp([trials.cue_type],'valid') & ~isnan([trials.rewarded])).rewarded];
ihits = [ihits, trials(strcmp([trials.cue_type],'invalid') & ~isnan([trials.rewarded])).rewarded];
nhits = [nhits, trials(strcmp([trials.cue_type],'neutral') & ~isnan([trials.rewarded])).rewarded];
if data.response.abort
vfalarm = [vfalarm, trials(strcmp([trials.cue_type],'valid')).aborted];
ifalarm = [ifalarm, trials(strcmp([trials.cue_type],'invalid')).aborted];
nfalarm = [nfalarm, trials(strcmp([trials.cue_type],'neutral')).aborted];
else
vfalarm = [vfalarm, trials(strcmp([trials.cue_type],'valid') & ~isnan([trials.punished])).punished];
ifalarm = [ifalarm, trials(strcmp([trials.cue_type],'invalid') & ~isnan([trials.punished])).punished];
nfalarm = [nfalarm, trials(strcmp([trials.cue_type],'neutral') & ~isnan([trials.punished])).punished];
end

vhits2(i) = mean([trials(strcmp([trials.cue_type],'valid') & ~isnan([trials.rewarded])).rewarded]);
ihits2(i) = mean([trials(strcmp([trials.cue_type],'invalid') & ~isnan([trials.rewarded])).rewarded]);
nhits2(i) = mean([trials(strcmp([trials.cue_type],'neutral') & ~isnan([trials.rewarded])).rewarded]);
if data.response.abort
vfalarm2(i) = mean([trials(strcmp([trials.cue_type],'valid')).aborted]);
ifalarm2(i) = mean([trials(strcmp([trials.cue_type],'invalid')).aborted]);
nfalarm2(i) = mean([trials(strcmp([trials.cue_type],'neutral')).aborted]);
else
vfalarm2(i) = mean([trials(strcmp([trials.cue_type],'valid') & ~isnan([trials.punished])).punished]);
ifalarm2(i) = mean([trials(strcmp([trials.cue_type],'invalid') & ~isnan([trials.punished])).punished]);
nfalarm2(i) = mean([trials(strcmp([trials.cue_type],'neutral') & ~isnan([trials.punished])).punished]);    
end

% across different SOAs
for j = 1:length(soa)-1
    vhits3{j} = [vhits3{j}, trials(strcmp([trials.cue_type],'valid') & ~isnan([trials.rewarded]) &...
        [trials.soa]>soa(j) & [trials.soa]<soa(j+1)).rewarded];
    ihits3{j} = [ihits3{j}, trials(strcmp([trials.cue_type],'invalid') & ~isnan([trials.rewarded]) &...
        [trials.soa]>soa(j) & [trials.soa]<soa(j+1)).rewarded];
    nhits3{j} = [nhits3{j}, trials(strcmp([trials.cue_type],'neutral') & ~isnan([trials.rewarded]) &...
        [trials.soa]>soa(j) & [trials.soa]<soa(j+1)).rewarded];
    vRT3{j} = [vRT3{j}, trials(strcmp([trials.cue_type],'valid') & ~isnan([trials.rewarded]) &...
        [trials.soa]>soa(j) & [trials.soa]<soa(j+1)).rt];
    iRT3{j} = [iRT3{j}, trials(strcmp([trials.cue_type],'invalid') & ~isnan([trials.rewarded]) &...
        [trials.soa]>soa(j) & [trials.soa]<soa(j+1)).rt];
    nRT3{j} = [nRT3{j}, trials(strcmp([trials.cue_type],'neutral') & ~isnan([trials.rewarded]) &...
        [trials.soa]>soa(j) & [trials.soa]<soa(j+1)).rt];   
%     if data.response.abort
    vfalarm3{j} = [vfalarm3{j}, trials(strcmp([trials.cue_type],'valid') & [trials.soa]>soa(j) & [trials.soa]<soa(j+1)).aborted];
    ifalarm3{j} = [ifalarm3{j}, trials(strcmp([trials.cue_type],'invalid') & [trials.soa]>soa(j) & [trials.soa]<soa(j+1)).aborted];
    nfalarm3{j} = [nfalarm3{j}, trials(strcmp([trials.cue_type],'neutral') & [trials.soa]>soa(j) & [trials.soa]<soa(j+1)).aborted];
%     end
end

rt_temp = zeros(size(trials));
for j=1:length(trials)
    if isempty(trials(j).rt); rt_temp(j) = NaN;
    else rt_temp(j) = trials(j).rt; end;
end

all_rt = [all_rt,rt_temp];
all_cue = [all_cue,trials.cue_type];
all_soa = [all_soa,trials.soa];
all_n = [all_n, length(trials)];

% reaction times
vRT = [vRT, trials(strcmp([trials.cue_type],'valid') & ~isnan([trials.rewarded])).rt];
iRT = [iRT, trials(strcmp([trials.cue_type],'invalid') & ~isnan([trials.rewarded])).rt];
nRT = [nRT, trials(strcmp([trials.cue_type],'neutral') & ~isnan([trials.rewarded])).rt];

fprintf('Analyzed %d of %d\n',i,length(files))
end

%% means and plots
vhits_mean = mean(vhits); 
ihits_mean = mean(ihits); 
nhits_mean = mean(nhits); 
vfalarm_mean = mean(vfalarm); 
ifalarm_mean = mean(ifalarm); 
nfalarm_mean = mean(nfalarm); 

test_vars = {'vhits_mean','ihits_mean','nhits_mean','vfalarm_mean',...
    'ifalarm_mean','nfalarm_mean','vhits2','ihits2','nhits2','vfalarm2',...
    'ifalarm2','nfalarm2'};
for i = 1:length(test_vars)
    eval(sprintf('%s(%s > 0.99) = 0.99; %s(%s < 0.01) = 0.01;',...
        test_vars{i},test_vars{i},test_vars{i},test_vars{i}))
end

vdprime = norminv(vhits_mean,0,1)-norminv(vfalarm_mean,0,1);
idprime = norminv(ihits_mean,0,1)-norminv(ifalarm_mean,0,1);
ndprime = norminv(nhits_mean,0,1)-norminv(nfalarm_mean,0,1);

figure;
subplot(3,2,3)
bar([vhits_mean,vfalarm_mean;nhits_mean,nfalarm_mean;ihits_mean,ifalarm_mean;])
text((1:3)-0.14,repmat(0.05,1,3),num2cell([length(vhits),length(nhits),length(ihits)]),...
    'horizontalalignment','center','fontsize',8,'fontweight','bold','Color',[1 1 1]);
text((1:3)+0.14,repmat(0.05,1,3),num2cell([length(vfalarm),length(nfalarm),length(ifalarm)]),...
    'horizontalalignment','center','fontsize',8,'fontweight','bold','Color',[1 1 1]);
title('Performance')
ylabel('Mean %')
set(gca,'XTickLabel',{'Valid','Neutral','Invalid'})

subplot(3,2,4)
bar([vdprime,ndprime,idprime],'FaceColor', 'k')
title('D-prime')
set(gca,'XTickLabel',{'Valid','Neutral','Invalid'})

subplot(3,2,[1, 2])
[vf vx] = ecdf(vRT);
% [nf nx] = ecdf(nRT);
[i_f ix] = ecdf(iRT);
hold all;
stairs(vx,vf)
% stairs(nx,nf)
stairs(ix,i_f)
xlim([0.25 1])
title(sprintf('%s: %s-%s',dir(end-10:end-1),files{1}(5:8),files{end}(5:8)))
xlabel('Reaction Time (s)')
ylabel('Cumulative Probability')
legend(sprintf('Valid (n=%d)',length(vRT)),...%sprintf('Neutral (n=%d)',length(nRT)),...
    sprintf('Invalid (n=%d)',length(iRT)))

subplot(3,2,5)
hold on;
plot([vhits2;nhits2;ihits2]./(ones(3,1)*vhits2)*vhits_mean,'.-b')
plot([vfalarm2;nfalarm2;ifalarm2]./(ones(3,1)*vfalarm2)*vfalarm_mean,'.-r')
title(sprintf('Performance by Session (n=%d)',length(files)))
xlim([0 4])
ylim([0 1.21])
set(gca,'XTick',1:3)
set(gca,'XTickLabel',{'Valid','Neutral','Invalid'})

vdprime2 = norminv(vhits2,0,1)-norminv(vfalarm2,0,1);
idprime2 = norminv(ihits2,0,1)-norminv(ifalarm2,0,1);
ndprime2 = norminv(nhits2,0,1)-norminv(nfalarm2,0,1);
subplot(3,2,6)
hold on;
plot([vdprime2;ndprime2;idprime2]./(ones(3,1)*vdprime2)*vdprime,'.-k')
title(sprintf('D-prime by Session (n=%d)',length(files)))
xlim([0 4])
set(gca,'XTick',1:3)
set(gca,'XTickLabel',{'Valid','Neutral','Invalid'})

set(gcf,'Position',[140 100 1000 600])

%% plots across SOAs

for i = 1:length(soa)-1
    mean_hits(i,1) = mean(vhits3{i});
    mean_hits(i,2) = mean(nhits3{i});
    mean_hits(i,3) = mean(ihits3{i});
    std_hits(i,1) = std(vhits3{i})/sqrt(length(vhits3{i}));
    std_hits(i,2) = std(nhits3{i})/sqrt(length(nhits3{i}));
    std_hits(i,3) = std(ihits3{i})/sqrt(length(ihits3{i}));
    
    mean_rt(i,1) = mean(vRT3{i});
    mean_rt(i,2) = mean(nRT3{i});
    mean_rt(i,3) = mean(iRT3{i});
    std_rt(i,1) = std(vRT3{i})/sqrt(length(vRT3{i}));
    std_rt(i,2) = std(nRT3{i})/sqrt(length(nRT3{i}));
    std_rt(i,3) = std(iRT3{i})/sqrt(length(iRT3{i}));
    
    mean_falarm(i,1) = mean(vfalarm3{i});
    mean_falarm(i,2) = mean(nfalarm3{i});
    mean_falarm(i,3) = mean(ifalarm3{i});
    std_falarm(i,1) = std(vfalarm3{i})/sqrt(length(vfalarm3{i}));
    std_falarm(i,2) = std(nfalarm3{i})/sqrt(length(nfalarm3{i}));
    std_falarm(i,3) = std(ifalarm3{i})/sqrt(length(ifalarm3{i}));
    
end
% shift = 0.1;
% x = (soa(1:end-1)+mean(diff(soa))/2)'*ones(1,3)+ ones(length(soa)-1,1)*shift*[-1 0 1];

% x = {'0.5-1.0','1.0-1.5','1.5-2.0','2.0-2.5','2.5-3.0','3.0-3.5'};
x = cell(length(soa)-1,1);
for i = 1:length(soa)-1
    x{i} = sprintf('%1.1f-%1.1f',soa(i),soa(i+1));
end
% x = {'0.2','0.5','1.25','2'};

figure
subplot(3,1,1)
barweb(mean_hits, std_hits,[],x);
ylabel('Hit%')
ylim([min(min(mean_hits-std_hits))-0.02,max(max(mean_hits+std_hits))+0.02])
% errorbar(x,mean_hits,std_hits)
% axis([1 3 0.5 1.2])
% legend('Valid','Neutral','Invalid')

subplot(3,1,2)
barweb(mean_falarm, std_falarm,[],x);
ylabel('Abort%')
ylim([min(min(mean_falarm-std_falarm)),max(max(mean_falarm+std_falarm))+0.02])
legend('Valid','Neutral','Invalid','Location','NorthWest')

subplot(3,1,3)
barweb(mean_rt, std_rt,[],x);
ylabel('RT (s)')
ylim([min(min(mean_rt-std_rt))-0.02,max(max(mean_rt+std_rt))+0.02])
xlabel('Delay period (s)')
% errorbar(x,mean_rt,std_rt)
% axis([1 3 0.3 0.8])

