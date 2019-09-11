function [data,param]=mouseTV_behavior(trainRegime,duration)
% Displays visual stimulus, records response of mouse and delivers rewards
% Original: MG 11/30/10, Latest update: MG 11/30/10
%
% Currently supported training regimes:
%
% respTrain    - Trains mouse to respond using lever press or lick.
% (stage1)       Plays blank stimulus until mouse responds, at which point
%                reward is given and chime occurs
%
% To be added:
%
% respTarget   - Gray background with occasionally presented target 
% (stage2)       stimulus (alternating checkerboard). Mouse response within
%                response window leads to reward/chime.
% respTarget2  - Gray background with occasionally presented target 
% (stage3)       stimulus (alternating checkerboard). Mouse response within
%                response window leads to reward/chime. Target stimulus
%                alternates sides psuedo-randomly.
% respTarget3  - Gray background with occasionally presented target 
% (stage4)       stimulus (alternating checkerboard). Mouse response within
%                response window leads to reward/chime, response outside of
%                window leads to timeout/whitenoise. Target stimulus
%                alternates sides psuedo-randomly.
% respTarget4  - Sparse noise background with occasionally presented target 
% (stage5)       stimulus (alternating checkerboard). Mouse response within
%                response window leads to reward/chime, response outside of
%                window leads to timeout/whitenoise. Target stimulus
%                alternates sides psuedo-randomly.
% respTarget5  - Sparse noise background with occasionally presented target 
% (stage6)       stimulus (alternating checkerboard). Target varies in 
%                contrast. Mouse response within response window leads to 
%                reward/chime, response outside of window leads to 
%                timeout/whitenoise. Target stimulus alternates sides 
%                psuedo-randomly.
%
% cuedTarget   - Sparse noise background with occasionally presented target 
% (stage7)       stimulus (alternating checkerboard). Target varies in 
%                contrast. Target can appear on either side of the mouse 
%                and is cued by the speaker on the same side as the target. 
%                Mouse response within response window leads to 
%                reward/chime, response outside of window leads to 
%                timeout/whitenoise.

%% monitor characteristics
x_length=37.6;     % Length(cm) of screen x-dimension [large screen]
y_length=30.1;     % Length(cm) of screen y-dimension [large screen]
% x_length=15.496;     % Length(cm) of screen x-dimension [small screen]
% y_length=8.7165;     % Length(cm) of screen y-dimension [small screen]
screens=Screen('Screens');
screenNumber=max(screens);                    % Window used for stimulus
frameRate=Screen('FrameRate',screenNumber);   % Framerate
monitorDistance=57;                           % Distance between monitor and eye
[x_pixel,y_pixel]= Screen('WindowSize',screenNumber); % Pixel resolution

% Target parameters
repeats=5;                  % Number of alternations of Target checkerboard
altPeriod=0.2;              % Period of checkerboard alternations (Sec)
numChecks=8;                % Number of squares in checkerboard (vertical dimension)
param.targetRepeats=repeats;
param.targetRate=1/altPeriod;

% Reward paramters
rewardVol=0.1;
rewardTone=sin(2*pi*880*[0.0001:0.0001:1]);
rewardEnv=rewardVol*rewardTone.*[logspace(-1,0,2000) ones(1,6000) logspace(0,-1,2000)];
param.rewardVol=rewardVol;
param.rewardTone=rewardTone;
param.rewardEnv=rewardEnv;

%% Training Regime
if strcmp(trainRegime,'respTrain') || strcmp(trainRegime,'stage1')
    
    %% respTrain (stage1)
    
    % User inputs
    rewardInterval=2;   % Interval before another reward can be triggered (sec)
    
    % Save data
    param.trainType='respTrain';
    param.train_duration=duration;
    param.train_rewardInterval=rewardInterval;
    
