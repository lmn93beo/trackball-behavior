% clear all; clc; close all; 
%% load files
[files, dir] = uigetfile('..\behaviorData\*.mat','MultiSelect','On');
% cd(dir);
if ~iscell(files) 
    files = {files};
end

%% parameters
blanktime = 2;

%% analysis loop 
o = []; p = []; h = []; f = []; fa = []; d = []; t=[]; m=[]; g=[]; iti=[];
gh = []; gfa = [];

rh = []; lh = []; rfa = []; lfa = []; rd = []; ld = []; rf = []; lf=[];
xh = cell(3,1); xfa = cell(3,1); xf = cell(3,1); xd = cell(3,1);

rt = [];

hlicks = []; mlicks = []; flicks = []; clicks = []; rlicks = []; plicks = [];
htrials = 0; mtrials = 0; ftrials = 0; ctrials = 0;
nt = 0;

for j = 1:length(files)    
    trials = loaddata(3,[dir files{j}]);    
%     trials([trials.n_licks]==0)=[]; % remove no-lick trials    

    n = 50;
    for i = 1:length(trials)     
        trials(i).delay = ~isempty(find(trials(i).licks<=trials(i).stims(1),1));                
        
%         block = i-n/2:i+n/2-1;
%         if min(block)>0 && max(block)<length(trials)
%             stimtimes = [trials(block).stims];
%             movietimes = stimtimes(1:3:end);
%             blanktimes = stimtimes(2:3:end)-movietimes;
%             ititimes = stimtimes(3:3:end)-stimtimes(2:3:end);
%             blockonsets = [trials(block).lickonsets2];
%             
%             trials(i).probm = sum(blockonsets<0)/sum(movietimes);
%             trials(i).probg = sum(blockonsets>=0 & blockonsets<=blanktime)/sum(blanktimes);
%             trials(i).probi = sum(blockonsets>blanktime)/sum(ititimes);
%         end
        
    end
    
    hlicks = [hlicks [trials([trials.rewarded]==1).licks2]];
    mlicks = [mlicks [trials([trials.rewarded]~=1 & [trials.target]).licks2]];
    flicks = [flicks [trials([trials.punished]==1).licks2]];
    clicks = [clicks [trials([trials.punished]~=1 & ~[trials.target]).licks2]];
%     rlicks = [rlicks [trials.rewards2]];
    plicks = [plicks [trials.punishs2]];
    
    htrials = htrials+length([trials.rewarded]==1);
    mtrials = mtrials+length([trials.rewarded]~=1 & [trials.target]);
    ftrials = ftrials+length([trials.punished]==1);
    ctrials = ctrials+length([trials.punished]~=1 & ~[trials.target]);
% rt = [rt median([trials.rewards2])];
    
    onset = smooth([trials.onset],n);
    onset = onset(n/2+1:end-n/2);
    
    primed = smooth([trials.primed],n);
    primed = primed(n/2+1:end-n/2);
    
    hits = movingwindow([trials.rewarded],1,n);
    falarm = movingwindow([trials.punished],1,n);
    delay = movingwindow([trials.delay],1,n);
    
%     if max([trials.screen]) > 0
%         righthits = movingwindow([trials.rewarded],~[trials.screen],n);
%         lefthits = movingwindow([trials.rewarded],[trials.screen],n);       
%         rightfalarm = movingwindow([trials.punished],~[trials.screen],n);
%         leftfalarm = movingwindow([trials.punished],[trials.screen],n);
%         rightdelay = movingwindow([trials.delay],~[trials.screen],n);
%         leftdelay = movingwindow([trials.delay],[trials.screen],n);
%         rightdprime = norminv(righthits,0,1)-norminv(rightfalarm,0,1);
%         leftdprime = norminv(lefthits,0,1)-norminv(leftfalarm,0,1);
%     else
%         righthits = NaN*ones(size(hits));
%         lefthits = NaN*ones(size(hits));
%         rightfalarm = NaN*ones(size(hits));
%         leftfalarm = NaN*ones(size(hits));
%         rightdelay = NaN*ones(size(hits));
%         leftdelay = NaN*ones(size(hits));
%         rightdprime = NaN*ones(size(hits));
%         leftdprime = NaN*ones(size(hits));
%     end
     
    if max([trials.movie]) > 0
        for i = 1:3
            xhits{i} = movingwindow([trials.rewarded],[trials.movie]==i,n);
            xfalarm{i} = movingwindow([trials.punished],[trials.movie]==i,n);
            xdelay{i} = movingwindow([trials.delay],[trials.movie]==i,n);
            xdprime{i} = norminv(xhits{i},0,1)-norminv(xfalarm{i},0,1);
        end
    else
        for i = 1:3
            xhits{i} = NaN*ones(size(hits));
            xfalarm{i} = NaN*ones(size(hits));
            xdelay{i} = NaN*ones(size(hits));
            xdprime{i} = NaN*ones(size(hits));        
        end
    end
    
    if sum(isnan(falarm))>0
        dprime = norminv(hits,0,1)-norminv(delay,0,1);
    else
        dprime = norminv(hits,0,1)-norminv(falarm,0,1);
    end
    dprime = smooth(dprime,5);
