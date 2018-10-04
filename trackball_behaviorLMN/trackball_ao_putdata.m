function trackball_ao_putdata()

global data;
persistent stim_time;
persistent stim_amp;
persistent outputdata;
persistent laser_id;

if ~isfield(data.response,'start_time')
    disp('reset')
    if isfield(data,'stimuli') && isfield(data.stimuli,'laser_on')
        laser_id = data.stimuli.laser_on;
    else
        laser_id = ones(1,1000);
    end
    laser_id(laser_id==0) = [];
    amp_ctr = 1;
end

if numel(data.params.laser_amp) > 1
    stim_amp = data.params.laser_amp(laser_id(1));
    stim_time = data.params.laser_time;
    laser_id(1) = [];
elseif numel(data.params.laser_time)>1
    stim_amp = data.params.laser_amp;
    stim_time = data.params.laser_time(laser_id(1));
    laser_id(1) = [];
else
    stim_amp = data.params.laser_amp;
    stim_time = data.params.laser_time;
end

if ~isfield(data.params,'laser_mode')
    laser_mode = 'continuous';
else
    laser_mode = data.params.laser_mode;
end

fs = data.card.ao_fs;
switch laser_mode
    case 'continuous'
        outputdata = [stim_amp*ones(fs*stim_time,1);zeros(6,1)];
        %                     disp('cont')
    case 'end_ramp'
        r = data.params.laser_ramptime; % ramp down time
        outputdata = [stim_amp*ones(round(fs*(stim_time-r)),1); ...
            linspace(stim_amp,0,fs*r)'; zeros(6,1)];
        if numel(data.params.laser_amp) > 1
            fprintf('next laser voltage: %1.1f\n',stim_amp);
        elseif numel(data.params.laser_time) > 1
            fprintf('next laser duration: %1.1f\n',stim_time);
        end
        %                     disp('end_ramp')
    case 'pulses'
        f = data.params.laser_freq; % frequency
        pw = data.params.laser_pw; % pulse width
        if pw < 1
            pw = pw*100;
        end
        t = 0:1/fs:stim_time-1/fs;
        outputdata = [stim_amp*(square(2*pi*f*t,pw)>0)';zeros(6,1)];
%                              disp('pulses')
end

putdata(data.card.ao, outputdata);
end