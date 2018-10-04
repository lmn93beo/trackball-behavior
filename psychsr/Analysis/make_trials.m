function make_trials(files,dir,reanalyze)
% extracts trial information from data structure
% trial structure = 3 stimuli:
% 2) delay
% 3) resp
% 4) iti

%% load file
if nargin<2
    [files, dir] = uigetfile('..\behaviorData\*.mat','MultiSelect','On');
end
if nargin<3
    reanalyze = input('Reanalyze files? (0/1): ');
end
if ~iscell(files) 
    files = {files};
end

for l = 1:length(files)
load([dir, files{l}])

if isfield(data,'analysis') && ~reanalyze
disp('Already analyzed');
else
%% load movie file names
mfile = data.stimuli.movie_file;
mfiles = unique(data.stimuli.movie_file);
mfiles(strcmp(mfiles,''))=[];

%% separate primes and "true" rewards
k = [];
for i = 1:length(data.response.rewards)    
    if max(data.response.licks == data.response.rewards(i)) == 0
        k(end+1) = i;
    end
end

data.response.primes = data.response.rewards(k);
data.response.truerewards = data.response.rewards;
data.response.truerewards(k) = [];    % non-primed rewards

%% count "tastes" = first lick after reward delivery
for i = 1:length(data.response.rewards)
    x = find(data.response.licks>data.response.rewards(i),1,'first');
    if ~isempty(x)
        data.response.tastes(i) = data.response.licks(x);   % first lick after reward delivery
    end
end

%% check number of licks
templicks = (find(diff(data.response.totaldata)>1)+1)/data.card.ai_fs;
if length(templicks)~=length(data.response.licks)
    disp('Unequal lick counts.')
end

%% find lick onsets
window = 0.3; % ignore all licks faster than 3.33 Hz
data.response.lickonsets = data.response.licks([true,diff(data.response.licks)>window]);

%% make trials
trials = struct([]);

for i = 1:length(data.response.tones)-1
    j = find(data.presentation.stim_times>=data.response.tones(i),1);
    trials(i).start_time = data.response.tones(i);
    
    if data.presentation.stim_times(j) == data.response.tones(i) % normal trial
        trials(i).end_time = data.presentation.stim_times(j+3);
        trials(i).stims = data.presentation.stim_times(j+1:j+3);
        if data.response.tones(i+1) < data.presentation.stim_times(j+3) % if next trial is abort
            trials(i).end_time = data.response.tones(i+1);
            trials(i).stims(3) = data.response.tones(i+1);
        end
    else % abort trial 
        trials(i).end_time = data.response.tones(i+1);
        trials(i).stims = data.response.tones(i+1);
    end
    
    % stored as times relative to trial start
	trials(i).licks = data.response.licks(data.response.licks>data.response.tones(i) & data.response.licks<=max(trials(i).stims));
    trials(i).lickonsets = data.response.lickonsets(data.response.lickonsets>data.response.tones(i) & data.response.lickonsets<=max(trials(i).stims));
    trials(i).rewards = data.response.truerewards(data.response.truerewards>data.response.tones(i) & data.response.truerewards<=max(trials(i).stims));
    trials(i).primes = data.response.primes(data.response.primes>data.response.tones(i) & data.response.primes<=max(trials(i).stims));
    trials(i).punishs = data.response.punishs(data.response.punishs>data.response.tones(i) & data.response.punishs<=max(trials(i).stims));
    trials(i).tastes = data.response.tastes(data.response.tastes>data.response.tones(i) & data.response.tastes<=max(trials(i).stims));
    
    trials(i).n_licks = length(trials(i).licks);
    trials(i).n_onsets = length(trials(i).lickonsets);

    % reaction time
    if isempty(trials(i).rewards)         
        trials(i).rt = [];
    elseif max(trials(i).rewards(1) == trials(i).lickonsets)
        trials(i).rt = trials(i).rewards(1) - trials(i).stims(1); % lick onset (earned reward)
    else
        trials(i).rt = trials(i).lickonsets(find(trials(i).lickonsets<trials(i).rewards(1),1,'last'));
        if ~isempty(trials(i).rt); trials(i).rt = trials(i).rt - trials(i).stims(1); end;        
        % early licking ("lucky" reward)            
    end    
    if trials(i).rt < 0.1
        trials(i).rt = [];
    end
        
    % booleans
    trials(i).licked = ~isempty(trials(i).licks);
    orients = data.stimuli.orientation(j+1:j+3);
    trials(i).target = (orients(~isnan(orients))==90);
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
    
    if isfield(data.stimuli,'stim_side')
        trials(i).screen = 2-data.stimuli.stim_side(j+1);
    else
        trials(i).screen = data.screen.dual && (data.stimuli.cue_tone(j+1) == 4);
    end
    
    if isfield(data.stimuli, 'cue_type')
        trials(i).cue_type = data.stimuli.cue_type(j+1);
    else
        trials(i).cue_type = 'valid';
    end
    
    if data.stimuli.contrast(j+1) > 0 || data.stimuli.contrast2(j+1) > 0
        trials(i).movie = find(strcmp(mfiles,mfile(j+1)));
    else
        trials(i).movie = 0;
    end
    
    trials(i).gracelick = ~isempty(find(trials(i).licks>=trials(i).stims(1) & ...
        trials(i).licks<trials(i).stims(1)+data.response.grace_period,1));
    
    trials(i).trialnums = i*ones(size(trials(i).licks));
    trials(i).trialnums2 = i*ones(size(trials(i).lickonsets));
    
    % make all times relative to start
    f = fieldnames(trials);
    for k = 2:9
        trials(i).(f{k}) = trials(i).(f{k}) - data.response.tones(i);
    end    
    
    trials(i).soa = trials(i).stims(1);
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

% fix SOA for aborted trials
x = find([trials.aborted]);
for i = length(x):-1:1
    if x(i) == length(trials)
        trials(x(i)) = [];
    else
        trials(x(i)).soa = trials(x(i)+1).soa;
    end
end

% remove trials at end with no licks
while isempty(trials(end).licks)
    trials = trials(1:end-1);
end

%% store into data
data.analysis.trials = trials;
save([dir files{l}], 'data')

end
fprintf('Completed %d of %d\n',l,length(files))
end