elseif strcmp(trainRegime,'sparseNoise')
    
    %% Sparse Noise stimulation
    
    % User inputs
    duration=20;                   % Duration of sparse stimulus (sec)
    tempFreq=3;                    % Temporal frequency of sparse noise (Hz)
    spotNum=8;                     % Number of spots presented simultaneously
    spotSizeMin=1.5;               % Smallest spot size (in degrees)
    spotSizeMax=8;                 % Smallest spot size (in degrees)
    blankTime=2;                   % blank frames before stimulus (sec)
    numFrames=frameRate/tempFreq;  % number of flips per noise stimulus
    
    % calculate circle sizes
    pixel_pitch=mean([x_length/x_pixel y_length/y_pixel]);   % in cm/pixel
    pixelPerDeg=(tan(pi/180)*monitorDistance)/pixel_pitch;   % in pixel/deg
    spotSizeVec=round(linspace(spotSizeMin,spotSizeMax,spotNum)/2*pixelPerDeg);
    
    % Save data
    data.stimType='sparseNoise';
    data.blankTime=blankTime;
    data.duration=duration;
    data.tempFreq=tempFreq;
    
else disp('trainRegime not recognized')
    return
end

%% Display
try
    % Take control of display
    AssertOpenGL;
    
    % Find the color values which correspond to white, black, and gray
    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    gray=round((white+black)/2);
    inc=white-gray;
    
    % Open a double buffered fullscreen window, measure flip interval
    waitframes=1;
    w=Screen('OpenWindow',screenNumber,gray);
    [ifi]=Screen('GetFlipInterval',w,100,0.0001,20);
    
    % Use realtime priority for better timing precision:
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);
    
    % Initialize analog input
    ai = analoginput('nidaq','Dev1');
    chan = addchannel(ai,1);
    set(ai,'SampleRate',1000)
    start(ai)
    threshold=1;
    
    %% Animate textures
    if strcmp(trainRegime,'respTrain')
        % Draw blank texture (for entire blank time)
        tex_blank(1)=Screen('MakeTexture',w,gray); % blank texture
        
        % initalize
        responseTimes=[];
        respCount=1;
        tStart=tic; tResp=tic;
        vbl=Screen('Flip',w);
        
        % present
        while toc(tStart)<duration*60
            currSample=max(getsample(ai));
            Screen('DrawTexture', w, tex_blank(1));
            vbl=Screen('Flip',w,vbl+(waitframes-0.5)*ifi);
            % check for valid response 
            if currSample>threshold & toc(tResp)>rewardInterval
                responseTimes(respCount)=toc(tStart);
                respCount=respCount+1;
                vbl=Screen('Flip',w,vbl+(ceil(frameRate)-0.5)*ifi);
                % output
