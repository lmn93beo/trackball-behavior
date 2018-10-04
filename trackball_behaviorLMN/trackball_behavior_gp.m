% Clear the workspace
close all;
clear all;
javaaddpath(which('MatlabGarbageCollector.jar'))
global data
psychsr_go_root();
%% params
mouse = input('Mouse #: ');
reward = 5;
freeChoice = 0; % percentage of free choices
perRight = 1;
gain = 1;
% 1 ~= 45 deg threshold
lr_ratio = 1;%1.4; 
antibias = 0;%.5;
targetdistance = 0.2;%0.01; % from 0 to 1
extenddelay = 1;
easymove = 2;
% data.easydist = 0.3;
data.easygain = 1; % slows down mvmt in the biased direction by this factor
wrongway = 1;

punishDelay = 3;
rewardDelay = 2.5;
delay = 1; % inter-trial interval
startbias = 0;
x = 0;
numTrials = 100;
responseTime = 5;
fxClock = tic;
trialEndTime = [];

aiFlag = 1; % record licks?
rewardFlag = 1; % give reward?

%% Setup Nidaq

data.card.name = 'nidaq';
data.card.id = 'Dev1';
data.card.trigger_mode = 'none';
data.card.inter_trigger_interval = Inf;
daqreset;

data.card.dio_ports = [1,2];
data.card.dio_lines = [0 4];
data.card.dio = digitalio(data.card.name, data.card.id);

for i = 1:length(data.card.dio_ports)
    addline(data.card.dio, data.card.dio_lines(i), data.card.dio_ports(i), 'out');
end

% line 1 = reward
% line 2 = punish
% line 3/4 = other

data.card.dio.TimerFcn = @psychsr_dio_output;
data.card.dio.TimerPeriod = 0.01; % every 10ms

% initialize UserData structure
outdata.dt = zeros(size(data.card.dio_ports));
outdata.tstart = NaN*ones(size(data.card.dio_ports));
data.card.dio.UserData = outdata;

if ~strcmp(data.card.trigger_mode, 'out')
    start(data.card.dio);
end

%%% analog input setup - GP 141219
data.card.ai = analoginput(data.card.name, data.card.id);
ai_chan = 2;
ai_fs = 64;
addchannel(data.card.ai, ai_chan);
set(data.card.ai, 'SampleRate', ai_fs);
set(data.card.ai,'TriggerType','Immediate');
set(data.card.ai, 'SamplesPerTrigger', inf);
%%% GP 141219

%% setup sound
data.sound.noise_amp = 0.25;
data.sound.noise_time = 2;
data.sound.tone_amp = 0.25;
data.sound.tone_time = 0.5;
data.sound.pahandle = 0;
data.sound.tone = 0;
data.sound.buffers = 0;
   
psychsr_sound_setup();

%% Setup reward
if rewardFlag
    
    load psychsr_reward_params
    [amt,time,b] = psychsr_set_reward(reward);
    
    data.response.reward_time = time;
    data.response.reward_amt = amt;
    data.response.reward_cal = b;
    
    if ~isnan(amt)
        data.response.reward_time = (data.response.reward_cal(1)*amt+data.response.reward_cal(2))/1000;
    end
end
%% Open communications with the Arduino
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end
arduino = serial('COM5');
arduino.InputBufferSize = 50000;
arduino.BaudRate = 115200;
arduino.FlowControl = 'hardware';
fopen(arduino);
% fscanf(arduino);
% if toc > 0.5
%     fprintf('------ARDUINO FAILURE------\n')
% end

%% Setup Screen
KbName('UnifyKeyNames');
AssertOpenGL;
Screen('Preference','VisualDebugLevel',3);
Screen('Preference', 'SkipSyncTests', 1);
% Get the screen numbers
screens = Screen('Screens');
% Screen('Preference', 'SkipSyncTests', 1);
% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = round(white/2);

% Open an on screen window
[window, windowRect] = Screen('OpenWindow', screenNumber, grey);

% [homescreen] = Screen('OpenWindow', screenNumber-1, white);
% HideCursor;
AssertGLSL;

