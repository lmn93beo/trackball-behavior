function data = jp_randori_laser()
% set up for laser on 2P3

psychsr_go_root();
%numTrials = 2;
for trial = 1:2

%% variable parameters
repeats = 6;
offTime = 6;
onTime = 2;

orients = [0:22.5:359];
sfs = 0.016; %cycles per degree
tfs = 1.5; %cycles per second
contrasts = 1;
sine_gratings = 1; % square wave

order = randomizeStims(mfilename('fullpath'),length(orients),repeats);
neworder = []; % interleave to generate same number of laser ON and OFF trials
for i = 1:floor(repeats/2)
    neworder = cat(2,neworder,reshape(order(:,i*2-[1 0])',size(order,1),2));
end
if mod(repeats,2)>0
    neworder = cat(2,neworder,order(:,end));
end
order = neworder;
    
total_duration = repeats*length(orients)*(offTime+onTime);
total_duration;

%% laser parameters
laser_every_n = 2;
response.laser_seq = 1; % align to stimulus on-time

response.laser_amp = input('Laser voltage: ');%3.1;%3.1;
response.laser_onset = offTime-2; % relative to stimulus on time
response.laser_time = 2; % total duration
response.laser_mode = 'multitrain';
response.laser_freq = 20; % frequency
response.laser_pw = 0.01; % pulse width (s)
response.laser_train_on = response.laser_time; % s
response.laser_train_off = 0;

response.feedback_fn = @jp_randori_laser_feedback;


%% save in Rajeev's structure
Params.Where = getenv('computername');
Params.durStim = onTime;
Params.durBlank = offTime;
Params.contrast = contrasts;
Params.MovsperTrial = repeats*length(orients);
Params.NumTrials = 2;
Params.TotalDuration = total_duration*2;
Params.TotalDuration_perTrial = total_duration;
Params.runNumber = trial;
Params.LaserFreq = response.laser_freq;
Params.LaserPW = response.laser_pw;
Params.LaserDur = response.laser_time;
Params.LaserOnset = response.laser_onset;
Params.LaserVolts = response.laser_amp;
N = [orients(order(:))', repmat(sfs,Params.MovsperTrial,1), ...
    mod(0:Params.MovsperTrial-1,laser_every_n)'];
fprintf('Press any key to start trial #%d\n',trial);
pause
home = 'C:\Users\Nathan Wilson\Desktop\Astrocytes\';
if exist( [home date '/'] ) < 7
    mkdir( [home date '/'] );
end;
if exist( [home date '/Orientation Tuning/'] ) <7
    mkdir( [home date '/Orientation Tuning/'] )
end;
savePath = [home date '/Orientation Tuning/'];

X = dir([savePath '*.mat']);
if size(X,1) == 0
    Params.runNumber = 1;
else
    Params.runNumber = max(cellfun(@(x) str2double(x(end-5:end-4)), {X.name}))+1;
end
save(sprintf('%sProtocol_%02d.mat',savePath,Params.runNumber));

%% constant parameters
screen.keep = 1;
card.trigger_mode = 'out';   
card.trigger_port = 1;
card.trigger_line = 0;

card.dio_ports = [1 2 0 2]; % [0]
card.dio_lines = [1 4 1 5]; % [0]

card.id = 'Dev3';
response.mode = 7;
sound.tone_amp = 0.2;
presentation.frame_rate = 30;
presentation.lag = -0.011;

%% stimuli
noris = length(orients);
num_stimuli = repeats*(noris)*2;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
laser_on = zeros(1,num_stimuli);
fade = zeros(1,num_stimuli); % 0 = no fade, 1 = fade in, -1 = fade out

% laser_time = response.laser_time*ones(1,num_stimuli);
% laser_freq = zeros(1,num_stimuli);

% freq = [20 60];
k = 1;
for i = 1:num_stimuli/2    
	duration(k) = offTime;
	stim_type{k} = 'blank';        
    laser_on(k) = (mod(i,laser_every_n)==0);
    k = k+1;
	
	duration(k) = onTime;
    stim_type(k) = {'grating'};
    orientation(k) = orients(order(i));
    spat_freq(k) = sfs;
    temp_freq(k) = tfs;
    contrast(k) = contrasts;	            
%     m=[mod(i-1,3)+1 mod(i-1,2)+1]    
    k = k+1;
end

% constant
% stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,orientation,...
%     spat_freq,temp_freq,fade,sine_gratings,laser_on);

% variable
stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,orientation,...
    spat_freq,temp_freq,fade,sine_gratings,laser_on);
stimuli.blackblank = 0;

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);
ShowCursor;
end
% date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
