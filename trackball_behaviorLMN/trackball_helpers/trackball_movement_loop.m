global data

while choice == 0
    

    % collect serial samples
    n = 0;
    if data.params.lever>0
        newdata = trackball_getdata(2);
        n = n+size(newdata,1);
    else
        while data.serial.in.BytesAvailable > 4
            trackball_keycheck(k);
            newdata = trackball_getdata(2);
            n = n+size(newdata,1);
        end
    end

    % play go cue
    if go == 0 && toc(currT) > data.params.noMvmtTime(abort_flip)
        go = 1;
        data.response.mvmt_delay(k,2) = toc(currT);

        if data.params.go_cue & ~(data.params.early_cue)% == 1                
            if data.params.lever>0 
                if data.params.lev_chirp
                    if data.params.lev_cont==1
                        ix = 20+data.stimuli.loc(k);
                    else
                        ix = 23-data.stimuli.loc(k);
                    end
                else
                    if data.params.lev_cont==1
                        ix = 12+data.stimuli.loc(k);
                    else
                        ix = 15-data.stimuli.loc(k);
                    end
                end
            else
                if data.params.noMvmtTime > 0
                    ix = 14;
                else
                    ix = data.params.earlyCue_sound;
                end
            end
            psychsr_sound(ix);
            data.stimuli.sound(k) = ix;
%             elseif data.params.go_cue==2
%                 psychsr_sound(18+data.stimuli.block(k));
        end
    end

    timePC(end+1) = toc(currT);

    % Pre-movement delay
    if data.params.lever>0
        if n>0                
            d = mean(data.response.mvmtdata(end-n+1:end,:))./data.params.lev_cal - curr_baseline;
            if data.params.lever == 1
                currX = d;                    
            else
                currX = diff(d);
            end
            x = currX * data.stimuli.startPos(1)/max(data.params.lev_thresh);

            x = x + data.stimuli.startPos(data.stimuli.loc(k));
        end
    else
        % integrate values
        if go && n>0
            d_all = data.response.mvmtdata(end-n+1:end,1);
        else
            d_all = 0;
            if ~go && n>0 && data.params.earlyAbort>0 && max(abs(data.response.mvmtdata(end-n+1:end,1)))>data.params.earlyAbort
                choice = 6;
                fprintf('%s PREMVMT EARLY ABORT - %1.2fs\n',datestr(toc(tstart)/86400,'MM:SS'),timePC(end))
            end
        end

        % multiply by gain to get screen position
        if max(data.params.training) > 0 && data.params.proOrienting
            if data.stimuli.loc(k) == 2
                d = sum(d_all(d_all<0))*data.response.gain(2) + sum(d_all(d_all>0))*data.response.gain(1)*data.params.trainingSide(2);
            elseif data.stimuli.loc(k) == 1
                d = sum(d_all(d_all>0))*data.response.gain(1) + sum(d_all(d_all<0))*data.response.gain(2)*data.params.trainingSide(1) ;
            end
        elseif max(data.params.training) > 0
            if data.stimuli.loc(k) == 2
                d = sum(d_all(d_all<0))*data.response.gain(2) + sum(d_all(d_all>0))*data.response.gain(1)*data.params.trainingSide(1);
            elseif data.stimuli.loc(k) == 1
                d = sum(d_all(d_all>0))*data.response.gain(1) + sum(d_all(d_all<0))*data.response.gain(2)*data.params.trainingSide(2) ;
            end
       else
            d = sum(d_all(d_all>0))*data.response.gain(1) + ...
                sum(d_all(d_all<0))*data.response.gain(2);
        end
        if data.params.proOrienting 
            x = d+x;
        else
            x = -d+x;
        end

        % log actual ball movement/time
        currX = -sum(d_all,1) + currX;
    end

    ballX(end+1) = currX;
    samps(end+1) = n;        


    % prevent cursor from moving beyond boundaries
   if sign(x) == sign(data.stimuli.loc(k)-1.5)
        x = 0;
    elseif abs(x) > data.stimuli.stopPos(1);
       x = sign(x)*data.stimuli.stopPos(1);
   end
    screenX(end+1) = x;

    % check for key press
    trackball_keycheck(k);

    %% Define choice threshold and save data when threshold is met.
    dstCenterRect = CenterRectOnPointd(data.stimuli.cursor, xCenter+x, yCenter);

    % check for choice
    if data.params.lever == 0
        if x == 0 % successfully moved to center
            if data.stimuli.loc(k) == 3; choice = 2;
            else choice = data.stimuli.loc(k); end
        elseif abs(x) == data.stimuli.stopPos(1) % moved to end
            if data.stimuli.loc(k) == 3; choice = 1;
            else choice = 3-data.stimuli.loc(k); end
        elseif choice==0 && toc(currT) >= data.params.responseTime
            choice = 5; %5 -- a choice was not made within alloted time
            fprintf('%s TIMEOUT - %1.2fs\n',datestr(toc(tstart)/86400,'MM:SS'),timePC(end))
        end
    elseif data.params.lever == 1
        if data.stimuli.loc(k)==2 && currX > data.params.lev_thresh % GO trial
            choice = 2;
        elseif data.stimuli.loc(k)==1 && abs(currX) > data.params.lev_thresh
            choice = 2;
        elseif choice==0 && toc(currT) >= data.params.responseTime
            if data.stimuli.loc(k) == 1
                choice = 1;
            else
                choice = 5;
                fprintf('%s TIMEOUT - %1.2fs\n',datestr(toc(tstart)/86400,'MM:SS'),timePC(end))
            end
        end

    elseif data.params.lever == 2
        if currX < -data.params.lev_thresh(1)
            choice = 1;
        elseif currX > data.params.lev_thresh(2)
            choice = 2;
        elseif choice==0 && toc(currT) >= data.params.responseTime
            choice = 5; %5 -- a choice was not made within alloted time
            fprintf('%s TIMEOUT - %1.2fs\n',datestr(toc(tstart)/86400,'MM:SS'),timePC(end))
        end
    end

    % update performance markers
    if choice ~= 0 
        switch choice
            case 1; fprintf('%s LEFT - %1.2fs\n',datestr(toc(tstart)/86400,'MM:SS'),timePC(end))
            case 2; fprintf('%s RIGHT - %1.2fs\n',datestr(toc(tstart)/86400,'MM:SS'),timePC(end))
        end
    end           

    % Draw center cursor
    if choice==0
        color = [1 1 1]*grey*(1-data.stimuli.contrast(k)*cos(2*pi*data.params.reversalFreq*toc(currT)));
    else
        color = [1 1 1]*grey*(1-data.stimuli.contrast(k));
    end

