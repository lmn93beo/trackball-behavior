function trackball_draw(k,x,color)
global data
window = data.screen.window;
xCenter = data.screen.xCenter;
yCenter = data.screen.yCenter;
X_pixels = data.screen.X_pixels;
Y_pixels = data.screen.Y_pixels;
grey = data.screen.grey;
x_cm = data.screen.X_cm;
x_deg = atan(x_cm / data.params.distance_to_screen_cm) / pi * 180;
w = X_pixels;
d = data.stimuli.cursor(3);

if data.params.flashStim > 0 && data.stimuli.loc(k) < 3
    x = data.stimuli.startPos(data.stimuli.loc(k));  
    x2 = data.stimuli.startPos(3 - data.stimuli.loc(k));
end
if ~(data.stimuli.loc(k) == 3 && data.params.freeBlank)
switch data.params.stims{data.stimuli.id(k)}
    case 'square'
        
        dstCenterRect = CenterRectOnPointd(data.stimuli.cursor, xCenter+x, yCenter);
        Screen('FillRect',window,color,dstCenterRect);
        
        if data.params.simultaneous
            color2 = [1 1 1]*grey*(1-data.stimuli.opp_contrast(k));
            dstCenterRect2 = CenterRectOnPointd(data.stimuli.cursor, ...
                    xCenter+x2, yCenter);
                Screen('FillRect',window,color2,dstCenterRect2);
        end

        if data.stimuli.loc(k) == 3 % free choice
            if max(data.stimuli.id) == 1 % squares only
                
                % draw square on opposite side
                dstCenterRect2 = CenterRectOnPointd(data.stimuli.cursor, ...
                    xCenter+x+data.stimuli.startPos(1)*2, yCenter);
                Screen('FillRect',window,color,dstCenterRect2);
                % cover up rectangles that go beyond start point
                Screen('FillRect',window,grey,[0 0 (w-d)/4 Y_pixels])
                Screen('FillRect',window,grey,[w-(w-d)/4 0 w Y_pixels])
                
            else
                % draw diamond on opposite side (right)
                diamondcenter = data.stimuli.diamond+repmat([xCenter+x+data.stimuli.startPos(1)*2 0],4,1);
                if data.params.whitediamond                
                    Screen('FillPoly',window,255-color,diamondcenter);
                else
                    Screen('FillPoly',window,color,diamondcenter);
                end
                % cover up rectangles that go beyond start point
                Screen('FillRect',window,grey,[0 0 (w-d)/4 Y_pixels])
                dx = d*(1+sqrt(2))/2 + x*(d*(1+4*sqrt(2))-w)/(w-d);
                Screen('FillRect',window,grey,[w-dx 0 w Y_pixels])
            end
        end
        
    case 'diamond'
        
        diamondcenter = data.stimuli.diamond+repmat([xCenter+x 0],4,1);
        if data.params.whitediamond
            Screen('FillPoly',window,255-color,diamondcenter);
        else
            Screen('FillPoly',window,color,diamondcenter);
        end
        
        if data.stimuli.loc(k) == 3 % free choice
            
            % draw square on opposite side (right)
            dstCenterRect2 = CenterRectOnPointd(data.stimuli.cursor, ...
                xCenter+x+data.stimuli.startPos(1)*2, yCenter);
            Screen('FillRect',window,color,dstCenterRect2);
            % cover up rectangles that go beyond start point
            dx = (x+(w-d)/4)*(d*(1+4*sqrt(2))-w)/(d-w)+(w+d*(1-2*sqrt(2)))/4;
            Screen('FillRect',window,grey,[0 0 dx Y_pixels])            
            Screen('FillRect',window,grey,[w-(w-d)/4 0 w Y_pixels])
        end
    case 'grating'
        srcCenterRect = CenterRectOnPointd(data.stimuli.cursor, xCenter, yCenter);
        dstCenterRect = CenterRectOnPointd(data.stimuli.cursor, xCenter+x, yCenter);
        if data.stimuli.loc(k) == 2
            ori = 90;
        else
            ori = 0;
        end            
        spf = 0.2;
        tf = 2;
        driftFlag = 0;
        
        if driftFlag
            pha = mod((now-data.response.start_time)*86400-data.response.trialstart(k),1/tf)*tf*360; % drifting
            con = 1;
        else
            pha = 0;
            con = 1; %sin(mod((now-data.response.start_time)*86400-data.response.trialstart(k),2/tf)*tf*pi);
        end        
        
        pixels_per_degree = X_pixels / x_deg;
        spf = spf/pixels_per_degree;        
        % adjust spf for non-square pixels
        o = ori*pi/180;
        spf = spf*(1*abs(cos(o))+data.screen.ff*abs(sin(o)))./(abs(cos(o))+abs(sin(o)));
        
        Screen('DrawTexture',window,data.stimuli.grating_tex,srcCenterRect,dstCenterRect,ori,[],[],[],...
            [],kPsychUseTextureMatrixForRotation,[pha; spf; con; 0]);
        
        if data.stimuli.loc(k) == 3
            % draw grating on opposite side
            dstCenterRect2 = CenterRectOnPointd(data.stimuli.cursor, ...
                xCenter+x+data.stimuli.startPos(1)*2, yCenter);
            Screen('DrawTexture',window,data.stimuli.grating_tex,srcCenterRect,dstCenterRect2,ori,[],[],[],...
                [],kPsychUseTextureMatrixForRotation,[pha; spf; con; 0]);
            % cover up rectangles that go beyond start point
            Screen('FillRect',window,grey,[0 0 (w-d)/4 Y_pixels])
            Screen('FillRect',window,grey,[w-(w-d)/4 0 w Y_pixels])
        end
        
    case 'gabor'
        srcCenterRect = CenterRectOnPointd(data.stimuli.cursor, xCenter, yCenter);
        dstCenterRect = CenterRectOnPointd(data.stimuli.cursor, xCenter+x, yCenter);
        
        gaborDimPix = X_pixels / 2;
        % Sigma of Gaussian
        dist = data.params.distance_to_screen_cm;
        sigma_cm = tan(data.params.gaborSigmaDeg / 180 * pi) * dist;
        sigma_pix = sigma_cm / data.screen.X_cm * data.screen.X_pixels;
        sigma = sigma_pix; %sigma_cm / data.screen.X_cm * data.screen.X_pixels;
        
        % Spatial Frequency (Cycles Per Pixel)
        % One Cycle = Grey-Black-Grey-White-Grey i.e. One Black and One White Lobe
        freq = data.params.gaborCyclesPerDeg * data.params.gaborSigmaDeg / sigma_pix;
        
        % Obvious Parameters
        orientation = 0;
        contrast = data.stimuli.contrast(k);
        aspectRatio = 1.0;
        phase = data.stimuli.phases(k);
        
        % Randomise the phase of the Gabors and make a properties matrix.
        propertiesMat = [phase, freq, sigma, contrast, aspectRatio, 0, 0, 0];
        %         if data.stimuli.loc(k) == 2
%             ori = 90;
%         else
%             ori = 0;
%         end            
%         spf = 0.2;
%         tf = 2;
%         driftFlag = 0;
%         
%         if driftFlag
%             pha = mod((now-data.response.start_time)*86400-data.response.trialstart(k),1/tf)*tf*360; % drifting
%             con = 1;
%         else
%             pha = 0;
%             con = 1; %sin(mod((now-data.response.start_time)*86400-data.response.trialstart(k),2/tf)*tf*pi);
%         end        
%         
%         pixels_per_degree = X_pixels / x_deg;
%         spf = spf/pixels_per_degree;        
%         % adjust spf for non-square pixels
%         o = ori*pi/180;
%         spf = spf*(1*abs(cos(o))+data.screen.ff*abs(sin(o)))./(abs(cos(o))+abs(sin(o)));
%         
        Screen('DrawTextures',window,data.stimuli.gabor_tex,[],dstCenterRect,orientation,[],[],[],...
            [],kPsychDontDoRotation,propertiesMat');
        
    
end
end