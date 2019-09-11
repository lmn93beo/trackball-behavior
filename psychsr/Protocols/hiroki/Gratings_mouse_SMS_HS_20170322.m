 function Gratings_mouse_SMS_HS_20170322(type)
% Modified from Grating_mouse_HS_20170321.m
% Showing Static-Moving-Static stimuli.
% Deleted commented lines.

% *** 09/19/2016 HS *** ***************************************************
% Grating parameters.
Nrepeats = 10;
Nori = 8; % 45 degree apart
Params.contrast        = 1;

% % DURATION
Params.Pre_Blank   = 0;
Params.Post_Blank  = 0;
Params.Pre_Static  = 3;
Params.durGratings = 6;
Params.Post_Static = 3;

% normal grating
Params.cyclespersecond = 2; % temporal frequency
% spatialFrequency_cpd = 4; % cycles per degree
spatialFrequency_cpd = 0.07; % cycles per degree

% % flashing
% Params.cyclespersecond = 5; % temporal frequency
% spatialFrequency_cpd = 0.0001;%4; % cycles per degree

% % SCREEN
% screen_distance_cm = 10;
screen_distance_cm = 7.5;
screen_width_cm = 15.4;
screen_width_pixels = 1024;
pixels_per_degree = psychsr_calibrate_screen_HS(screen_width_cm, screen_distance_cm, screen_width_pixels);

sf_cyclesperpixel = spatialFrequency_cpd / pixels_per_degree; % spatial frequency in cycles per pixel

% cyclesperpixel

% *** 09/19/2016 HS *** ***************************************************
%% Preamble................................................................
% identify the computer, if lab computer, initialize the DAQ..............
name = getenv('computername');

global data
fullscr = 1;
if strcmp(name,'ACHR2')
    mypath='C:\Users\Hiroki\Dropbox (MIT)\MouseAttention\Matlab\psychsr\Protocols\RG_2p4Scripts';
else
    mypath='C:\Dropbox\MouseAttention\Matlab\psychsr\Protocols\RG_2p4Scripts';
end
cd (mypath)
imageFlag = 0;

if strcmp(name,'RAINBOW') == 1
    %     global data
    rfmap_define_monitor();
    rfmap_define_io_cards();
    rfmap_config_trigger_port();    rfmap_share_parameters();
    labComp = 1;
elseif strcmp(name, 'VISSTIM-2P4') == 1
    % %         global data
    %         data.response.mode = 0;
    %         data.card.trigger_mode = 'out';
    %         psychsr_card_setup;
    %
    card.trigger_mode = 'out';
    card.id = 'Dev1';
    card.name = 'nidaq';
    if strcmp(card.trigger_mode, 'out')
        if ~isfield(card,'dio')
            card.dio = digitalio(card.name, card.id);
        end
        card.trigger_port = 2;
        card.trigger_line = 5;
        
        addline(card.dio, card.trigger_line, card.trigger_port, 'out');
        card.trigger = card.dio.Line(end);
        
        putvalue(card.trigger,0);
        start(card.dio);
    end
    labComp = 2;
% *** 05/04/2016 HS *** ***************************************************
elseif strcmp(name, '2P2_BEHAVIOR-PC') == 1
    card.trigger_mode = 'out';
    card.id = 'Dev1';
    card.name = 'nidaq';
    if strcmp(card.trigger_mode, 'out')
        if ~isfield(card,'dio')
            card.dio = digitalio(card.name, card.id);
        end
        card.trigger_port = 0;
        card.trigger_line = 0;
        
        addline(card.dio, card.trigger_line, card.trigger_port, 'out');
        card.trigger = card.dio.Line(end);
        
        putvalue(card.trigger,0);
        start(card.dio);
    end
    labComp = 3;
% *** 05/04/2016 HS *** ***************************************************
else
    labComp = 0;
end;

%% Set all the timing parameters, i.e duration of stim and blank; contrast........

if nargin<1; type = 'Soma'; end;

% *** 09/19/2016 HS *** ***************************************************
% Params.contrast        = 1;
% Params.cyclespersecond = 2;
% *** 09/19/2016 HS *** ***************************************************

switch type
    case 'Astro'
        Params.durBlank        = 4;
        Params.durBlank_Grats  = 6;
        Params.durStim         = 13;
        Params.durGratings     = 2;
        fprintf('Case = Astro\t\tTotal Time(s) = %d\n', 6.*((4*17)+(8*12)) );
        Params
    case 'Soma'  
%         Params.durBlank        = 2;
        Params.durBlank_Grats  = 4;
%         Params.durStim         = 13;
% %         Params.durGratings     = 2;
%         Params.durGratings     = 2;
%         fprintf('Case = Soma\t\tTotal Time(s) = %d\n', 6.*((4*15)+(6*12)) );
%         Params
    case 'Dendrites'
        Params.durBlank        = 2;
        Params.durBlank_Grats  = 2;
        Params.durStim         = 13;
        Params.durGratings     = 2;
        Params
        fprintf('Case = Dendrites\t\tTotal Time(s) = %d\n', 6.*((4*15)+(4*12)) );
