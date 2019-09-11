x = cell(1,6);
y = cell(1,6);

for i = 1:6
    figure(i);
    axs = get(gcf, 'Children');
    pos = get(axs(1), 'Children');
    x{i} = get(pos(3),'XData');
    y{i} = get(pos(3),'YData');
        
end

% resort = [5 1 2 3 4 6];
% x = x(resort);
% y = y(resort);

mousenums = [8 9 13 14 16 18];

%% calculate median d-prime
medians = cell(1,6);
sessionends = cell(1,6);
goodsessions = cell(1,6);
threshold = 1.2;

for i = 1:6
    sessionends{i} = [0 find(diff(x{i})>.002) length(x{i})];
    for j = 1:length(sessionends{i})-1
        medians{i} = [medians{i} median(y{i}(sessionends{i}(j)+1:sessionends{i}(j+1)))];        
        if medians{i}(j) >= threshold && sessionends{i}(j)+1>1000
            goodsessions{i} = [goodsessions{i} sessionends{i}(j)+1:sessionends{i}(j+1)];
        end
    end    
end

%% calculate median trials per session

trials_per_session = cell(1,6);
median_trials = NaN*ones(1,6);
mean_trials = NaN*ones(1,6);
std_trials = NaN*ones(1,6);

for i = 1:6
    for j = 1:length(sessionends{i})-1
        trials_per_session{i}(j) = 1000*(x{i}(sessionends{i}(j+1))-x{i}(sessionends{i}(j)+1))+1;
    end
    median_trials(i) = median(trials_per_session{i});
    mean_trials(i) = mean(trials_per_session{i});
    std_trials(i) = std(trials_per_session{i});
end



%% plot d-prime over trials
figure;
colors = jet(6);
gray = [0.3 0.3 0.3];
for i = 1:6
    subplot(6,1,i)
    hold on;
    plot(x{i},y{i},'.','Color',gray,'MarkerSize',5)
    
    plot(x{i}(goodsessions{i}),y{i}(goodsessions{i}),'.','Color',colors(i,:),'MarkerSize',5)
    
    plot([0 max([x{:}])],[threshold threshold],'--k')
    plot([0 max([x{:}])],[0 0],'--k')
    xlim([0 max([x{:}])])    
    ylim([-1 5])
    if i < 6
        set(gca,'XTickLabel',[])
    end
    ylabel(sprintf('#%d',mousenums(i)))
end
shg
    