%Get the screen size
res = Screen(screenNumber, 'Resolution');

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Setup the text type for the window
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 50);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

wait_frames = 1;
flip_int = 1/Screen('FrameRate', window);

% move cursor off screen
SetMouse(-700,0) 

%% Trial params
data.stims = (rand(1,numTrials)<perRight)+1;
data.stims(rand(1,numTrials)<=freeChoice) = 3;

% Change color
% color{1} = [255 0 0];
% color{2} = [0 255 0];
% color{3} = [0 0 255];
color{1} = [0 0 0]; %[255 0 0];
color{2} = [0 0 0]; %[0 255 0];
color{3} = [0 0 0]; %[0 0 255];

%% Rectangle parameters
%Set rectangle positions (in pixels)
xSidePos = [screenXpixels*(0.5-0.3*targetdistance), screenXpixels * (0.5+0.3*targetdistance)];

height_cm = 9.2;
width_cm = 15.2;
ff=(height_cm/width_cm)/(screenYpixels/screenXpixels);

oval_factor = 2/sqrt(pi);

m1 = screenXpixels*0.2; % set cursor size to be 1/5 of screen width
m2 = m1/ff;
midRect = [0 0 m1 m2];
ovalRect = midRect*oval_factor + [0 0 20 20];
sideRect = midRect + [0 0 20 20];

dwidth = sqrt(2)*m1/2;
diamond = [-dwidth, yCenter; ...
    0, yCenter+dwidth/ff; ...
    dwidth, yCenter; ...    
    0, yCenter-dwidth/ff];

diamondleft = diamond+repmat([xSidePos(1) 0],4,1);
diamondright = diamond+repmat([xSidePos(2) 0],4,1);

decisionPos = xCenter - xSidePos(1);

dstSideRects = [];
dstSideRects(:, 1) = CenterRectOnPointd(sideRect, xSidePos(1), yCenter);
dstSideRects(:, 2) = CenterRectOnPointd(sideRect, xSidePos(2), yCenter);
ovalLeft = CenterRectOnPointd(ovalRect, xSidePos(1), yCenter);
ovalRight = CenterRectOnPointd(ovalRect, xSidePos(2), yCenter);


%% Loop through all the trials

%%% start analog input - GP 141219
mvmt_test = true;
fprintf('testing trackball, waiting for mvmt...\n')
while mvmt_test
    bytes = arduino.BytesAvailable;
    while bytes > 4
        [d,b] = fscanf(arduino,'%d'); % read x and y
        bytes = bytes-b;
        if length(d) == 2 && d(2)~= 0
            mvmt_test = false;
            break;            
        end
    end
    pause(0.1);
end
fprintf('movement detected.\n')

lastdata = tic;
if aiFlag
    start(data.card.ai);
    nsampled = 0;
    data.response.lickdata = [];
    arddata = [];
end
last_press = 0;
data.quitFlag = 0;
data.userFlag = 0;
%%% GP 141219
data.response.n_free =[];
data.response.n_left = [];
data.response.n_right = [];

k = 0;
while k < numTrials && ~data.quitFlag
    k = k+1;
    % reset reward
    % establish block timer
    if k == 1
        tstart = tic;
    end
    fprintf('%s ITI\n',datestr(toc(tstart)/86400,'MM:SS'))
    
    % reset vars
    currX = 0;          % current trackball position (actual)
    currY = 0;
    currT = 0;          % current trial time
    
    screenX = [];       % log of all screen positions
    ballX = [];         % log of all trackball positions
    ballY = [];         % log of all trackball positions
    samps = [];         % samples per loop
    timePC = [];        % log of all timestamps        
    licks = [];         % log all licks
    choice = 0;         % current trial choice
    x = startbias;      % current screen position
    
    % pick the stimulus
    centerColor = cell2mat(color(data.stims(k))); %Update stimulus rect color
    
    Screen('FillRect', window, grey)
    Screen('Flip', window);
    
    %     tic
    ttemp = tic;    
    bytes = arduino.BytesAvailable;
    while toc(ttemp) < delay
        trackball_keycheck(k);
        if bytes > 4
            [d,b] = fscanf(arduino,'%d'); % read x and y
            bytes = bytes-b;
            if length(d) == 2
                arddata(end+1,:) = d;                
                if abs(d(2)) > 1 && extenddelay
                    if toc(ttemp) > 0.1
                        fprintf('%s EXTEND DELAY...\n',datestr(toc(tstart)/86400,'MM:SS'))
                    end
                    ttemp = tic;
                end
            end 
        else
            bytes = arduino.BytesAvailable;
        end
    end
