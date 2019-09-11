function newCellArray = cat_cell(oldCellArray, newData, dim)
if nargin<3
    dim = 2;
end
% concatenates from a matrix to each cell of a similarly-sized cell array
if ~iscell(newData)
    newData = num2cell(newData);
end

newCellArray = cellfun(@(x,y) {cat(dim,x,y)},squeeze(oldCellArray),...
    newData);