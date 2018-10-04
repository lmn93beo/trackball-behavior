function matchAxes(axes_handles)
miny = Inf;
maxy = -Inf;

for i = 1:length(axes_handles)
    y = get(axes_handles(i),'Ylim');
    if min(y)<miny
        miny = min(y);
    end
    if max(y)>maxy
        maxy = max(y);
    end    
end

for i = 1:length(axes_handles)
    set(axes_handles(i),'ylim',[miny maxy])
end