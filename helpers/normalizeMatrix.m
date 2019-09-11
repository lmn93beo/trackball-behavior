function [y drange offset] = normalizeMatrix(x,prctiles)
if nargin<2 || isempty(prctiles)    
    prctiles = [0 100];
end
if length(prctiles)==1
    prctiles = sort([prctiles, 100-prctiles]);
end

offset = prctile(x(:),prctiles(1));
z = x-offset; % make baseline 0
z(z<0) = 0;
drange = prctile(z(:),prctiles(2));
y = z/drange; 
y(y>1) = 1;
