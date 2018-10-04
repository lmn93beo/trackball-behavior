function data = gpi_varydots()
psychsr_go_root();
%% variable parameters
repeats = 10;
offTime = 2;    
onTime = 2;

%  dot_color = [255 255 255]; blackblank = 1; % white on black
dot_color = [0 0 0]; blackblank = 0; % black on gray

contrasts = 1; % coherence

orients = [180 0]; % two directions
tfs = [50 100 200]; % degrees per second
dsizes = [60 90 120]; % size in pixels
ddens = [0.2]; % density

% stimuli
no = length(orients);
nt = length(tfs);
ns = length(dsizes);
nd = length(ddens);

oid = reshape(repmat(1:no,1,nt*ns*nd),1,[]);
tid = reshape(repmat(1:nt,no,ns*nd),1,[]);
sid = reshape(repmat(1:ns,no*nt,nd),1,[]);
did = reshape(repmat(1:nd,no*nt*ns,1),1,[]);

% order = repmat(1:length(oid),1,repeats);
order = randomizeStims(mfilename('fullpath'),length(oid),repeats);

total_duration = numel(order)*(offTime+onTime);
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
num_stimuli = numel(order)*2;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
dot_size = zeros(1,num_stimuli);
dot_density = zeros(1,num_stimuli);

for i = 1:numel(order)
	duration(i*2-1) = offTime;
	stim_type{i*2-1} = 'blank';
	
	duration(i*2) = onTime;
    stim_type{i*2} = 'dots';
    orientation(i*2) = orients(oid(order(i)));
    temp_freq(i*2) = tfs(tid(order(i)));
    contrast(i*2) = contrasts;
    dot_size(i*2) = dsizes(sid(order(i)));
    dot_density(i*2) = ddens(did(order(i)));
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,...
    orientation,spat_freq,temp_freq,blackblank,dot_size,dot_density,dot_color);

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);
ShowCursor;

% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
