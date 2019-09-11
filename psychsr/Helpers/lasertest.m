function lasertest(amplitude, duration)
% direction = 1 or 'extend' or 'out'
%             2 or 'retract' or 'in'
global data;
data = struct;
if nargin<2
    duration = 2;
end
if nargin<1
    amplitude = 5;
end

data.response.mode = 7;
data.response.laser_amp = amplitude;
data.response.laser_time = duration;

%% setup analog output object
data.card.name = 'nidaq';
if strcmpi(getenv('computername'),'rainbow')
data.card.id = 'Dev3';    
else
data.card.id = 'Dev1';
end

data.card.ao = analogoutput(data.card.name, data.card.id); 
data.card.ao_chans = 1;  % laserstim channel
data.card.ao_fs = 2000;

addchannel(data.card.ao, data.card.ao_chans);
set(data.card.ao,'SampleRate',data.card.ao_fs);
set(data.card.ao,'StopFcn','psychsr_ao_putdata()');  

clear psychsr_ao_putdata();
psychsr_ao_putdata(); 

%% turn on laser
start(data.card.ao);
fprintf('LASER ON\n')
% tstart = tic;
% while toc(tstart)<1+duration
%     key = KbCheck;
%     if key
%         disp('Done.')
%         return
%     end
% end
% stop(data.card.ao)
wait(data.card.ao,1+duration);

%% remove digital object
while strcmp(data.card.ao.Running,'On') || (data.card.ao.SamplesOutput>0)
end
putsample(data.card.ao,zeros(size(data.card.ao_chans)));
putsample(data.card.ao,zeros(size(data.card.ao_chans)));
wait(data.card.ao,10);
delete(data.card.ao);