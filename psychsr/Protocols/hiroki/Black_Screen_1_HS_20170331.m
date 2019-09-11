function Black_Screen_1_HS_20170331

% *** 03/31/2017 HS ***
% Modified from Gratings_3_HS_20170329.m
% Just send black screen.
% *** 03/31/2017 HS ***


%% Start ..................................................................
AssertOpenGL;

screenid = max(Screen('Screens'));
HideCursor;
Screen('OpenWindow', screenid, 0); % Black screen

KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');
ESC       = 1; %% var for keyboard escape check
while ESC

    % Check for 's'top or 'c'ontinue Key
    [touch, secs, keyCode] = KbCheck;
    ESC=(1-keyCode(escapeKey));

end

% We're done. Close the window. This will also release all other resources:
Screen('CloseAll');
ShowCursor;

end
