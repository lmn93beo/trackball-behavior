function [h, yMean, yStd, n, alldata] = plotBinned(xmat,ymat,xbins,color,semFlag,plotFlag,scatterFlag,allFlag)
if nargin<4 || isempty(color)
    color = lines(1);
end
if nargin<5 || isempty(semFlag)
    semFlag = 0;
end
if nargin<6 || isempty(plotFlag)
    plotFlag = 1;
end
if nargin<7 || isempty(scatterFlag)
    scatterFlag = 0;
end
if nargin<8 || isempty(allFlag) % use whole pairwise matrix except diagonals
    allFlag = 0;
end    

minperbin = 5;
    
if size(xmat,1) == size(xmat,2)
    include = tril(true(size(xmat)),-1);    
    if allFlag
        include = include + triu(true(size(xmat)),+1);
    end
else
    include = true;
end

yMean = nan(length(xbins)-1,1);
yStd = nan(length(xbins)-1,1);
n = nan(length(xbins)-1,1);
alldata = cell(length(xbins)-1,1);
for b = 1:length(xbins)-1
    idx = xmat>=xbins(b) & xmat<xbins(b+1) & include;    
    if sum(idx(:))>=minperbin
        yMean(b) = mean(ymat(idx));        
        yStd(b) = std(ymat(idx));
        if semFlag
            yStd(b) = yStd(b)/sqrt(sum(idx(:)));
        end
        n(b) = sum(idx(:));
    end
    alldata{b} = ymat(idx);
end
idx = ~isnan(yMean);
pbins = xbins(1:end-1)+mean(diff(xbins))/2;

if plotFlag
hold on
if scatterFlag
    allidx = xmat>=xbins(1) & xmat<xbins(end) & include;
    scatter(xmat(allidx),ymat(allidx),'.','markeredgealpha',0.2,'markeredgecolor',color)
end
h = boundedline(pbins(idx),yMean(idx),yStd(idx),'cmap',color,'alpha');
set(h,'linewidth',2)
else
    h=  [];
end

end