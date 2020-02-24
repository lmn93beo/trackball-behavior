function result = repelem(arr, blockSize)
% Repeat each elem in arr 'blockSize' times
result = [];
for i = 1:numel(arr)
    startid = (i - 1) * blockSize + 1;
    endid = i * blockSize;
    result(startid : endid) = arr(i);
end