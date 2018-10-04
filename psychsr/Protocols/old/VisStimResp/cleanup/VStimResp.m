% VStimResp = Visual Stimulation and Response
function data = VStimResp(stimresp, stimtype)
% function VStimResp(stimresp[, stimtype])
%
% Written by GP 1/26/11

clc; daqreset;
%% Parameters
if nargin < 1 || isempty(stimresp)
disp('Stimulus, Response, or Both?')
disp('1 - Stim only')
disp('2 - Response only')
disp('3 - Stim & Response')
stimresp = input('stimresp: ');
end

if (nargin < 2 || isempty(stimtype)) && stimresp ~= 2
disp('Choose stimulus type')
disp('1 - Checkerboard')
disp('2 - Gratings, random orientation')
stimtype = input('stimtype: ');
end

%% Monitor characteristics
if stimresp ~= 2
x_length = 37.6;     % Length(cm) of screen x-dimension [large screen]
y_length = 30.1;     % Length(cm) of screen y-dimension [large screen]
% x_length=15.496;     % Length(cm) of screen x-dimension [small screen]
% y_length=8.7165;     % Length(cm) of screen y-dimension [small screen]

screenid = max(Screen('Screens'));       % Window used for stimulus
refreshRate = Screen('FrameRate', screenid);  % Monitor refresh rate
fr_rate = 60;
waitframes = round(refreshRate/fr_rate);  % Set frame rate to 30Hz
monitorDistance = 57;                       % Distance between monitor and eye
[x_pixel, y_pixel] = Screen('WindowSize', screenid); % Pixel resolution

pixel_pitch=mean([x_length/x_pixel y_length/y_pixel]);   % in cm/pixel
degPerPixel=pixel_pitch*1/(tan(pi/180)*monitorDistance); % in deg/pixel
end

%% Display setup
if stimresp ~= 2
AssertOpenGL;

% Find the color values which correspond to white, black, and gray
wht=WhiteIndex(screenid);
blk=BlackIndex(screenid);
gry=round((wht+blk)/2);
inc=wht-gry;

% Open a double buffered fullscreen window (SLOW step -- 1 to 3 sec)
[win winRect] = Screen('OpenWindow', screenid, gry);   
[w, h] = RectSize(winRect);     % size of window in pixels

AssertGLSL; % Make sure the GLSL shading language is supported

% Get flip interval (SLOW step -- up to 20 seconds)
ifi = Screen('GetFlipInterval', win, 100, 0.0001, 20); % should be 8.3ms (120Hz)

% Use realtime priority for better timing precision:
Priority(MaxPriority(win));

dParams = struct('win',win,'w',w,'h',h,'ifi',ifi,'fr_rate',fr_rate,...
    'waitframes',waitframes,'degPerPixel',degPerPixel,'wht',wht,...
    'blk',blk,'gry',gry,'x_pixel',x_pixel,'y_pixel',y_pixel);

end

%% NIDAQ setup
if stimresp > 1
% analog input    
fs = 60;
ai = analoginput('nidaq','Dev1');
ichan = addchannel(ai,2);
fs = 5000; ai = analoginput('winsound'); ichan = addchannel(ai,1);
set(ai, 'SampleRate', fs)
set(ai, 'SamplesPerTrigger', inf)

% digital or analog output
ao=analogoutput('nidaq','Dev1');
ochan=addchannel(ao,1);
putsample(ao,0);
% dio = digitalio('nidaq','Dev1');
% addline(dio,0,1,'out');
% putvalue(dio.Line(1),0)

rParams = struct('ai',ai,'ichan',ichan,'fs',fs,'ao',ao,'ochan',ochan);

end

rParams = struct([]);
%% Call stimulus function 
if stimresp ~= 2
switch stimtype
    case 1
        data = checkerboard(dParams);
    case 2
        data = gratings(dParams,rParams);
end
else
    data = response(rParams);
    start(ai);
    Beeper(440);
    for i = 1:fs*60
        data = response(rParams);
    end
end

%% Cleanup
Screen('CloseAll');
Priority(0)

return