%     toc
%     data.stimDelay(k) = toc(trialDelayTimer); %Log the actual delay
%     pause(delay);
    
    dstCenterRect = CenterRectOnPointd(midRect, xCenter + startbias, yCenter);
%     Screen('DrawTextures', window, centerRectTex, [],...
%         dstCenterRect, [], [], [], centerColor);
    vbl = Screen('Flip', window);
    
%     Screen('DrawText',homescreen,sprintf('%s TRIAL %d',datestr(toc(tstart)/86400,'MM:SS'),k))
%     Screen('Flip',homescreen)
    stimDelayTimer = tic;
    
    
    left = [round(mean(data.response.n_left==1)*100),round(mean(data.response.n_left==2)*100), round(mean(data.response.n_left==5)*100), length(data.response.n_left)]; 
    right = [round(mean(data.response.n_right==2)*100),round(mean(data.response.n_right==1)*100), round(mean(data.response.n_right==5)*100), length(data.response.n_right)]; 
    free = [round(mean(data.response.n_free==4)*100), round(mean(data.response.n_free==3)*100), round(mean(data.response.n_free==5)*100), length(data.response.n_free)];

    str = '';
    str = [str, sprintf('LEFT%%  %3d%%/%3d%%/%3d%% of %3d\n',left)];
    str = [str, sprintf('RIGHT%% %3d%%/%3d%%/%3d%% of %3d\n',right)];
    str = [str, sprintf('FREE%%  %3d%%/%3d%%/%3d%% of %3d\n',free)];
%     str = [str, sprintf('LAST LICK: -%s\n\n',datestr((loop.prev_flip_time-max(data.response.licks))/86400,'MM:SS'))];
    fprintf('%s',str);
    
%     WaitSecs(delay);

%     psychsr_sound(2); % indicate trial start
    fprintf('\n\n%s TRIAL %d START\n',datestr(toc(tstart)/86400,'MM:SS'),k)    
    
    % keeps a running account of trial times to help synch with physiology data
    trialStart(k) = toc(tstart);
    
    bytes = arduino.BytesAvailable;
    while bytes > 4
        trackball_keycheck(k);        
        [d,b] = fscanf(arduino,'%d');
        bytes = bytes-b;
        if length(d) == 2
            arddata(end+1,:) = d;
        end
    end
    
%% track ball movements
    while choice == 0
        
        if currT == 0
            currT = tic;
            samples_start = size(arddata,1);
        end
        
        % Get the current position of the trackball, log movement, and
        % create time stamp
        n = 0;
        bytes = arduino.BytesAvailable;
        while bytes > 4
            [d,b] = fscanf(arduino,'%d'); % read x and y
            bytes = bytes-b;
            if length(d) == 2
                arddata(end+1,:) = d; n = n+1;
                lastdata = tic;
            end
        end
%         fprintf('%d\n',n)
        if n > 0
            d_all = arddata(end-n+1:end,2);
            d_all(d_all<0) = d_all(d_all<0)*lr_ratio;
            
            d = sum(d_all,1); % integrate                       
            if n > 2
%                 fprintf('DELAY %d points\n',n)
            end
            if d ~= 0
%                 fprintf('move\n')
            end
        else
%             continue;      
            d_all = 0;
            d = 0;
