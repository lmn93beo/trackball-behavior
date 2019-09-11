function []=behav_proto_2screens()

trials=10;

% make stimulus vectors
randVec=randperm(trials);
left_stimVec=ones(1,trials)*90;
left_stimVec(randVec(1:trials/2))=180;
randVec=randperm(trials);
right_stimVec=ones(1,trials)*90;
right_stimVec(randVec(1:trials/2))=180;

try
    % This script calls Psychtoolbox commands available only in OpenGL-based
    % versions of the Psychtoolbox. (So far, the OS X Psychtoolbox is the
    % only OpenGL-base Psychtoolbox.)  The Psychtoolbox command AssertPsychOpenGL will issue
    % an error message if someone tries to execute this script on a computer without
    % an OpenGL Psychtoolbox
    AssertOpenGL;
    
    % Assign screen numbers
    fullScreen=0;
    leftScreen=1;
    rightScreen=2;
    
    % Find the color values which correspond to white and black: Usually
    % black is always 0 and white 255, but this rule is not true if one of
    % the high precision framebuffer modes is enabled via the
    % PsychImaging() commmand, so we query the true values via the
    % functions WhiteIndex and BlackIndex:
    leftWhite=WhiteIndex(leftScreen);
    leftBlack=BlackIndex(leftScreen);
    rightWhite=WhiteIndex(rightScreen);
    rightBlack=BlackIndex(rightScreen);
    fullWhite=WhiteIndex(fullScreen);
    fullBlack=BlackIndex(fullScreen);
    
    % Round gray to integral number, to avoid roundoff artifacts with some
    % graphics cards:
    leftGray=round((leftWhite+leftBlack)/2);
    rightGray=round((rightWhite+rightBlack)/2);
    fullGray=round((fullWhite+fullBlack)/2);
    
    % This makes sure that on floating point framebuffers we still get a
    % well defined gray. It isn't strictly neccessary in this demo:
    if leftGray==leftWhite
        leftGray=leftWhite/2;
    end
    if rightGray==rightWhite
        rightGray=rightWhite/2;
    end
    if fullGray==fullWhite
        fullGray=fullWhite/2;
    end
    
    % Contrast 'inc'rement range for given white and gray values:
    leftInc=leftWhite-leftGray;
    rightInc=rightWhite-rightGray;
    fullInc=fullWhite-fullGray;
    
    % Open a double buffered fullscreen window and select a gray background
    % color:
    full_rect=Screen('Rect',0);
    [full_w]=Screen('OpenWindow',fullScreen,fullGray,full_rect);
    
    % Run the movie animation for a fixed period.
    numFrames=30; % temporal period, in frames, of the drifting grating
    movieDurationSecs=2;
    frameRate=Screen('FrameRate',fullScreen);
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
    [full_ifi nvalid stddev]=Screen('GetFlipInterval',full_w,100,0.00005,20);
    fprintf('Measured refresh interval, as reported by "GetFlipInterval" is %2.5f ms. (nsamples = %i, stddev = %2.5f ms)\n', full_ifi*1000, nvalid, stddev*1000);
    
    % Use realtime priority for better timing precision:
    priorityLevel=MaxPriority(full_w);
    Priority(priorityLevel);
    
    for trialNum=1:trials
        
        respTag=0;
        lastData=10;
        % Compute each frame of the movie and convert the those frames, stored in
        % MATLAB matices, into Psychtoolbox OpenGL textures using 'MakeTexture';
        for i=1:numFrames
            phase=(i/numFrames)*2*pi;
            left_angle=left_stimVec(trialNum)*pi/180; % set orientation.
            left_a=cos(left_angle)*f;
            left_b=sin(left_angle)*f;
            left_m=sin(left_a*x+left_b*y+phase); 
            right_angle=right_stimVec(trialNum)*pi/180; % set orientation.
            right_a=cos(right_angle)*f;
            right_b=sin(right_angle)*f;
            right_m=sin(right_a*x+right_b*y+phase); 
            full_tex(i)=Screen('MakeTexture',full_w,[leftGray+leftInc*left_m rightGray+rightInc*right_m]);
        end
        
        % Perform initial Flip to sync us to the VBL and for getting an initial
        % VBL-Timestamp for our "WaitBlanking" emulation:
        full_vbl=Screen('Flip',full_w);
        
        % Animation loop:
        for i=1:movieDurationFrames
            
            % collect 3 samples from analog input before flip
            inputData(1)=max(getsample(ai));
            inputData(2)=max(getsample(ai));
            inputData(3)=max(getsample(ai));
            
            % Draw image
            Screen('DrawTexture',full_w,full_tex(movieFrameIndices(i)));
            full_vbl=Screen('Flip',full_w,full_vbl+(waitframes-0.5)*full_ifi);

            % collect 3 samples from analog input after flip
            inputData(4)=max(getsample(ai));
            inputData(5)=max(getsample(ai));
            inputData(6)=max(getsample(ai));
            
            % Determine if lick occured
            if max(inputData)>threshold & max(inputData)>lastData & respTag==0
                if left_stimVec(trialNum)==90
                    result{trialNum}='Hit';
                    fVolume=0.1;
                    tone=sin(2*pi*880*[0.0001:0.0001:1]);
                    envelope=[logspace(-1,0,2000) ones(1,6000) logspace(0,-1,2000)];
                    Snd('Play',tone.*envelope*fVolume,10000);
                elseif left_stimVec(trialNum)==180
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
            if left_stimVec(trialNum)==90
                result{trialNum}='Miss';
            elseif left_stimVec(trialNum)==180
                result{trialNum}='CorrectReject';
            end
        end
        
        % blank interval
        blankDurationSecs=2;
        blankDurationFrames=round(blankDurationSecs*frameRate);
        blankFrameIndices=mod(0:(blankDurationFrames-1),numFrames)+1;
        
        for i=1:blankDurationFrames
            % make texture
              full_tex2(i)=Screen('MakeTexture',full_w,[leftGray rightGray]);
            % Draw image:
              Screen('DrawTexture',full_w,full_tex2(blankFrameIndices(i)));
              full_vbl=Screen('Flip',full_w,full_vbl+(waitframes-0.5)*full_ifi);
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
    
    left_stimVec
    result
    
catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    Priority(0);
    psychrethrow(psychlasterror);
    stop(ai);
end %try..catch..


