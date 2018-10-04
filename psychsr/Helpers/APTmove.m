
clear; close all; clc;
global h; % make h a global variable so it can be used outside the main
          % function. Useful when you do event handling and sequential           move
%% Create Matlab Figure Container
fpos    = get(0,'DefaultFigurePosition'); % figure default position
fpos(3) = 650; % figure window size;Width
fpos(4) = 450; % Height
 
f = figure('Position', [45   505   650   450],...
           'Menu','None',...
           'Name','APT GUI');
% f = figure('Visible','off');
%% Create ActiveX Controller
times = [];
tstart = tic;
h = actxcontrol('MGMOTOR.MGMotorCtrl.1',[20 20 600 400 ], f);
times(end+1) = toc(tstart)
% set(gcf,'position',[45   505   650   450])
%% Initialize
% Start Control
h.StartCtrl;
times(end+1) = toc(tstart) 
% Set the Serial Number
SN = 83835193; % put in the serial number of the hardware
set(h,'HWSerialNum', SN);
 
% Indentify the device
h.Identify;
times(end+1) = toc(tstart)
% pause(5); % waiting for the GUI to load up;
%% Controlling the Hardware
%h.MoveHome(0,0); % Home the stage. First 0 is the channel ID (channel 1)
                 % second 0 is to move immediately
%% Event Handling
% h.registerevent({'MoveComplete' 'MoveCompleteHandler'});
 
%% Sending Moving Commands
timeout = 10; % timeout for waiting the move to be completed
%h.MoveJog(0,1); % Jog

h.SetJogStepSize(0,1);
times(end+1) = toc(tstart)
% Move a absolute distance

center = 11;
pos = center + [-1 0 1]*4;

tic
h.SetAbsMovePos(0,center);
h.MoveAbsolute(0,1==0);
shg
s = h.GetStatusBits_Bits(0);
while (bitget(abs(s),5)||bitget(abs(s),6)) ~= 0
    s = h.GetStatusBits_Bits(0);
    pause(0.1)
end
toc

for i = 1:10
    tic
    h.SetAbsMovePos(0,pos(mod(i,3)+1));
    h.MoveAbsolute(0,1==0);
    disp(pos(mod(i,3)+1))
%     h.SetRelMoveDist(0,mod(i,2)*2-1);
%     disp(mod(i,2)*2-1)
%     h.MoveRelative(0,1==0);
    shg
    s = h.GetStatusBits_Bits(0);
    while (bitget(abs(s),5)||bitget(abs(s),6)) ~= 0
        s = h.GetStatusBits_Bits(0);
        pause(0.1)
    end    
        toc
    
%     pause(2)
end

% h.SetAbsMovePos(0,14);
% h.MoveAbsolute(0,1==0);
 
% t1 = clock; % current time
% while(etime(clock,t1)<timeout) 
% % wait while the motor is active; timeout to avoid dead loop
%     s = h.GetStatusBits_Bits(0);
%     if (bitget(abs(s),5)||bitget(abs(s),6)) == 0
%       pause(2); % pause 2 seconds;
%       h.MoveHome(0,0);
%       disp('Home Started!');
%       break;
%     end
% end
h.StopCtrl;
close all