%             lasttime = toc(lastdata);
%             if lasttime > 0.1
%                 fprintf('%1.2f\n',lasttime)
%             end
        end
        
        
        if (easymove == 1 || easymove == 3) && data.stims(k) == 1
            d2 = sum(d_all(d_all>0)) + data.easygain*sum(d_all(d_all<0));
            x = -d2*gain+x;
        elseif (easymove == 2 || easymove == 3) && data.stims(k) == 2
            d2 = sum(d_all(d_all<0)) + data.easygain*sum(d_all(d_all>0));
            x = -d2*gain+x;
        else            
            x = -d*gain+x;
        end
        currX = -d + currX;
%         currY = d(1) + currY;
        ballX(end+1) = currX;
        ballY(end+1) = currY;
        samps(end+1) = n;
        % Create a running timestamp for incoming data
        timePC(end+1) = toc(currT);
        
        % Set left and right boundaries so that the middle stimulus
        % can't be moved beyond them
        if abs(x) < xCenter - xSidePos(1)%(xCenter-400)
            x = x;
        elseif abs(x) > (xCenter-xSidePos(1)) && x<0
            x = -1*(xCenter-xSidePos(1));
        elseif abs(x) >(xCenter-xSidePos(1)) && x>0
            x = (xCenter-xSidePos(1));
        end                
        screenX(end+1) = x;
        
        %% check for key press
        trackball_keycheck(k);
        
%% Define choice threshold and save data when threshold is met.
        %In this example, green should be right and red should be left
        if data.stims(k) == 3
            dstCenterRect = CenterRectOnPointd(midRect*oval_factor, xCenter+x, yCenter);
        elseif data.stims(k) == 2
            dstCenterRect = CenterRectOnPointd(midRect, xCenter+x, yCenter);            
        end
        if choice==0           
                
            % Draw side targets before center cursor
            switch data.stims(k)
                case 3
                    Screen('FrameOval',window,black,ovalLeft,12);
                    Screen('FrameOval',window,black,ovalRight,12);
                    Screen('FillOval',window,black,dstCenterRect);
                case 2
%                     Screen('FrameOval',window,black,ovalRight,12);
%                     Screen('FillOval',window,black,dstCenterRect);
                    Screen('FrameRect',window,black,dstSideRects(:,2),12);
                    Screen('FillRect',window,black,dstCenterRect);
                case 1
%                     Screen('FrameOval',window,black,ovalLeft,12);
%                     Screen('FillOval',window,black,dstCenterRect);
                    diamondcenter = diamond+repmat([xCenter+x 0],4,1);
                    Screen('FramePoly',window,black,diamondleft,12);                    
                    Screen('FillPoly',window,black,diamondcenter);
            end
        end
        
        dx = diff(screenX);
        if abs(x) >= decisionPos && data.stims(k) < 3
            choice = (x>=decisionPos)+1;
            if choice == 2
                fprintf('%s RIGHT - %1.2fs\n',datestr(toc(tstart)/86400,'MM:SS'),timePC(end))
            else
                fprintf('%s LEFT - %1.2fs\n',datestr(toc(tstart)/86400,'MM:SS'),timePC(end))
            end
            if data.stims(k) == 2
                data.response.n_right(end+1) = choice;
            else
                data.response.n_left(end+1) = choice;
            end
            x = 0;
%                 
%         if data.stims(k) == 2 && (x >= decisionPos ...  %color 2 is green, 1 is red
%                 )%|| (easymove == 2 && sum(dx(dx>0)) >= decisionPos/targetdistance*data.easydist))
%             choice = 2; % 2 means correct rightward choice
%             x = 0;
%             fprintf('%s RIGHT - %1.2fs\n',datestr(toc(tstart)/86400,'MM:SS'),timePC(end))
%             data.response.n_right(end+1) = choice;
%         elseif data.stims(k) == 1 && (x <= -1*decisionPos ...
%                 )%|| (easymove == 1 && sum(dx(dx<0)) <= -decisionPos/targetdistance*data.easydist))
%             choice = 1; %1 means correct leftward choice
%             x = 0;
%             fprintf('%s LEFT - %1.2fs\n',datestr(toc(tstart)/86400,'MM:SS'),timePC(end))
%             data.response.n_left(end+1) = choice;
        elseif abs(x) >= decisionPos && data.stims(k) == 3
            if x>= decisionPos                
                choice = 3; %3 means a free choice was made to the right
            elseif x <= -1*decisionPos
                choice = 4; %4 means a free choice was made to the left
            end
            data.response.n_free(end+1) = choice;
            x = 0;
            fprintf('%s FREE - %1.2fs\n',datestr(toc(tstart)/86400,'MM:SS'),timePC(end))
        elseif choice==0 && toc(currT) >= responseTime
            choice = 5; %5 -- a (correct) choice was not made within alloted time
            trialEndTime(k) = toc(tstart);
            fprintf('%s TIMEOUT - %1.2fs\n',datestr(toc(tstart)/86400,'MM:SS'),timePC(end))        
            switch data.stims(k)
                case 1
                    data.response.n_left(end+1) = choice;
                case 2
                    data.response.n_right(end+1) = choice;
                otherwise
                    data.response.n_free(end+1) = choice;
            end
        end
        
