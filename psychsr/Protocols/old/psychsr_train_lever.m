function data = psychsr_train_lever()

%% variable parameters
pc = getenv('computername');
pc = str2num(pc(end));
mouse = input('Mouse #: ');
response.reward_amp = input('Reward (V): ');

if pc == 3
    screen.id = 1;
else
    screen.id = 3;
end

    total_duration = (90)*60;
    
    clear psychsr_draw;
    
%% constant parameters
    screen.keep = 1;      
    card.trigger_mode = 'key';   
    card.ao_fs = 20000; % output sampling rate     
    response.mode = 1;
    response.reward_time = 0.2; %sec
    response.reward_freq = 141; %Hz
    response.reward_pw = 0.1; %ms
    response.reward_conv = 100; %uA/V
    response.reward_type = 'mfb';
    response.feedback_fn = @psychsr_lick_feedback2;
    sound.tone_amp = 0.2;        
    sound.tone_time = 0.5;
    presentation.frame_rate = 60;
    
%% stimuli
    % define your stimuli	
    num_stimuli = 1;
    
    stim_type = {'blank','grating'};
    duration = total_duration;
    orientation = NaN;
    spat_freq = NaN;
    temp_freq = NaN;
    contrast = NaN;
    
    stimuli = psychsr_zip(num_stimuli,total_duration,stim_type,duration,orientation,spat_freq,temp_freq,contrast);       
    
%% input parameters into psychsr
    params = psychsr_zip(pc,mouse,screen,response,card,sound,stimuli,presentation);
    data = psychsr(params);
    
%% save
date = clock;
folder = sprintf('C:/Dropbox/MouseAttention/behaviorData/mouse %04d',mouse);
if ~isdir(folder); mkdir(folder); end
uisave('data',sprintf('%s/%4d%02d%02d_trainlever_%04d',folder,date(1),date(2),date(3),mouse));    


end