%                 AO = analogoutput('nidaq','dev1');
%                 chan = addchannel(AO,1);
%                 Fs = 1000; % Sampling frequency
%                 T = 1000; % Total time in ms
%                 pulseStart = 200; % start output pulse
%                 pulseEnd = pulseStart+pulseLength;   % end output pulse
%                 set(AO,'SampleRate',Fs)
%                 set(AO,'TriggerType','Manual');
%                 outputVec=zeros(T,1);
%                 outputVec(pulseStart:pulseEnd)=5;
%                 putdata(AO,outputVec);
%                 start(AO);
%                 trigger(AO);
%                 wait(AO,1.1);
%                 delete(AO);
%                 clear AO;
                
                tResp=tic;
            elseif currSample>threshold & toc(tResp)<rewardInterval
                tResp=tic;
            end
        end
        toc(tStart)
        Screen('Close',tex_blank)
        data.responseTimes=responseTimes
        
    elseif strcmp(trainRegime,'respTarget')
        
        % Create checkerboard template
        squareLength=floor(y_pixel/numChecks);
        numChecks_horizontal=floor(x_pixel/squareLength);
        line1=[]; line2=[]; template=[];
        for x=1:numChecks_horizontal
            line1=[line1 ones(squareLength)*white*rem(x,2)];
            line2=[line2 ones(squareLength)*white*rem(x+1,2)];
        end
        for y=1:numChecks
            eval(['template=[template; line' num2str(rem(y,2)+1) '];'])
        end
        
        % Draw blank texture (for entire blank time)
        tex_blank(1)=Screen('MakeTexture',w,gray); % blank texture
        % Draw stim texture (long enough for two alternations)
        for i=1:repeats
            tex_stim(i)=Screen('MakeTexture',w,template); % draw texture
            % reverse checkerboard 
            template(template==0)=-1;
            template(template==white)=0;
            template(template==-1)=white;
        end
        
        % Start flip
        remTarget=0;
        vbl=Screen('Flip',w);
        
        % Animate
        while timeLeft>0
            % Draw blanks:
            Screen('DrawTexture', w, tex_blank(1));
            vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
            for i=1:round(frameRate*altPeriod*2)
                % Draw image
                Screen('DrawTexture',w,tex_stim(i));
                vbl=Screen('Flip',w,vbl+(waitframes-0.5)*ifi);
            end
        end
        Screen('Close',tex_blank)
        Screen('Close',tex_stim)
        
    elseif strcmp(stimType,'sparseNoise')
        
        %% Make sparse noise textures
        
        % Draw blank texture
        for i=1:blankTime*frameRate
            tex_blank(i)=Screen('MakeTexture',w,gray); % blank texture
        end
        
        % pseudo-randomly generate non-overlapping spot coordinates
        spotMatrix=zeros(spotNum,3,duration*tempFreq+1);    % coordinates of spots
        for i=2:duration*tempFreq+1
            currSizeVec=spotSizeVec(randperm(spotNum)); % determine random spot sizes
            spotCount=1;                                % initalize spot count
            while spotCount<=spotNum
                currSpot=round([rand(1)*y_pixel,rand(1)*x_pixel,currSizeVec(spotCount)]);
                % check for overlap with spots in previous and current frame
                compSpotMat=[spotMatrix(:,:,i-1); spotMatrix([1:spotCount-1],:,i)];
                currSpotMat=repmat(currSpot,size(compSpotMat,1),1);
                distanceVec=sqrt((compSpotMat(:,1)-currSpotMat(:,1)).^2+(compSpotMat(:,2)-currSpotMat(:,2)).^2);
                minDistVec=compSpotMat(:,3)+currSpotMat(:,3);
                if sum(minDistVec>distanceVec)==0
                    spotMatrix(spotCount,:,i)=currSpot;
                    spotCount=spotCount+1;
                end
            end
        end
        spotMatrix=spotMatrix(:,:,2:end);
        data.spotMatrix=spotMatrix;
        
        % Make first frame
        blankFrame=ones(y_pixel,x_pixel)*gray;           % make blank frame
        [x,y]=meshgrid(1:x_pixel,1:y_pixel);             % make meshgrid
        curr_stim=blankFrame;                             % initalize frame
        spot_sign=rem(randperm(spotNum),2)*white+black; % randomize spot sign
        for j=1:spotNum
            xy_map=sqrt((x-spotMatrix(j,2,1)).^2+(y-spotMatrix(j,1,1)).^2);
            curr_stim(xy_map<=spotMatrix(j,3,1))=spot_sign(j);
        end
        
        % Start flip, Output pulse to acquisition computer
        vbl=Screen('Flip',w);
        
        
        % Animate
        for i=1:blankTime*frameRate
            % Draw image:
            Screen('DrawTexture',w,tex_blank(i));
            vbl = Screen('Flip',w,vbl+(waitframes-0.5)*ifi);
        end
        Screen('Close',tex_blank)
        for i=2:duration*tempFreq
            % Draw image
            tex_stim=Screen('MakeTexture',w,curr_stim); % make stim texture
            Screen('DrawTexture',w,tex_stim);
            vbl=Screen('Flip',w,vbl+(numFrames-0.5)*ifi);
            curr_stim=blankFrame;                             % initalize frame
            spot_sign=rem(randperm(spotNum),2)*white+black; % randomize spot sign
            for j=1:spotNum
                xy_map=sqrt((x-spotMatrix(j,2,i)).^2+(y-spotMatrix(j,1,i)).^2);
                curr_stim(xy_map<=spotMatrix(j,3,i))=spot_sign(j);
            end
            Screen('Close',tex_stim)
        end
        tex_stim=Screen('MakeTexture',w,curr_stim); % make stim texture
        Screen('DrawTexture',w,tex_stim);
        vbl=Screen('Flip',w,vbl+(numFrames-0.5)*ifi);
        Screen('Close',tex_stim)
    end
    
    %% Clean up
    Priority(0);
    Screen('CloseAll');
    stop(ai);
    
catch
    % Return in case of error
    Screen('CloseAll');
    Priority(0);
    stop(ai)
    psychrethrow(psychlasterror);
end


