%% Trigger Camera and Stimuli
CamTrigger=daq.createSession('ni');
addDigitalChannel(CamTrigger,'USB6000',{'Port0/Line0:1'},'OutputOnly');
outputSingleScan(CamTrigger,decimalToBinaryVector(0,2)); %% intialization

%%%
StopTrigger=daq.createSession('ni');
addDigitalChannel(StopTrigger,'USB6000',{'Port0/Line3'},'InputOnly');

%%% strobe INPUT
CamStrobe= daq.createSession('ni');
addAnalogInputChannel(CamStrobe,'USB6000','ai0','Voltage');
CamStrobe.DurationInSeconds=10;


%% Trigger on HIGH
outputSingleScan(CamTrigger,decimalToBinaryVector(3,2));

[CamStrobeValue,CamStrobeTimestamps,CamStrobeTime] = startForeground(CamStrobe);
% while 1
% StopSignal=inputSingleScan(StopTrigger); %% scan for stop signal from stimuli computer
% if(StopSignal)
%     stop(CamStrobe)
%     break;
% end;
% end;
stop(CamStrobe)
%% Reset when done.
outputSingleScan(CamTrigger,decimalToBinaryVector(0,2)); %% intialization

release(CamStrobe);
% release(StopSignal);
release(CamTrigger);