function y = bsmooth(x,varargin)
% remove NaNs, smooth, interpolate

nanx = isnan(x);

z = smooth(x(~nanx),varargin{:});

y = nan(size(x));

y(~nanx) = z;


t = 1:numel(y);
y(nanx) = interp1(t(~nanx), y(~nanx), t(nanx));

if isnan(y(1))
    start = find(~isnan(y),1);
    y(1:start-1) = y(start);    
end

if isnan(y(end))
    stop = find(~isnan(y),1,'last');
    y(stop+1:end) = y(stop);    
end