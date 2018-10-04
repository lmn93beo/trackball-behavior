% Clear the workspace
close all;
clear all;
global data

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

%% Setup reward
% reward = 10;
% 
% load psychsr_reward_params
% [amt time b] = psychsr_set_reward(reward);
% 
% data.response.reward_time = time;
% data.response.reward_amt = amt;
% data.response.reward_cal = b;
% 
% if ~isnan(amt)
%     data.response.reward_time = (data.response.reward_cal(1)*amt+data.response.reward_cal(2))/1000;
% end
%% Open communications with the Arduino
a = serial('COM4');
fopen(a);
WaitSecs(0.01);
%params
freeChoice = input('Free choice on (1), or off (0): ');
gain = 5;
rewardDelay = 2.5;
trialLength = 5;
delay = 1.5;
x = 0;
numTrials = 30;
responseTime = 5;
fxClock = tic;
trialEndTime = [];



%% Setup Screen 

AssertOpenGL;

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white/2;

% Open an on screen window
[window, windowRect] = Screen('OpenWindow', screenNumber, white);
HideCursor;
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

%% Trial params
if freeChoice == 0
    data.stims = double(randi([1 2], 1,numTrials));
elseif freeChoice == 1
    data.stims = double(randi([1 3], 1, numTrials));
end
    

% Change color
color{1} = [0 0 0]; %[255 0 0];
color{2} = [0 0 0]; %[0 255 0];
color{3} = [0 0 0]; %[0 0 255];
   
%% Rectangle parameters

% Text output of mouse position draw in the centre of the screen
% DrawFormattedText(window, textString, 'center', 'center', white);

[xSideRect, ySideRect] = meshgrid(-150:1:150, -150:1:150);
[xCenterRect, yCenterRect] = meshgrid(-100:1:100, -100:1:100);
[xBlankRect, yBlankRect] = meshgrid(-screenXpixels:1:screenXpixels, -screenYpixels:1:screenYpixels);

xSideRect(:,:) = grey;
xCenterRect(:,:) = grey;
xBlankRect(:,:) = white;

% midRect = [0 0 200 200];
sideRectTex = Screen('MakeTexture', window, xSideRect);
blankTex = Screen('MakeTexture', window, xBlankRect);
centerRectTex = Screen('MakeTexture', window, xCenterRect);

% blankRect = [0 0 res.width res.height];

%Set rectangle positions (in pixels)  

yPos = yCenter;
xSidePos = linspace(screenXpixels * 0.2, screenXpixels * 0.8, 2);
[s1, s2] = size(xSideRect);
[m1, m2] = size(xCenterRect);
sideRect = [0 0 s1 s2];
midRect = [0 0 m1 m2];
blankRect = [0 0 res.width res.height];
dstSideRects = [];

decisionPos = xCenter - xSidePos(1);

for i=1:length(xSidePos)
    dstSideRects(:, i) = CenterRectOnPointd(sideRect, xSidePos(i), yPos);
end

% rightPos = CenterRectOnPointd(sideRect, xCenter+400, yCenter);
% leftPos = CenterRectOnPointd(sideRect, xCenter-400, yCenter);

dstBlankRect = CenterRectOnPointd(blankRect, xCenter, yCenter);
% blankPos = CenterRectOnPointd(blankRect, xCenter, yCenter);

%Set outer rectangle colors
grey = round(grey);
sideColor = [grey grey grey; grey grey grey]';



%% Loop through all the trials

%%% start analog input - GP 141219
start(data.card.ai);
%%% GP 141219
for k = 1:numTrials
 
   
    % reset reward    
    % establish block timer
    if k == 1 
        tstart = tic;
    end
    %reset vars
    unboundX = 0;
    currStart = 0;
    cumMove = [];
    unboundMove = [];
    timeStamp = [];
    choice = 0;   
    x = 0;
    % pick the stimulus
    centerColor = cell2mat(color(data.stims(k))); %Update stimulus rect color

    Screen('DrawTexture', window, blankTex, [], ...
    [], [], [], [], white);
    Screen('Flip', window);
    
tic
    WaitSecs(delay);
  toc  
