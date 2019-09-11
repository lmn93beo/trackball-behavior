totaldist = [];
[files dir] = uigetfile('..\behaviorData\*.mat','MultiSelect','On');
if ~iscell(files)
    files = {files};
end

for j = 1:length(files)
load([dir files{j}]);
    
% compare data.response.licks with totaldata
fliplicks = data.response.licks; % licks timestamped based on flips

totaldata = data.response.totaldata;
fs = data.card.ai_fs;
rawlicks = (find(diff(totaldata)>1)+1)/fs; % licks timestamped based on daq

flip = median(diff(data.presentation.flip_times));

flags = [];

absdist = zeros(size(fliplicks));
absdist2 = zeros(size(fliplicks));
for i = 1:length(fliplicks)
    absdist(i) = min(abs(fliplicks(i)-rawlicks));    
end
for i = 1:length(rawlicks)
    absdist2(i) = min(abs(rawlicks(i)-fliplicks));    
end

rawid = 1:length(fliplicks);
if length(rawlicks) < length(fliplicks)
    rawid(length(rawlicks)+1:end) = NaN;
end

% find false positives/negatives
while max([absdist;absdist2]) > flip
    if max(absdist) > max(absdist2); f = 1;
    else f = 2; end
    
    if f == 1
        [x id] = max(absdist);
    else
        [x id] = max(absdist2);
    end
        
    close all
    figure; hold on      
    t = fliplicks(id);
    plot(fliplicks(fliplicks>t-2 & fliplicks<t+2),0.9,'ro')
    if ~isempty(rawlicks(rawlicks>t-2 & rawlicks<t+2))
        plot(rawlicks(rawlicks>t-2 & rawlicks<t+2),1,'b.')
    end    
    axis([t-2 t+2 0 2]) 
    plot([t t],ylim,'k--')

    fp = input('False Positive or Negative? (-1/[0]/1):');
    if ~isempty(fp) && fp==1
        flags = [flags id];
    elseif ~isempty(fp) && fp==-1
        break;
    end
    if f == 1
        absdist(id) = [];
    else
        absdist2(id) = [];
    end
end
end

rawid = 1:length(fliplicks);
for i = 1:length(flags)
    rawid(flags(i)) = NaN;
    rawid(flags(i)+1:end) = rawid(flags(i)+1:end)-1;
end

dist = zeros(size(fliplicks));
for i = 1:length(fliplicks)
    if isnan(rawid(i))
        dist(i) = NaN;
    else
        dist(i) = fliplicks(i)-rawlicks(rawid(i));
    end
end
% 
% figure;
% hold on;
% hist(dist,20)
% plot(2*flip*ones(1,2),ylim,'r--')
% plot(flip*ones(1,2),ylim,'r--')
% plot(zeros(1,2),ylim,'r--')
% plot(-flip*ones(1,2),ylim,'r--')
% plot(-2*flip*ones(1,2),ylim,'r--')

totaldist = [totaldist; dist];

end

figure;
hold on;
bins = -3*flip:flip/4:5*flip;
n = histc(totaldist,bins)
bar(bins,n)
plot(2*flip*ones(1,2),ylim,'r--')
plot(flip*ones(1,2),ylim,'r--')
plot(zeros(1,2),ylim,'r--')
plot(-flip*ones(1,2),ylim,'r--')
plot(-2*flip*ones(1,2),ylim,'r--')