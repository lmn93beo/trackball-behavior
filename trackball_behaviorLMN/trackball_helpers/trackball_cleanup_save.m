global data

psychsr_sound(3); 
Screen('FillRect', window, grey);
Screen('Flip', window);
if data.params.lever==0
    fclose(data.serial.in);
    delete(data.serial.in);
    data.serial = rmfield(data.serial,'in');
end
if data.params.laser || data.params.laser_blank_only
    tstart = tic;
    while (strcmp(data.card.ao.Running,'On') || (data.card.ao.SamplesOutput>0)) && toc(tstart)<10
        pause(0.1)
    end
    putsample(data.card.ao,zeros(size(data.card.ao_chans)));
    putsample(data.card.ao,zeros(size(data.card.ao_chans)));
    wait(data.card.ao,10);    
    stop(data.card.ao);
    delete(data.card.ao)
    data.card = rmfield(data.card,'ao');
end
putvalue(data.card.dio.Line(1:2),0);
stop(data.card.dio)
delete(data.card.dio);
data.card = rmfield(data.card,'dio');
data.card = rmfield(data.card,'trigger');
stop(data.card.ai);
delete(data.card.ai);
data.card = rmfield(data.card,'ai');


% notify
if data.quitFlag<2 && max(strcmp(data.params.notify,{'g','l','r'}))
    i = str2num(data.screen.pc(end));
    if ~isempty(strfind(lower(data.screen.pc),'ball'))
        i = i+4;
    end
    for e = 1:length(data.params.email)
        sendmail(data.params.email{e},sprintf('m%02d done on rig %d at %s after %smin',...
            data.mouse,i,datestr(now,'mm/dd HH:MM'),datestr(max(data.response.trialtime)/86400,'MM')));
        fprintf('SENT EMAIL\n');
    end
    data.response.notify = '0';
end

data = rmfield(data,'quitFlag');
data = rmfield(data,'userFlag');

% convert serial timestamps
if data.params.lever==0
    time = data.response.mvmtdata(:,2);
    neg = find(diff(time)<-1000,1);
    while ~isempty(neg)
        time(neg+1:end,1) = time(neg+1:end,1) + 2^16;
        neg = find(diff(time)<-1000,1);
    end
    time = time/1000;
    x = data.response.mvmtdata(:,1);
    data.response.time = time;
    data.response.dx = x;
end

% display performance
str = trackball_dispperf;
str = [sprintf('\nMouse %d\n',data.mouse), str];
fprintf('%s',str);

i = str2num(data.screen.pc(end));
if ~isempty(strfind(lower(data.screen.pc),'ball'))
    i = i+4;
end
fid = fopen(sprintf('rig%1d.txt',i),'w');
fprintf(fid,'RIG %1d\nEMPTY\n',i);
fclose(fid);

%% save data
date = clock;
folder = sprintf('behaviorData/mouse%04d',data.mouse);
if ~isdir(folder); mkdir(folder); end
uisave('data',sprintf('%s/%4d%02d%02d_trackball_%04d',folder,date(1),date(2),date(3),data.mouse));