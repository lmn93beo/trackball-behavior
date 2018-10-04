function [data,flip_t]=mouseTV(stimType,saveFlag)
% Displays visual stimulus for measuring response properties of neurons
% Original: MG 11/18/10, Latest update: MG 11/18/10
%
% Currently supported Stimulus Types:
%
% checkerboard - Display alternating checkerboard pattern
%                generates transient responses while maintaining mean
%                luminence and contrast
% gratings     - Display drifting gratings of different orientations
%                used for measuring orientation tuning
% sparseNoise  - Display sparse noise (white/black dots on grey background)
%                used for measuring spatial receptive fields
%
% To be added:
%
% naturalMov   - Displays pre-generated natural movies
%                used for measuring more complex stimulus properties
% spatialFreq  - Displays gratings of different spatial frequency
%                used for measuring spatial frequency tuning
% temporalFreq - Displays gratings of different temporal frequency
%                used for measuring temporal frequency tuning

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

%% Stimulus Type
if strcmp(stimType,'checkerboard')
    
    %% Alternating checkerboard
    
    % User inputs
    repeats=20;                % Number of times to alternate checkerboard
    altPeriod=2;                % Period of checkerboard alternations (Sec)
    numChecks=8;                % Number of squares in checkerboard (vertical dimension)
    blankTime=2;                % Length of blank frames before stimulus (in seconds)
    
    % Save data
    data.stimType='checkerboard';
    data.blankTime=blankTime;
    data.period=altPeriod;
    data.repeats=repeats;
	
elseif strcmp(stimType,'RFmap')
	
    %% RF mapping using 1D noise
	
	% User Inputs
    repeats=3;                    % Number of times to run all orientations
    onTime=2;                     % Grating display time
    offTime=2;                    % Length of blanks between gratings
	x_pos_num=6;                  % number of positions to test in x dimension
	y_pos_num=6;                  % number of positions to test in y dimension
    orientation_list=[0,90];      % List of orientations to test
    spatFreq=0.04;                % Spatial frequency (cycles/deg)
    tempFreq=2;                   % Temporal frequency (cycles/sec)
    
    % Determine orientations, make stimulus vector for analysis
	x_pos_list=[1:x_pos_num]; y_pos_list=[1:y_pos_num];
    for i=1:repeats     % Create random stimulus vector
        x_pos(i,:)=randperm(x_pos_num);
		y_pos(i,:)=randperm(y_pos_num);
    end
    
    % Determine spatial frequency
    pixel_pitch=mean([x_length/x_pixel y_length/y_pixel]);   % in cm/pixel
    degPerPixel=pixel_pitch*1/(tan(pi/180)*monitorDistance); % in deg/pixel
    f=spatFreq*degPerPixel*2*pi;         % spatial freq in cycles per pixel
	
	% Determine number of pixels for x and y widths
	x_bar_width=round(x_pixel/x_pos_num);
	y_bar_width=round(y_pixel/y_pos_num);
    
    % Make stimulus vector for later analysis
    % each value corresponds to x or y position being tested at that time (sec) 
    stimulusVec_x=[]; stimulusVec_y=[]; 
	x_pos_t=x_pos'; y_pos_t=y_pos';
    for i=1:repeats*x_pos_num
        stimulusVec_x=[stimulusVec_x zeros(1,offTime) x_pos_t(i)*ones(1,onTime) zeros(1,onTime+offTime)];
		stimulusVec_y=[stimulusVec_y zeros(1,2*offTime+onTime) y_pos_t(i)*ones(1,onTime)];
    end
    
    % determine number of frames and interim times
    numFrames=floor(frameRate/tempFreq); % Temporal period of the drifting grating (in frames)
	interim_time=1-numFrames*frameRate;  % interval to wait after stimulus to ensure second timing
	
	% Blank interval
    blankFrames=ceil(offTime*frameRate)+50;
    blankIndices=mod(0:(blankFrames-1),numFrames)+1;
    
    % Determine frame indices
    stimFrames=ceil(onTime*frameRate)+50;
    stimIndices=mod(0:(stimFrames-1),numFrames)+1;
    
    % Save data
    data.stimType='RFmap';
    data.onTime=onTime;
    data.offTime=offTime;
    data.spatialFreq=spatFreq;
    data.temporalFreq=tempFreq;
	data.xPos=x_pos;
	data.yPos=y_pos;
    data.stimulusVecX=stimulusVec_x;
	data.stimulusVecY=stimulusVec_y;
	
	
