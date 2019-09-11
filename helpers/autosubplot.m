function [r,c] = autosubplot(n)
% automatically divides a plot into N panels

r = sqrt(n);
if r~=round(r)
    r = floor(r);
end
while n/r~=round(n/r)
    r = r-1;
end

c = n/r;