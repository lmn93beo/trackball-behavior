 function Gratings_mouse_HS_20161213(type)
% function NatScenes_Gratings(type)


NTrialRepeats = 2; % number of trials to repeat
% *** 09/19/2016 HS *** ***************************************************
% Grating parameters.
Nrepeats = 1;
Nori = 8; % 45 degree apart
Params.contrast        = 1;

% *** 10/12/2016 HS *** ***************************************************
WAIT_PRE_S  = 10; % wait time before stimuli in seconds.
WAIT_POST_S = 10; % wait time after  stimuli in seconds.
% *** 10/12/2016 HS *** ***************************************************

% normal grating
% Params.cyclespersecond = 0.5; % temporal frequency
% % spatialFrequency_cpd = 4; % cycles per degree
% spatialFrequency_cpd = 5; % cycles per degree
% spatialFrequency_cpd = 3; % cycles per degree
% Params.cyclespersecond = 0.5; % temporal frequency
Params.cyclespersecond = 2; % temporal frequency
spatialFrequency_cpd = 0.03; % cycles per degree

% % flashing
% Params.cyclespersecond = 5; % temporal frequency
% spatialFrequency_cpd = 0.0001;%4; % cycles per degree

screen_distance_cm = 10;
screen_width_cm = 15.4;
screen_width_pixels = 1024;
% % screen_distance_cm = 30;
% screen_distance_cm = 7;
% screen_width_cm = 59.69;
% screen_width_pixels = 1920;
pixels_per_degree = psychsr_calibrate_screen_HS(screen_width_cm, screen_distance_cm, screen_width_pixels);

sf_cyclesperpixel = spatialFrequency_cpd / pixels_per_degree; % spatial frequency in cycles per pixel

% cyclesperpixel

% *** 09/19/2016 HS *** ***************************************************
%% Preamble................................................................
global data
fullscr = 1;
% mypath='C:\Dropbox\MouseAttention\Matlab\psychsr\Protocols\RG_2p4Scripts';
% cd (mypath)
imageFlag = 0;

% identify the computer, if lab computer, initialize the DAQ..............
name = getenv('computername');

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
% *** 12/01/2016 HS *** ***************************************************
elseif strcmp(name, '3P1_BEHAVIOR') == 1
%             data.response.mode = 0;
%             data.card.trigger_mode = 'out';
%             psychsr_card_setup;

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
% *** 12/01/2016 HS *** ***************************************************
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
        Params.durBlank        = 2;
        Params.durBlank_Grats  = 4;
        Params.durStim         = 13;
%         Params.durGratings     = 2;
        Params.durGratings     = 4;
        fprintf('Case = Soma\t\tTotal Time(s) = %d\n', 6.*((4*15)+(6*12)) );
        Params
    case 'Dendrites'
        Params.durBlank        = 2;
        Params.durBlank_Grats  = 2;
        Params.durStim         = 13;
        Params.durGratings     = 2;
        Params
        fprintf('Case = Dendrites\t\tTotal Time(s) = %d\n', 6.*((4*15)+(4*12)) );
end;

%% Generate Grating Sequence...............................................
NumTrials  = 20;
% *** 09/19/2016 HS *** ***************************************************
% N  = GenerateCombinations_for_dendImaging;
% NN = reshape(N,12,5,2);
N  = GenerateCombinations_for_dendImaging_HS(Nori, sf_cyclesperpixel);
NN = reshape(N,Nori,5,2);
% *** 09/19/2016 HS *** ***************************************************
NN = repmat( NN, 1, 2);
% *** 09/19/2016 HS *** ***************************************************
% V  = {'I','I','I','I','G'};
% DisplaySequence = repmat(V,1,6);
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

