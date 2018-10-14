function trackball_card_setup
global data

data.card.name = 'nidaq';
data.card.id = 'Dev1';
data.card.trigger_mode = 'out';
data.card.inter_trigger_interval = Inf;
daqreset;

if strcmpi(data.screen.pc,'behave-ball2')
    data.card.dio_ports = [1,1]; % water, trigger % CHANGED TO [1,1] FROM [1,2]
    data.card.dio_lines = [1 5];
elseif strcmpi(data.screen.pc,'behave-ball3')
    data.card.dio_ports = [1,2];
    data.card.dio_lines = [0 4];
elseif strcmpi(data.screen.pc,'visstim-2p4')
    data.card.dio_ports = [1 0];
    data.card.dio_lines = [0 1];
elseif strcmpi(data.screen.pc,'behavior2')
    data.card.dio_ports = [1,1];
    data.card.dio_lines = [0 1];
else
    
    data.card.dio_ports = [1,2];
    data.card.dio_lines = [0 4];
end
data.card.dio = digitalio(data.card.name, data.card.id);

for i = 1:length(data.card.dio_ports)
    addline(data.card.dio, data.card.dio_lines(i), data.card.dio_ports(i), 'out');
end

% Add read ports
if strcmpi(data.screen.pc,'behave-ball2')
    addline(data.card.dio, 1, 2, 'in'); %port2/line1 for touch
    addline(data.card.dio, 0, 2, 'in'); %port2/line0 for release
end

% line 1 = reward
% line 2 = punish
% line 3/4 = other

data.card.dio.TimerFcn = @psychsr_dio_output;
data.card.dio.TimerPeriod = 0.01; % every 10ms

% initialize UserData structure
outdata.dt = zeros(size(data.card.dio_ports));
outdata.tstart = NaN*ones(size(data.card.dio_ports));
data.card.dio.UserData = outdata;

% trigger
psychsr_set('card','trigger_port',1);
psychsr_set('card','trigger_line',5);
%addline(data.card.dio, data.card.trigger_line, data.card.trigger_port, 'out');
data.card.trigger = data.card.dio.Line(2);
putvalue(data.card.trigger,0);    
start(data.card.dio);


data.card.ai = analoginput(data.card.name, data.card.id);
if data.params.lever == 1
%     if data.params.lev_touch        
        data.card.ai_chan = [0 1 3]; % lick, lever, touch
%     else
%         data.card.ai_chan = [0 1]; % lick, lever
%     end
    data.card.ai_fs = 256;  
    
    if strcmpi(data.screen.pc,'visstim-2p4')
       data.card.ai_chan(1) = 2; 
    end
elseif data.params.lever == 2    
    data.card.ai_chan = [0 3 1]; % lick, lever
    data.card.ai_fs = 256;
% elseif data.params.balldaq
%     data.card.ai_chan = [2 4];
%     data.card.ai_fs = 256;
else % no lever (trackball)
    data.card.ai_chan = 2; % lick
    data.card.ai_fs = 64;
end
addchannel(data.card.ai, data.card.ai_chan);
set(data.card.ai, 'SampleRate', data.card.ai_fs);
set(data.card.ai,'TriggerType','Immediate');
set(data.card.ai, 'SamplesPerTrigger', inf);

%% arduino serial port
if data.params.lever==0
    if ~isempty(instrfind)
        fclose(instrfind);
        delete(instrfind);
    end
     if strcmpi(getenv('computername'),'behave-ball1')
        data.serial.port = 'COM9';
     elseif strcmpi(getenv('computername'),'visstim-2p4')
         data.serial.port = 'COM7';
     elseif strcmpi(getenv('computername'),'behavior2')
         data.serial.port = 'COM1';
     else
         data.serial.port = 'COM7';
     end
    data.serial.in = serial(data.serial.port);
    data.serial.in.InputBufferSize = 50000;
    data.serial.in.BaudRate = 115200;
    data.serial.in.FlowControl = 'hardware';
    fopen(data.serial.in);
end

%% 
if data.params.laser || data.params.laser_blank_only 
    % analog output for laser control
    data.card.ao = analogoutput(data.card.name, data.card.id);
    psychsr_set('card','ao_chans',1);  % laserstim channel
    psychsr_set('card','ao_fs',2000);
    
    addchannel(data.card.ao, data.card.ao_chans);
    set(data.card.ao,'SampleRate',data.card.ao_fs);
    set(data.card.ao,'StopFcn','trackball_ao_putdata()');
    
    clear trackball_ao_putdata();
    trackball_ao_putdata();
    
end

%% notification
letters = {'g','l','r'};
emails = {'6177672116@messaging.sprintpcs.com','6365445597@txt.att.net',''};
eFlag = find(cellfun(@(x) ~isempty(strfind(data.params.notify,x)),letters));
data.params.email = emails(eFlag);

if ~isempty(eFlag)
    % send text to gerald
    setpref('Internet', 'E_mail', 'surcalendar@gmail.com');
    setpref('Internet', 'SMTP_Username', 'surcalendar@gmail.com');
    setpref('Internet', 'SMTP_Password', 'GolgivCajal');
    setpref('Internet', 'SMTP_Server', 'smtp.gmail.com');
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port', '465');
    
    for e = 1:length(eFlag)
        if eFlag(e)~=2
            i = str2num(data.screen.pc(end));
            if ~isempty(strfind(lower(data.screen.pc),'ball'))
                i = i+4;
            end
            sendmail(data.params.email{eFlag(e)},sprintf('m%02d starting on rig%d at %s',...
                data.mouse,i,datestr(now,'mm/dd HH:MM')));
        end
    end        
end