end;

%% Generate Grating Sequence...............................................
N  = GenerateCombinations_for_dendImaging_HS(Nori, sf_cyclesperpixel);
NN = reshape(N,Nori,5,2);
% *** 09/19/2016 HS *** ***************************************************
NN = repmat( NN, 1, 2);
V = {'G'};
DisplaySequence = repmat(V,1,Nrepeats);
% *** 09/19/2016 HS *** ***************************************************

%% define the screen .......................................................
AssertOpenGL;

rotateMode = kPsychUseTextureMatrixForRotation;

KbName('UnifyKeyNames');
esc   = KbName('ESCAPE');

screenid = max(Screen('Screens'));
% screenid = 2; % GP test code
res      = Screen(screenid, 'Resolution');
Params.width    = res.width;
Params.height   = res.height;
ep = 450;

if fullscr == 0
    Params.Dims = [ep, -300, Params.width, Params.width-ep];
elseif fullscr == 1
    Params.Dims = [0, 0, Params.width, Params.height];
end;

% define black, white and gray values
white = WhiteIndex(screenid);
black = BlackIndex(screenid);
gray  = round((white+black)/2);

if gray == white
    gray = white / 2;
end;
inc = white-gray;

win = Screen('OpenWindow', screenid, 128);
AssertGLSL;
ifi = Screen('GetFlipInterval', win);

%% Bulid Gray textures ....................................................
% for i = 1 : fix(Params.durBlank_Grats*FrameRate)+ 20
for i = 1 : fix(Params.durBlank_Grats*FrameRate(screenid))+ 20
    texgray(i) = Screen('MakeTexture', win, gray);
end;

%% Build Movie textures....................................................
% display text telling the user that the textures are loading..............
Screen('TextFont',win, 'Courier New');
Screen('TextSize',win, 50);
Screen('TextStyle', win, 1+2);
tstring = ['Loading Frames, Please Wait'];
DrawFormattedText(win, tstring, 100, 100, [255, 255, 255, 255]);
Screen('Flip',win);

waitframes = 1.0007;

%% Start ..................................................................
% display text telling the user to press the trigger...................
Screen('TextFont',win, 'Courier New');
Screen('TextSize',win, 50);
Screen('TextStyle', win, 1+2);
tstring = ['Waiting for trigger!'];
DrawFormattedText(win, tstring, 100, 100, [255, 255, 255, 255]);
Screen('Flip',win);

fprintf('Note: 20 reps of NI, 6 reps of Gratings, Total Dur = 648s\n');
fprintf('Waiting for trigger....\n')
KbWait;

% flush the keyboard buffer ..........................................
keyIsDown = 0;
keyCode   = zeros(1,256);

tic;
vbl = Screen('Flip',win); % starting time point. All time points refer back to this.
vbl0 = vbl;
ctg = 0; cti = 0;

[keyIsDown, secs, keyCode] = KbCheck;

if keyIsDown == 1 && keyCode(esc) == 1
    % skip to last when Esc is pressed.............................
    i = 81; Trial = 7;
else
    
    % continue as per normal.......................................
    if labComp == 1
        putvalue(data.card.trigger_line, 0);
        rfmap_put_trigger_pulse()
    end;
    
    if labComp == 2
        putvalue(card.trigger,0);
        pause(0.05);
        putvalue(card.trigger,1);
    end;
    
    if labComp == 3
        putvalue(card.trigger,0);
        pause(0.05);
        putvalue(card.trigger,1);
    end;

    % Wait for release of all keys on keyboard, then sync us to retrace:
    KbReleaseWait;
    tic
    for v = 1:length(DisplaySequence)
        currentPosition =  DisplaySequence{v};
        if strcmpi( currentPosition, 'I') == 1
            
        elseif strcmpi( currentPosition, 'G') == 1
            ctg = ctg+1;
            fprintf('Displaying Grating seqeuence %d of %d\n', ctg, length(DisplaySequence)./5);
            vbl = Screen('Flip',win); % starting time point. All time points refer back to this.
            vbl0 = vbl;
            Nnew = squeeze( NN(:,ctg,:) );
            displayGratingSequence_HS(rotateMode,Nnew,texgray, Params, waitframes, ifi, vbl,vbl0, win, Nori)
            if imageFlag
                tempArray = Screen('GetImage',win);
                imageArray = tempArray(:,:,1);
                imwrite(imageArray,'screenOutput.tif','WriteMode','append')
            end
        end;
    end; % end for
    toc
end; % end if
% We're done. Close the window. This will also release all other resources:
Screen('CloseAll');
if exist('card', 'var')
    putvalue(card.trigger,0);
    stop(card.dio);
end

return;
end


function N = GenerateCombinations_for_dendImaging_HS(NumOrient, sf_cyclesperpixel)

