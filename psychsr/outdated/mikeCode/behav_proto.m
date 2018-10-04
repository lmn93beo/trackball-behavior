function []=behav_proto()

trials=10;
randVec=randperm(trials);
stimVec=ones(1,trials)*90;
stimVec(randVec(1:trials/2))=270;
maskFlag=0;


try
    % This script calls Psychtoolbox commands available only in OpenGL-based
    % versions of the Psychtoolbox. (So far, the OS X Psychtoolbox is the
    % only OpenGL-base Psychtoolbox.)  The Psychtoolbox command AssertPsychOpenGL will issue
    % an error message if someone tries to execute this script on a computer without
    % an OpenGL Psychtoolbox
    AssertOpenGL;
    
    % Get the list of screens and choose the one with the highest screen number.
    % Screen 0 is, by definition, the display with the menu bar. Often when
    % two monitors are connected the one without the menu bar is used as
    % the stimulus display.  Chosing the display with the highest dislay number is
    % a best guess about where you want the stimulus displayed.
    screens=Screen('Screens');
    % screenNumber=max(screens);
    screenNumber=0;
    
    % Find the color values which correspond to white and black: Usually
    % black is always 0 and white 255, but this rule is not true if one of
    % the high precision framebuffer modes is enabled via the
    % PsychImaging() commmand, so we query the true values via the
    % functions WhiteIndex and BlackIndex:
    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    
    % Round gray to integral number, to avoid roundoff artifacts with some
    % graphics cards:
    gray=round((white+black)/2);
    
    % This makes sure that on floating point framebuffers we still get a
    % well defined gray. It isn't strictly neccessary in this demo:
    if gray == white
        gray=white / 2;
    end
    
    % Contrast 'inc'rement range for given white and gray values:
    inc=white-gray;
    
    % Open a double buffered fullscreen window and select a gray background
    % color:
    w=Screen('OpenWindow',screenNumber, gray);
    
    % Run the movie animation for a fixed period.
    numFrames=30; % temporal period, in frames, of the drifting grating
    movieDurationSecs=2;
    frameRate=Screen('FrameRate',screenNumber);
    % Convert movieDuration in seconds to duration in frames to draw:
    movieDurationFrames=round(movieDurationSecs * frameRate);
    movieFrameIndices=mod(0:(movieDurationFrames-1), numFrames) + 1;
    
    % grating parameters
    [x,y]=meshgrid(-800:800,-800:800);  % mask
    cpd=0.125;               % desired cycles/cm
    pixel_pitch=0.0265;      % in cm/pixel
    f=cpd*pixel_pitch*2*pi;  % cycles per cm
    
    % Initialize analog input
    ai = analoginput('nidaq','Dev1');
    chan = addchannel(ai,1);
    set(ai,'SampleRate',10000)
    set(ai,'SamplesPerTrigger',inf)
    set(ai,'TriggerType','Manual')
    set(ai,'Transfermode','SingleDMA')
    start(ai)
    trigger(ai)
    threshold=0.01;
    
    data=zeros(trials,movieDurationFrames);
    
    waitframes=1;
    [ifi nvalid stddev]= Screen('GetFlipInterval', w, 100, 0.00005, 20);
    fprintf('Measured refresh interval, as reported by "GetFlipInterval" is %2.5f ms. (nsamples = %i, stddev = %2.5f ms)\n', ifi*1000, nvalid, stddev*1000);
    
    % Use realtime priority for better timing precision:
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);
    
    for trialNum=1:trials
        
        respTag=0;
        lastData=10;
        % Compute each frame of the movie and convert the those frames, stored in
        % MATLAB matices, into Psychtoolbox OpenGL textures using 'MakeTexture';
        for i=1:numFrames
            phase=(i/numFrames)*2*pi;
            angle=stimVec(trialNum)*pi/180; % set orientation.
            a=cos(angle)*f;
            b=sin(angle)*f;
            m=sin(a*x+b*y+phase); 
            if maskFlag==1
                mask_size=900; % mask size in pixels
                mask=exp(-((x/mask_size).^2)-((y/mask_size).^2));
                m=m.*mask;
            end
            tex(i)=Screen('MakeTexture', w, gray+inc*m); %#ok<AGROW>
        end
        
        % Perform initial Flip to sync us to the VBL and for getting an initial
        % VBL-Timestamp for our "WaitBlanking" emulation:
        vbl=Screen('Flip', w);
        
        % Animation loop:
        for i=1:movieDurationFrames
            
            % collect 3 samples from analog input before flip
            inputData(1)=max(getsample(ai));
            inputData(2)=max(getsample(ai));
            inputData(3)=max(getsample(ai));
            
            % Draw image
            Screen('DrawTexture', w, tex(movieFrameIndices(i)));
            vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
            
            % collect 3 samples from analog input after flip
            inputData(4)=max(getsample(ai));
            inputData(5)=max(getsample(ai));
            inputData(6)=max(getsample(ai));
            
            % Determine if lick occured
            %      		data(trialNum,i)=max(inputData);
            if max(inputData)>threshold & max(inputData)>lastData & respTag==0
                if stimVec(trialNum)==90
                    result{trialNum}='Hit';
                    fVolume=0.1;
                    tone=sin(2*pi*880*[0.0001:0.0001:1]);
                    envelope=[logspace(-1,0,2000) ones(1,6000) logspace(0,-1,2000)];
                    Snd('Play',tone.*envelope*fVolume,10000);
                elseif stimVec(trialNum)==270
                    result{trialNum}='FalseAlarm';
                    fVolume=0.5;
                    sampRate=10000;
                    signal=(rand(1,sampRate)-0.5);
                    Snd('Play',signal*fVolume,sampRate);
                end
                respTag=1;
                break
            end
            lastData=max(inputData);
        end
        
        % If no lick occured
        if respTag==0
            if stimVec(trialNum)==90
                result{trialNum}='Miss';
            elseif stimVec(trialNum)==270
                result{trialNum}='CorrectReject';
            end
        end
        
        % blank interval
        blankDurationSecs=2;
        blankDurationFrames=round(blankDurationSecs * frameRate);
        blankFrameIndices=mod(0:(blankDurationFrames-1), numFrames) + 1;
        
        for i=1:blankDurationFrames
            % make texture
            tex2(i)=Screen('MakeTexture', w, gray); %#ok<AGROW>
            % Draw image:
            Screen('DrawTexture', w, tex2(blankFrameIndices(i)));
            vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
        end
        
    end
    
    
    Priority(0);
    
    % Close all textures. This is not strictly needed, as
    % Screen('CloseAll') would do it anyway. However, it avoids warnings by
    % Psychtoolbox about unclosed textures. The warnings trigger if more
    % than 10 textures are open at invocation of Screen('CloseAll') and we
    % have 12 textues here:
    Screen('Close');
    
    % Close window:
    Screen('CloseAll');
    
    stop(ai);
    
    stimVec
    result
    
catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    Priority(0);
    psychrethrow(psychlasterror);
end %try..catch..
