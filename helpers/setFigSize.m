function setFigSize(cols,idx)
if nargin<1
    rows=1;
    cols=1;
    idx=1;
end

pos = get(0,'screensize');
pos(2) = 40; 
pos(4) = pos(4) - pos(2);
pos(3) = pos(3)/cols;
pos(1) = pos(1) + pos(3)*(idx-1);
set(gcf,'OuterPosition',pos)
% set(gcf,'color',[1 1 1])