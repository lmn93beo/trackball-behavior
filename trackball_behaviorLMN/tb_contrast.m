choice = data.response.choice; 
choice(choice == 5) = 0;
choice(find(choice>0,1,'last')+1:end) = [];

n = length(choice);

stim = data.stimuli.loc(1:n);
block = data.stimuli.block(1:n);
con = data.stimuli.contrast(1:n);

if ~isfield(data.response,'reward')
    reward = zeros(size(stim));
    reward(choice == stim) = data.params.reward(xor(choice(choice==stim)-1,block(choice==stim)-1)+1);
    reward(stim == 3 & choice > 0) = data.params.reward(choice(stim == 3 & choice > 0));
else
    reward = data.response.reward(1:n);
end

%%
ucon = unique(con);
xlab = [-fliplr(ucon) 0 ucon]*100;
n = length(ucon);
perf = zeros(2,length(ucon)*2+1,4);

for b = 1:2
    for s = 1:2
        
        for c = 1:n
            if s == 2
                x = c+n+1;
            else
                x = n+1-c;
            end
            
            perf(b,x,1) = mean(choice(stim==s & block == b & con == ucon(c))==2);
            perf(b,x,2) = mean(choice(stim==s & block == b & con == ucon(c))==1);
            
            perf(b,x,3) = mean(choice(stim==s & block == b & con == ucon(c) & choice > 0)==2);
            perf(b,x,4) = mean(choice(stim==s & block == b & con == ucon(c))==0);
        end
        
        perf(b,n+1,1) = mean(choice(stim==3 & block == b)==2);
        perf(b,n+1,2) = mean(choice(stim==3 & block == b)==1);
        
        perf(b,n+1,3) = mean(choice(stim==3 & block == b & choice > 0)==2);
        perf(b,n+1,4) = mean(choice(stim==3 & block == b)==0);
    end
    
end

figure
set(gcf,'position',[1         122        1024         875])

str = {'% right choices', '% left choices','% right (no timeout)','% timeout trials'};
for i = 1:2
    subplot(2,2,i)
    hold on
    plot(perf(:,:,i)','-*')
    axis([0 n*2+2 0 1])
    plot(xlim,[0.5 0.5],':k')
    plot((n+1)*[1 1],[0 1],':k')
    set(gca,'xtick',1:(n*2+1))
    set(gca,'xticklabel',xlab)
    xlabel('R Contrast - L Contrast')
    ylabel(str{i})
    axis square
    legend('R High', 'L High','location','best')
end

for i = 3:4
    subplot(2,2,i)
    hold on
    plot(perf(:,:,i)','-*')
    axis([0 n*2+2 0 1])
    plot(xlim,[0.5 0.5],':k')
    plot((n+1)*[1 1],[0 1],':k')
    set(gca,'xtick',1:(n*2+1))
    set(gca,'xticklabel',xlab)
    xlabel('R Contrast - L Contrast')
    ylabel(str{i})
    axis square
    legend('R High', 'L High','location','best')
end

figure
hold on
perf2 = perf(:,:,[1 2]);
perf2(perf2<0.01) = 0.01; perf2(perf2>0.99) = 0.99;
dp = -diff(norminv(perf2),[],3);
plot(dp','-*')
y = max(abs(ylim));
axis([0 n*2+2 -y y])
plot(xlim,[0 0],':k')
plot((n+1)*[1 1],ylim,':k')
set(gca,'xtick',1:(n*2+1))
set(gca,'xticklabel',xlab)
xlabel('R Contrast - L Contrast')
ylabel('D-prime (R-L)')
legend('R High', 'L High','location','best')


