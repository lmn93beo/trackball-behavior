function trackball_keycheck(k)

persistent last_press
persistent hold
if isempty(last_press)
    last_press = 0;
end
if isempty(hold)
    hold = 0;
end
global data;

[key_press, time, key_code] = KbCheck;
key_1 = [KbName('control'), KbName('shift'), KbName('w')];
key_2 = [KbName('control'), KbName('shift'), KbName('c')];
key_3 = KbName('escape');
key_4 = [KbName('control'), KbName('shift'), KbName('-_')];
key_9 = [KbName('control'), KbName('shift'), KbName('q')];
key_5 = [KbName('control'), KbName('shift'), KbName('r')];
key_6 = [KbName('control'), KbName('shift'), KbName('l')];
key_7 = [KbName('control'), KbName('shift'), KbName('s')];
key_8 = [KbName('control'), KbName('shift'), KbName('f')];

if key_press
    if min(key_code(key_1))
        if last_press == 0
            psychsr_sound(6);
            fprintf('FREE REWARD\n')
            outdata = data.card.dio.UserData;
            outdata.dt(1) = data.response.reward_time;
            outdata.tstart(1) = NaN;
            data.card.dio.UserData = outdata;
            last_press = 1;
        end
    elseif min(key_code(key_5))  % next stim right
        if last_press == 0
            data.stimuli.loc(k+1) = 2;
            
            if data.params.actionValue == 0 && data.params.linkStimAction                
                data.stimuli.id(k+1) = xor(data.stimuli.loc(k+1)-1,data.stimuli.block(k+1)-1)+1;
            end
            
            data.userFlag = k+1;
            fprintf('NEXT STIM RIGHT\n')
            last_press = 1;
        end
    elseif min(key_code(key_6)) % next stim left
        if last_press == 0
            data.stimuli.loc(k+1) = 1;
            
            if data.params.actionValue == 0 && data.params.linkStimAction                
                data.stimuli.id(k+1) = xor(data.stimuli.loc(k+1)-1,data.stimuli.block(k+1)-1)+1;
            end
            
            data.userFlag = k+1;
            fprintf('NEXT STIM LEFT\n')
            last_press = 1;
        end
    elseif min(key_code(key_8))
        if last_press == 0
            data.stimuli.loc(k+1) = 3;
            
            if data.params.actionValue == 0 && data.params.linkStimAction                
                data.stimuli.id(k+1) = 3-data.stimuli.block(k+1);
            end
            
            data.userFlag = k+1;
            fprintf('NEXT STIM FREE\n')
            last_press = 1;
        end
    elseif min(key_code(key_7))
        if last_press == 0
            psychsr_sound(6);
            last_press = 1;
        end
    elseif min(key_code(key_2))
        if last_press == 0
            clear trackball_custom_code;
            trackball_custom_code(k);
            last_press = 1;
        end        
        % Hold Escape for 1 second to exit
    elseif min(key_code(key_3))
        if hold == 0
            hold = tic;
        elseif toc(hold) > 1 && last_press == 0
            data.quitFlag = 2;
            disp('QUIT')
            last_press = 1;
            hold = 0;
        end        
%     elseif min(key_code(key_4))
%         if last_press == 0
%             data.easygain = data.easygain - 0.1;
%             fprintf('Easygain decreased to %1.2f\n',data.easygain);
%             last_press = 1;
%         end
        % ctrl+shift+q to exit
    elseif min(key_code(key_9))
        if last_press == 0
            data.quitFlag = 2;
            disp('QUIT')
            last_press = 1;
        end;
    end
else
    last_press = 0;
    hold = 0;
end