%         if easymove > 0 && choice == easymove% "teleport" cursor for easymove
%             Screen('FillRect', window, grey);
%             if easymove == 2
%                 dstCenterRect = CenterRectOnPointd(midRect, xCenter+decisionPos, yCenter);    
%                 Screen('FrameRect',window,black,dstSideRects(:,2),12);
%                 Screen('FillRect',window,black,dstCenterRect);
%             else
%                 diamondcenter = diamond+repmat([xCenter-decisionPos 0],4,1);
%                 Screen('FramePoly',window,black,diamondleft,12);
%                 Screen('FillPoly',window,black,diamondcenter);
%             end
%         end
        
        newvbl = Screen('Flip', window, vbl + (wait_frames-0.5)*flip_int);
%         if newvbl-vbl>1.5*wait_frames*flip_int
%             fprintf('MISSED FLIP')
%             fprintf(' %02.1f ms',(newvbl-vbl)*1000)
%             fprintf('\n');            
%             
%         end
        vbl = newvbl;
        
            
%         Screen('Flip', window);
        
        
    end
    
    samples_stop = size(arddata,1);
    %% reward or punish        
    if choice == data.stims(k) 
        psychsr_sound(6);
        fprintf('%s REWARD\n',datestr(toc(tstart)/86400,'MM:SS'))
        if rewardFlag
            outdata = data.card.dio.UserData;
            outdata.dt(1) = data.response.reward_time;
            outdata.tstart(1) = NaN;
            data.card.dio.UserData = outdata;
        end
    elseif choice < 5
        psychsr_sound(3);        
    else % timeout        
        psychsr_sound(1);
    end;
    for i = 1:10
        pause(0.1) % pause allows reward to be administered
        trackball_keycheck(k);
    end    
    Screen('FillRect', window, grey);
    Screen('Flip', window);    
    
    %% antibias
    data.choice(k) = choice;
    if k+1 < numTrials && data.stims(k) < 3 && rand <= antibias && data.userFlag ~= k+1
        if data.choice(end) == data.stims(k) ||  ... % if success on last trial
                (k>2 && mean(diff(data.stims(k-2:k)))==0 && min(data.choice(end-2:end))==5 )
            % or failed 3 times in a row
            nextstim = 3-data.stims(k); % switch side
        else % if failed on last trial
            nextstim = data.stims(k); % repeat side
        end
        data.stims(k+1) = nextstim;
        if nextstim == 1
            fprintf('ANTIBIAS: NEXT STIM LEFT\n')
        else
            fprintf('ANTIBIAS: NEXT STIM RIGHT\n')
        end
    end
    
    %% save post-trial ball movements
    ttemp = tic;
    bytes = arduino.BytesAvailable;
    while toc(ttemp) < rewardDelay-1+punishDelay*(choice~=data.stims(k))  
        trackball_keycheck(k);
        if bytes > 4
            [d,b] = fscanf(arduino,'%d'); % read x and y
            bytes = bytes-b;
            if length(d) == 2
                arddata(end+1,:) = d;                
            end
        else
            bytes = arduino.BytesAvailable;
        end
    end
        
    %% record licks
    if aiFlag
        if data.card.ai.SamplesAcquired > nsampled
            newdata = peekdata(data.card.ai,data.card.ai.SamplesAcquired-nsampled);
            n = size(newdata,1);
            
            testdata = newdata; % testdata is newdata plus previous data point
            if ~isempty(data.response.lickdata)
                testdata = [data.response.lickdata(end,:);testdata]; 
            end
            
            abovetrs = testdata(end-rewardDelay*ai_fs:end) > 1;
            crosstrs = find([0;abovetrs(2:end)-abovetrs(1:end-1)] > 0);
            
            licks(end+1) = length(crosstrs);
            
            fprintf('%s LICKED %d TIMES\n',datestr(toc(tstart)/86400,'MM:SS'),licks(end))     
            
            % store data
            nsampled = nsampled + n;
            data.response.lickdata = [data.response.lickdata; newdata];
            
        end
    end

    data.screenX{k} = screenX;
    data.ballX{k} = ballX;
