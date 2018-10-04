function [trials licks lickonsets] = loaddata(numstims, file)
%% check parameters
% choose file
if nargin < 2
    [file, dir] = uigetfile('../behaviorData/');
    file = [dir file];    
end

% number of stimuli displayed per trial
if nargin < 1
    numstims = 3;   % default is 3: delay, response, iti
end

%% load file and extract vectors
load(file)
if isfield(data.card,'trigger')
    clear data.card.trigger;
    data.card = rmfield(data.card,'trigger');
    save(file,'data')
end

licks = data.response.licks;    
stims = data.presentation.stim_times;   % time each stimulus turns OFF
% cons = data.stimuli.contrast;
% if isfield(data.stimuli,'contrast2')
%     cons2 = data.stimuli.contrast2;
% else
%     cons2 = zeros(size(cons));
% end
% cuetone = data.stimuli.cue_tone;
% dual = data.screen.dual;
% mfile = data.stimuli.movie_file;
% mfiles = unique(data.stimuli.movie_file);
% mfiles(strcmp(mfiles,''))=[];

if isfield(data.stimuli,'movie_file')
m = zeros(1,length(data.stimuli.movie_file));
for i = 1:length(data.stimuli.movie_file)
    if strcmp(data.stimuli.stim_type(i),'image')
        mtemp = data.stimuli.movie_file{i}(end-5);
        if isempty(str2num(mtemp))
            m(i) = str2num(data.stimuli.movie_file{i}(end-4));
        else
            m(i) = str2num(data.stimuli.movie_file{i}(end-5:end-4));
        end
    else
        m(i) = 0;
    end
end
end

% duration = data.stimuli.total_duration;
rewards = data.response.rewards;
punishs = data.response.punishs;
tones = data.response.tones;    % tones mark beginning of trial
if isempty(tones)
    tones = stims(2:numstims:end); % first stimulus is "dummy"
end
  
k = [];
for i = 1:length(rewards)    
    if max(licks == rewards(i)) == 0
        k(end+1) = i;
    end
end
primes = rewards(k);
truerewards = rewards;
truerewards(k) = [];    % non-primed rewards

tastes = [];
for i = 1:length(rewards)
    x = find(licks>rewards(i),1,'first');
    if ~isempty(x)
        tastes(i) = licks(x);   % first lick after reward delivery
    end
end

% check number of licks
totaldata = data.response.totaldata;
fs = data.card.ai_fs;
templicks = (find(diff(totaldata)>1)+1)/fs;
if length(templicks)~=length(licks)
    disp('Unequal lick counts.')
end

% find lick onsets
window = 0.3; % ignore all licks faster than 3.33 Hz
if isempty(licks)
    lickonsets = [];
else
    if size(licks,1)>1; licks = licks'; end;
    lickonsets = licks([true,diff(licks)>window]);
end

%% make trials
trials = struct([]);

for i = 1:length(tones)-1
    j = find(stims>=tones(i),1);
    trials(i).start_time = tones(i);
    
    if stims(j) == tones(i) % normal trial
        trials(i).end_time = stims(j+numstims);
        trials(i).stims = stims(j+1:j+numstims);
        if tones(i+1) < stims(j+numstims) % if next trial is abort
            trials(i).end_time = tones(i+1);
            trials(i).stims(numstims) = tones(i+1);
        end
    else % abort trial 
        trials(i).end_time = tones(i+1);
        trials(i).stims = tones(i+1);
    end
    
    % stored as times relative to trial start
	trials(i).licks = licks(licks>tones(i) & licks<=max(trials(i).stims));
    trials(i).lickonsets = lickonsets(lickonsets>tones(i) & lickonsets<=max(trials(i).stims));
    trials(i).rewards = truerewards(truerewards>tones(i) & truerewards<=max(trials(i).stims));
    trials(i).primes = primes(primes>tones(i) & primes<=max(trials(i).stims));
    trials(i).punishs = punishs(punishs>tones(i) & punishs<=max(trials(i).stims));
    trials(i).tastes = tastes(tastes>tones(i) & tastes<=max(trials(i).stims));
    
    trials(i).n_licks = length(trials(i).licks);
    trials(i).n_onsets = length(trials(i).lickonsets);

    % booleans
    trials(i).licked = ~isempty(trials(i).licks);
    orients = data.stimuli.orientation(j+1:j+numstims);
    trials(i).target = (orients(~isnan(orients))==90);
    if isempty(trials(i).target)
        trials(i).target = 0;
    end
    trials(i).rewarded = ~isempty(trials(i).rewards);
    if trials(i).rewarded
        % was the reward earned at the beginning of a lick bout?
        trials(i).onset = isempty(find(trials(i).licks>trials(i).rewards(1)-0.5 & trials(i).licks<trials(i).rewards(1),1));
    else
        trials(i).onset = false;
    end
    trials(i).primed = ~isempty(trials(i).primes);
    trials(i).primetrials = i*ones(~isempty(trials(i).primes));
    trials(i).punished = ~isempty(trials(i).punishs);       
    trials(i).aborted = (length(trials(i).stims)==1);
    if trials(i).aborted || trials(i).primed || ~trials(i).target
        trials(i).rewarded = NaN;
    end
    if trials(i).target
        trials(i).punished = NaN;
    end
    
    if ~isnan(trials(i).rewarded)
        trials(i).correct = trials(i).rewarded;
    elseif ~isnan(trials(i).punished)
        trials(i).correct = ~trials(i).punished;
    else
        trials(i).correct = NaN;
    end

    if exist('m','var')
        trials(i).movie = m(j+2);
    end
    
    if trials(i).target
        trials(i).tf = data.stimuli.temp_freq(j+2);
    else
        trials(i).tf = NaN;
    end
    
%     trials(i).screen = dual && (cuetone(j+1) == 4);
%     if cons(j+1) > 0 || cons2(j+1) > 0
%         trials(i).movie = find(strcmp(mfiles,mfile(j+1)));
%     else
%         trials(i).movie = 0;
%     end
    
%     trials(i).gracelick = ~isempty(find(trials(i).licks>=trials(i).stims(1) & ...
%         trials(i).licks<trials(i).stims(1)+data.response.grace_period,1));
    
    trials(i).trialnums = i*ones(size(trials(i).licks));
    trials(i).trialnums2 = i*ones(size(trials(i).lickonsets));
    
    % make all times relative to start
    f = fieldnames(trials);
    for k = 2:9
        trials(i).(f{k}) = trials(i).(f{k}) - tones(i);
    end    
    
end

% duplicate fields, but make times relative to beginning of grating
f = fieldnames(trials);
for i = 1:length(trials)
    mstop = trials(i).stims(1);    
    trials(i).start_time2 = -mstop;
    for k = 2:9
        trials(i).(strcat(f{k},'2')) = trials(i).(f{k})-mstop;
    end
end

% remove trials at end with no licks
% while isempty(trials(end).licks)
%     trials = trials(1:end-1);
% end

end