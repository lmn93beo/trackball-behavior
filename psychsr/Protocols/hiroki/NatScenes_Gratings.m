function NatScenes_Gratings(type)

%% Preamble.................................................................
global data
fullscr = 1;
mypath='C:\Dropbox\MouseAttention\Matlab\psychsr\Protocols\RG_2p4Scripts';
cd (mypath)
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
else
    labComp = 0;
end;

%% Set all the timing parameters, i.e duration of stim and blank; contrast........

if nargin<1; type = 'Astro'; end;

Params.contrast        = 1;
Params.cyclespersecond = 2;

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
        Params.durGratings     = 2;
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
N  = GenerateCombinations_for_dendImaging;
NN = reshape(N,12,5,2);
NN = repmat( NN, 1, 2);
V  = {'I','I','I','I','G'};
DisplaySequence = repmat(V,1,6);

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
for i = 1 : fix(Params.durBlank_Grats*FrameRate)+ 20
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

displayType = 'Movies';

fprintf( 'Loading: %s, Please Wait...\n', displayType );

switch displayType
    case 'Images'
        moviePath  = [cd '\NaturalImages\'] ;
        fprintf('Loading...');
        load([moviePath 'Sequence']);
        for fr = 1:size(NatImageSeq,3)
            x  = 250.*mat2gray(NatImageSeq(:,:,fr));
            footex(fr) = Screen('MakeTexture', win, x);
        end;
    case 'Movies'
        moviePath  = [cd '\NaturalMovies\'] ;
        folderName =  '\NatMovies_High\' ;
        directory  = [moviePath folderName];
        NumMovies  = 7;
        DurEachMov = 2;
        for mov = 1 : NumMovies
            currMov = mov;
            load( [directory 'mov' num2str(currMov) '.mat'] );
            for fr = 1 : ceil(DurEachMov*FrameRate)
                x  = 200.*mat2gray(movnew(:,:,fr));
                footex(mov,fr) = Screen('MakeTexture', win, x);
            end;
            clear x movnew
        end;
        footex = footex';
        footex = footex(:);
        footex = footex';
        clear movnew x;
end; % end switch-case
tex = repmat( footex,NumTrials,1);
size(tex)
waitframes = 1.0007;

%% Start ..................................................................
% display text telling the user to press the trigger...................
Screen('TextFont',win, 'Courier New');
Screen('TextSize',win, 50);
Screen('TextStyle', win, 1+2);
tstring = ['Waiting for trigger!'];
DrawFormattedText(win, tstring, 100, 100, [255, 255, 255, 255]);
Screen('Flip',win);

% fprintf('Note: 20 reps of NI, 6 reps of Gratings, Total Dur = 648s\n');
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
    
    % Wait for release of all keys on keyboard, then sync us to retrace:
    KbReleaseWait;
    tic
    for v = 1:length(DisplaySequence)
        currentPosition =  DisplaySequence{v};
        if strcmpi( currentPosition, 'I') == 1
            cti = cti+1;
            fprintf('Displaying Image seqeuence %d of %d\n', cti, NumTrials);
            vbl = Screen('Flip',win); % starting time point. All time points refer back to this.
            vbl0 = vbl;
            displayImageSequence( texgray,tex,Params, waitframes, ifi, vbl,vbl0, win)
            if imageFlag
                if v==1
                    tempArray = Screen('GetImage',win);
                    imageArray = tempArray(:,:,1);
                    imwrite(imageArray,'screenOutputNS.tif')
                else
                    tempArray = Screen('GetImage',win);
                    imageArray = tempArray(:,:,1);
                    imwrite(imageArray,'screenOutputNS.tif','WriteMode','append')
                end
                
            end
            
        elseif strcmpi( currentPosition, 'G') == 1
            ctg = ctg+1;
            fprintf('Displaying Grating seqeuence %d of %d\n', ctg, length(DisplaySequence)./5);
            vbl = Screen('Flip',win); % starting time point. All time points refer back to this.
            vbl0 = vbl;
            Nnew = squeeze( NN(:,ctg,:) );
            displayGratingSequence(rotateMode,Nnew,texgray, Params, waitframes, ifi, vbl,vbl0, win)
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
return;