%     data.stimDelay(k) = toc(trialDelayTimer); %Log the actual delay
    %pause(delay);
    
     dstCenterRect = CenterRectOnPointd(midRect, xCenter, yCenter);
     Screen('DrawTextures', window, centerRectTex, [],...
     dstCenterRect, [], [], [], centerColor);
     Screen('Flip', window); 
     stimDelayTimer = tic;   
     
     WaitSecs(delay);
 
     %keeps a running account of trial times to help synch with physiology data    
     trialStart(k) = toc(tstart);
     
     %Clear buffer and reset trackball position
     flushinput(a);
     x = 0;
        
    while choice == 0 
        
        if currStart == 0
            currStart = tic;
        end
        
        % Get the current position of the trackball, log movement, and
        % create time stamp
        x = str2double(fscanf(a))*gain+x;
        if isnan(x)
            x = 0;
        end
        unboundX = str2double(fscanf(a)) + unboundX;
        cumMove(end+1) = x;
        unboundMove(end+1) = unboundX;
        % Create a running timestamp for incoming data
        timeStamp(end+1) = toc(currStart);

        % Set left and right boundaries so that the middle stimulus
        % can't be moved beyond them
        if abs(x) < xCenter - xSidePos(1)%(xCenter-400)
            x = x;
        elseif abs(x) > (xCenter-xSidePos(1)) && x<0 
            x = -1*(xCenter-xSidePos(1));
        elseif abs(x) >(xCenter-xSidePos(1)) && x>0
            x = (xCenter-xSidePos(1));
        end

        %Define choice threshold and save data when threshold is met.
        %In this example, green should be right and red should be left

        if choice==0
            % Draw side rectangles
            Screen('DrawTextures', window, sideRectTex , [],...
            dstSideRects, [], [], [], sideColor); %Draw response rects

            % Draw center rectangle
            Screen('DrawTextures', window, centerRectTex, [],...
            dstCenterRect, [], [], [], centerColor);
        end
        
        if x >= decisionPos && data.stims(k) == 2 %color 2 is green, 1 is red
            choice = 2; % 2 means correct rightward choice
             x = 0;
            Screen('DrawTexture', window, blankTex);                   
        elseif x <= -1*decisionPos && data.stims(k) == 1
            choice = 1; %1 means correct leftward choice
            x = 0;
            Screen('DrawTexture', window, blankTex);
        elseif abs(x) >= decisionPos && data.stims(k) == 3
            if x>= decisionPos
                choice = 3; %3 means a free choice was made to the right
            elseif x <= -1*decisionPos
                choice = 4; %4 means a free choice was made to the left
            end
            x = 0;
            Screen('DrawTexture', window, blankTex);
        elseif choice==0 && toc(currStart) >= responseTime
            choice = 5; %5 -- a (correct) choice was not made within alloted time
            trialEndTime(k) = toc(tstart);
        else
            x = x;
            dstCenterRect = CenterRectOnPointd(midRect, xCenter+x, yCenter);
        end
        Screen('Flip', window);


        % Draw the rectangles


        % save trial data
                           
    end     
         
           dump_dio_data{k} = data.card.dio.UserData;
           if choice == 1 || choice == 2 || choice == 3 || choice == 4     
                disp('reward')
                outdata = data.card.dio.UserData;
                outdata.dt(1) = .1;%data.response.reward_time;
                outdata.tstart(1) = NaN;
                data.card.dio.UserData = outdata;
           end;
          
           WaitSecs(rewardDelay);
                
%                disp('next trial')
%            if ~choice == 0
%                Screen('TextFont',window, 'Courier New');
%                Screen('TextSize',window, 50);
%                Screen('TextStyle', window, 1+2);
%                tstring = ['Reward'];
%                DrawFormattedText(window, tstring, 100, 100, [255, 255, 255, 255]);
%                Screen('Flip',window);
%                rewardTimer = tic;
%                while toc(rewardTimer) < rewardDelay
%                end
%            end
    
    data.cumMove{k} = cumMove;
    data.unboundMove{k} = unboundMove;
    data.timeStamp{k} = timeStamp;
    data.choice{k} = choice;
end
%% Save data
disp(num2str(toc(fxClock)));
ShowCursor;

%% Clear the screen
sca;
close all;
delete(a);
clear a;

%%% get lick data and clear DAQ - GP 141219
stop(data.card.ai);
[lickraw,time,abstime] = getdata(data.card.ai);
delete(data.card.ai);
clear data.card.ai;
%%% GP 141219