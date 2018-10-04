function data = psychsr_train_lick2(mouse)

%% variable parameters
if nargin<1
    mouse = input('Mouse #: ');
end
[amt time b] = psychsr_set_reward(4);
response.reward_time = time; 
response.reward_amt = amt;
response.reward_cal = b;

    total_duration = (60)*60;
    
    clear psychsr_draw;
    
    response.iri = 1; % inter-reward interval(s)
    
%% constant parameters
    screen.keep = 1;      
    card.trigger_mode = 'key';        
    response.mode = 1;
    response.feedback_fn = @psychsr_lick_feedback2;
    sound.tone_amp = 0.5;        
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
    params = psychsr_zip(mouse,screen,response,card,sound,stimuli,presentation);
    data = psychsr(params);
    
%% save
if nargin<1
date = clock;
folder = sprintf('../behaviorData/mouse %04d',mouse);
if ~isdir(folder); mkdir(folder); end
uisave('data',sprintf('%s/%4d%02d%02d_trainlick2_%04d',folder,date(1),date(2),date(3),mouse));    
end

end