NumSpatFreq = 1;
Angles  = linspace(0, 360-360/NumOrient, NumOrient);
SpatInc  = sf_cyclesperpixel.*ones(1,1);

B       = repmat(SpatInc, 1, NumOrient )';
A       = repmat(Angles,NumSpatFreq,1);

Combs = zeros(NumSpatFreq*NumOrient,2);
Combs(:,2) = B;

for i = 1:1:NumOrient
    foo = A(:,i);
    Combs( 1 + NumSpatFreq*(i-1) : i*NumSpatFreq) = foo;
end;

N = [];
for i = 1:5
    N = [N; Combs ];
end;

end


function displayGratingSequence_HS(rotateMode, Nnew, texgray, Params, waitframes, ifi, vbl,vbl0, win, Nori)

for m =  1:Nori
    amplitude = Params.contrast; % contrast value.
    angle     = Nnew(m,1);
    freq      = Nnew(m,2);
    % phase increment..................................................
    phase = 90;
    phaseincrement = (Params.cyclespersecond * 360) * ifi;
    
    % Build grating texture....................................................
    gratingtex = CreateProceduralSineGrating(win, 256, 256, [0.5 0.5 0.5 0.0], inf, Params.contrast);
    % then a movie................................................
    nFrames = 1;
    
    grayFrames = 1;

%     % Gray
%     while vbl-vbl0 < m*Params.durBlank_Grats + (m-1)*Params.durGratings - 1.5*waitframes*ifi
%         Screen('DrawTexture', win, texgray(grayFrames), [0, 0, Params.width, Params.height]);
%         vbl = Screen('Flip', win, vbl + (waitframes-0.5)* ifi);
%         if grayFrames == 1
%             fprintf('Gray #%d START: %3.3f\n',i,vbl-vbl0)
%         end
%         grayFrames = grayFrames +1;
%     end
%     fprintf('Gray #%d STOP:  %3.3f -- %d frames\n',i,vbl-vbl0,grayFrames)
    
    % Pre_Static
    while vbl-vbl0 < m*Params.Pre_Static + (m-1)*Params.durGratings + (m-1)*Params.Post_Static - 1.5*waitframes*ifi
        % Draw the grating,
        Screen('DrawTexture', win, gratingtex, [], Params.Dims, angle, [], [], [], [], rotateMode, [phase, freq, amplitude, 0]);
        vbl = Screen('Flip', win, vbl + (waitframes-0.5)*ifi);
        if nFrames == 1
            fprintf('Mov  #%d START: %3.3f\n',m,vbl-vbl0)
        end;
        nFrames = nFrames + 1;
%         phase   = phase + phaseincrement;
    end;

    % Moving grating
    while vbl-vbl0 < m*Params.Pre_Static + m*Params.durGratings + (m-1)*Params.Post_Static - 1.5*waitframes*ifi
        % Draw the grating,
        Screen('DrawTexture', win, gratingtex, [], Params.Dims, angle, [], [], [], [], rotateMode, [phase, freq, amplitude, 0]);
        vbl = Screen('Flip', win, vbl + (waitframes-0.5)*ifi);
        if nFrames == 1
            fprintf('Mov  #%d START: %3.3f\n',m,vbl-vbl0)
        end;
        nFrames = nFrames + 1;
        phase   = phase + phaseincrement;
    end;

    % Post_Static
    while vbl-vbl0 < m*Params.Pre_Static + m*Params.durGratings + m*Params.Post_Static - 1.5*waitframes*ifi
        % Draw the grating,
        Screen('DrawTexture', win, gratingtex, [], Params.Dims, angle, [], [], [], [], rotateMode, [phase, freq, amplitude, 0]);
        vbl = Screen('Flip', win, vbl + (waitframes-0.5)*ifi);
        if nFrames == 1
            fprintf('Mov  #%d START: %3.3f\n',m,vbl-vbl0)
        end;
        nFrames = nFrames + 1;
%         phase   = phase + phaseincrement;
    end;

end;

end


function pixels_per_degree = psychsr_calibrate_screen_HS(screen_width_cm, screen_distance_cm, screen_width_pixels)
% PURPOSE:
%	use the screen size and position to determine the stimulus parameters from the point of view of the animal

	% a triangle is formed between the mouse, the screen middle, and the screen left
	
	% first, get the "opposite" side of the triangle, which is half the screen
	opposite_side_length = screen_width_cm / 2;
	
	% second, get the "adjacent" side of the triangle, the distance from screen to animal
	adjacent_side_length = screen_distance_cm;

	% get the visual angle from screen side to center: take the inverse tangent (in degrees) of opposite over adjacent 
	visual_degrees_of_half_screen = atand(opposite_side_length / adjacent_side_length);
	
	% calculate how many pixels are in each degree
	visual_degrees_of_screen = visual_degrees_of_half_screen * 2;
	pixels_per_degree = screen_width_pixels / visual_degrees_of_screen;

end