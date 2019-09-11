global data
currX = 0;          % current trackball position (actual)
currT = 0;          % current trial time    
screenX = [];       % log of all screen positions
ballX = [];         % log of all trackball positions
samps = [];         % samples (serial) per loop
timePC = [];        % log of all timestamps
licks = [];         % log all licks
choice = 0;         % current trial choice
go = 0;             % count mvmts?
drawFlag = 0;       % was stimulus drawn on last loop?
flips = [];         % fliptimes of stimulus ON v OFF
godelay = 0;        % delay between trial start and stimulus on
actdelay = 0;       % actual flip time diff

if max(data.params.flashStim) > 0 % randomly choose a stimulus duration
    stimtime = data.params.flashStim(randi(numel(data.params.flashStim)));
    %stimtime = min(data.params.flashStim) + rand*range(data.params.flashStim);
else
    stimtime = 0;
end
