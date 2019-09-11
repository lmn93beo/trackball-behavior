function data = gpi_rfcenter()
psychsr_go_root();
%% variable parameters

contrasts = 1;

mousecontrol = 0; % 2: complete online control
rad = [0.04];
% 2P3: 0.1 ~= 8 deg
centerpos = [0.4 0.6]; % x y from top left

gridsize = 5; % test 5x5 center locations
xdist = rad; % distance (in fraction of screen width) between each gridpoint
ydist = xdist*1920/1080;
pos_all = zeros(gridsize^2,2);
for i = 1:gridsize
	pos_all(5*(i-1)+1:5*i,1) = centerpos(1)+xdist*(i-3);
	for j = 1:gridsize
		pos_all(5*(i-1)+j,2) = centerpos(2)+ydist*(j-3);		
	end
end

repeats = 4;
offTime = 2;
onTime = 1;

orients = [0 90 45 135];
sfs = 0.04; %cycles per degree 
tfs = 2; %cycles per second
sine_gratings = 1;
  
total_duration = repeats*size(pos_all,1)*(offTime+onTime);
disp(total_duration)
%% constant parameters 
screen.keep = 1;
card.trigger_mode = 'out';   
card.id = 'Dev1';
response.mode = 0;
% response.mode = 1;
% response.punish_time = 0.2;
% response.feedback_fn = @psychsr_punish_feedback;
sound.tone_amp = 0.5;
presentation.frame_rate = 30;
presentation.lag = -0.011;

%% stimuli
noris = length(orients);
num_stimuli = repeats*(noris+1)*size(pos_all,1);

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
pos = cell(1,num_stimuli); 
radius = zeros(1,num_stimuli); 
fade = zeros(1,num_stimuli); % 0 = no fade, 1 = fade in, -1 = fade out

for i = 1:repeats*size(pos_all,1)	
	k = (noris+1)*(i-1)+1;
	duration(k) = offTime;
	stim_type{k} = 'blank';
	
	duration(k+1:k+noris) = onTime/noris;
    stim_type(k+1:k+noris) = repmat({'grating_patch'},1,noris);
    orientation(k+1:k+noris) = orients;
    spat_freq(k+1:k+noris) = sfs;
    temp_freq(k+1:k+noris) = tfs;
    contrast(k+1:k+noris) = contrasts;	
	pos(k+1:k+noris) = repmat({pos_all(mod(i-1,size(pos_all,1))+1,:)},1,noris);
	radius(k+1:k+noris) = repmat(rad,1,noris);
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,orientation,spat_freq,temp_freq,fade,sine_gratings,pos,radius,mousecontrol);
stimuli.blackblank = 0;

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);
ShowCursor;

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
