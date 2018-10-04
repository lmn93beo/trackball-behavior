% measure size tuning at 2 contrasts, 
% contrast tuning in 3 conditions
% each stim has 4 orientations

function data = gpi_consize()
psychsr_go_root();
%% variable parameters
centerpos = [0.55 0.6]; % x y from top left
mousecontrol = 0;

contrasts = [0	0.03125 0.0625 0.125 0.25 0.5 1];
rads =		[0.02 0.04 0.08 0.16 0.25 0.4 Inf];
% 2P3: 0.1 ~= 7 deg
types = {'grating_patch','grating_annulus'};

c = length(contrasts);
r = length(rads);
low = 4; %12%
cen = 3; %0.08
ann = 6; %0.25

%         sizeHC      sizeLC		blank conCenter			conFF		    conAnnulus
con_id = [c*ones(1,r) low*ones(1,r)    1  setxor(2:c-1,low) setxor(2:c-1,low) 1:c-1	   ];
rad_id = [1:r 			1:r 		 r	cen*ones(1,c-3)	  r*ones(1,c-3)     ann*ones(1,c-1)];
typ_id = [1*ones(1,r) 1*ones(1,r)    1  1*ones(1,c-3)     1*ones(1,c-3 )    2*ones(1,c-1)];

repeats = 4;
offTime = 4;
onTime = 2;

orients = 90;%[0 90 45 135];
sfs = 0.04; %cycles per degree 
tfs = 2; %cycles per second
sine_gratings = 1;

order = randomizeStims(mfilename('fullpath'),length(con_id),repeats);

total_duration = repeats*length(con_id)*(offTime+onTime);
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
num_stimuli = repeats*(noris+1)*length(con_id);

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
pos = cell(1,num_stimuli); 
radius = zeros(1,num_stimuli); 
fade = zeros(1,num_stimuli); % 0 = no fade, 1 = fade in, -1 = fade out

for i = 1:repeats*length(con_id)	
	k = (noris+1)*(i-1)+1;
	duration(k) = offTime;
	stim_type{k} = 'blank';
	
	duration(k+1:k+noris) = onTime/noris;
    stim_type(k+1:k+noris) = repmat(types(typ_id(order(i))),1,noris);
    orientation(k+1:k+noris) = orients;
    spat_freq(k+1:k+noris) = sfs;
    temp_freq(k+1:k+noris) = tfs;
    contrast(k+1:k+noris) = contrasts(con_id(order(i)));	
	pos(k+1:k+noris) = repmat({centerpos},1,noris);
	radius(k+1:k+noris) = rads(rad_id(order(i)));
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
