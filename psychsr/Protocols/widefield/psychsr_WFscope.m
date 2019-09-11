function data = psychsr_WFscope(params)
%
% PsychSR = Psych(Toolbox) S(timulation) (and) R(esponse)
% Real-time visual stimulation with behavioral readout using MATLAB,
% PsychToolbox and Data Acquisition Toolbox
%
% Gerald Pho 2011-02-04

% start a new data structure

global data;
data = params;

% add psychsr functions
psychsr_go();

% setup
psychsr_screen_setup();
psychsr_response_setup_WFscope();   % configure response parameters

%     psychsr_card_setup();

%%% trigger for starting or stopping Arduino loop 
daqreset
data.StartTrigger=daq.createSession('ni');
addDigitalChannel(data.StartTrigger,'NI6229',{'Port0/Line2'},'OutputOnly');
outputSingleScan(data.StartTrigger,0);




% data.StopTrigger=daq.createSession('ni');
% addDigitalChannel(data.StopTrigger,'USB6000',{'Port0/Line1'},'OutputOnly');
% outputSingleScan(data.StopTrigger,0);

% outputSingleScan(data.CamTrigger,0); %% intialization

% % %%% strobe OUTPUT
% data.CamStrobe= daq.createSession('ni');
% addAnalogInputChannel(data.CamStrobe,'USB6000','ai0','Voltage');
% data.CamStrobe.DurationInSeconds=100;

% disp('Press any key to begin')
% KbPressWait;
% KbReleaseWait;


psychsr_sound_setup();
psychsr_prepare_stimuli();

% run
psychsr_present_WFscope(); % calls psychsr_start_presentation() after a trigger

outputSingleScan(data.StartTrigger,0);
release(data.StartTrigger);

data.StartTrigger=[];
clear data.StartTrigger
% date = clock;
%  cd('C:\Users\surlab\Dropbox\WFScope');    
%  uisave('data',sprintf('%4d%02d%02d_passivemovies',date(1),date(2),date(3)));    


% stop
psychsr_cleanup();



end