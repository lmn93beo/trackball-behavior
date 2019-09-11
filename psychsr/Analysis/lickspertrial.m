close all
targ = find([trials.target]);
ntarg = find(~[trials.target]);

figure
subplot(2,1,1)
hold on;
set(gca,'YDir','reverse')
set(gca,'TickLength',[0 0])
set(gca,'Layer','top')
for i = 1:length(targ)    
    plot([0.01 6],[i i],'Color',[0.8 0.8 0.8])
    if trials(targ(i)).rewarded
        plot([1 2],[i i],'Color','g','LineWidth',2)
    else
        plot([1 2],[i i],'Color','r','LineWidth',2)
    end
    licks = trials(targ(i)).licks;    
        
    if ~isempty(licks)
        plot(licks,i,'k.')    
    end
    if ~isempty(trials(targ(i)).rewards)
        plot(trials(targ(i)).rewards(1),i,'g.','MarkerSize',20)        
    end    
end
xlim([0 6])
ylim([0.5 length(targ)+0.5])
set(gca,'YTick',[1,5:5:length(targ)])
set(gca,'YTick',[1,5:5:length(targ)])


% figure
subplot(2,1,2)
hold on;
set(gca,'YDir','reverse')
set(gca,'TickLength',[0 0])
set(gca,'Layer','top')
for i = 1:length(ntarg)    
    plot([0.01 6],[i i],'Color',[0.8 0.8 0.8])
    if trials(ntarg(i)).punished
        plot([1 2],[i i],'Color','r','LineWidth',2)
    else
        plot([1 2],[i i],'Color','g','LineWidth',2)
    end
    licks = trials(ntarg(i)).licks;
    if ~isempty(licks)
        plot(licks,i,'k.')    
    end
    if ~isempty(trials(ntarg(i)).punishs)
        plot(trials(ntarg(i)).punishs(1),i,'r.','MarkerSize',20)        
    end   
end
xlim([0 6])
ylim([0.5 length(ntarg)+0.5])
set(gca,'YTick',[1,5:5:length(ntarg)])
set(gca,'YTick',[1,5:5:length(ntarg)])

    
    