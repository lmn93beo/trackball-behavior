function [meandata semdata] = plotMeanSE(data,dim,x,allFlag)

if nargin<4
    allFlag = 0;
end
if nargin<3
    x = [];
end
if nargin<2
    dim = 1;
end

n = size(data,dim);
meandata = mean(data,dim);
semdata = std(data,[],dim)/sqrt(n);

hold on;
if isempty(x)
    if allFlag
        plot(data,'Color',0.7*ones(1,3))
    end
    plot(meandata,'k','LineWidth',2)
    plot(meandata+semdata,'k','LineWidth',1)
    plot(meandata-semdata,'k','LineWidth',1)    
else
    if allFlag
        plot(data,'Color',0.7*ones(1,3))
    end
    plot(x,meandata,'k','LineWidth',2)
    plot(x,meandata+semdata,'k','LineWidth',1)
    plot(x,meandata-semdata,'k','LineWidth',1)
end
hold off;