%     probm = [trials.probm]';
%     probg = [trials.probg]';
%     probi = [trials.probi]';
    
    o = [o,onset];
    p = [p,primed];
    h = [h,hits];
%     gh = [gh;ghits];
    fa = [fa,falarm];
%     gfa = [gfa;gfalarm];
    f = [f,delay];
    d = [d,dprime];
%     rh = [rh;righthits];
%     lh = [lh;lefthits];
%     rfa = [rfa;rightfalarm];
%     lfa = [lfa;leftfalarm];
%     rf = [rf;rightdelay];
%     lf = [lf;leftdelay];
%     rd = [rd;rightdprime];
%     ld = [ld;leftdprime];
    for i = 1:3
        xh{i} = [xh{i},xhits{i}];
        xfa{i} = [xfa{i},xfalarm{i}];
        xf{i} = [xf{i},xdelay{i}];
        xd{i} = [xd{i},xdprime{i}];
    end
%     m = [m;probm];
%     g = [g;probg];
%     iti = [iti;probi];
    
    t = [t;[nt+1:nt+length(hits)]'];
    
    if j<length(files)
        days = datenum(files{j+1}(1:8),'yyyymmdd')-datenum(files{j}(1:8),'yyyymmdd');
        days = (days-1)*(days>1);
        nt = max(t)+50+days*100;
    end
    
    fprintf('Completed %d of %d\n',j,length(files))
end
%% convert to 1000s of trials
t = t/1000;

%% figures


figure
% figure('units','pixels','outerposition',[0 0 65*max(t) 450]);
subplot(2,1,1); hold on;
plot(t,f,'b.'); 
plot(t,fa,'r.'); plot(t,h,'g.'); 
xlim([0 max(t)]);%1.3*max(t)]); 
ylim([0 1]);
ylabel('Hits/FAs/Early')
title(sprintf('%s: %s-%s',dir(end-10:end-1),files{1}(5:8),files{end}(5:8)))
%legend('Mov%','FA%','Hit%','Location','SouthEast')

% subplot(4,1,2); hold on;
% plot(t,o,'b.'); plot(t,p,'c.');
% xlim([0 1.3*max(t)]); ylim([0 1]);
% ylabel('Onsets/Primes')
% legend('Ons%','Pri%')

% subplot(3,1,2); hold on;
% plot(t,gfa,'r.'); plot(t,gh,'g.'); 
% xlim([0 1.3*max(t)]); ylim([0 1]);
% ylabel('Grace period Hits/FAs')
% legend('FA%','Hit%','Location','SouthEast')

