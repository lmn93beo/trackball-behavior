% analyze_plasticity.m
%
% create lick histograms for target and non-target stimuli
% MG 110912

% user inputs
bin_size = 0.1;               % bin size (s)
pre_time = 1;                 % time(s) before movie to use for histograms
post_time = 4;                % time(s) after reward to use for histograms
stim_time = 1.75;             % stimulus duration (s)
trace_interval = 0.25;        % length of interval (s)

% calculate offsets
start_offset = pre_time+stim_time;
end_offset = (trace_interval+post_time);
histogram_bins = (start_offset+end_offset)/bin_size;

% open data file
cd C:\Dropbox\MouseAttention\behaviorData\plasticity
% cd C:\Users\mikeg\Dropbox\MouseAttention\behaviorData\plasticity
[filename, pathname] = uigetfile('*.mat');
cd(pathname)
load(filename)

% determine indices for targets and non-targets
allstim_indices = ~strcmp(data.stimuli.movie_file,'');
target_indices = strcmp(data.stimuli.movie_file,data.stimuli.target_movie);
nontarget_indices = logical(allstim_indices-target_indices);

% determine stim times
target_stim_times = data.presentation.stim_times(target_indices);
nontarget_stim_times = data.presentation.stim_times(nontarget_indices);

% make onset vector
ITI=data.response.licks-[0 data.response.licks(1:end-1)];
onset_licks=data.response.licks(ITI>0.25);

% make nontarget lick histogram
nontarget_hist=zeros(length(nontarget_stim_times),histogram_bins);
for i = 1:length(nontarget_stim_times)
    curr_start_time = nontarget_stim_times(i)-start_offset;
    curr_end_time = nontarget_stim_times(i)+end_offset;
    edges = [curr_start_time:bin_size:curr_end_time];
    counts = histc(data.response.licks,edges);
    onset_counts = histc(onset_licks,edges);
    nontarget_hist(i,:) = counts(1:end-1);
    nontarget_onset_hist(i,:) = onset_counts(1:end-1);
end
nontarget_mean_hist=mean(nontarget_hist);
nontarget_mean_onset_hist=mean(nontarget_onset_hist);

% make target lick histogram
target_hist=zeros(length(target_stim_times),histogram_bins);
for i = 1:length(target_stim_times)
    curr_start_time = target_stim_times(i)-start_offset;
    curr_end_time = target_stim_times(i)+end_offset;
    edges = [curr_start_time:bin_size:curr_end_time];
    counts = histc(data.response.licks,edges);
    onset_counts = histc(onset_licks,edges);
    target_hist(i,:) = counts(1:end-1);
    target_onset_hist(i,:) = onset_counts(1:end-1);
end
target_mean_hist=mean(target_hist);
target_mean_onset_hist=mean(target_onset_hist);

% make bar plots and save
time_vector = [-(pre_time+stim_time+trace_interval)+bin_size:bin_size:post_time];
movie_time = linspace(-(stim_time+trace_interval),-trace_interval,100);
hist_max = max(max(nontarget_mean_hist),max(target_mean_hist));
hist_max = ceil(hist_max*10)/10;
subplot(2,2,1);
bar(time_vector,nontarget_mean_hist)
hold on
plot(movie_time,ones(1,100)*0.1,'Color',[0.5 0.5 0.5],'linewidth',3)
plot(zeros(1,100),linspace(0,hist_max,100),'r:','linewidth',2)
axis([time_vector(1) time_vector(end) 0 hist_max])
title('Non-Target Stimuli - Total Responses')
subplot(2,2,2);
bar(time_vector,target_mean_hist)
hold on
plot(movie_time,ones(1,100)*0.1,'Color',[0.5 0.5 0.5],'linewidth',3)
plot(zeros(1,100),linspace(0,hist_max,100),'r:','linewidth',2)
axis([time_vector(1) time_vector(end) 0 hist_max])
title('Target Stimuli - Total Responses')
subplot(2,2,3);
bar(time_vector,nontarget_mean_onset_hist,'r')
hold on
plot(movie_time,ones(1,100)*0.1,'Color',[0.5 0.5 0.5],'linewidth',3)
plot(zeros(1,100),linspace(0,hist_max,100),'r:','linewidth',2)
axis([time_vector(1) time_vector(end) 0 hist_max])
title('Non-Target Stimuli - Onset Responses')
subplot(2,2,4);
bar(time_vector,target_mean_onset_hist,'r')
hold on
plot(movie_time,ones(1,100)*0.1,'Color',[0.5 0.5 0.5],'linewidth',3)
plot(zeros(1,100),linspace(0,hist_max,100),'r:','linewidth',2)
axis([time_vector(1) time_vector(end) 0 hist_max])
title('Target Stimuli - Onset Responses')
set(gcf,'Position',[250 150 1250 750])
pause
saveas(gcf,filename(1:end-4))
close
clear