elseif strcmp(stimType,'gratings')
    
    %% Drifting Gratings
    
    % User Inputs
    repeats=3;                    % Number of times to run all orientations
    onTime=2;                     % Grating display time
    offTime=2;                    % Length of blanks between gratings
    orientation_list=[0:30:330];  % List of orientations to test
    spatFreq=0.04;                % Spatial frequency (cycles/deg)
    tempFreq=2;                   % Temporal frequency (cycles/sec)
    
    % Determine orientations, make stimulus vector for analysis
    for i=1:repeats     % Create random stimulus vector
        orientations(i,:)=orientation_list(randperm(length(orientation_list)));
    end
    
    % Determine spatial frequency
    pixel_pitch=mean([x_length/x_pixel y_length/y_pixel]);   % in cm/pixel
    degPerPixel=pixel_pitch*1/(tan(pi/180)*monitorDistance); % in deg/pixel
    f=spatFreq*degPerPixel*2*pi;         % spatial freq in cycles per pixel
    
    % Make stimulus vector for later analysis
    % each value corresponds to orientation at that time in sec (blank = -1)
    stimulusVector=[]; ori_transpose=orientations';
    for i=1:repeats*length(orientation_list)
        stimulusVector=[stimulusVector -1*ones(1,offTime) ori_transpose(i)*ones(1,onTime)];
    end
    
    % determine number of frames and interim times
    numFrames=floor(frameRate/tempFreq); % Temporal period of the drifting grating (in frames)
	interim_time=1-numFrames*frameRate;  % interval to wait after stimulus to ensure second timing
	
	% Blank interval
    blankFrames=ceil(offTime*frameRate)+50;
    blankIndices=mod(0:(blankFrames-1),numFrames)+1;
    
    % Determine frame indices
    stimFrames=ceil(onTime*frameRate)+50;
    stimIndices=mod(0:(stimFrames-1),numFrames)+1;
    
    % Save data
    data.stimType='gratings';
    data.onTime=onTime;
    data.offTime=offTime;
    data.spatialFreq=spatFreq;
    data.temporalFreq=tempFreq;
    data.orientations=orientations;
    data.stimulusVector=stimulusVector;
    
elseif strcmp(stimType,'sparseNoise')
    
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
    
