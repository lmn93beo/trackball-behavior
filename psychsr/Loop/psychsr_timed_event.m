function [run seq reltime] = psychsr_timed_event(loop, seq, reltime, numseq)
% run is a boolean -- tells program whether or not to run the event

% seq = position of stimulus in the trial sequence
% reltime = time relative to onset of that stimulus
% numseq = number of stimuli in the trial sequence (default = 3)

global data;
run = false; % default is false

if nargin < 4
    numseq = 3;
end

if reltime == Inf    
    return 
end

% convert reltime to a value that is nonnnegative and within stimulus time
i = 1;
while reltime < 0        
    % find index of next stimulus at position seq-i
    ind = (seq-i) + (0:numseq:loop.stim+numseq*2);
    ind = ind(find(ind>=loop.stim,1));
    
    try
        if sum(data.stimuli.duration(ind:ind+i-1)) + reltime >= 0
            reltime = sum(data.stimuli.duration(ind:ind+i-1)) + reltime;
            seq = mod(seq-i,numseq);
        else
            i=i+1;
        end
    catch
        return
    end
end

% reduce reltime by 1 seq if necessary
ind = seq+(0:numseq:loop.stim+numseq*2);
ind = ind(find(ind<=loop.stim,1,'last'));
i = 0;
try
    % use "while" instead of "if" to reduce to lowest possible nonnegative value
    if ~isempty(ind) && reltime >= sum(data.stimuli.duration(ind:ind+i))
        i = i+1;
    end
catch
    return
end
seq = mod(seq+i,numseq);
reltime = reltime-sum(data.stimuli.duration(ind:ind+i-1));

% check to see if current stimulus
if mod(loop.stim,numseq) == seq
    if (loop.stim == 1 && loop.prev_flip_time >= reltime)
        if (reltime == 0 && loop.frame == 1) || data.presentation.flip_times(end-1) < reltime
            run = true;
        end
    elseif (loop.stim>1 && loop.prev_flip_time-data.presentation.stim_times(end) >= reltime)
        if (data.presentation.flip_times(end-1)-data.presentation.stim_times(end) < reltime)
            run = true;
        end 
    end
end       
