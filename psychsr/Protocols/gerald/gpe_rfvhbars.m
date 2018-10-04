function data = gpe_rfvhbars()
%% variable parameters
repeats = 20;
offTime = 0.3;
onTime = 0.2;

nvert = 14;
nhoriz = 8;
% 2P3 0.1 ~= 8deg

sfs = 0;
tfs = [2];%; -2];	
contrasts = 1;
blackblank = 0;
sine_gratings = 1;

rects = zeros(nvert+nhoriz,4);
orients = [90*ones(nvert,1);zeros(nhoriz,1)];
for i = 1:nvert
    rects(i,:) = [(i-1)/nvert,0,i/nvert,1];    
end
for j = 1:nhoriz
    rects(j+nvert,:) = [0,(j-1)/nhoriz,1,j/nhoriz];
end

% randomize positions
order = randomizeStims(mfilename('fullpath'),nvert+nhoriz,repeats);

total_duration = repeats*(nvert+nhoriz)*(offTime+onTime);
total_duration
%% constant parameters
screen.keep = 1;
card.trigger_mode = 'out';   
card.id = 'Dev3';
response.mode = 0;
sound.tone_amp = 0;
presentation.frame_rate = 30;
presentation.lag = 0.03;

%% stimuli
num_stimuli = repeats*(nvert+nhoriz)*(offTime+onTime)*3;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
rect = cell(1,num_stimuli);

for i = 1:repeats*(nvert+nhoriz)
%     idx = mod(i-1,length(order))+1;
    
	duration(i*3-2) = offTime;
	stim_type{i*3-2} = 'blank';
	
	duration(i*3-1:i*3) = onTime/2;
    stim_type(i*3-1:i*3) = {'fillrect','fillrect'};%{'grating','grating'};
    orientation(i*3-1:i*3) = orients(order(i));
    spat_freq(i*3-1:i*3) = sfs;
    temp_freq(i*3-1:i*3) = tfs;
    contrast(i*3-1:i*3) = contrasts;	
	% [xmin ymin ymin ymax] normalized to 1	
    rect{i*3-1} = rects(order(i),:);
	rect{i*3} = rect{i*3-1};
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,orientation,spat_freq,temp_freq,rect,blackblank,sine_gratings);

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
