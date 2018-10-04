function data = gpi_rfquickmap_v(repeats,offTime,onTime)
%% variable parameters I
if nargin==0
    repeats = 10;
    offTime = 4;
    onTime = 2;
end

nvert = 5;
nhoriz = 1;
% 2P3 0.1 ~= 8deg
total_duration = repeats*(nvert*nhoriz)*(offTime+onTime);
fprintf('Rpts: %2.0f\nOff: %2.0fs\nOn: %2.0fs\n', repeats, offTime, onTime)
fprintf ('Rf-V Protocol duration: %2.0f min \n', total_duration/60);

%% variable parameters II
xrange = [0 1];
% yrange = [0.25 0.75];
yrange = [0 1];
	
orients = [0 90 45 135];
noris = length(orients);
sfs = 0.04;%[0 (0.01)*2.^(0:7)]; %cycles per degree
tfs = 2; %cycles per second
contrasts = 1;
sine_gratings = 0; % square wave
blackblank = 0;

rects = zeros(nvert*nhoriz,4);
k = 1;
for i = 1:nvert
    for j = 1:nhoriz
		rects(k,:) = [(i-1)/nvert*diff(xrange)+xrange(1),(j-1)/nhoriz*diff(yrange)+yrange(1),...
			i/nvert*diff(xrange)+xrange(1),j/nhoriz*diff(yrange)+yrange(1)];    
		k = k+1;
	end
end

% randomize positions
order = repmat([1:nvert*nhoriz],1,repeats);
% order = randomizeStims(mfilename('fullpath'),nvert*nhoriz,repeats);

%% constant parameters
screen.keep = 1;
card.trigger_mode = 'out';   
card.id = 'Dev3';
response.mode = 0;
sound.tone_amp = 0;
presentation.frame_rate = 30;
presentation.lag = 0.03;

%% stimuli
num_stimuli = repeats*(nvert*nhoriz)*(offTime+onTime)*3;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
rect = cell(1,num_stimuli);

for i = 1:repeats*(nvert*nhoriz)
    k = (noris+1)*(i-1)+1;
	
	duration(k) = offTime;
	stim_type{k} = 'blank';
	
	duration(k+1:k+noris) = onTime/noris;
    stim_type(k+1:k+noris) = repmat({'grating'},1,noris);
    orientation(k+1:k+noris) = orients;
    spat_freq(k+1:k+noris) = sfs(mod(i-1,length(sfs))+1);
    temp_freq(k+1:k+noris) = tfs;
    contrast(k+1:k+noris) = contrasts;	
	
	% [xmin ymin ymin ymax] normalized to 1	
	rect(k+1:k+noris) = repmat({rects(order(i),:)},1,noris);
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,orientation,spat_freq,temp_freq,rect,blackblank,sine_gratings);

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
