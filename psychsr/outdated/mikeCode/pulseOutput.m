function []=pulseOutput(pulseLength);

AO = analogoutput('nidaq','dev1');
chan = addchannel(AO,1);

Fs = 1000; % Sampling frequency
T = 1000; % Total time in ms
pulseStart = 200; % start output pulse
pulseEnd = pulseStart+pulseLength;   % end output pulse
set(AO,'SampleRate',Fs)
set(AO,'TriggerType','Manual');
outputVec=zeros(T,1); 
outputVec(pulseStart:pulseEnd)=5;


putdata(AO,outputVec);
start(AO);
trigger(AO);
wait(AO,1.1);
delete(AO);
clear AO;