% engagementBehavior
% analyze engagement behavioral data from an entire session
% multiple interleaved engaged and passive blocks
clear all; % close all; 
clc;

windowsize = 16;

%% load files
if strcmp(getenv('computername'),'analysis-2P4')
    root = 'c:\users\surlab\dropbox\mouseattention\behaviorData';
else
    root = 'c:\dropbox\mouseattention\behaviorData';
end
[files, dir] = uigetfile([root '\*.mat'],'MultiSelect','On');
if ~iscell(files); files = {files}; end
other = cellfun(@(x) ~strcmp(x(10:15),'train7'),files); files(other) = [];
nfiles = length(files);
passive = cellfun(@(x) strcmp(x(end-4),'P'),files);

%% output variables
grating_trials = cell(nfiles,1);
    % each cell = ntrials X 1 vector of trial #s with grating       
grating_times = cell(nfiles,1);
    % each cell = ntrials X 2 vector of grating start/stop times
grating_licked = cell(nfiles,1);
    % each cell = ntrials X 1 vector of bools (1 = licked)
movie_trials = cell(nfiles,12);
    % each cell (column = mov#) = ntrials X 1 vector of trial #s with movie    
movie_times = cell(nfiles,12); 
    % each cell (column = mov#) = ntrials X 2 vector of movie start/stop times     
movie_licked = cell(nfiles,12);
    % each cell (column = mov#) contains ntrials X 1 vector of bools (1 = licked) 

%% analysis per file
for i = 1:nfiles       
    % load data (from engaged blocks) into trials
    trials = loaddata(3,[dir files{i}]);
    
    % extract grating trials/times
    grating_trials{i} = find([trials.target]);        
    temp = [trials(grating_trials{i}).stims]; 
    temp(3:3:end) = [];
    temp = reshape(temp,2,[])';    
    grating_times{i} = repmat([trials(grating_trials{i}).start_time],2,1)'+temp;    
    grating_licked{i} = [trials(grating_trials{i}).rewarded];
    
    % extract movie trials/times
    umovies = unique([trials.movie]); % find unique movies
    umovies(umovies==0) = [];
    
    for j = 1:length(umovies)
        k = umovies(j);
        movie_trials{i,k} = find([trials.movie]==k);
        
        temp = [trials(movie_trials{i,k}).stims];
        temp(3:3:end) = [];
        temp = reshape(temp,2,[])';    
        movie_times{i,k} = repmat([trials(movie_trials{i,k}).start_time],2,1)'+temp;
        
        movie_licked{i,k} = [trials(movie_trials{i,k}).punished];        
    end    
    
    % extract performance
    hits = movingwindow([trials.rewarded],1,windowsize);
    falarm = movingwindow([trials.punished],1,windowsize);
    dprime = smooth(norminv(hits,0,1)-norminv(falarm,0,1),5);
    all_hits = append_vector(hits);
    all_falarm = append_vector(falarm);
    all_dprime = append_vector(dprime);    
    
end

%% bulk analysis
% plot performance
figure; 
subplot(2,1,1)
hold on;
plot(all_hits,'b')
plot(all_falarm,'r')
ylim([0 1])
ylabel('Hit% / FA%')
legend('Hit%','FA%')
title([files{1}(1:8),' - Performance across session'])
subplot(2,1,2)
hold on;
plot(all_dprime,'k')
plot([1,length(all_dprime)],[1.2 1.2],'--b')
ylabel('D-prime')
ylim([0 4])
xlabel('Trial #')

% count # of "usable" (no lick) trials per movie, per file
movie_usable = cellfun(@(x) sum(x==0),movie_licked);
movie_total = cellfun(@length,movie_licked);

% count # of usable trials per movie across files
movie_all_usable = sum(movie_usable(~passive,:),1);
movie_all_total = sum(movie_total(~passive,:),1);

% plot usable repeats per movie
figure;
bar(movie_all_usable./movie_all_total)
ylim([0 1])
text(1:12,max(ylim)*0.05*ones(1,12),cellstr(num2str(movie_all_usable')),...
    'HorizontalAlignment','center','Color',[1 1 1])
xlabel('Movie #')
ylabel('% correct reject')
title([files{1}(1:8),' - Usable repeats per movie'])

%% save data
bdata = psychsr_zip(grating_times,grating_trials,grating_licked,movie_trials,movie_times,...
    movie_licked,movie_usable,movie_total,movie_all_usable,movie_all_total,...
    all_hits,all_falarm,all_dprime);

uisave('bdata',sprintf('%s/%s_engagementanalysis_%s',dir,files{1}(1:8),files{1}(17:20)));
