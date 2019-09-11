function trackball_screen_setup
global data

data.screen.X_cm = 15.2;
data.screen.Y_cm = 9.2;

KbName('UnifyKeyNames');
AssertOpenGL;
Screen('Preference','VisualDebugLevel',3);
Screen('Preference', 'SkipSyncTests', 1);

% Get the screen numbers
screens = Screen('Screens');

data.screen.pc = getenv('computername');

% Draw to the external screen if avaliable
if strcmpi(data.screen.pc,'behave-ball2') || strcmp(data.screen.pc,'BEHAVE-BALL1') %|| strcmpi(data.screen.pc,'behavior2') 
    data.screen.id = 1;
elseif strcmp(data.screen.pc,'behavior2') 
    data.screen.id = 2;
else
data.screen.id = max(screens);
end

% Define black and white
data.screen.white = WhiteIndex(data.screen.id);
data.screen.black = BlackIndex(data.screen.id);
data.screen.grey = round(data.screen.white/2);

% get currently open windows
win = Screen('Windows');
for i = 1:length(win) % close all offscreen windows
    if Screen(win(i),'IsOffScreen')
        Screen('Close',win(i));
        win(i) = 0;
    end
end
win(win==0) = [];
if ~isempty(win) && Screen('WindowScreenNumber', win(1))==data.screen.id
    data.screen.window = win(1);
else
    % Open an on screen window
    if ~isempty(win)
        Screen('CloseAll');
        win = [];
    end
    [data.screen.window, windowRect] = Screen('OpenWindow', data.screen.id, data.screen.grey);
end
window = data.screen.window;

AssertGLSL;

% Get the screen size
res = Screen(data.screen.id, 'Resolution');

% Get the size of the on screen window
[data.screen.X_pixels, data.screen.Y_pixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Setup the text type for the window
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 50);

% Get the centre coordinate of the window
data.screen.xCenter = data.screen.X_pixels/2;
data.screen.yCenter = data.screen.Y_pixels/2;

data.screen.wait_frames = 1;
data.screen.flip_int = 1/Screen('FrameRate', window);

% move cursor off screen
SetMouse(-700,0)

data.screen.ff = (data.screen.Y_cm/data.screen.X_cm)/(data.screen.Y_pixels/data.screen.X_pixels);

if data.params.itiBlack
    Screen('FillRect', window, data.screen.black)
else    
    Screen('FillRect', window, data.screen.grey)
end
Screen('Flip', window);