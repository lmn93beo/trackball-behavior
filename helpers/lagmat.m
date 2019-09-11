function XLAG = lagmat(X,lags,groupLags)

% X must have time in columns, can have multiple rows
% X can be a cell array, if so XLAG is cell array

% by default groups by original columns, if groupLags --> will group by lags

if nargin<3 || isempty(groupLags)
    groupLags = 0;
end

cellFlag = iscell(X);

if ~cellFlag
    X = {X};
end

L = length(lags);

XLAG = cell(size(X));

for i = 1:length(X) % for each cell
    
    [R,C] = size(X{i});
    Xtemp = zeros(R,L,C);
    
    for c = 1:C
        for l = 1:L
            
            k = lags(l);   
            idx1 = max([1, 1-k]):min([R, R-k]);
            idx2 = idx1+k;
            
            Xtemp(idx2,l,c) = X{i}(idx1,c);
            
        end
    end
    
    if groupLags
        Xtemp = permute(Xtemp,[1 3 2]);
    end
    
    XLAG{i} = reshape(Xtemp,R,[]);
end
   

if ~cellFlag
    XLAG = XLAG{1};
end
    
    
    
    
    
