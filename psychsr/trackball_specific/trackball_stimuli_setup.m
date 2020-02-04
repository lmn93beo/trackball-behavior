function trackball_stimuli_setup
global data
screen = data.screen; struct_unzip(screen);

%x = X_pixels*0.2; % set cursor size to be 1/5 of screen width

% Set cursor file to be 10 degrees
dist = data.params.distance_to_screen_cm;
cursor_cm = tan(data.params.cursor_size_deg / 180 * pi) * dist;
x = cursor_cm / X_cm * X_pixels;
y = x/ff;

startPosCenterCm = tan(data.params.startPosDeg / 180 * pi) * dist;
startPosCenterPix = startPosCenterCm / X_cm * X_pixels;


if data.params.lever>0
    data.stimuli.cursor = [0 0 X_pixels Y_pixels];
    data.stimuli.startPos = 0*[1 -1 -1];
    data.stimuli.stopPos = 0*[1 -1];
    
%     data.response.mvmt_volts_per_mm = 0.1;
%     data.response.gain = data.stimuli.startPos(1)...
%         ./data.response.mvmt_volts_per_mm./data.params.threshold;    
    
else
    data.stimuli.cursor = [0 0 x y];
    data.stimuli.startPos = startPosCenterPix * [1 -1 -1]; %(X_pixels-x)/4*[1 -1 -1];
    data.stimuli.stopPos = startPosCenterPix * 2 * [1 -1];%(X_pixels-x)/2*[1 -1];
    
    load trackball_calibration;
    id = find(strcmp(getenv('computername'),{params.pc}), 1);
    if isempty(id)
        disp('PC not recognized, please quit and calibrate trackball.')
        data.response.mvmt_degrees_per_pixel = 3/20;
    else
        data.response.mvmt_degrees_per_pixel = params(id).cal;
    end
        
    data.response.gain = (data.stimuli.startPos(1)...
        .*data.response.mvmt_degrees_per_pixel)./data.params.threshold;
end

dwidth = sqrt(2)*x/2;
data.stimuli.diamond = [-dwidth, yCenter; ...
    0, yCenter+dwidth/ff; ...
    dwidth, yCenter; ...    
    0, yCenter-dwidth/ff];


bg_color_offset = [0.5, 0.5, 0.5, 1];
bg_offset_gabor = [0.5, 0.5, 0.5, 0.0];
disableNorm = 1;
contrast_multiplier = 1; %0.5;
radius = []; % full screen grating
data.stimuli.grating_tex = CreateProceduralSineGrating(screen.window,X_pixels,Y_pixels,...
    bg_color_offset,radius,contrast_multiplier);

% 2.3.20: used to be X_pixels/2, X_pixels/2 for both dimensions
data.stimuli.gabor_tex = CreateProceduralGabor(screen.window,ceil(x),ceil(y),...
    [], bg_offset_gabor, disableNorm, contrast_multiplier);
