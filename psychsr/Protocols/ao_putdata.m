function ao_putdata
global ao;

% stimulus parameters
stim_amp = 5; % leave at 5
fs = 2000;
laser_mode = 'continuous'; % continuous or pulses
stim_time = .5;


switch laser_mode
    case 'continuous'        
        outputdata = [stim_amp*ones(fs*stim_time,1);zeros(6,1)];
        disp(stim_time)
    case 'pulses'
%         f = 5; % frequency
%         dutycycle = 5; % pulse width
%         if dutycycle < 1
%             dutycycle = dutycycle*100;
%         end
%         t = 0:1/fs:stim_time-1/fs;
%         outputdata = [stim_amp*(square(2*pi*f*t,dutycycle)>0)';zeros(6,1)];
        outputdata = [zeros(fs*stim_time,1);zeros(6,1)];
        outputdata(1:10:end) = stim_amp;
end

putdata(ao, outputdata);

