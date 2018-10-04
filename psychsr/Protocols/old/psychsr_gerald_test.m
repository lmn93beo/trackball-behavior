function data = psychsr_gerald_test()
%% variable parameters
delay = 5;
delay_var = 2;
resp = 2;
iti = 2;

orients = [90 0];
sfs = 0.012;
tfs = [2 2];	
mcontrast = 1;
contrasts = 1;
aperture = [0 0 1 1];

mask_std = 1;

ntarget = 1;
per_targ = 0.5;
max_targ = 3;

total_duration = (30)*60;

%% constant parameters
screen.keep = 1;
screen.pixels_per_degree = 28.0489;
card.trigger_mode = 'none';   
response.mode = 0;
sound.tone_amp = 0;
presentation.frame_rate = 60;
presentation.lag = 0.03;

%% stimuli
mfiles = {'c:\Dropbox\MouseAttention\Matlab\movies\mov043-antelopeturn395.mat',...
    'c:\Dropbox\MouseAttention\Matlab\movies\mov055-penguins500.mat',...
    'c:\Dropbox\MouseAttention\Matlab\movies\mov184-meercatgroom268.mat'};

num_loops = ceil(total_duration/(delay-delay_var/2+resp+iti));
num_stimuli = num_loops*3;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = zeros(1,num_stimuli);
movie_con = zeros(1,num_stimuli);
movie_file = cell(1,num_stimuli);
orientation = NaN*ones(1,num_stimuli);
spat_freq = NaN*ones(1,num_stimuli);
temp_freq = zeros(1,num_stimuli);
fade = zeros(1,num_stimuli);
rect = cell(1,num_stimuli);

for i = 1:num_stimuli
    movie_file{i} = '';
end

k = 1;
repeats = 0;
for i = 1:num_loops
	duration(k) = iti;
    stim_type{k} = 'image';
    movie_file{k} = mfiles{mod(i,3)+1};
    contrast(k) = mcontrast;
    k = k+1;
    
    duration(k) = delay + delay_var*(rand-0.5);
    stim_type{k} = 'movie';
    movie_file{k} = mfiles{mod(i,3)+1}; 
    contrast(k) = mcontrast;
    k = k+1;
	
	duration(k) = resp;
    stim_type{k} = 'grating2';
    movie_file{k} = mfiles{mod(i,3)+1}; 
    movie_con(k) = mcontrast;
    spat_freq(k) = sfs;
    contrast(k) = contrasts;
    fade(k) = 1;
    if (k<=ntarget*3) || (repeats == -3) || (repeats<max_targ && rand<per_targ)
        orientation(k) = orients(1);
        temp_freq(k) = tfs(1);
        if repeats < 1; repeats = 1; else repeats = repeats + 1; end;
    else
        orientation(k) = orients(2);
        temp_freq(k) = tfs(2);
        if repeats > -1; repeats = -1; else repeats = repeats - 1; end;
    end
    rect{k} = aperture;
    k = k+1;
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,contrast,orientation,spat_freq,temp_freq,rect,movie_file,movie_con,mask_std,fade);
stimuli.blackblank = 1;

%% input parameters into psychsr
params = psychsr_zip(screen,response,card,sound,stimuli,presentation);
data = psychsr(params);
ShowCursor;

date = clock;
% cd(sprintf('C:/Dropbox/MouseAttention/'));    
% uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    
