% Flush water -- use at beginning of training session

water_amt = 100;
disp('Place paper towel under spout');

%% Setup card

global data
data.screen.pc = getenv('computername');
data.params.lever = 0; data.params.laser = 0; data.params.laser_blank_only = 0; data.params.notify = [];
trackball_card_setup;
putvalue(data.card.dio,0);

%% Set water and deliver
[~,reward_time,~] = psychsr_set_reward(water_amt);
disp('Dispensing water ...');
stop_water = 1;

while stop_water
    outdata = data.card.dio.UserData;
    outdata.dt(1) = reward_time;
    outdata.tstart(1) = NaN;
    data.card.dio.UserData = outdata;
    stop_water = logical(input('Enter 1 for more, 0 to stop: '));
end

%% Clean up

pause(1);
putvalue(data.card.dio,0);
stop(data.card.dio)
delete(data.card.dio);
data.card = rmfield(data.card,'dio');
data.card = rmfield(data.card,'trigger');
stop(data.card.ai);
delete(data.card.ai);
data.card = rmfield(data.card,'ai');
clear all