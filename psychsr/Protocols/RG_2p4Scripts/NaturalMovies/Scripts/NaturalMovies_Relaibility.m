function [] = NaturalMovies_Relaibility
clear all;
global data
%% identify the computer, if lab computer, initialize the DAQ..............
name = getenv('computername');
Params.Where     = name;

if strcmp(name,'RAINBOW') == 1
    rfmap_define_monitor();
    rfmap_define_io_cards();
    rfmap_config_trigger_port();
    rfmap_share_parameters();
    labComp = 1;
elseif strcmp(name, 'VISSTIM-2P4') == 1
    data.response.mode = 0;
    data.card.trigger_mode = 'out';
    psychsr_card_setup;
    labComp = 2;
else
    labComp = 0;
end;

%% Set all the parameters, i.e duration of stim and blank; contrast........
Params.moviePath = 'C:\Dropbox\MouseAttention\Matlab\psychsr\Protocols\RG_2p4Scripts\MoviesDirectory\' ;
Params.durStim   = 4; % duration of each movie in sec, don't change this
Params.NumMovies = 5;
Params.SessionDuration = 640; % in seconds
Params.fullscr = 1;
FrameRate = 60;
minMiss = 0; maxAllowedBlankTime = 4;

if minMiss == 1
    OptBlk = OptimizeMissMatchTime(maxAllowedBlankTime, Params.NumMovies, Params.SessionDuration);
    Params.durBlank = OptBlk;
else
    Params.durBlank  = 8; % in seconds
end;

fprintf('Generating Movie Seqeuence .....');
[MissMatch, Params.MovIndex] = GenerateSequence( Params.NumMovies , Params.durBlank, Params.SessionDuration );
% Params.Reps     = size(Params.MovIndex,1);
Params.Reps  = 20;
fprintf('.....Done!\n');

%% make save folders and save sequence....................................
fprintf('Creating Folders .....');

folderName1 =  '/NatOnlyMovies/' ;
folderName1 =  'NaturalMov_Rel\' ;
folderName3 =  '/NatMovies_Low/' ;

folderName = '/ReliabilityExpt/';
if exist( ['../' date '/'] ) < 7
    mkdir( ['../' date '/'] );
end;

if exist( ['../' date folderName] ) <7
    mkdir( ['../' date folderName] )
end;
savePath = ['../' date folderName];
fprintf('..... Done!\n');

X = dir(['../' date folderName '*.mat']);
if size(X,1) == 0
    % this is the first protocol..
    ctr = 1;
    Params.runNumber = ctr;
elseif size(X,1) > 0
    ctr =  size(X,1) + 1;
end;

%% define the screen and other PTB stuff ..................................
AssertOpenGL;

KbName('UnifyKeyNames');
esc   = KbName('ESCAPE');
screenid = max(Screen('Screens'));

res      = Screen(screenid, 'Resolution');
width    = res.width;
height   = res.height;
ep = 450;

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

%% Build Gray textures.....................................................
for i = 1 : ceil(Params.durBlank*FrameRate)
    texgray(i) = Screen('MakeTexture', win, gray);
end;

for i = 1 : ceil(15*FrameRate)
    filler(i) = Screen('MakeTexture', win, black);
end;

%% Build Movie textures....................................................
fprintf('Loading Frames .....');

Screen('TextFont',win, 'Courier New');
Screen('TextSize',win, 50);
Screen('TextStyle', win, 1+2);
tstring = ['Loading Frames...'];
DrawFormattedText(win, tstring, 100, 100, [255, 255, 255, 255]);
Screen('Flip',win);

% % normal contrast.........................................................
% directory = [Params.moviePath folderName1];
% for mov = 1 : Params.NumMovies
%     currMov = Params.MovIndex(1,mov);
%     load( [directory 'mov' num2str(currMov) '.mat'] );
%     for fr = 1 : ceil(Params.durStim*FrameRate)
%         x  = 200.*mat2gray(movnew(:,:,fr));
%         localtex_Normal(mov,fr) = Screen('MakeTexture', win, x);
%     end;
%     clear x movnew
% end;
% clear movnew x;

