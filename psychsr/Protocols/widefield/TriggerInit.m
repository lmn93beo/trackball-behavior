%%% reset trigger 
clear all;
StartTrigger=daq.createSession('ni');
addDigitalChannel(StartTrigger,'NI6229',{'Port0/Line2'},'OutputOnly');
outputSingleScan(StartTrigger,0);
release(StartTrigger)
clear all;