% analyze training data across days
% clearvars -except mht mfa mdp; %close all;
clear all_hits all_falarm all_dprime;
clc;

windowsize = 50; % moving window size

%% load files
if strcmp(getenv('computername'),'analysis-2P4')
    root = 'c:\users\surlab\dropbox\mouseattention\behaviorData';
else
    root = 'c:\dropbox\mouseattention\behaviorData';
end
[files, dir] = uigetfile([root '\*.mat'],'MultiSelect','On');
if ~iscell(files); files = {files}; end
other = cellfun(@(x) ~strcmp(x(10:15),'train7'),files); files(other) = [];
passive = cellfun(@(x) strcmp(x(end-4),'P'),files); files(passive) = [];
engaged = cellfun(@(x) strcmp(x(end-4),'E'),files);
if sum(engaged)==0
    engaged = NaN;
else
    engaged = datenum(files{find(engaged,1)}(1:8),'yyyymmdd')-datenum(files{1}(1:8),'yyyymmdd')+0.5;
end

nfiles = length(files);

%% analysis per file
nt = 0; t =[];

% these vectors are for each DAY, not for each file
ndays = datenum(files{end}(1:8),'yyyymmdd')-datenum(files{1}(1:8),'yyyymmdd')+1;
ntrials = NaN*ones(ndays,1); 
nmovies = NaN*ones(ndays,1);
tspeed = NaN*ones(ndays,1);
mean_hit = NaN*ones(ndays,1);
mean_falarm = NaN*ones(ndays,1);
mean_dprime = NaN*ones(ndays,1);
i = 1; % index representing day

for j = 1:nfiles
    trials = loaddata(3,[dir files{j}]);
    
    % remove no-lick trials at end
    while ~isempty(trials) && isempty(trials(end).licks)
        trials = trials(1:end-1);
    end
    
    hits = movingwindow([trials.rewarded],1,windowsize);
    falarm = movingwindow([trials.punished],1,windowsize);
    dprime = smooth(norminv(hits,0,1)-norminv(falarm,0,1),5);
    all_hits = append_vector(hits);
    all_falarm = append_vector(falarm);
    all_dprime = append_vector(dprime);
        
    umovies = unique([trials.movie]); % find unique movies
    umovies(umovies==0) = [];
    
    if isnan(ntrials(i))        
        mean_hit(i) = nanmean([trials.rewarded]);
        mean_falarm(i) = nanmean([trials.punished]);        
        ntrials(i) = length(trials);
        nmovies(i) = length(umovies);
        tspeed(i) = nanmin([trials.tf]);
    else
        n1 = length(trials); n2 = ntrials(i);
        mean_hit(i) = n1/(n1+n2)*nanmean([trials.rewarded])+n2/(n1+n2)*mean_hit(i);
        mean_falarm(i) = n1/(n1+n2)*nanmean([trials.punished])+n2/(n1+n2)*mean_hit(i);        
        ntrials(i) = length(trials)+ntrials(i);
        nmovies(i) = max([length(umovies), nmovies(i)]);
        tspeed(i) = min([nanmin([trials.tf]), tspeed(i)]);
    end    
    
    t = [t;[nt+1:nt+length(hits)]'];
    
    if j<length(files)
        days = datenum(files{j+1}(1:8),'yyyymmdd')-datenum(files{j}(1:8),'yyyymmdd');        
        i = i+days; % increment i
        days = (days-1)*(days>1);
        nt = max(t)+50+days*100;        
    end    
    
end

% calculate mean_dprime
mhit = mean_hit; mfalarm = mean_falarm;
mhit(mhit>0.99) = 0.99; mfalarm(mfalarm>0.99) = 0.99;
mhit(mhit<0.01) = 0.01; mfalarm(mfalarm<0.01) = 0.01;
mean_dprime = norminv(mhit,0,1)-norminv(mfalarm,0,1);

% convert to 1000s of trials
t = t/1000;

%% plot
%close all

% performance across trials
% figure
% subplot(2,1,1); hold on;
% plot(t,all_hits,'b.');
% plot(t,all_falarm,'r.');  
% xlim([0 max(t)]);%1.3*max(t)]); 
% ylim([0 1]);
% ylabel('Hits/FAs')
% title(sprintf('%s: %s-%s',dir(end-10:end-1),files{1}(5:8),files{end}(5:8)))
% legend('Hit%','FA%','Location','SouthEast')
% 
% subplot(2,1,2); hold on;
% plot(t,all_dprime,'.k'); 
% plot([0 1.3*max(t)],[0 0],'--k')
% plot([0 1.3*max(t)],[1.2 1.2],'--b')
% xlim([0 max(t)]);%1.3*max(t)]); 
% ylim([-1 5])
% ylabel('D-prime')
% xlabel('Thousands of trials');

% mean performance across sessions
% figure; 
% subplot(2,1,1); hold on;
d = 1:length(ntrials);
x = ~isnan(ntrials);
% shade = [0.9 0.9 0.9];
% area([engaged,max(d)+0.5],[1 1],'FaceColor',shade,'EdgeColor',shade)
% plot(d(x),mean_hit(x),'bo-')
% plot(d(x),mean_falarm(x),'ro-'); 
% set(gca,'XTick',[1,5:5:max(d)],'YTick',0:0.5:1);
% set(gca,'Layer','top')
% xlim([1 max(d)])
% ylim([0 1]);
% ylabel('Hits/FAs')
% title(sprintf('%s: %s-%s',dir(end-10:end-1),files{1}(5:8),files{end}(5:8)))
% legend('Imaging','Hit%','FA%','Location','SouthEast')
% 
% subplot(2,1,2); hold on;
% shade = [0.9 0.9 0.9];
% area([engaged,max(d)+0.5],[5 5],-1,'FaceColor',shade,'EdgeColor',shade)
% plot(d(x),mean_dprime(x),'ko-')
% % plot([0 max(d)],[0 0],'--k')
% % plot([0 max(d)],[1.2 1.2],'--b')
% set(gca,'XTick',[1,5:5:max(d)],'YTick',0:4);
% set(gca,'Layer','top')
% xlim([1 max(d)])
% ylim([-0.5 3.5])
% ylabel('D-prime')
% xlabel('Day #')

level = (nmovies>1)+(nmovies>3)+(tspeed<2);
figure
hold on;
shade = [0.9 0.9 0.9];
area([engaged,max(d)+0.5],[5 5],-1,'FaceColor',shade,'EdgeColor',shade)
plot(d(x),mean_dprime(x),'k-')
plot(d(x & level==0),mean_dprime(x & level==0),'k^','MarkerFaceColor','w')
plot(d(x & level==1),mean_dprime(x & level==1),'ks','MarkerFaceColor',[0.5 0.5 0.5])
plot(d(x & level>1),mean_dprime(x & level>1),'ko','MarkerFaceColor','k','MarkerSize',8)
% plot([0 max(d)],[0 0],'--k')
% plot([0 max(d)],[1.2 1.2],'--b')
set(gca,'XTick',[1,5:5:max(d)],'YTick',0:4);
set(gca,'Layer','top')
xlim([1 max(d)])
ylim([-0.5 3.5])
ylabel('D-prime')
xlabel('Day #')

