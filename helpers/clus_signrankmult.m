function p = clus_signrankmult(x,cluster,display)
if nargin<4
    display = 0;
end

inputdata = [cluster,x];
home2 = 'C:\Users\Gerald\Documents\';
rcommand = '"C:\Program Files\R\R-3.4.0\bin\x64\R" CMD BATCH C:\Users\Gerald\Documents\';
csvwrite([home2 'input.csv'],inputdata)

if display; fprintf('running R...'); end
system([rcommand 'signrank_multiple.r']);
if display; fprintf('done.\n'); end
outputdata = csvread([home2 'output.csv']);

p = outputdata;