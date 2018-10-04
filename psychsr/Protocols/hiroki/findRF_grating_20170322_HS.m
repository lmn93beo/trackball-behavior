function [mX, mY] =findRF_grating_20170322_HS(angle,radius,tf,sf)

if nargin<1
   angle = 270;
end

if nargin<2
   radius = 250;
end

if nargin<3
   tf = 2; 
end

if nargin<4
   sf = 0.003; 
end


try

    % ------ Screen and Color Setup ------

    % monitor characteristics
    screens=Screen('Screens');
    screenNumber=max(screens);                    % Window used for stimulus
    frameRate=FrameRate(screenNumber);   %Screen('FrameRate',screenNumber);   % Framerate
    [x_pixel,y_pixel]= Screen('WindowSize',screenNumber); % Pixel resolution
% 
    % Find the color values which correspond to white, black, and gray
    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    gray=round((white+black)/2);
    inc=white-gray;
    	
    % Open a window and paint the background white
    waitframes=1;
    [window,screenRect] = Screen('OpenWindow', screenNumber, gray);

    % Use realtime priority for better timing precision:
    priorityLevel=MaxPriority(window,'WaitBlanking');
    Priority(priorityLevel);
    HideCursor;
    
    % ------ Bookkeeping Variables ------
    buttons = 0; % When the user clicks the mouse, 'buttons' becomes nonzero.
    mX = 0; % The x-coordinate of the mouse cursor
    mY = 0; % The y-coordinate of the mouse cursor               
    p=ceil(1/sf); % pixels/cycle, rounded up.
    fr=sf*2*pi;
    [x,y]=meshgrid(-x_pixel:x_pixel + p, 1);
    grating=gray + inc*cos(fr*x);
    grating(grating>gray)  = white;
    grating(grating<=gray) = black;
    gratingtex=Screen('MakeTexture', window, grating);   
    blanktex=Screen('MakeTexture', window, gray);
    
    % Create a single gaussian transparency mask and store it to a texture:    
    mask            = ones(y_pixel+1,x_pixel+1, 2) * gray;
    [x,y]           = meshgrid(-x_pixel/2:x_pixel/2,-y_pixel/2:y_pixel/2);        
    mask(:, :, 2)   = white * (1- (x./radius).^2 - (y./radius).^2 >= 0);
    masktex         = Screen('MakeTexture', window, mask);        
	dstRect=[0 0 x_pixel y_pixel];
    dstRect=CenterRect(dstRect, screenRect);       
	dstgrtRect=[0 0 2*x_pixel 2*y_pixel];
    dstgrtRect=CenterRect(dstgrtRect, screenRect);           
    ifi=Screen('GetFlipInterval', window);
    p=1/sf; % pixels/cycle
    
    tic
%     angle = 0;
    % Exit the demo as soon as the user presses a mouse button.
    while ~KbCheck%any(buttons)
        previousX = mX;
        previousY = mY;
        [mX, mY, buttons] = GetMouse;
        
        xoffset = mod(toc*tf*p,p);
        srcRect=[xoffset 0 xoffset + x_pixel*2 y_pixel*2];
        Screen('DrawTexture', window, blanktex, [0 0 x_pixel y_pixel], [0 0 2*x_pixel 2*y_pixel], 0);
        Screen('Blendfunction', window, GL_ONE, GL_ZERO, [0 0 0 1]);        
        Screen('FillRect', window, [0 0 0 0], dstRect);
        Screen('DrawTexture', window, masktex, [0 0 x_pixel y_pixel], [mX-x_pixel/2 mY-y_pixel/2 ,mX+x_pixel/2 mY+y_pixel/2],0);
        Screen('Blendfunction', window, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [1 1 1 1]);
        Screen('DrawTexture', window, gratingtex, srcRect, dstgrtRect, angle);        
        Screen('Blendfunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);        
        Screen('WaitBlanking',window,1);
        Screen('Flip', window);
        
        if buttons(1) ~= 0
            angle = angle + 45;
            pause(.1)
        end
    end
            
    % Revive the mouse cursor.
    ShowCursor; 
    
    % Close screen
    Screen('CloseAll');
    
catch
    
    % If there is an error in our try block, let's
    % return the user to the familiar MATLAB prompt.
    if ~exist('mX'); mY = x_pixel/2; end
    if ~exist('mY'); mX = y_pixel/2; end
 
    ShowCursor; 
    Screen('CloseAll');
    psychrethrow(psychlasterror);
    
end