else disp('stimType not recognized')
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
    w=Screen('OpenWindow',screenNumber,black);
    [ifi]=Screen('GetFlipInterval',w,100,0.0001,20);
    
    % Use realtime priority for better timing precision:
	priorityLevel=MaxPriority(w);
	Priority(priorityLevel);
	
	%% Animate textures
	if strcmp(stimType,'checkerboard')
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
		for i=1:round(frameRate*blankTime)
			tex_blank(i)=Screen('MakeTexture',w,gray); % blank texture
		end
		% Draw stim texture (long enough for two alternations)
		for i=1:round(frameRate*altPeriod*2)
			tex_stim(i)=Screen('MakeTexture',w,template); % blank texture
			% reverse checkerboard at appropriate time points
			if rem(i,round(frameRate*altPeriod))==0
				template(template==0)=-1;
				template(template==white)=0;
				template(template==-1)=white;
			end
		end
		
		% Start flip, Output pulse to acquisition computer
		vbl=Screen('Flip',w);
		
		
		% Animate
		for i=1:round(frameRate*blankTime)
			% Draw image:
			Screen('DrawTexture', w, tex_blank(i));
			vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
		end
		for repeatNumber=1:round(repeats/2)
			for i=1:round(frameRate*altPeriod*2)
				% Draw image
				Screen('DrawTexture',w,tex_stim(i));
				vbl=Screen('Flip',w,vbl+(waitframes-0.5)*ifi);
			end
		end
		Screen('Close',tex_blank)
		Screen('Close',tex_stim)
		
	elseif strcmp(stimType,'RFmap')
		
		%% Make grating textures
		[x,y]=meshgrid(1:x_pixel,1:y_pixel);
		% Draw blank texture
		for i=1:numFrames
			tex_blank(i)=Screen('MakeTexture',w,gray); % blank texture
		end
		% Draw stim texture
		for j=1:length(x_pos_list)
			for i=1:numFrames
				phase=(i/numFrames)*2*pi;
				angle=orientation_list(2)*pi/180; % set orientation
				a=cos(angle)*f;
				b=sin(angle)*f;
				m_x=sin(a*x+b*y-phase);
				angle=orientation_list(1)*pi/180; % set orientation
				a=cos(angle)*f;
				b=sin(angle)*f;
				m_y=sin(a*x+b*y-phase);
				% confine grating to bar corresponding to x position
				bar_template=zeros(y_pixel,x_pixel);
				bar_template(:,round((x_pos_list(j)-1)*x_bar_width)+1:floor(x_pos_list(j)*x_bar_width))=1;
				background_x=black+gray*bar_template;
				m_x=m_x.*bar_template;
				bar_template=zeros(y_pixel,x_pixel);
				bar_template(round((y_pos_list(j)-1)*y_bar_width)+1:floor(y_pos_list(j)*y_bar_width),:)=1;
				background_y=black+gray*bar_template;
				m_y=m_y.*bar_template;
				% draw stim textures 
				tex_stim_x((j-1)*numFrames+i)=Screen('MakeTexture',w,background_x+inc*m_x); % stim texture
				tex_stim_y((j-1)*numFrames+i)=Screen('MakeTexture',w,background_y+inc*m_y); % stim texture
			end
		end
		
		%% Animate
		lag=0.03; % lag between stimulus and acquisition computers (calculated empirically)
		dio=digitalio('nidaq','Dev3');
		addline(dio,0:7,1,'out');       % create 8 output lines on Port 1 of DIO
		% flip_t is a vector of presentation times, computed immediately after eachflip
		flip_t=zeros(1,round(frameRate*(onTime+offTime)*repeats*length(orientation_list))+1); count=1;
		disp('Stimulus On');
		vbl=Screen('Flip',w);
		for i=1:5
			putvalue(dio.Line(1),1);       % put the trigger pulse
		end
		putvalue(dio.Line(1),0);       % put the trigger pulse
		clear('dio');
		tStart=tic;
		for repeatNumber=1:repeats
			repTime=(repeatNumber-1)*(2*(onTime+offTime))*length(x_pos_list);
			for posNumber=1:length(x_pos_list)
				posTime=(posNumber-1)*2*(onTime+offTime);
				posIndex_x=find(x_pos_list==x_pos(repeatNumber,posNumber));
				posIndex_y=find(y_pos_list==y_pos(repeatNumber,posNumber));
				currIndex=1;
				while (toc(tStart)-repTime-posTime+lag)<offTime
					% Draw image:
					Screen('DrawTexture',w,tex_blank(blankIndices(currIndex)));
					vbl = Screen('Flip',w,vbl + (waitframes - 0.5) * ifi);
					flip_t(count)=toc(tStart); count=count+1;
					currIndex=currIndex+1;
				end
				currIndex=1;
				while (toc(tStart)-repTime-posTime-offTime+lag)<onTime
					% Draw image
					Screen('DrawTexture',w,tex_stim_x((posIndex_x-1)*numFrames+stimIndices(currIndex)));
					vbl=Screen('Flip',w,vbl+(waitframes-0.5)*ifi);
					flip_t(count)=toc(tStart); count=count+1;
					% move grating both directions
					if (toc(tStart)-repTime-posTime-offTime+lag)<=ceil(onTime/2)
						currIndex=currIndex+1;
					else currIndex=max(currIndex-1,1);
					end
				end
				currIndex=1;
				while (toc(tStart)-repTime-posTime-offTime-onTime+lag)<offTime
					% Draw image:
					Screen('DrawTexture',w,tex_blank(blankIndices(currIndex)));
					vbl = Screen('Flip',w,vbl + (waitframes - 0.5) * ifi);
					flip_t(count)=toc(tStart); count=count+1;
					currIndex=currIndex+1;
				end
				currIndex=1;
				while (toc(tStart)-repTime-posTime-2*offTime-onTime+lag)<onTime
					% Draw image
					Screen('DrawTexture',w,tex_stim_y((posIndex_y-1)*numFrames+stimIndices(currIndex)));
					vbl=Screen('Flip',w,vbl+(waitframes-0.5)*ifi);
					flip_t(count)=toc(tStart); count=count+1;
					% move grating both directions
					if (toc(tStart)-repTime-posTime-2*offTime-onTime+lag)<=ceil(onTime/2)
						currIndex=currIndex+1;
					else currIndex=max(currIndex-1,1);
					end
				end
			end
		end
		toc(tStart)
		% calculate missed flips
		tolerance=0.0001; % tolerance in sec
		flip_t=flip_t(find(flip_t~=0));
		data.flip_t=flip_t;
		isi=flip_t(2:end)-flip_t(1:end-1);
		if sum(isi<mean(isi)-tolerance | isi>mean(isi)+tolerance)>1
			disp('WARNING: One or more interflip intervals was greater than tolerance')
		end
		% clean up
		Screen('Close',tex_blank)
		Screen('Close',tex_stim_x)
		Screen('Close',tex_stim_y)
        
    elseif strcmp(stimType,'gratings')
        
        %% Make grating textures
        [x,y]=meshgrid(1:x_pixel,1:y_pixel);
        % Draw blank texture
        for i=1:numFrames
            tex_blank(i)=Screen('MakeTexture',w,gray); % blank texture
        end
        % Draw stim texture
        for j=1:length(orientation_list)
            for i=1:numFrames
                phase=(i/numFrames)*2*pi;
                angle=orientation_list(j)*pi/180; % set orientation
                a=cos(angle)*f;
                b=sin(angle)*f;
                m=sin(a*x+b*y+phase);
                tex_stim((j-1)*numFrames+i)=Screen('MakeTexture',w,gray+inc*m); % stim texture
            end
		end
        
        %% Animate
		lag=0.03; % lag between stimulus and acquisition computers (calculated empirically)
		dio=digitalio('nidaq','Dev3');
		addline(dio,0:7,1,'out');       % create 8 output lines on Port 1 of DIO
		% flip_t is a vector of presentation times, computed immediately after eachflip
		flip_t=zeros(1,round(frameRate*(onTime+offTime)*repeats*length(orientation_list))+1); count=1;
		disp('Stimulus On');
		vbl=Screen('Flip',w);
		for i=1:5
			putvalue(dio.Line(1),1);       % put the trigger pulse
		end
		putvalue(dio.Line(1),0);       % put the trigger pulse
		clear('dio');
		tStart=tic;
        for repeatNumber=1:repeats
			repTime=(repeatNumber-1)*(onTime+offTime)*length(orientation_list);
            for oriNumber=1:length(orientation_list)
				oriTime=(oriNumber-1)*(onTime+offTime);
                oriIndex=find(orientation_list==orientations(repeatNumber,oriNumber));
				currIndex=1; 
				while (toc(tStart)-repTime-oriTime+lag)<offTime
					% Draw image:
					Screen('DrawTexture',w,tex_blank(blankIndices(currIndex)));
                    vbl = Screen('Flip',w,vbl + (waitframes - 0.5) * ifi);
					flip_t(count)=toc(tStart); count=count+1;
					currIndex=currIndex+1;
				end
				currIndex=1;
				while (toc(tStart)-repTime-oriTime-offTime+lag)<onTime
                    % Draw image
					Screen('DrawTexture',w,tex_stim((oriIndex-1)*numFrames+stimIndices(currIndex)));
					vbl=Screen('Flip',w,vbl+(waitframes-0.5)*ifi);
					flip_t(count)=toc(tStart); count=count+1;
					currIndex=currIndex+1;
				end
            end
		end
		toc(tStart)
		% calculate missed flips
		tolerance=0.0001; % tolerance in sec
		flip_t=flip_t(find(flip_t~=0));
		data.flip_t=flip_t;
		isi=flip_t(2:end)-flip_t(1:end-1);
		if sum(isi<mean(isi)-tolerance | isi>mean(isi)+tolerance)>1
			disp('WARNING: One or more interflip intervals was greater than tolerance')
		end
		% clean up
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
	
	%% Save data
	if nargin==1; saveFlag=1; end
	if saveFlag==1
		C=clock;
		if C(2)<10; month=['0' num2str(C(2))]; else month=num2str(C(2));end
		if C(3)<10; day=['0' num2str(C(3))]; else day=num2str(C(3));end
		dirname=[num2str(C(1)) month day];
		try cd('C:\Data\mikeData')
		end
		try cd(dirname)
		catch mkdir(dirname); cd(dirname)
		end
		if C(4)<10; hour=['0' num2str(C(4))]; else hour=num2str(C(4));end
		if C(5)<10; minute=['0' num2str(C(5))]; else minute=num2str(C(5));end
		if round(C(6))<10; second=['0' num2str(round(C(6)))]; else second=num2str(round(C(6)));end
		filename=['data_' hour minute second];
		eval(['save ' filename ' data'])
	end
	
catch
    % Return in case of error
    Screen('CloseAll');
    Priority(0);
    psychrethrow(psychlasterror);
end


