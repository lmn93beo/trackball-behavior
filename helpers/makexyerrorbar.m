function makexyerrorbar( meanx, meany, stx, sty, clr)

plot( meanx, meany,'o','markersize',2,...
    'markerfacecolor', clr, 'markeredgecolor', clr,'linewidth',1); hold on;

line( [meanx, meanx], [meany-sty, meany+sty], 'linestyle', '-', 'marker','o',...
       'markersize',1,'markerfacecolor','w', 'linewidth',1,'color', clr); hold on;

line( [meanx-stx, meanx+stx], [meany, meany], 'linestyle', '-', 'marker','o',...
       'markersize', 1, 'markerfacecolor','w','linewidth',1,'color', clr); hold on;
