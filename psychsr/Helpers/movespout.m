function movespout(direction, duration)
% direction = 1 or 'extend' or 'out'
%             2 or 'retract' or 'in'

if nargin<2
    duration = 0.2;
end

%% set direction
if ischar(direction)
    if strcmpi(direction,'out') || strcmpi(direction,'extend')
        direction = 1;
    elseif strcmpi(direction,'in') || strcmpi(direction,'retract')
        direction = 2;
    else
        fprintf('INVALID DIRECTION\n')
        return
    end
end

if direction == 1
    port = 2; line = 4;
elseif direction == 2
    port = 1; line = 1;
else
    fprintf('INVALID DIRECTION\n')
    return
end

%% setup digital object
dio = digitalio('nidaq', 'Dev1');
addline(dio,line,port, 'out');

%% move spout
putvalue(dio,1); tstart = tic;
WaitSecs(duration);
putvalue(dio,0);
if direction == 1
    fprintf('EXTEND\n')
else
    fprintf('RETRACT\n')
end

%% remove digital object
stop(dio)
delete(dio);