function psychsr_cleanup()

    global data;    
    
	psychsr_sound(3); % play low tone
       
    if isfield(data.card,'trigger')
        putvalue(data.card.trigger,0);
        WaitSecs(0.1);
    end
    
    % stop daq
    if data.response.mode
        stop(data.card.ai);
        delete(data.card.ai);
        clear data.card.ai;
        data.card = rmfield(data.card,'ai');
        
        if isfield(data.card,'ao')
            tstart = tic;
            while (strcmp(data.card.ao.Running,'On') || (data.card.ao.SamplesOutput>0)) && toc(tstart)<10
                pause(0.1)
            end
            putsample(data.card.ao,zeros(size(data.card.ao_chans)));
            putsample(data.card.ao,zeros(size(data.card.ao_chans)));
            wait(data.card.ao,10);
            delete(data.card.ao);
            clear data.card.ao;
            data.card = rmfield(data.card,'ao');
        end
            
        if isfield(data.card,'dio')
            putvalue(data.card.dio,0);
            stop(data.card.dio)
            delete(data.card.dio);
            clear data.card.dio;
            data.card = rmfield(data.card,'dio');
        end
        
    end 
    if data.response.mode==8 && isfield(data.card,'ax')
        data.card.ax.StopCtrl;
        close all
    end
    
    if isfield(data.card,'trigger')
        clear data.card.trigger;
        data.card = rmfield(data.card,'trigger');
	end
    
		
    % close screens        
    pause(2)
    if ~data.screen.keep
        Screen('CloseAll')
        data.screen = rmfield(data.screen,'win');
    else
        Screen('FillRect',data.screen.win,data.screen.gray);
        Screen('Flip',data.screen.win);
	end
    
	RestoreCluts;
	
    java.lang.Runtime.getRuntime.gc;
    Priority(0);
    ShowCursor;

    % send notification email
    if data.response.mode>0 && max(strcmp(data.response.notify,{'g','m','a','b'}))
        switch data.response.notify
            case 'g'
                email = '6177672116@messaging.sprintpcs.com';
            case 'm'
                email = 'goardm@gmail.com';
            case 'j'
                email = 'jeetu63js@gmail.com';
        end        
        try 
            sendmail(email,sprintf('m%02d on %s %smin at %s',...
                data.mouse,data.screen.pc,datestr(max(data.response.licks)/86400,'MM:SS'),datestr(now,'mm/dd HH:MM')));
            fprintf('SENT EMAIL\n');
            data.response.notify = '0';
        catch
            fprintf('EMAIL FAILED...\n');
        end
    end
    
    % remove extra stimuli
    x = find(data.stimuli.end_time>data.presentation.stim_times(end),1);
    if isempty(x)
        x = length(data.stimuli.end_time);
    end
    f = fieldnames(data.stimuli);
    y = data.stimuli.num_stimuli;
    for i = 1:length(f)
        if strcmp(f{i},'num_stimuli')
            data.stimuli.(f{i}) = x;
        elseif size(data.stimuli.(f{i})) == [1 y];
            data.stimuli.(f{i}) = data.stimuli.(f{i})(1:x);
        end
    end
    
    % remove data fields
	if data.sound.on
		data.sound = rmfield(data.sound,{'pahandle','buffers'});
	end
    
    % clear status file
    if strcmp(data.screen.pc(1:end-1),'BEHAVIOR') || strcmp(data.screen.pc,'VISSTIM-2P4')
        fid = fopen(sprintf('rig%1d.txt',str2num(data.screen.pc(end))),'w');
        fprintf(fid,'RIG %1d\nEMPTY\n',str2num(data.screen.pc(end)));
        fclose(fid);
	end               
    
	% clear java heap (less crashes)
% 	javaaddpath(which('MatlabGarbageCollector.jar'))
	try
		jheapcl
	catch
		disp('java heap not cleared')
		disp('Run this line to enable java heap clearing:')
		disp('javaaddpath(which(''MatlabGarbageCollector.jar''))')
	end
end
    