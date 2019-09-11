function dotInfo = psychsr_drawdots(loop,win,dotInfo)
global data

if ~isfield(data.stimuli,'dotsets')
    dotsets = 1;
else
    dotsets = data.stimuli.dotsets;
end

% persistent ss loopi dxdy Ls ndots coh d_ppd center dotSize w h
% if loop.frame==1     
%     clearvars ss loopi dxdy Ls ndots coh d_ppd center dotSize w h
% end

if (loop.frame-loop.new_stim)==0
    
    % Variables sent to rex have been multiplied by a factor of 10 to make sure 
    % they are integers. Now convert them back so that they are correct for plotting.
    coh = dotInfo.coh;	% dotInfo.coh is specified in range 0..1000 (because of
                            % rex need integers), but we want in range 0..1
    apD = dotInfo.apXYD(:,3); % diameter of aperture
    
    w = data.screen.width_pixels; h = data.screen.height_pixels;
    center(1) = w/2; center(2) = h/2; 
%     center = repmat(screenInfo.center,size(dotInfo.apXYD(:,1)));
% 
%     % Change x,y coordinates to pixels (y is inverted - pos on bottom, neg. on top)
%     center = [center(:,1) + dotInfo.apXYD(:,1)/10*screenInfo.ppd center(:,2) - ...
%         dotInfo.apXYD(:,2)/10*screenInfo.ppd]; % where you want the center of the aperture
%     center(:,3) = dotInfo.apXYD(:,3)/2/10*screenInfo.ppd; % add diameter
%     d_ppd = floor(apD/10 * screenInfo.ppd);	% size of aperture in pixels
    d_ppd = max([w h]);
    dotSize = dotInfo.dotSize; % probably better to leave this in pixels, but not sure

    % ndots is the number of dots shown per video frame. Dots will be placed in a 
    % square of the size of aperture.
    % - Size of aperture = Apd*Apd/100  sq deg
    % - Number of dots per video frame = 16.7 dots per sq deg/sec,
    % When rounding up, do not exceed the number of dots that can be plotted in a 
    % video frame (dotInfo.maxDotsPerFrame). maxDotsPerFrame was originally in 
    % setupScreen as a field in screenInfo, but makes more sense in createDotInfo as 
    % a field in dotInfo.
%     ndots = min(dotInfo.maxDotsPerFrame, ...
%         ceil(16.7 * apD .* apD * 0.01 / data.presentation.frame_rate));
    ndots = dotInfo.maxDotsPerFrame;
    if ndots ==0; ndots = 1; end;
    
    % Don't worry about pre-allocating, the number of dot fields should never be 
    % large enough to cause memory problems.
    for df = 1 : dotInfo.numDotField
        % dxdy is an N x 2 matrix that gives jumpsize in units on 0..1
        %   deg/sec * ap-unit/deg * sec/jump = ap-unit/jump
               
        dxdy{df} = repmat((dotInfo.speed(df)) * (1/data.screen.width_degrees) *...
                (dotsets/data.presentation.frame_rate) * [cos(pi*dotInfo.dir(df)/180.0), ...
                -sin(pi*dotInfo.dir(df)/180.0)], ndots(df),1);    
        
        if ndots > 1
            ss{df} = rand(ndots(df)*dotsets, 2); % array of dot positions raw [x,y]
        else
            ss{df} = [0 0.5];
        end
        % Divide dots into three sets
        Ls{df} = cumsum(ones(ndots(df),dotsets)) + repmat(ndots(df)*(0:dotsets-1), ... 
            ndots(df), 1);
        loopi(df) = 1; % loops through the three sets of dots
    end
else
    
    ss = dotInfo.ss;
    loopi = dotInfo.loopi;
    dxdy = dotInfo.dxdy;
    Ls = dotInfo.Ls;
    ndots = dotInfo.ndots;
    coh = dotInfo.coh;
    d_ppd = dotInfo.d_ppd;
    center = dotInfo.center;
    dotSize = dotInfo.dotSize;
    w = dotInfo.w;
    h = dotInfo.h;
    
end


%% update parameters
for df = 1 : dotInfo.numDotField
      % Lthis has the dot positions from 3 frames ago, which is what is then
    Lthis{df}  = Ls{df}(:,loopi(df));
    
    % Moved in the current loop. This is a matrix of random numbers - starting
    % positions of dots not moving coherently.
    this_s{df} = ss{df}(Lthis{df},:);
    
    % Update the loop pointer
    loopi(df) = mod(loopi(df)+1,dotsets)+1;
        
    % Compute new locations, how many dots move coherently
    L = rand(ndots(df),1) < coh(df);
    % Offset the selected dots
    this_s{df}(L,:) = bsxfun(@plus,this_s{df}(L,:),dxdy{df}(L,:));
    
    if sum(~L) > 0
        this_s{df}(~L,:) = rand(sum(~L),2);	% get new random locations for the rest
    end
    
    % Check to see if any positions are greater than 1 or less than 0 which
    % is out of the square aperture, and replace with a dot along one of the
    % edges opposite from the direction of motion.
    N = sum((this_s{df} > 1 | this_s{df} < 0)')' ~= 0;
    
    if sum(N) > 0
        xdir = sin(pi*dotInfo.dir(df)/180.0);
        ydir = cos(pi*dotInfo.dir(df)/180.0);
        % Flip a weighted coin to see which edge to put the replaced dots
        if rand < abs(xdir)/(abs(xdir) + abs(ydir))                        
%             this_s{df}(find(N==1),:) = [rand(sum(N),1),(xdir > 0)*ones(sum(N),1)];
            this_s{df}(N,:) = [rand(sum(N),1),mod(this_s{df}(N,2),1)]; 
        else
%             this_s{df}(find(N==1),:) = [(ydir < 0)*ones(sum(N),1),rand(sum(N),1)];
            this_s{df}(find(N==1),:) = [mod(this_s{df}(N,1),1),rand(sum(N),1)];
        end
        
        if ndots == 1
            this_s{df}(:,2) = 0.5;
        end
    end
    
    % Convert for plot
    this_x{df} = floor(d_ppd(df) * this_s{df});	% pix/ApUnit
    
    % It assumes that 0 is at the top left, but we want it to be in the
    % center, so shift the dots up and left, which means adding half of the
    % aperture size to both the x and y directions.
    dot_show{df} = (this_x{df} - d_ppd(df)/2)';
    
    % Update the dot position array for the next loop
    ss{df}(Lthis{df}, :) = this_s{df};
end

%% draw
for df = 1:dotInfo.numDotField
    % NaN out-of-circle dots
%     xyDis = dot_show{df};
%     outCircle = sqrt(xyDis(1,:).^2 + xyDis(2,:).^2) + dotInfo.dotSize/2 > center(df,3);
%     outCircle = abs(dot_show{df}(1,:))>w/2 | abs(dot_show{df}(2,:))>h/2;
    dots2Display = dot_show{df};
%     dots2Display(:,outCircle) = NaN;
    
    Screen('DrawDots',win,dots2Display,dotSize,dotInfo.dotColor,center);
end

dotInfo.ss = ss;
dotInfo.loopi = loopi;
dotInfo.dxdy = dxdy;
dotInfo.Ls = Ls;
dotInfo.ndots = ndots;
dotInfo.coh = coh;
dotInfo.d_ppd = d_ppd;
dotInfo.center = center;
dotInfo.dotSize = dotSize;
dotInfo.w = w; 
dotInfo.h = h;