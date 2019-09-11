function data = psychsr_dual_lick(mouse)
psychsr_go_root();
%% variable parameters
if nargin<1
    mouse = input('Mouse #: ');
end
amt = 5;
response.max_consec = Inf; % max number of consecutive rewards at one spout
response.switchFlag = 0; % force animal to switch back and forth
response.iri = 1; % inter-reward interval(s)
if mouse == 1007
    response.max_consec = 7;
    amt = 7;
    response.iri = 0.5;
    response.spout_xpos = [11.5 5];
elseif mouse == 1008
    response.spout_xpos = [8 5];
    amt = 5;
elseif mouse == 1009
    response.spout_xpos = [8.25 5];
elseif mouse == 1010
    response.spout_xpos = [6.75 5];
    response.max_consec = 7;
elseif mouse == 1011
    response.spout_xpos = [7 5];
    response.max_consec = 7;
    amt = 4;
else    
    response.switchFlag = 0; % force animal to switch back and forth    
end



[amt time b] = psychsr_set_reward(amt);
response.reward_time(2,:) = time;
response.reward_amt(2,:) = amt;
response.reward_cal(2,:) = b;

[amt time b] = psychsr_set_quinine(amt);
response.reward_time(1,:) = time;
response.reward_amt(1,:) = amt;
response.reward_cal(1,:) = b;

total_duration = (60)*60;

clear psychsr_draw;


%% constant parameters
screen.keep = 1;
% card.ai_chan = [0 3]; % dual lick channels
card.trigger_mode = 'key';
response.mode = 8;
response.feedback_fn = @psychsr_dual_feedback;
sound.tone_amp = 0.5;
sound.tone_time = 0.5;
presentation.frame_rate = 30;

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
    uisave('data',sprintf('%s/%4d%02d%02d_duallick_%04d',folder,date(1),date(2),date(3),mouse));
end

end