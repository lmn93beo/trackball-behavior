function psychsr_punish(loop,sound,side)
    
    global data;
    
    if nargin<2
        sound = 1;
    end 
    if nargin<3
        side = 1;
    end
    
    % make sure ao is off, and samples are loaded
    if data.response.mode == 1 || data.response.mode == 3 
        outdata = data.card.dio.UserData;
        outdata.dt(2) = data.response.punish_time;
        outdata.tstart(2) = NaN;
        data.card.dio.UserData = outdata;
        
        % play noise
        psychsr_sound(sound);
        
        data.response.punishs(end+1,side) = loop.prev_flip_time;
        fprintf(' PUNISH %3d',size(data.response.punishs,1))
    elseif data.response.mode == 5 % retract spout (and airpuff if connected)
                
        % retract spout
        psychsr_move_spout(loop,2);
                
        % airpuff
        if data.response.punish_time > 0
            outdata = data.card.dio.UserData;
            outdata.dt(4) = data.response.punish_time;
            outdata.tstart(4) = -(GetSecs + data.response.spout_time);
            data.card.dio.UserData = outdata;
        end
        
        % play noise
        psychsr_sound(sound);
        data.response.punishs(end+1,side) = loop.prev_flip_time;
        fprintf(' PUNISH %3d',size(data.response.punishs,1))        
    elseif data.response.mode == 6 || data.response.mode == 7
        
                
        % dispense quinine
        if data.response.punish_time > 0
            outdata = data.card.dio.UserData;
            outdata.dt(4) = data.response.punish_time;
            outdata.tstart(4) = NaN;
            data.card.dio.UserData = outdata;
            fprintf(' Q');
        end
        
%         % play noise
        psychsr_sound(sound);
        data.response.punishs(end+1,side) = loop.prev_flip_time;
        fprintf(' PUNISH %3d',size(data.response.punishs,1))        
        
    elseif data.response.mode == 8
        
        if length(data.card.dio_ports)==5
            % airpuff
            if data.response.punish_time > 0
                outdata = data.card.dio.UserData;
                outdata.dt(5) = data.response.punish_time;
                outdata.tstart(5) = NaN;
                data.card.dio.UserData = outdata;
            end
        end
        % play noise
        psychsr_sound(sound);
        data.response.punishs(end+1,side) = loop.prev_flip_time;
        fprintf(' PUNISH %3d',size(data.response.punishs,1))   
        
    else
        if strcmp(data.card.ao.Running,'Off') && (data.card.ao.SamplesOutput==0) 
            % airpuff        
            if data.response.mode==1 || (side == 1 && data.response.mode ~= 3)
                start(data.card.ao);                    
            else            
                putsample(data.card.ao,[5,0]);
                WaitSecs(0.004)
                putsample(data.card.ao,[0,0]);            
            end

            % play noise
            psychsr_sound(sound);

            data.response.punishs(end+1,side) = loop.prev_flip_time;        
            fprintf(' PUNISH %3d',size(data.response.punishs,1))

        else
            fprintf(' GRACE2');

        end
    end
    fprintf('\n')

    
end