subplot(2,1,2); hold on;
plot(t,d,'.k'); 
plot([0 1.3*max(t)],[0 0],'--k')
plot([0 1.3*max(t)],[1.2 1.2],'--b')
xlim([0 max(t)]);%1.3*max(t)]); 
ylim([-1 5])
ylabel('D-prime')
% 
% if sum(~isnan(rh))>0
%     figure
%     subplot(2,1,1); hold on;
%     plot(t,lf,'b.'); plot(t,lfa,'r.'); plot(t,lh,'g.'); 
%     xlim([0 1.3*max(t)]); ylim([0 1]);
%     ylabel('Hits/FAs/Early')
%     title(sprintf('%s: %s-%s LEFT',dir(end-10:end-1),files{1}(5:8),files{end}(5:8)))
%     legend('Mov%','FA%','Hit%','Location','SouthEast')
%     
%     subplot(2,1,2); hold on;
%     plot(t,ld,'.k'); 
%     plot([0 1.3*max(t)],[0 0],'--k')
%     xlim([0 1.3*max(t)]); ylim([min(ld) 4])
%     ylabel('D-prime')
%     
%     figure
%     subplot(2,1,1); hold on;
%     plot(t,rf,'b.'); plot(t,rfa,'r.'); plot(t,rh,'g.'); 
%     xlim([0 1.3*max(t)]); ylim([0 1]);
%     ylabel('Hits/FAs/Early')
%     title(sprintf('%s: %s-%s RIGHT',dir(end-10:end-1),files{1}(5:8),files{end}(5:8)))
%     legend('Mov%','FA%','Hit%','Location','SouthEast')
%     
%     subplot(2,1,2); hold on;
%     plot(t,rd,'.k'); 
%     plot([0 1.3*max(t)],[0 0],'--k')
%     xlim([0 1.3*max(t)]); ylim([min(rd) 4])
%     ylabel('D-prime')
%     
%     % comparison plot
%     figure
%     subplot(4,1,1); hold on;
%     plot(t,lf,'.','Color',[0 0 0.5]); plot(t,rf,'.','Color',[0.5 0.5 1]); 
%     xlim([0 1.3*max(t)]); ylim([0 1]);
%     ylabel('Movie%')
%     title(sprintf('%s: %s-%s Compare Sides',dir(end-10:end-1),files{1}(5:8),files{end}(5:8)))
%     legend('Lt','Rt','Location','SouthEast')
%     
%     subplot(4,1,2); hold on;
%     plot(t,lh,'.','Color',[0 0.5 0]); plot(t,rh,'.','Color',[0.5 1 0.5]); 
%     xlim([0 1.3*max(t)]); ylim([0 1]);    
%     ylabel('Hit%')    
%     legend('Lt','Rt','Location','SouthEast')
%     
%     subplot(4,1,3); hold on;
%     plot(t,lfa,'.','Color',[0.5 0 0]); plot(t,rfa,'.','Color',[1 0.5 0.5]); 
%     xlim([0 1.3*max(t)]); ylim([0 1]);    
%     ylabel('False Alarm%')    
%     legend('Lt','Rt','Location','SouthEast')
%     
%     subplot(4,1,4); hold on;
%     plot(t,ld,'.','Color',[0 0 0]); plot(t,rd,'.','Color',[0.6 0.6 0.6]); 
%     xlim([0 1.3*max(t)]); ylim([min([ld;rd]) 4])
%     ylabel('D-prime')
%     legend('Lt','Rt','Location','SouthEast')
% 
% end
% 
% if sum(~isnan(xh{1}))>0
% %     for i = 1:3
% %         figure
% %         subplot(2,1,1); hold on;
% %         plot(t,xf{i},'b.'); plot(t,xfa{i},'r.'); plot(t,xh{i},'g.'); 
% %         xlim([0 1.3*max(t)]); ylim([0 1]);
% %         ylabel('Hits/FAs/Early')
% %         title(sprintf('%s: %s-%s Movie%d',dir(end-10:end-1),files{1}(5:8),files{end}(5:8),i))
% %         legend('Mov%','FA%','Hit%','Location','SouthEast')
% % 
% %         subplot(2,1,2); hold on;
% %         plot(t,xd{i},'.k'); 
% %         plot([0 1.3*max(t)],[0 0],'--k')
% %         xlim([0 1.3*max(t)]); ylim([min(xd{i}) 4])
% %         ylabel('D-prime')
% %     end
%     
%     figure
%     subplot(4,1,1); hold on;
%     plot(t,xf{1},'.','Color',[0 0 0.5]); plot(t,xf{2},'.','Color',[0 0 1]); plot(t,xf{3},'.','Color',[0.5 0.5 1]); 
%     xlim([0 1.3*max(t)]); ylim([0 1]);
%     ylabel('Movie%')
%     title(sprintf('%s: %s-%s Compare Movies',dir(end-10:end-1),files{1}(5:8),files{end}(5:8)))
%     legend('1','2','3','Location','SouthEast')
%     
%     subplot(4,1,2); hold on;
%     plot(t,xh{1},'.','Color',[0 0.5 0]); plot(t,xh{2},'.','Color',[0 1 0]); plot(t,xh{3},'.','Color',[0.5 1 0.5]); 
%     xlim([0 1.3*max(t)]); ylim([0 1]);    
%     ylabel('Hit%')    
%     legend('1','2','3','Location','SouthEast')
%     
%     subplot(4,1,3); hold on;
%     plot(t,xfa{1},'.','Color',[0.5 0 0]); plot(t,xfa{2},'.','Color',[1 0 0]); plot(t,xfa{3},'.','Color',[1 0.5 0.5]); 
%     xlim([0 1.3*max(t)]); ylim([0 1]);    
%     ylabel('False Alarm%')    
%     legend('1','2','3','Location','SouthEast')
%     
%     subplot(4,1,4); hold on;
%     plot(t,xd{1},'.','Color',[0 0 0]); plot(t,xd{2},'.','Color',[0.3 0.3 0.3]); plot(t,xd{3},'.','Color',[0.6 0.6 0.6]); 
%     xlim([0 1.3*max(t)]); ylim([min(xd{i}) 4])
%     ylabel('D-prime')
%     legend('1','2','3','Location','SouthEast')
% 
% end
% 
% % subplot(4,1,4);hold on;
% % plot(t,iti,'c.'); plot(t,m,'r.'); plot(t,g,'g.'); 
% % xlim([0 1.3*max(t)]); ylim([0 max([m;g;iti])])
% % ylabel('Lickonsets/sec')
% % legend('ITI','Mov','Grat','Location','SouthEast')
% 
% 
% % hlicks(hlicks<-2 | hlicks>6) = [];
% % mlicks(mlicks<-2 | mlicks>6) = [];
% % flicks(flicks<-2 | flicks>6) = [];
% % clicks(clicks<-2 | clicks>6) = [];
% % [x,xout] = hist([hlicks,mlicks,flicks,clicks],80);
% % hl = hist(hlicks,xout);
% % ml = hist(mlicks,xout);
% % fl = hist(flicks,xout);
% % cl = hist(clicks,xout);
% % rl = hist(rlicks,xout);
% % pl = hist(plicks,xout);
% 
% % figure;
% % subplot(2,2,1)
% % bar(xout,hl/htrials)
% % hold on; plot(xout,rl/htrials,'r')
% % subplot(2,2,2)
% % bar(xout,ml/mtrials)
% % subplot(2,2,3)
% % bar(xout,fl/ftrials)
% % hold on; plot(xout,pl/ftrials,'r')
% % subplot(2,2,4)
% % bar(xout,cl/ctrials)