switch getenv('computername')
    case 'GERALD-LAB'
        root = 'H:\Dropbox (MIT)\';
    case 'GERALD-THINK'
        root = 'C:\Dropbox (MIT)\';
    case 'LIADAN'
        root = 'C:\Users\Liadang\Dropbox\';
    case 'VISSTIM-2P4';
        root = 'C:\Users\Surlab\Dropbox (MIT)\MouseAttention\matlab';
    case 'BEHAVIOR2';
        root = 'C:\Users\Surlab\Dropbox (MIT)\'; 
    case 'BEHAVIOR3';
        root = 'C:\Users\surlab\Dropbox (MIT)\';
    case 'GSIPE-PC';
        root = 'C:\Users\GSIPE\Dropbox (MIT)\gray\scripts\';
    case 'BEHAVE-BALL1'
        root = 'C:\Users\surlab\Dropbox\';
    case 'BEHAVE-BALL3'
        root = 'C:\Users\surlab\Dropbox\MouseAttention\Matlab';
    otherwise
        if exist('C:\Dropbox','dir') == 7
            root = 'C:\Dropbox\';
        else
            root = 'C:\Users\Surlab\Dropbox\';
        end
end

if strcmp(getenv('computername'), 'BEHAVE-BALL1')
    directory = fullfile(root, 'Nhat/trackball-behavior');
elseif strcmp(getenv('computername'), 'BEHAVE-BALL3')
    directory = fullfile(root, 'trackball-behavior');
else
    directory = [root, 'nhat'];
end
addpath(genpath(directory));
cd(directory);
clearvars directory root