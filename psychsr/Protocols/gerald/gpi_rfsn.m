function data = gpi_rfsn()
%% variable parameters
repeats = 18;
offTime = 1/3-0.2;
onTime = 0.2;

nvert = 14;
nhoriz = 8;
% 2P3 0.1 ~= 8deg
	
contrasts = 1;
ncolors = 2;

rects = zeros(nvert*nhoriz,4);
k = 1;
for i = 1:nvert
    for j = 1:nhoriz
		rects(k,:) = [(i-1)/nvert,(j-1)/nhoriz,i/nvert,j/nhoriz];    
		k = k+1;
	end
end
rects = repmat(rects,2,1);
colors = [0*ones(1,size(rects,1)/2),255*ones(1,size(rects,1)/2)];

% pseudo-randomize positions
order = randomizeStims(mfilename('fullpath'),size(rects,1),repeats);

total_duration = repeats*ncolors*(nvert*nhoriz)*(offTime+onTime);
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
num_stimuli = repeats*ncolors*(nvert*nhoriz)*2;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
rect = cell(1,num_stimuli);
color = zeros(1,num_stimuli);

for i = 1:repeats*ncolors*(nvert*nhoriz)
%     idx = mod(i-1,length(order))+1;
    
	duration(i*2-1) = offTime;
	stim_type{i*2-1} = 'blank';
	
	duration(i*2) = onTime;
    stim_type{i*2} = 'fillrect';    
    contrast(i*2) = contrasts;	
	% [xmin ymin ymin ymax] normalized to 1	
    rect{i*2} = rects(order(i),:);
	color(i*2) = colors(order(i));
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,orientation,spat_freq,temp_freq,rect,color);

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
