function data = gpi_rfsn_fast()
%% variable parameters
repeats = 5;
offTime = 0.3;
onTime = 0.2;

nvert = 14;
nhoriz = 8;

center = [0.52 0.32];

x = ((1:nvert)-0.5)/nvert;
y = ((1:nhoriz)-0.5)/nhoriz;
[a,xid] = min(abs(center(1)-x));
[a,yid] = min(abs(center(2)-y));

nv_sub = 9;
nh_sub = 5;

if xid-ceil(nv_sub/2) < 0
	xid = ceil(nv_sub/2);
elseif xid+ceil(nv_sub/2) > nvert+1
	xid = nvert+1-ceil(nv_sub/2);
end
if yid-ceil(nh_sub/2) < 0
	yid = ceil(nh_sub/2);
elseif yid+ceil(nh_sub/2) > nhoriz+1
	yid = nhoriz+1-ceil(nh_sub/2);
end

xoffset = (xid-ceil(nv_sub/2))/nvert;
yoffset = (yid-ceil(nh_sub/2))/nhoriz;

contrasts = 1;
ncolors = 2;

rects = zeros(nv_sub*nh_sub,4);
k = 1;
for i = 1:nv_sub
    for j = 1:nh_sub
		rects(k,:) = [(i-1)/nvert,(j-1)/nhoriz,i/nvert,j/nhoriz];    
		k = k+1;
	end
end
rects(:,[1 3]) = rects(:,[1 3]) +xoffset;
rects(:,[2 4]) = rects(:,[2 4]) +yoffset;
rects = repmat(rects,2,1);
colors = [255*ones(1,size(rects,1)/2),255*ones(1,size(rects,1)/2)];

% pseudo-randomize positions
load('gpi_rfsn_fast.mat')

total_duration = length(order)*(offTime+onTime);
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
num_stimuli = length(order)*2;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
rect = cell(1,num_stimuli);
color = zeros(1,num_stimuli);

for i = 1:length(order)
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
