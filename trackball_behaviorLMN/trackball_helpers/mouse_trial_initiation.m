global data

if data.params.lickInitiate>0
    % no licking for 1 second
    ttemp = tic;
    while toc(ttemp) < data.params.itiDelay
        trackball_keycheck(k);
        % record licks 
        newdata = trackball_getdata(1);
        if ~isempty(newdata)
            testdata = newdata; % testdata is newdata plus previous data point
            if ~isempty(data.response.lickdata)
                testdata = cat(1,data.response.lickdata(end,:),testdata);
            end
            abovetrs = testdata > 1;
            crosstrs = find([0;abovetrs(2:end)-abovetrs(1:end-1)] > 0);
            if ~isempty(crosstrs) && data.params.extenddelay && data.quitFlag==0
                if toc(ttemp) > 0.1;
                    fprintf('%s EXTEND DELAY...\n',datestr(toc(tstart)/86400,'MM:SS'));
                end
                ttemp = tic;
            end
        end
    end        
    % mouse must lick to initiate trial
    licked = 0;
    ttemp = tic; lastt = 1;
    while ~licked
        trackball_keycheck(k);
        newdata = trackball_getdata(1);
        if ~isempty(newdata)            
            testdata = [data.response.lickdata(end,:);newdata]; % testdata is newdata plus previous data point                
            abovetrs = testdata > 1;
            crosstrs = find([0;abovetrs(2:end)-abovetrs(1:end-1)] > 0);
            licked = ~isempty(crosstrs);
        end
        if toc(ttemp)>lastt
            fprintf('%s WAITING FOR LICK %ds...\n',datestr(toc(tstart)/86400,'MM:SS'),lastt);
            lastt = lastt+1;
            if lastt > 30;
                licked = 1;
                data.quitFlag = 1;
            end
        end
    end
    % deliver a small reward
    fprintf('%s INITIATE %1.1fuL\n',datestr(toc(tstart)/86400,'MM:SS'),data.params.lickInitiate)
    if data.response.init_time>0
        outdata = data.card.dio.UserData;
        outdata.dt(1) = data.response.init_time;
        outdata.tstart(1) = NaN;
        data.card.dio.UserData = outdata;
    end

else
    % mouse must stop moving for 1s to initiate trial
    ttemp = tic; ttemp2 = tic;
    lastval = [];
    while toc(ttemp) < data.params.itiDelay
        trackball_keycheck(k);
        newdata = trackball_getdata(2);

        if ~isempty(newdata) && data.params.extenddelay && data.quitFlag==0
            if data.params.lever>0
                if isempty(lastval)
                    lastval = mean(newdata)./data.params.lev_cal;
                elseif max(abs(smooth(newdata,16)./data.params.lev_cal-lastval)) > data.params.lev_still ...
                        || (data.params.lev_touch && min(data.response.touchdata(end-size(newdata,1)+1:end))<1) 
                    if toc(ttemp2) > 1
                        fprintf('%s EXTEND DELAY...\n',datestr(toc(tstart)/86400,'MM:SS'));
                        ttemp2 = tic;
                    end
                    lastval = mean(newdata)./data.params.lev_cal;
                    ttemp = tic;
                end

            elseif abs(newdata(2)) > 1
                if toc(ttemp2) > 1
                    fprintf('%s EXTEND DELAY...\n',datestr(toc(tstart)/86400,'MM:SS'));
                    ttemp2 = tic;
                end
                ttemp = tic;
            end
            if data.params.lever > 0
                curr_baseline = mean(newdata)./data.params.lev_cal;
            end
        end
    end
    if data.params.lever > 0
        fprintf('baseline: %1.1f%%',curr_baseline*100);
    end

end