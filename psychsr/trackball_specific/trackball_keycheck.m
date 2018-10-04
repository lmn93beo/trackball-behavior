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

[key_press, ~, key_code] = KbCheck;
free_reward_key = [KbName('control'), KbName('shift'), KbName('w')];
custom_key = [KbName('control'), KbName('shift'), KbName('c')];
slow_quit_key = KbName('escape');
quit_key = [KbName('control'), KbName('shift'), KbName('q')];
next_right_key = [KbName('control'), KbName('shift'), KbName('r')];
next_left_key = [KbName('control'), KbName('shift'), KbName('l')];
sound_key = [KbName('control'), KbName('shift'), KbName('s')];
next_free_key = [KbName('control'), KbName('shift'), KbName('f')];

if key_press
    if min(key_code(free_reward_key))
        if last_press == 0
            psychsr_sound(6);
            fprintf('FREE REWARD\n')
            outdata = data.card.dio.UserData;
            outdata.dt(1) = data.response.reward_time;
            outdata.tstart(1) = NaN;
            data.card.dio.UserData = outdata;
            last_press = 1;
        end
    elseif min(key_code(next_right_key))  % next stim right
        if last_press == 0
            data.stimuli.loc(k+1) = 2;
            
            if data.params.actionValue == 0 && data.params.linkStimAction                
                data.stimuli.id(k+1) = xor(data.stimuli.loc(k+1)-1,data.stimuli.block(k+1)-1)+1;
            end
            
            data.userFlag = k+1;
            fprintf('NEXT STIM RIGHT\n')
            last_press = 1;
        end
    elseif min(key_code(next_left_key)) % next stim left
        if last_press == 0
            data.stimuli.loc(k+1) = 1;
            
            if data.params.actionValue == 0 && data.params.linkStimAction                
                data.stimuli.id(k+1) = xor(data.stimuli.loc(k+1)-1,data.stimuli.block(k+1)-1)+1;
            end
            
            data.userFlag = k+1;
            fprintf('NEXT STIM LEFT\n')
            last_press = 1;
        end
    elseif min(key_code(next_free_key))
        if last_press == 0
            data.stimuli.loc(k+1) = 3;
            
            if data.params.actionValue == 0 && data.params.linkStimAction                
                data.stimuli.id(k+1) = 3-data.stimuli.block(k+1);
            end
            
            data.params.freeBlank = 1;
            data.userFlag = k+1;
            fprintf('NEXT STIM FREE\n')
            last_press = 1;
        end
    elseif min(key_code(sound_key))
        if last_press == 0
            psychsr_sound(6);
            last_press = 1;
        end
    elseif min(key_code(custom_key))
        if last_press == 0
            clear trackball_custom_code;
            trackball_custom_code(k);
            last_press = 1;
        end        
        % Hold Escape for 1 second to exit
    elseif min(key_code(slow_quit_key))
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
    elseif min(key_code(quit_key))
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