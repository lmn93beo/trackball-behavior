totaldist = [];
[files dir] = uigetfile('..\behaviorData\*.mat','MultiSelect','On');
if ~iscell(files)
    files = {files};
end

for k = 1:length(files)
load([dir files{k}]);

fliplicks = data.response.licks; % licks timestamped based on flips
totaldata = data.response.totaldata;
fs = data.card.ai_fs;
rawlicks = (find(diff(totaldata)>1)+1)/fs; % licks timestamped based on daq
flip = median(diff(data.presentation.flip_times));

flipid = zeros(size(rawlicks));
% find corresponding fliplick for each rawlick
for i = 1:length(rawlicks)
    rellicks = fliplicks-rawlicks(i); % fliplicks relative to this lick    
    id = find(rellicks > -0.2 & rellicks <0.2);
        
    foundid = false;
    while ~isempty(id) && ~foundid
        if sum(flipid==id(1))==0
            foundid = true;
        else
            id = id(2:end);
        end
    end
    if isempty(id)
        flipid(i) = NaN;
    else
        flipid(i) = id(1);
    end
end

missed_raw = find(isnan(flipid));

% check for false positives
missed_flip = [];
for i = 1:length(fliplicks)
    if isempty(find(i==flipid, 1))
        missed_flip = [missed_flip, i];
    end
end

fprintf('%d false negatives, %d false positives.\n',length(missed_raw),length(missed_flip));
p=input('Plot?');
if p
    
    % optional plot false negatives
    for i = 1:length(missed_raw)
        close all
        figure;
        hold on;

        t = rawlicks(missed_raw(i));
        if ~isempty(fliplicks(fliplicks>t-2 & fliplicks<t+2))
            plot(fliplicks(fliplicks>t-2 & fliplicks<t+2),0.9,'ro')
        end
        rawlines = (rawlicks>t-2 & rawlicks<t+2);    
        plot(rawlicks(rawlines),1,'b.')
        axis([t-2 t+2 0 2]) 
        plot([t t],ylim,'k--')
        for j = 1:length(rawlines)
            if ~isnan(flipid(j))
                plot([rawlicks(j),fliplicks(flipid(j))],[1 0.9],'k-')
            end
        end

        pause
    end
    
    for i = 1:length(missed_flip)
        close all
        figure;
        hold on;

        t = fliplicks(missed_flip(i));
        plot(fliplicks(fliplicks>t-2 & fliplicks<t+2),0.9,'ro')        
        rawlines = (rawlicks>t-2 & rawlicks<t+2);    
        if ~isempty(rawlines)
            plot(rawlicks(rawlines),1,'b.')
        end
        axis([t-2 t+2 0 2]) 
        plot([t t],ylim,'k--')
        for j = 1:length(rawlines)
            if ~isnan(flipid(j))
                plot([rawlicks(j),fliplicks(flipid(j))],[1 0.9],'k-')
            end
        end

        pause
    end
end



keyboard
dist = [];
for i = 1:length(rawlicks)
    if ~isnan(flipid)
        dist = [dist fliplicks(flipid(i))-rawlicks];
    end
end

% figure
% hold on;
% plot(rawlicks,1,'b.')
% plot(fliplicks,0.9,'ro')
% for i = 1:length(rawlicks)
%     if ~isnan(flipid(i))
%         plot([rawlicks(i),fliplicks(flipid(i))],[1 0.9],'k-')
%     end
% end
% ylim([0 2])
% r = rand*max(fliplicks);
% xlim([r-2, r+2])
% shg

totaldist = [totaldist; dist];

end