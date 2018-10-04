function behaviorChecker(dateval)
% datenum should be in format 140715 for july 15, 2014
% default: find latest date

home = 'C:\Dropbox\MouseAttention\behaviorData';
cd(home)

folders = dir('mouse*');

if nargin<1 % find latest date
    
    dateval = 0;
    for i = 1:length(folders)
        cd(home)
        cd(folders(i).name)
        temp = dir('*.mat');        
        
        dateval = max([temp.datenum dateval]);
    end     
    dateval = datestr(dateval,'yyyymmdd');
elseif isnumeric(dateval)
    dateval = ['20' sprintf('%06d',dateval)];
elseif ischar(dateval) && length(dateval)<8
    dateval = ['20' dateval];
end

mouse = []; 
pc = [];
summary = {};
timestamp = [];
for i = 1:length(folders)
    cd(home)
    cd(folders(i).name)
    temp = dir('*.mat');
    
    ix = find(cellfun(@(x) strcmp(x(1:min([8,end])),dateval),{temp.name}));
    
    for j = 1:length(ix)
        load(temp(ix(j)).name);
        mouse(end+1) = data.mouse;
        pc(end+1) = str2num(data.screen.pc(end));
        if isfield(data.response,'summary')
            summary{end+1} = data.response.summary;
        else
            summary{end+1} = 'Not saved properly';
        end
        timestamp(end+1) = temp(j).datenum;
    end
end

close all
figure
setFigSize(1,1)
for r = 1:3
    files = find(pc == r);
    [~,ix] = sort(timestamp(files));
    files = files(ix);
    mice = unique(mouse(files));
        
    for m = 1:length(mice)                      
        subplot(4,3,(m-1)*3+r)        
        axis off
                
        mfiles = find(mouse(files)==mice(m));
        for f = 1:length(mfiles)
            text(0.4*(f-1),1,summary{files(mfiles(f))},'VerticalAlignment','top')
        end                       
    end
    
end
 
subplot(4,3,2)
title(dateval)
axis off
shg
disp(dateval)
user = input('[n]ext, [p]revious, [q]uit?: ' ,'s');
switch user
    case 'n'
        behaviorChecker(datestr(datenum(dateval,'yyyymmdd')+1,'yyyymmdd'))
    case 'p'
        behaviorChecker(datestr(datenum(dateval,'yyyymmdd')-1,'yyyymmdd'))
    case 'q'
        disp('Done')
        return        
end
