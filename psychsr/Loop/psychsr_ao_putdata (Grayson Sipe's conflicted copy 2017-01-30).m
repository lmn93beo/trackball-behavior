function psychsr_ao_putdata()
    
    global data;
    persistent stim_time;
    persistent stim_amp;
    persistent outputdata;
    persistent reward_type;    
    persistent laser_id;
        
    if isfield(data,'loop')
        stim = data.loop.stim;
    else
        stim = 0;
    end
    if isfield(data,'stimuli')
        nextstim = find(data.stimuli.laser_on(stim+1:end)>0,1)+stim;
    else
        nextstim = [];
    end
    
    if ~isfield(data,'presentation') || ~isfield(data.presentation,'flip_times')
        disp('reset')
        if isfield(data,'stimuli') && isfield(data.stimuli,'laser_on')
            nseq = find(isnan(data.stimuli.orientation(2:6)),1);
            laser_id = data.stimuli.laser_on(nseq:nseq:end);
        else
            laser_id = ones(1,1000);
        end
        laser_id(laser_id==0) = [];
        amp_ctr = 1;
    end
    
    if data.response.mode == 3 || data.response.mode == 7 % laser stim
%         if isempty(stim_time) || stim_time ~= data.response.laser_time || ...
%                 isempty(stim_amp) || stim_amp ~= data.response.laser_amp
            if numel(data.response.laser_amp) > 1                                                 
                stim_amp = data.response.laser_amp(laser_id(1));
                stim_time = data.response.laser_time;
                laser_id(1) = [];
            elseif numel(data.response.laser_time)>1
                stim_amp = data.response.laser_amp;
                stim_time = data.response.laser_time(laser_id(1));
                laser_id(1) = [];
            else
                
                if isempty(nextstim) || ~isfield(data.stimuli,'laser_time')                    
                    stim_time = data.response.laser_time;
                else
                    stim_time = data.stimuli.laser_time(nextstim);
                end
                
                if isempty(nextstim) || ~isfield(data.stimuli,'laser_amp')
                    stim_amp = data.response.laser_amp;
                else
                    stim_amp = data.stimuli.laser_amp(nextstim);
                end                
            end
                        
            if ~isfield(data.response,'laser_mode')
                laser_mode = 'continuous';
            else
                laser_mode = data.response.laser_mode;
            end
            
            fs = data.card.ao_fs;
            switch laser_mode
                case 'continuous'
                    outputdata = [stim_amp*ones(fs*stim_time,1);zeros(6,1)];
%                     disp('cont')
                case 'end_ramp'
                    r = data.response.laser_ramptime; % ramp down time
                    outputdata = [stim_amp*ones(round(fs*(stim_time-r)),1); ...
                        linspace(stim_amp,0,fs*r)'; zeros(6,1)];
                    if numel(data.response.laser_amp) > 1
                        fprintf('next laser voltage: %1.1f\n',stim_amp);
                    elseif numel(data.response.laser_time) > 1
                        fprintf('next laser duration: %1.1f\n',stim_time);
                    end
%                     disp('end_ramp')
                case 'pulses'
                    T = 1/data.response.laser_freq; % frequency
                    pw = data.response.laser_pw; % pulse width
%                     if pw < 1
%                         pw = pw*100;
%                     end
                    t = 0:1/fs:stim_time-1/fs;             
                    outputdata = [stim_amp*(rem(t,T)<pw)';zeros(6,1)];
%                     outputdata = [stim_amp*(square(2*pi*f*t,pw)>0)';zeros(6,1)];
%                     disp('pulses')

                case 'multitrain'
                                                           
                    if isfield(data.stimuli,'laser_ton') && ~isempty(nextstim)
                        t_on = data.stimuli.laser_ton(nextstim);
                    else
                        t_on = data.response.laser_train_on;
                    end
                    
                    if isfield(data.stimuli,'laser_toff') && ~isempty(nextstim)                   
                        t_off = data.stimuli.laser_toff(nextstim);
                    else
                        t_off = data.response.laser_train_off;
                    end
                    
                    if isfield(data.stimuli,'laser_freq') && ~isempty(nextstim)                   
                        T = 1/data.stimuli.laser_freq(nextstim);
                    else
                        T = 1/data.response.laser_freq; % frequency
                    end
                    
                    if isfield(data.stimuli,'laser_pw') && ~isempty(nextstim)
                        pw = data.stimuli.laser_pw(nextstim); % pulse width
                    else
                        pw = data.response.laser_pw; % pulse width
                    end
                    
                    t = 0:1/fs:stim_time-1/fs;
                    t_train = rem(t,t_on+t_off);

                    outputdata = [stim_amp*(rem(t_train,T)<pw & t_train<t_on)';zeros(6,1)];
                    
            end
                
%         end
    
    elseif strcmp(data.response.reward_type,'water')
        
        if isempty(stim_time) || stim_time ~= data.response.stim_time...
                || isempty(reward_type) || ~strcmp(reward_type,'water')
            stim_time = data.response.punish_time;            
            outputdata = [5*ones(data.card.ao_fs*stim_time,1);zeros(6,1)];
            outputdata = [zeros(size(outputdata)),outputdata];
        end        
        reward_type = 'water';
        
        
        
%     else
%         % mfb stim (temporary code)
%         if isempty(stim_amp) || stim_amp ~= data.response.reward_amp...
%                 || isempty(reward_type) || ~strcmp(reward_type,'mfb')
%             stim_amp = data.response.reward_amp;            
%             t = 0:1/data.card.ao_fs:data.response.reward_time;
%             duty = data.response.reward_pw*data.response.reward_freq/10;
%             outputdata = stim_amp*...%/data.response.reward_conv*...
%                 (square(data.response.reward_freq*2*pi*t,duty)+1)/2;
%             outputdata = [zeros(size(outputdata')),outputdata'];            
%         end
%         reward_type = 'mfb';
    end        
    putdata(data.card.ao, outputdata);
end