function data = checkerboard_old(dParams)    
%% User parameters
fnames = fieldnames(dParams);
for i = 1:length(fnames)
    eval([fnames{i}, '=getfield(dParams,fnames{i});']);
end
repeats=10;                 % Number of times to alternate checkerboard
altPeriod=2;                % Period of checkerboard alternations (Sec)
numChecks=8;                % Number of squares in checkerboard (vertical dimension)
blankTime=2;                % Length of blank frames before stimulus (in seconds)

% Save data
data.stimType='checkerboard';
data.blankTime=blankTime;
data.period=altPeriod;
data.repeats=repeats;

%% Make textures
% Create checkerboard template
squareLength=floor(y_pixel/numChecks);
numChecks_horizontal=floor(x_pixel/squareLength);
line1=[]; line2=[]; template=[];
for x=1:numChecks_horizontal
    line1=[line1 ones(squareLength)*wht*rem(x,2)];
    line2=[line2 ones(squareLength)*wht*rem(x+1,2)];
end
for y=1:numChecks
    eval(['template=[template; line' num2str(rem(y,2)+1) '];'])
end

% Make blank texture
tex(1)=Screen('MakeTexture',win,gry); 

% Make stim textures
tex(2)=Screen('MakeTexture',win,template);
template(template==blk)=-1;
template(template==wht)=blk;
template(template==-1)=wht;
tex(3)=Screen('MakeTexture',win,template); % alternated checkerboard

%% Stimulus indices and durations
stims = [1,repmat([2,3],1,round(repeats/2))];
stimtimes = cumsum([blankTime,repmat(altPeriod,1,repeats)]);

nstims = length(stims);

%% Animation
disp('Press any key to begin trial')
Screen('TextSize', win, 24);
Screen('DrawText', win, 'Press any key to begin trial', 10, 10, 255);
Screen('Flip', win);

KbPressWait;    % Wait for key press
KbReleaseWait;

flips = []; f = 1; i = 1;
lasti = 1;
times = zeros(1,repeats+2);

vbl = Screen('Flip', win);
vbl0 = vbl;

while i <= nstims
    Screen('DrawTexture', win, tex(stims(i)));
    Screen('DrawingFinished', win); 
    
    % was previously drawn frame same as this frame?
    if (lasti ~= i) % last flip of each stimulus
        times(i) = 1000*(vbl - vbl0);        
    end
    lasti = i;    
    
    % is onset time of prev frame approaching a new stimulus time?
    if (vbl-vbl0) > stimtimes(i)-1.5*ifi
        i = i + 1; % next stimulus        
    end
    
    flips(f) = 1000*(vbl-vbl0); f = f+1;
    
    vbl = Screen('Flip', win, vbl + (waitframes - 0.5) * ifi);
end
times(i) = 1000*(vbl - vbl0);
flips(length(flips)+1) = 1000*(vbl-vbl0);

data.flips = flips;
data.times = times;
return
