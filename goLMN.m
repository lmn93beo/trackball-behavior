if strcmp(getenv('computername'),'GERALD-LAB')
    root = 'H:\Dropbox (MIT)\';
elseif strcmp(getenv('computername'),'GERALD-THINK')
    root = 'C:\Dropbox (MIT)\';
elseif strcmp(getenv('computername'),'LIADAN')
    root = 'C:\Users\Liadang\Dropbox\';
elseif strcmp(getenv('computername'),'VISSTIM-2P4');
    root = 'C:\Users\Surlab\Dropbox (MIT)\MouseAttention\matlab';
elseif strcmp(getenv('computername'),'BEHAVIOR2');
    root = 'C:\Users\Surlab\Dropbox (MIT)\'; 
elseif strcmp(getenv('computername'),'BEHAVIOR3');
    root = 'C:\Users\surlab\Dropbox (MIT)\';
elseif strcmp(getenv('computername'),'GSIPE-PC');
    root = 'C:\Users\GSIPE\Dropbox (MIT)\gray\scripts\';
elseif exist('C:\Dropbox','dir') == 7
    root = 'C:\Dropbox\';
else
    root = 'C:\Users\Surlab\Dropbox\';
end
directory = [root, 'nhat'];
addpath(genpath(directory));
cd(directory);
clearvars directory root