function psychsr_card_setup()

	global data;	    
        
    % define your data acquisition card
    psychsr_set('card','name','nidaq');
    psychsr_set('card','id','Dev1');
    psychsr_set('card','trigger_mode','none');
    psychsr_set('card','inter_trigger_interval',Inf);
    daqreset;
    
    % setup analog input
    if data.response.mode>0 || strcmp(data.card.trigger_mode, 'in')        
        data.card.ai = analoginput(data.card.name, data.card.id); 
        
        ai_chan = psychsr_set('card','ai_chan',2);
        ai_fs = psychsr_set('card','ai_fs',64);
        
        addchannel(data.card.ai, ai_chan);
        
        set(data.card.ai, 'SampleRate', ai_fs);
        
        if strcmp(data.card.trigger_mode, 'in')
            set(data.card.ai,'TriggerType','HwDigital');
            psychsr_set('card','ai_trigger_src','PFI0');            
            set(data.card.ai,'HwDigitalTriggerSource',data.card.ai_trigger_src);  
            set(data.card.ai,'TriggerFcn','psychsr_start_presentation()');
        else
            set(data.card.ai,'TriggerType','Immediate');
        end
        
        if data.response.mode
            set(data.card.ai, 'SamplesPerTrigger', inf);
        end        
    end
    
    if data.response.mode == 4 
        % old setup = analog outputs for reward and airpuff
        
        data.card.ao = analogoutput(data.card.name, data.card.id); 

        psychsr_set('card','ao_chans',[1 0]);  % reward, airpuff channels
        psychsr_set('card','ao_fs',2000);

        addchannel(data.card.ao, data.card.ao_chans);
        set(data.card.ao,'SampleRate',data.card.ao_fs);
        set(data.card.ao,'StopFcn','psychsr_ao_putdata()');  
        
        clear psychsr_ao_putdata();
        psychsr_ao_putdata(); 
    elseif data.response.mode == 1 
        % current setup = digital outputs for reward and airpuff
        
        data.card.dio = digitalio(data.card.name, data.card.id);
        % line 1 = reward
        % line 2 = punish
        % line 3/4 = other
        psychsr_set('card','dio_ports',[1 2]); % [1 0]
        psychsr_set('card','dio_lines',[0 4]); % [1 0]
        for i = 1:length(data.card.dio_ports)
            addline(data.card.dio, data.card.dio_lines(i), data.card.dio_ports(i), 'out');
        end
        
        data.card.dio.TimerFcn = @psychsr_dio_output;
        data.card.dio.TimerPeriod = 0.01; % every 10ms        
        
        % initialize UserData structure
        outdata.dt = zeros(size(data.card.dio_ports));
        outdata.tstart = NaN*ones(size(data.card.dio_ports));
        data.card.dio.UserData = outdata;
        
        if ~(strcmp(data.card.trigger_mode, 'out') || strcmp(data.card.trigger_mode, 'out-hold'))
            start(data.card.dio);
        end
        
    elseif data.response.mode == 2
        % dual setup = two digital outputs (reward) and two analog (airpuff)
        
        % analog output: airpuff        
        data.card.ao = analogoutput(data.card.name, data.card.id); 
        psychsr_set('card','ao_chans',[1 0]);  % airpuff channels
        psychsr_set('card','ao_fs',2000);
        addchannel(data.card.ao, data.card.ao_chans);
        set(data.card.ao,'SampleRate',data.card.ao_fs);
        set(data.card.ao,'StopFcn','psychsr_ao_putdata()');          
        clear psychsr_ao_putdata();
        psychsr_ao_putdata(); 
        
        % digital output: reward (2 channels)
        data.card.dio = digitalio(data.card.name, data.card.id);
        psychsr_set('card','reward_ports',[2 1]);
        psychsr_set('card','reward_lines',[4 0]);
                
        addline(data.card.dio, data.card.reward_lines(1), data.card.reward_ports(1), 'out');
        addline(data.card.dio, data.card.reward_lines(2), data.card.reward_ports(2), 'out');
        data.card.reward1 = data.card.dio.Line(1);
        data.card.reward2 = data.card.dio.Line(2);
        putvalue(data.card.reward1,0);
        putvalue(data.card.reward2,0);
                
    elseif data.response.mode == 3 % reward, airpuff, laser stim
        % laser stim = digital output for reward/airpuff, analog for laser
        
        % analog output for laser control
        data.card.ao = analogoutput(data.card.name, data.card.id); 
        psychsr_set('card','ao_chans',1);  % laserstim channel
        psychsr_set('card','ao_fs',2000);

        addchannel(data.card.ao, data.card.ao_chans);
        set(data.card.ao,'SampleRate',data.card.ao_fs);
        set(data.card.ao,'StopFcn','psychsr_ao_putdata()');  
        
        clear psychsr_ao_putdata();
        psychsr_ao_putdata(); 
                
        
        % digital lines for reward/punish
        data.card.dio = digitalio(data.card.name, data.card.id);
        % line 1 = reward
        % line 2 = punish        
        psychsr_set('card','dio_ports',[1 2]); % [1 0]
        psychsr_set('card','dio_lines',[0 4]); % [1 0]
        for i = 1:length(data.card.dio_ports)
            addline(data.card.dio, data.card.dio_lines(i), data.card.dio_ports(i), 'out');
        end        
        data.card.dio.TimerFcn = @psychsr_dio_output;
        data.card.dio.TimerPeriod = 0.01; % every 10ms        
        
        % initialize UserData structure
        outdata.dt = zeros(size(data.card.dio_ports));
        outdata.tstart = NaN*ones(size(data.card.dio_ports));
        data.card.dio.UserData = outdata;
        
        if ~(strcmp(data.card.trigger_mode, 'out') || strcmp(data.card.trigger_mode, 'out-hold'))
            start(data.card.dio);
        end        
        
    elseif data.response.mode == 5  
        % spout retract = digital outputs for reward, spout extend & retract
        
        data.card.dio = digitalio(data.card.name, data.card.id);
        % line 1 = reward
        % line 2 = extend
        % line 3 = retract
        % line 4 = punish
        psychsr_set('card','dio_ports',[1 2 1 0]); % [0]
        psychsr_set('card','dio_lines',[0 4 1 1]); % [0]
        for i = 1:length(data.card.dio_ports)
            addline(data.card.dio, data.card.dio_lines(i), data.card.dio_ports(i), 'out');
        end
        
        data.card.dio.TimerFcn = @psychsr_dio_output;
        data.card.dio.TimerPeriod = 0.01; % every 10ms        
        
        % initialize UserData structure
        outdata.dt = zeros(size(data.card.dio_ports));
        outdata.tstart = NaN*ones(size(data.card.dio_ports));
        data.card.dio.UserData = outdata;
        
        if ~(strcmp(data.card.trigger_mode, 'out') || strcmp(data.card.trigger_mode, 'out-hold'))
            start(data.card.dio);
        end       
        
    elseif data.response.mode == 6 || data.response.mode == 7
        % spout retract + QUININE
        
        if data.response.mode == 7
            % laser stim = digital output for reward/airpuff, analog for laser

            % analog output for laser control
            data.card.ao = analogoutput(data.card.name, data.card.id); 
            psychsr_set('card','ao_chans',1);  % laserstim channel
            psychsr_set('card','ao_fs',2000);

            addchannel(data.card.ao, data.card.ao_chans);
            set(data.card.ao,'SampleRate',data.card.ao_fs);
            set(data.card.ao,'StopFcn','psychsr_ao_putdata()');  

            clear psychsr_ao_putdata();
            psychsr_ao_putdata(); 
        end
        
        data.card.dio = digitalio(data.card.name, data.card.id);
        % line 1 = reward
        % line 2 = extend
        % line 3 = retract
        % line 4 = quinine (punish)
        if strcmp(getenv('computername'),'VISSTIM-2P4')
            psychsr_set('card','dio_ports',[1 2 1 0]); % [0]
            psychsr_set('card','dio_lines',[0 4 1 1]); % [0]
        elseif strcmpi(getenv('computername'),'behave-ball2')
            psychsr_set('card','dio_ports',[1]); % [0]
            psychsr_set('card','dio_lines',[1]); % [0]
        else
            psychsr_set('card','dio_ports',[1 2 1 2]); % [0]
            psychsr_set('card','dio_lines',[0 4 1 5]); % [0]
        end

        for i = 1:length(data.card.dio_ports)
            addline(data.card.dio, data.card.dio_lines(i), data.card.dio_ports(i), 'out');
        end
        
        data.card.dio.TimerFcn = @psychsr_dio_output;
        data.card.dio.TimerPeriod = 0.01; % every 10ms        
        
        % initialize UserData structure
        outdata.dt = zeros(size(data.card.dio_ports));
        outdata.tstart = NaN*ones(size(data.card.dio_ports));
        data.card.dio.UserData = outdata;
        
        if ~(strcmp(data.card.trigger_mode, 'out') || strcmp(data.card.trigger_mode, 'out-hold'))
            start(data.card.dio);
        end           
    elseif data.response.mode == 8

        % Create ActiveX Controller
        if strcmp(data.screen.pc,'BEHAVIOR2')
            f = figure('Position', [45   505   650   450],...
                'Menu','None',...
                'Name','APT GUI');
            data.card.ax = actxcontrol('MGMOTOR.MGMotorCtrl.1',[20 20 600 400 ], f);
            data.card.ax.StartCtrl;
            % Set the Serial Number
            SN = 83835193; % put in the serial number of the hardware
            set(data.card.ax,'HWSerialNum', SN);
            % Identify the device
            data.card.ax.Identify;
            data.card.ax.SetJogStepSize(0,0.25);
            
            if isfield(data.response,'spout_xpos')
                % move to starting point
                data.card.ax.SetAbsMovePos(0,data.response.spout_xpos(1));
                data.card.ax.MoveAbsolute(0,1==0);
            end
        elseif strcmp(data.screen.pc,'VISSTIM-2P4')
            data.response.auto_adjust_spout = 0; 
            disp('Turned off auto adjust.')
            fprintf('Move spout to %1.2f.\n',data.response.spout_xpos(2));
            pause            
        end
        
        % dual spout        
        data.card.dio = digitalio(data.card.name, data.card.id);
        % line 1 = reward - left (animal's right)
        % line 2 = extend
        % line 3 = retract
        % line 4 = reward - right
        % line 5 = punish (airpuff)
        if strcmp(data.screen.pc,'VISSTIM-2P4')
            psychsr_set('card','dio_ports',[0 2 1 1]); % [0]
            psychsr_set('card','dio_lines',[1 4 1 0]); % [0]
        else
            psychsr_set('card','dio_ports',[2 2 1 1 0]); % [0]
            psychsr_set('card','dio_lines',[5 4 1 0 0]); % [0]
        end
        
        for i = 1:length(data.card.dio_ports)
            addline(data.card.dio, data.card.dio_lines(i), data.card.dio_ports(i), 'out');
        end
        
        data.card.dio.TimerFcn = @psychsr_dio_output;
        data.card.dio.TimerPeriod = 0.01; % every 10ms        
        
        % initialize UserData structure
        outdata.dt = zeros(size(data.card.dio_ports));
        outdata.tstart = NaN*ones(size(data.card.dio_ports));
        data.card.dio.UserData = outdata;
        
        if ~(strcmp(data.card.trigger_mode, 'out') || strcmp(data.card.trigger_mode, 'out-hold'))
            start(data.card.dio);
        end           
        
        data.card.reward1 = data.card.dio.Line(1);
        data.card.reward2 = data.card.dio.Line(4);
    end    
    
    % setup digital output for triggering
    if strcmp(data.card.trigger_mode, 'out') || strcmp(data.card.trigger_mode, 'out-hold')
        if ~isfield(data.card,'dio') 
            data.card.dio = digitalio(data.card.name, data.card.id);
		end        
		
        psychsr_set('card','trigger_port',2);
        psychsr_set('card','trigger_line',5);
        
        addline(data.card.dio, data.card.trigger_line, data.card.trigger_port, 'out');
        data.card.trigger = data.card.dio.Line(end);
                
        putvalue(data.card.trigger,0);        
        if max(data.response.mode == [1, 5, 6, 7 8])            
            start(data.card.dio);
        end
    end
    
end