%     data.ballY{k} = ballY;
    data.samps{k} = samps;
    data.timePC{k} = timePC;
    data.samples_start{k} = samples_start; 
    data.samples_stop{k} = samples_stop; 
    data.samples_reward{k} = size(arddata,1); 
    data.licksamples{k} = size(data.response.lickdata,1);
end
data.params.targetdistance = targetdistance;
data.params.gain = gain;
data.params.lr_ratio = lr_ratio;
data.params.extenddelay = extenddelay;
data.params.responseTime = responseTime;
data.params.easymove = easymove;
% data.params.easydist = data.easydist;
data.params.easygain = data.easygain;

disp(num2str(toc(fxClock)));
ShowCursor;

%% Clear the screen

psychsr_sound(3);
sca;
close all;
disp('closing serial port...')
fclose(arduino);
delete(arduino);
clear arduino;
disp('closed')

putvalue(data.card.dio,0);
stop(data.card.dio)
delete(data.card.dio);
data.card = rmfield(data.card,'dio');

jheapcl

%%% get lick data and clear DAQ - GP 141219
if aiFlag
    stop(data.card.ai);
%     [lickraw,time,abstime] = getdata(data.card.ai);
    delete(data.card.ai);
    data.card = rmfield(data.card,'ai');
end
disp('done.')
%%% GP 141219

%% save data

%% conversion
time = arddata(:,1);
neg = find(diff(time)<-1000,1);
while ~isempty(neg)    
    time(neg+1:end,1) = time(neg+1:end,1) + 2^16;
    neg = find(diff(time)<-1000,1);
end 
time = time/1000;
x = arddata(:,2) ;%.* mousesign(:,5);
% y = arddata(:,3) ;%.* mousesign(:,6);

data.response.time = time;
data.response.dx = x;
% data.response.dy = y;
data = rmfield(data,'quitFlag');
data = rmfield(data,'userFlag');

left = [round(mean(data.response.n_left==1)*100),round(mean(data.response.n_left==2)*100), round(mean(data.response.n_left==5)*100), length(data.response.n_left)];
right = [round(mean(data.response.n_right==2)*100),round(mean(data.response.n_right==1)*100), round(mean(data.response.n_right==5)*100), length(data.response.n_right)];
free = [round(mean(data.response.n_free==4)*100), round(mean(data.response.n_free==3)*100), round(mean(data.response.n_free==5)*100), length(data.response.n_free)];
str = '';
str = [str, sprintf('\nMouse %d\n',mouse)];
str = [str, sprintf('LEFT%%  %3d%%/%3d%%/%3d%% of %3d\n',left)];
str = [str, sprintf('RIGHT%% %3d%%/%3d%%/%3d%% of %3d\n',right)];
str = [str, sprintf('FREE%%  %3d%%/%3d%%/%3d%% of %3d\n',free)];
fprintf('%s',str);

date = clock;
folder = sprintf('../behaviorData/trackball/mouse %04d',mouse);
if ~isdir(folder); mkdir(folder); end
uisave('data',sprintf('%s/%4d%02d%02d_trackball_%04d',folder,date(1),date(2),date(3),mouse));