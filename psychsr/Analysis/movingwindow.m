function output = movingwindow(input,condition,n,x)
% passes a moving window of length N across a binary input function to
% produce percentage as a function of trial
% "condition" specifies which trials to include (same length as input)
% NaN values of input are removed

if nargin<4
    x = 1;
end

included = condition & ~isnan(input); % trials to include
excluded = find(~included);
output = input(included); 
if ~isempty(output)
    output = smooth(output,n*x);  % apply moving filter
end


for i = 1:length(excluded)
    if excluded(i)<length(output)
        output(excluded(i):end+1) = [output(excluded(i)),output(excluded(i):end)];    
    elseif isempty(output)
        output = NaN*ones(size(input));
        break;
    else        
        output(end+1) = output(end);
    end
end    
if length(output)>n/2
    output(1:n/2) = output(n/2+1);
    output(end-n/2+1:end) = output(end-n/2);
end
% output = output(n/2+1:end-n/2);
output(output>0.99)=0.99;
output(output<0.01)=0.01;