global data
% wait for movement
%     mvmt_test = true; << CHANGE
fprintf('testing, waiting for mvmt...\n')

if data.params.lever>0
    start(data.card.ai);
    nsampled = 0;
    while mvmt_test        
        if data.card.ai.SamplesAcquired > nsampled
            newdata = peekdata(data.card.ai,data.card.ai.SamplesAcquired-nsampled);
            nsampled = nsampled + size(newdata,1);
            if data.params.lever == 1; chans = 2; else chans = [2 3]; end;
            vals = max(abs(smooth(newdata(:,chans)-repmat(data.params.lev_baseline,size(newdata,1),1),16)))./data.params.lev_cal;
            if max(vals > data.params.lev_still)
                mvmt_test = false;
            end
        end
        pause(0.1)
    end
    stop(data.card.ai)
else
    while mvmt_test
        bytes = data.serial.in.BytesAvailable;
        while bytes > 4
            [d,b] = fscanf(data.serial.in,'%d'); % read x and y
            %disp(d)
            bytes = bytes-b;
            if length(d) == 2 && d(2)~= 0
                mvmt_test = false;
                break;
            end
        end
        pause(0.1);
    end
end
fprintf('movement detected.\n')
data.response.start_time = now;
start(data.card.ai);
if strcmp(data.card.trigger_mode, 'out')
    putvalue(data.card.trigger,1);
    WaitSecs(0.005);
    putvalue(data.card.trigger,0);
    disp('Triggered')
end