% *** 09/19/2016 HS *** ***************************************************
% displayType = 'Movies';
% 
% fprintf( 'Loading: %s, Please Wait...\n', displayType );
% 
% switch displayType
%     case 'Images'
%         moviePath  = [cd '\NaturalImages\'] ;
%         fprintf('Loading...');
%         load([moviePath 'Sequence']);
%         for fr = 1:size(NatImageSeq,3)
%             x  = 250.*mat2gray(NatImageSeq(:,:,fr));
%             footex(fr) = Screen('MakeTexture', win, x);
%         end;
%     case 'Movies'
%         moviePath  = [cd '\NaturalMovies\'] ;
%         folderName =  '\NatMovies_High\' ;
%         directory  = [moviePath folderName];
%         NumMovies  = 7;
%         DurEachMov = 2;
%         for mov = 1 : NumMovies
%             currMov = mov;
%             load( [directory 'mov' num2str(currMov) '.mat'] );
% %             for fr = 1 : ceil(DurEachMov*FrameRate)
%             for fr = 1 : ceil(DurEachMov*FrameRate(screenid))
%                 x  = 200.*mat2gray(movnew(:,:,fr));
%                 footex(mov,fr) = Screen('MakeTexture', win, x);
%             end;
%             clear x movnew
%         end;
%         footex = footex';
%         footex = footex(:);
%         footex = footex';
%         clear movnew x;
% end; % end switch-case
% tex = repmat( footex,NumTrials,1);
% size(tex)
% *** 09/19/2016 HS *** ***************************************************
waitframes = 1.0007;

%% Start ..................................................................
% *** 12/13/2016 HS *** ***************************************************
for tmpRepeat = 1:NTrialRepeats
% *** 12/13/2016 HS *** ***************************************************

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
    
% *** 05/04/2016 HS *** ***************************************************
    if labComp == 3
        putvalue(card.trigger,0);
        pause(0.05);
        putvalue(card.trigger,1);
    end;
% *** 05/04/2016 HS *** ***************************************************   

% *** 10/12/2016 HS *** ***************************************************
% wait before stimuli.
    tic;
    while toc <= WAIT_PRE_S
    end
% *** 10/12/2016 HS *** ***************************************************

    % Wait for release of all keys on keyboard, then sync us to retrace:
    KbReleaseWait;
    tic
    for v = 1:length(DisplaySequence)
        currentPosition =  DisplaySequence{v};
        if strcmpi( currentPosition, 'I') == 1
% *** 09/19/2016 HS *** ***************************************************
%             cti = cti+1;
%             fprintf('Displaying Image seqeuence %d of %d\n', cti, NumTrials);
%             vbl = Screen('Flip',win); % starting time point. All time points refer back to this.
%             vbl0 = vbl;
%             displayImageSequence( texgray,tex,Params, waitframes, ifi, vbl,vbl0, win)
%             if imageFlag
%                 if v==1
%                     tempArray = Screen('GetImage',win);
%                     imageArray = tempArray(:,:,1);
%                     imwrite(imageArray,'screenOutputNS.tif')
%                 else
%                     tempArray = Screen('GetImage',win);
%                     imageArray = tempArray(:,:,1);
%                     imwrite(imageArray,'screenOutputNS.tif','WriteMode','append')
%                 end
%                 
%             end
% *** 09/19/2016 HS *** ***************************************************
            
        elseif strcmpi( currentPosition, 'G') == 1
            ctg = ctg+1;
            fprintf('Displaying Grating seqeuence %d of %d\n', ctg, length(DisplaySequence)./5);
            vbl = Screen('Flip',win); % starting time point. All time points refer back to this.
            vbl0 = vbl;
            Nnew = squeeze( NN(:,ctg,:) );
% *** 09/19/2016 HS *** ***************************************************
%             displayGratingSequence(rotateMode,Nnew,texgray, Params, waitframes, ifi, vbl,vbl0, win)
            displayGratingSequence_HS(rotateMode,Nnew,texgray, Params, waitframes, ifi, vbl,vbl0, win, Nori)
% *** 09/19/2016 HS *** ***************************************************
            if imageFlag
                tempArray = Screen('GetImage',win);
                imageArray = tempArray(:,:,1);
                imwrite(imageArray,'screenOutput.tif','WriteMode','append')
            end
        end;
    end; % end for
    toc
    
% *** 12/13/2016 HS *** ***************************************************
% wait after stimuli.
Screen('Flip',win);
tic;
    while toc <= WAIT_POST_S
    end
% *** 12/13/2016 HS *** ***************************************************

end; % end if

% *** 12/13/2016 HS *** ***************************************************
end; % end of file repeats
% *** 12/13/2016 HS *** ***************************************************


% We're done. Close the window. This will also release all other resources:
Screen('CloseAll');
% *** 10/12/2016 HS *** ***************************************************
putvalue(card.trigger,0);
stop(card.dio);
% *** 10/12/2016 HS *** ***************************************************
return;
end


function N = GenerateCombinations_for_dendImaging_HS(NumOrient, sf_cyclesperpixel)

NumSpatFreq = 1;
% *** 09/19/2016 HS *** ***************************************************
% NumOrient   = 12;
% *** 09/19/2016 HS *** ***************************************************

% minSpatFreq = 0;
% maxSpatFreq = 32; % i.e 0.1 cyc/px

% range of spatial freqs = 0.01 cyc/px -> .6 cyc/px
% range of angles = 22.5 deg -> 360 deg

% SpatInc = [1,2,3,4,6,8,10,16];
% SpatInc = linspace( minSpatFreq, maxSpatFreq, NumSpatFreq);
% *** 09/19/2016 HS *** ***************************************************
% Angles  = linspace(0, 330, NumOrient);
Angles  = linspace(0, 360-360/NumOrient, NumOrient);
% *** 09/19/2016 HS *** ***************************************************
% SpatInc = [0.005*2.^(0:NumSpatFreq-1)];
% *** 09/19/2016 HS *** ***************************************************
% SpatInc  = 0.008.*ones(1,1);
SpatInc  = sf_cyclesperpixel.*ones(1,1);
% *** 09/19/2016 HS *** ***************************************************

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

% *** 09/19/2016 HS *** ***************************************************
% m = 1;
% *** 09/19/2016 HS *** ***************************************************

% *** 09/19/2016 HS *** ***************************************************
% for m =  1:12
for m =  1:Nori
% *** 09/19/2016 HS *** ***************************************************
    amplitude       = Params.contrast; % contrast value.
    angle           = Nnew(m,1);
    freq            = Nnew(m,2);
    % phase increment..................................................
    phase = 90;
    phaseincrement = (Params.cyclespersecond * 360) * ifi;
    
    % Build grating texture....................................................
    gratingtex = CreateProceduralSineGrating(win, 256, 256, [0.5 0.5 0.5 0.0], inf, Params.contrast);
    % then a movie................................................
    nFrames = 1;
    
    grayFrames = 1;

    while vbl-vbl0 < m*Params.durBlank_Grats + (m-1)*Params.durGratings - 1.5*waitframes*ifi
        Screen('DrawTexture', win, texgray(grayFrames), [0, 0, Params.width, Params.height]);
        vbl = Screen('Flip', win, vbl + (waitframes-0.5)* ifi);
        if grayFrames == 1
            fprintf('Gray #%d START: %3.3f\n',i,vbl-vbl0)
        end
        grayFrames = grayFrames +1;
    end
    fprintf('Gray #%d STOP:  %3.3f -- %d frames\n',i,vbl-vbl0,grayFrames)
    

    while vbl-vbl0 < m*(Params.durBlank_Grats+Params.durGratings) - 1.5*waitframes*ifi
        % Draw the grating,
        Screen('DrawTexture', win, gratingtex, [], Params.Dims, angle, [], [], [], [], rotateMode, [phase, freq, amplitude, 0]);
        vbl = Screen('Flip', win, vbl + (waitframes-0.5)*ifi);
        if nFrames == 1;
            fprintf('Mov  #%d START: %3.3f\n',m,vbl-vbl0)
        end;
        nFrames = nFrames + 1;
        phase   = phase + phaseincrement;
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