%         if sum(data.params.flashStim) > 0
        newdrawFlag = choice < 6 && (stimtime==0 || toc(currT)<stimtime);
%         end

    if newdrawFlag
        trackball_draw(k,x,color);
    end

    newvbl = Screen('Flip', window, vbl + (wait_frames-0.5)*flip_int);
%         fprintf('%2.1f\n',1000*(newvbl-vbl))

    if newdrawFlag ~= drawFlag || length(samps)==1 % stimulus turns ON/OFF
        flips(end+1) = newvbl;
        if drawFlag == 0 % save first flip time
            actdelay = newvbl-vbl;
            if stimtime>0
                fprintf('stim time = %1.3f\n',stimtime);
            end
        end
    end
    vbl = newvbl;
    drawFlag = newdrawFlag;


    if ~laserFlag && (data.params.laser || data.params.laser_blank_only) && sum(data.params.laser_start) > 0 && toc(currT) >= curr_laser_start && data.stimuli.laser(k) == 2 % RH -- laser start after cue onset
        start(data.card.ao);
        fprintf('LASER START TIME -- %d ms\n',curr_laser_start*1000);
        fprintf('LASER ON -- %d ms\n',data.params.laser_time*1000)
        data.response.actualLaserTime(k) = toc(currT);
        data.response.trial_laser_time(k) = curr_laser_start;
        laserFlag = 1;
    end
end