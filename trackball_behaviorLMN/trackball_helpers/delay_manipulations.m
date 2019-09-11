global data
godelay = delay;
ttemp = tic;    
laserFlag = 0;
while toc(ttemp)<delay && choice == 0
    pause(0.01) % pause allows reward to be administered

    if data.params.preCueEarlyAbort>0  
        newdata = trackball_getdata(2); % -- RH
         if ~isempty(newdata) && abs(newdata(2)) > 1
            choice = 7; %7 = aborted because mvmt during foreperiod -- RH
            fprintf('%s PRECUE EARLY ABORT - %1.2fs\n',datestr(toc(tstart)/86400,'MM:SS'))
         end
    end

    if choice == 0 && data.params.early_cue && ~laserFlag && data.params.laser && data.stimuli.laser(k) == 2 && sum(data.params.laser_start) < 0 
        if toc(ttemp) > delay + data.params.laser_start
            start(data.card.ao)
            data.response.laserTimeAfterBeep(k) = toc(ttemp); %laser start time relative to trial start
            fprintf('LASER ON -- %d s\n',data.params.laser_time)        
            laserFlag = 1;
        end
    end
    trackball_keycheck(k);
end

if ~laserFlag && (data.params.laser || data.params.laser_blank_only) && sum(data.params.laser_start) ==  0 && data.stimuli.laser(k) == 2 && ~data.params.early_cue   
    start(data.card.ao)
    data.response.actualLaserTime(k) = toc(tstart);
    fprintf('LASER ON -- %d s\n',data.params.laser_time)        
elseif ~laserFlag && data.params.laser && sum(data.params.laser_start) < 0 && ~data.params.early_cue     %RH -- start laser before trial start
    if data.stimuli.laser(k) == 2
        start(data.card.ao);
        fprintf('LASER ON -- %d s\n',data.params.laser_time)
    end
    preLaserDelay = tic;
    while toc(preLaserDelay) < abs(data.params.laser_start); end
end