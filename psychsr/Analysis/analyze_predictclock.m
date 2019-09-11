[files, dir] = uigetfile('..\behaviorData\*.mat','MultiSelect','On');
% cd(dir);
if ~iscell(files) 
    files = {files};
end

for i = 1%:length(files)
    load([dir files{i}]);
    oris = data.stimuli.orientation;
    stims = data.presentation.stim_times;
    licks = data.response.licks;
    
    ori_licks = cell(1,8); % for each orientation    
    
    unique_oris = oris(2:2:16);
    
    for j = 1:floor((length(stims)-1)/2)
        l = licks(licks>stims(2*j-1) & licks<stims(2*j+1))-stims(2*j-1);
        id = find(oris(2*j)==unique_oris);
        ori_licks{id} = [ori_licks{id} l];
    end
    
    figure;    
    plotorder = [2,3,6,9,8,7,4,1];
    maxy = 0;
    for j = 1:length(unique_oris)
        subplot(3,3,plotorder(j))
        x = 0:0.2:4;
        n = hist(ori_licks{j},x)/sum(unique_oris(j) == oris);
        bar(x,n)
        if max(n)>maxy; maxy=max(n); end;        
    end
    for j = 1:length(unique_oris)
        subplot(3,3,plotorder(j))        
        hold on; plot([2 2],[0 maxy],'r--')
        ylim([0 maxy])
    end
end
    