% High contrast.........................................................
directory = [Params.moviePath folderName1];
for mov = 1 : Params.NumMovies
    currMov = Params.MovIndex(1,mov);
    load( [directory 'mov' num2str(currMov) '.mat'] );
    for fr = 1 : ceil(Params.durStim*FrameRate)
        x  = 200.*mat2gray(movnew(:,:,fr));
        localtex_High(mov,fr) = Screen('MakeTexture', win, x);
    end;
    clear x movnew
end;
clear movnew x;

% % Low contrast.........................................................
% directory = [Params.moviePath folderName3];
% for mov = 1 : Params.NumMovies
%     currMov = Params.MovIndex(1,mov);
%     load( [directory 'mov' num2str(currMov) '.mat'] );
%     for fr = 1 : ceil(Params.durStim*FrameRate)
%         x  = 128.*mat2gray(movnew(:,:,fr));
%         localtex_Low(mov,fr) = Screen('MakeTexture', win, x);
%     end;
%     clear x movnew
% end;
% clear movnew x;

for trial = 1:1:20
    tex(trial,:,:) = localtex_High;
    Params.MovSeq{trial} = 'High';
end;

% for trial = 2:2:20
%     tex(trial,:,:) = localtex_High;
%     Params.MovSeq{trial} = 'High';
% end;

% for trial = 3:3:21
%     tex(trial,:,:) = localtex_Low;
%     Params.MovSeq{trial} = 'L';
% end;

save( [savePath 'Protocol_' num2str(ctr)], 'Params' )
fprintf('....Done\n')

%% display text telling the user to press the trigger......................
fprintf('Waiting for trigger....')
Screen('Flip',win);
Screen('TextFont',win, 'Courier New');
Screen('TextSize',win, 50);
Screen('TextStyle', win, 1+2);
tstring = ['Waiting for trigger...'];
DrawFormattedText(win, tstring, 100, 100, [255, 255, 255, 255]);
Screen('Flip',win);

KbWait;

%% User has pressed trigger, display the stimulus.........................

% flush the keyboard buffer ..........................................
keyIsDown = 0;
keyCode   = zeros(1,256);

vbl = Screen('Flip', win);

% trigger system for 2p4...............................................
if labComp == 2
    tstart = tic;
    putvalue(data.card.trigger,1);
    while toc(tstart) < 0.005; end
    putvalue(data.card.trigger,0);
    fprintf('...Triggered\n')
end;
tic
% loop over the number of reps...........................................
for trial = 1 : Params.Reps
    for mov = 1 : Params.NumMovies
     fprintf( 'Trial: %d\tContrast: %s\tDisplaying Movie %d\n', trial,Params.MovSeq{trial},mov );
        % display the movie ...............................................
        for nframes = 1:fix(Params.durStim*FrameRate)
            if Params.fullscr == 0
                Screen('DrawTexture', win, tex(trial, mov, nframes), [], [ep, -300, width, width-ep]);
                vbl = Screen('Flip', win, vbl + 0.5 * ifi);
            elseif Params.fullscr == 1
                Screen('DrawTexture', win, tex(trial, mov, nframes), [], [0, 0, width, height]);
                vbl = Screen('Flip', win, vbl + 0.5 * ifi);
            end;
        end;
    end;
    
    fprintf( 'Trial: %d\tContrast: %s\tDisplaying Blank Screen\n', trial,Params.MovSeq{trial} );
    % display the blank.....................................................
    for j = 1:ceil(Params.durBlank*FrameRate)
        Screen('DrawTexture', win, texgray(j), [0, 0, width, height]);
        vbl = Screen('Flip', win, vbl + 0.5 * ifi);
    end;
end;
toc
fprintf('All trials over, filling rest of screen with black for %d sec.\n', MissMatch);
Missed = Params.SessionDuration;

% % fill the rest of the time with a black screen...........................
% for j = 1:floor(Missed*FrameRate)
%     Screen('DrawTexture', win, filler(j), [0, 0, width, height]);
%     vbl = Screen('Flip', win, vbl + 0.5 * ifi);
% end;
%


%% We're done. Close the window. This will also release all other resources:
fprintf('Imaging session completed!\n');
Screen('CloseAll');
return;

