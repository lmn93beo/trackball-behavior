function [p,Z] = clus_ranksum(x,cluster,group,display)
if nargin<4
    display = 0;
end
home2 = 'C:\Users\Gerald\Documents\';

if exist([home2 'input.csv'],'file')
    delete([home2 'input.csv'])
end
if exist([home2 'output.csv'],'file')
    delete([home2 'output.csv'])
end

inputdata = [x,cluster,group];
rcommand = '"C:\Program Files\R\R-3.4.0\bin\x64\R" CMD BATCH C:\Users\Gerald\Documents\';
csvwrite([home2 'input.csv'],inputdata)

if display; fprintf('running R...'); end
system([rcommand 'ranksum.r']);
if display; fprintf('done.\n'); end
outputdata = csvread([home2 'output.csv']);

p = outputdata(1);
Z = outputdata(2);