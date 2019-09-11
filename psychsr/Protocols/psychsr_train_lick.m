function data = psychsr_train_lick(mouse)
psychsr_go_root();
%% variable parameters
% cd('C:\Dropbox\MouseAttention\matlab');
if nargin < 1
mouse = input('Mouse #: ');
end

rewardAmt = input('Water amount: ');
[amt time b] = psychsr_set_reward(rewardAmt); %was hardset to 4
response.reward_time = time; 
response.reward_amt = amt;
response.reward_cal = b;

total_duration = (60)*60;
    
clear psychsr_draw;
    
%% constant parameters    
screen.keep = 1;
card.trigger_mode = 'key';        
response.mode = 1;
sound.tone_amp = 0.5;        
sound.tone_time = 0.5;
presentation.frame_rate = 60;

%% mouse-specific parameters
switch mouse
    case {1001, 0301, 0302, 0303,0304,0268,0292,0293,0294,11001,11002,11003,11004,11005} %2P4
        card.ai_chan = 2;
        response.iri = 1;
    case {1004, 0401, 2001, 2002, 2003, 2004, 2005, 0057, 0058, 0061,7794,5001, 5002, 0306, 0307, 2157, 2158,2159,2160,2161,2162,2163,2164,2165,2166}
        card.ai_chan = 0; % for lever mice 5th floor
        response.iri = 1;
%         [amt time b] = psychsr_set_reward(4);
%         sound.tone_amp = 0.25;
    case 1005
        card.ai_chan = 0;
        response.iri = 1;
    case {8, 9}
        screen.id = 1;
                card.dio_ports = [1 2]; % test second solenoid
        card.dio_lines = [1 4];
        
    case 11
%         [amt time b] = psychsr_set_reward(3);
        sound.tone_amp = 0.25;
%         card.dio_ports = [1 2]; % test second solenoid
%         card.dio_lines = [1 4];
end

    
%% stimuli
% define your stimuli	
num_stimuli = 1;

stim_type = {'blank'};
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
folder = sprintf('../behaviorData/trackball/mouse %04d',mouse);
if ~isdir(folder); mkdir(folder); end
uisave('data',sprintf('%s/%4d%02d%02d_trainlick_%04d',folder,date(1),date(2),date(3),mouse));    
end

end