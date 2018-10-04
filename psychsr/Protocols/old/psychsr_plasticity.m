function data = psychsr_plasticity()

% stimulus parameters
iti_dur=5;
stim_dur=1.75;
trace_dur=0.25;

% variable parameters
pc = getenv('computername');
pc = str2num(pc(end));
if isempty(pc)
    pc = 4;
	card.id = 'Dev3';
	screen.keep = 0;
 	screen.id = 2;
else
	screen.keep = 1;      
end
mouse = input('Mouse #: ');
paired_index= mod(mouse-1,3)+1;
reward = input('Reward (uL): ');

% % adjust solenoid activation time based on calibrated water measurements
% time_s = [10 , 8.0, 6.0, 4.0]/1000;
% rew_ul = [8.0, 6.5, 5.0, 2.5];
% b = polyfit(rew_ul,time_s,1);    
% response.reward_time = reward*b(1)+b(2);
% response.reward_time = round(response.reward_time*2000)/2000;
% response.reward_amt = (response.reward_time-b(2))/b(1);
% fprintf('Reward set to %2.1fms --> %3.2fuL; press enter to confirm.\n',...
% response.reward_time*1000,response.reward_amt);
% pause;

response.reward_time = 0.01;
response.reward_amt = reward;

total_duration = (75)*60;

clear psychsr_draw;
    
%% constant parameters
card.trigger_mode = 'out';   
response.mode = 1;
response.feedback_fn = @psychsr_plasticity_feedback;
sound.tone_amp = 0.2;
sound.tone_time = 0.5;
presentation.frame_rate = 30;
presentation.lag = 0;

%% stimuli
% define your stimuli

% image names
mfiles = {'C:\Dropbox\MouseAttention\Matlab\movies\antelope_image.mat',...
    'C:\Dropbox\MouseAttention\Matlab\movies\penguins_image.mat',...
    'C:\Dropbox\MouseAttention\Matlab\movies\meercats_image.mat'};
target_movie=mfiles{paired_index};

num_loops = ceil(total_duration/(iti_dur+stim_dur+trace_dur));
num_stimuli = num_loops*3;

stim_type = cell(1,num_stimuli);
duration = zeros(1,num_stimuli);
contrast = ones(1,num_stimuli);
movie_file = cell(1,num_stimuli);

for i = 1:num_stimuli
    movie_file{i} = '';
end

k = 1;
repeats = 0;
for i = 1:num_loops                
    duration(k) = iti_dur;
    stim_type{k} = 'blank'; 
    k = k+1; 

    duration(k) = stim_dur;
    stim_type{k} = 'image';
    movie_file{k} = mfiles{randi(3)};   
    k = k+1;
        
    duration(k) = trace_dur;
    stim_type{k} = 'blank';      
    k = k+1;
end

stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,movie_file,contrast,target_movie);

%% input parameters into psychsr
params = psychsr_zip(pc,mouse,screen,response,card,sound,stimuli,presentation);
data = psychsr(params);

%% save
date = clock;
folder = sprintf('C:/Dropbox/MouseAttention/behaviorData/plasticity/mouse %04d',mouse);
if ~isdir(folder); mkdir(folder); end
uisave('data',sprintf('%s/%4d%02d%02d_plasticity_%04d',folder,date(1),date(2),date(3),mouse));    


end