function [p,Z] = clus_signrank(x,y,cluster,display)
if nargin<4
    display = 0;
end

inputdata = [x,y,cluster];
home2 = 'C:\Users\Gerald\Documents\';
rcommand = '"C:\Program Files\R\R-3.4.0\bin\x64\R" CMD BATCH C:\Users\Gerald\Documents\';
csvwrite([home2 'input.csv'],inputdata)

if display; fprintf('running R...'); end
system([rcommand 'signrank.r']);
if display; fprintf('done.\n'); end
outputdata = csvread([home2 'output.csv']);

p = outputdata(1);
Z = outputdata(2);