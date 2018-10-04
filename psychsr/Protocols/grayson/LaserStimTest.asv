stim_amp = 1;
pw = 0.01;

stim_time = 1;
freq = 5;
t_on = 0.3;
t_off = 0.7;

%%
fs = 1000;
T = 1/freq;

t = 0:1/fs:stim_time-1/fs;
outputdata = [stim_amp*(rem(t,T)<pw & rem(t,t_on+t_off)<t_on)'];%;zeros(6,1)];

plot(t,outputdata)
