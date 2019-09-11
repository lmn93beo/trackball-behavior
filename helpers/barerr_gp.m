function [bars, errs] = barerr_gp(x,n_mean,n_ci,bcolors,xlabels,linewidth,errwidth)
if isempty(x)
    x = 1:length(n_mean);
end

if nargin<6 || isempty(linewidth)
    linewidth = 1;
end

if nargin<7 || isempty(errwidth)
    errwidth = 0.1;
end

if nargin<5 || isempty(xlabels)
    xlabels = x;
end

if nargin<4 || isempty(bcolors)
    bcolors = lines(length(n_mean));
end

if nargin<3 || isempty(n_ci);
    n_ci = zeros(size(n_mean));
end

n = length(n_mean);

bars = zeros(n,1);
errs = zeros(n,3);

[m,d] = min(size(n_ci));
if m == 1
    n_range = cat(d,n_mean-n_ci,n_mean+n_ci);    
else
    n_range = n_ci;
end
if d==1
    n_range = n_range';
end

for i = 1:n
%     [bars(i), errs(i)] = barwitherr(n_ci(i),n_mean(i));
    bars(i) = bar(n_mean(i));    
    hold on
    errs(i,1) = plot(x(i)+[0 0],n_range(i,:),'k','linewidth',linewidth);
    
    errs(i,2) = plot(x(i)+errwidth*[-1 1],n_range(i,1)+[0 0],'k','linewidth',linewidth);
    errs(i,3) = plot(x(i)+errwidth*[-1 1],n_range(i,2)+[0 0],'k','linewidth',linewidth);
%     set(errs(i),'linewidth',linewidth,'xdata',x(i));
    set(bars(i),'facecolor',bcolors(i,:),'xdata',x(i));
end

% axis([0 5.5 0 100])
% set(gca,'xtick',[1 2 3.5 4.5])
% set(gca,'xticklabel',{'E','P','E','P'})
box off
xlim([min(x)-1 max(x)+1]);
%ylim([0 100])
set(gca,'xtick',sort(x))
set(gca,'xticklabel',xlabels)