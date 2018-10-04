function mapOrientations_Axonal_SpatFreqs %<<
% Oriented Sine-wave Gratings..............................................................
% version 2.0, 12-Dec-2014, RVR MIT

spatFreq = 0.064;
freq     = spatFreq;
%% identify the computer, if lab computer, initialize the DAQ..............
name = getenv('computername');
Params.Where     = name;
if strcmp(name,'RAINBOW') == 1
    global data
    fprintf('Welcome to 2P3\n')
    rfmap_define_monitor();
    rfmap_define_io_cards();
    rfmap_config_trigger_port();
    rfmap_share_parameters();
    labComp = 1;
elseif strcmp(name, 'VISSTIM-2P4') == 1 
    fprintf('Welcome to 2P4\n')
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

%% Set stim parameters....................................................
N = GenerateCombinations_Axonal_TempFreqs; %<<
% duration of stim and blank; contrast........
Params.durStim   = 2;
Params.durBlank  = 4;
Params.contrast  = 1;
ISI = Params.durStim + Params.durBlank;
% set timing information..................................................
numMovies = size(N,1);
TotalStimTime = numMovies*ISI; % in seconds.
Params.MovsperTrial  = 100;
Params.NumTrials     = floor( size(N,1)/Params.MovsperTrial );
Params.TotalDuration = TotalStimTime;
Params.TotalDuration_perTrial = ISI*Params.MovsperTrial;
fprintf('This script will run for %d trials each %d seconds long\n',  Params.NumTrials, Params.TotalDuration_perTrial);
%% generate and save the protocol used .....................................
fprintf('Creating Folders .....');
if exist( ['../' date '/'] ) < 7
    mkdir( ['../' date '/'] );
    
end;
if exist( ['../' date ['/Orientation Temp Tuning' name '/'] ] ) <7
    mkdir( ['../' date ['/Orientation Temp Tuning' name '/'] ] )
end;
savePath = ['../' date ['/Orientation Temp Tuning' name '/'] ];
fprintf('..... Done!\n');

fprintf('Generating Random Seqeuence .....');
X = dir([savePath '*.mat']);
if size(X,1) == 0
    % this is the first protocol..
    ctr = 1;
    Params.runNumber = ctr;
elseif size(X,1) > 0
    % if this code is run more than 1 time in the same day, the ctr will
    % increment and the highest number will be the latest seqeunce. If the
    % code is run only once in the day, the ctr will remain at 1.
    foo = X( size(X,1), 1);
    v   = sprintf( foo.name );
    v   = v(10:end);
    for q = 1:length(v)
        if strcmp(v(q),'.') == 1
            locdot(q) = 1;
        else
            locdot(q) = 0;
        end;
    end;
    runNum = str2num(v(1 : find(locdot == 1 )));
    ctr =  runNum + 1;
    Params.runNumber = ctr;
end;
save([savePath 'Protocol_' num2str(ctr)], 'N','Params');
fprintf('..... Saved!');
%% Define screen and other PTB stuff......................................
KbName('UnifyKeyNames');
esc   = KbName('ESCAPE');

AssertOpenGL;
rotateMode = kPsychUseTextureMatrixForRotation;
screenid = max(Screen('Screens'));
res      = Screen(screenid, 'Resolution');
width    = res.width;
height   = res.height;
ep = 450;

fullscr = 1;
waitframes = 1.0007;

if fullscr == 0
    Dims = [ep, -300, width, width-ep];
elseif fullscr == 1
    Dims = [0, 0, width, height];
end;

% define black, white and gray values
white = WhiteIndex(screenid);
black = BlackIndex(screenid);
gray  = round((white+black)/2);

if gray == white
    gray = white / 2;
end;

win = Screen('OpenWindow', screenid, 128);
AssertGLSL;
ifi = Screen('GetFlipInterval', win);

%% Bulid Gray textures
for i = 1 : fix(Params.durBlank*FrameRate)+5
    texgray(i)=Screen('MakeTexture', win, gray);
end;

%% run loop over the number of trials, each trial lasts for 2mins..........
for Trial = 1 : Params.NumTrials %<<
    Nnew = N(1+(Trial-1)*Params.MovsperTrial:Params.MovsperTrial*Trial,:);
    fprintf('Trial: %d of %d\t Protocol: %d\n', Trial, Params.NumTrials, Params.runNumber);
    % display text telling the user to press the trigger...................
    Screen('TextFont',win, 'Courier New');
    Screen('TextSize',win, 50);
    Screen('TextStyle', win, 1+2);
    tstring = ['Prot.: ' num2str(Params.runNumber ) 'Trial ' num2str(Trial) 'of ' num2str(Params.NumTrials) '..Waiting for trigger ...'];
    DrawFormattedText(win, tstring, 100, 100, [255, 255, 255, 255]);
    Screen('Flip',win);
    fprintf('Waiting for trigger....\n');

    KbWait;
    tic;
    % flush the k eyboard buffer ..........................................
    keyIsDown = 0;
    keyCode   = zeros(1,256);
    
    vbl  = Screen('Flip', win);
    vbl0 =  vbl; % time reference.
    
    % run loop over movies in that trial...................................
    for i = 1 : Params. MovsperTrial
        [keyIsDown, secs, keyCode] = KbCheck;
        
        if keyIsDown == 1 && keyCode(esc) == 1
            i = 30; Trial = 16;
        else
            % grating params...................................................
            amplitude       = Params.contrast; % contrast value.
            angle           = Nnew(i,1);
            freq            = 0.064;
            cyclespersecond = Nnew(i,2);
            
            % phase increment..................................................
            phase = 00;
            phaseincrement = (cyclespersecond * 360) * ifi;
            
            % Build grating texture....................................................
            gratingtex = CreateProceduralSineGrating(win, 256, 256, [0.5 0.5 0.5 0.0], inf, Params.contrast);
            
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
            % first a blank screen.........................................
            % GP: loop until TIME has elapsed
            grayFrames = 1;
            while vbl-vbl0 < i*Params.durBlank + (i-1)*Params.durStim - 1.5*waitframes*ifi
                Screen('DrawTexture', win, texgray(grayFrames), [0, 0, width, height]);
                vbl = Screen('Flip', win, vbl + (waitframes-0.5)* ifi);
                if grayFrames == 1
                    fprintf('Gray #%d START: %3.3f\n',i,vbl-vbl0)
                end;
                grayFrames = grayFrames +1;
            end
            fprintf('Gray #%d STOP:  %3.3f -- %d frames\n',i,vbl-vbl0,grayFrames)
            % then a movie................................................
            nFrames = 1;
            while vbl-vbl0 < i*(Params.durBlank+Params.durStim) - 1.5*waitframes*ifi
                % Draw the grating,
                Screen('DrawTexture', win, gratingtex, [], [0, 0, width, height], angle, [], [], [], [], rotateMode, [phase, freq, amplitude, 0]);
                vbl = Screen('Flip', win, vbl + (waitframes-0.5)*ifi);
                if nFrames == 1;
                    fprintf('Mov  #%d START: %3.3f\n',i,vbl-vbl0)
                end;
                nFrames = nFrames + 1;
                phase   = phase + phaseincrement;
            end;
            fprintf('Mov  #%d STOP:  %3.3f -- %d frames\n',i,vbl-vbl0,nFrames)
        end; % end if.
    end;
    toc;
end; % end trial

% We're done. Close the window. This will also release all other ressources:
Screen('CloseAll');

return;
