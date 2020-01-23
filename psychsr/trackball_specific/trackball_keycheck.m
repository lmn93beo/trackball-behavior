function trackball_keycheck(k)

% k: trial number
% Check which key has been pressed and performs the corresponding action
% ------------- List of keys: --------------------
% 'w' - free reward
% 'escape' - quit after 1s hold
% 't' - toggle sides 100% L or 100% R
% 'q' - quit
% 'r' - next stim right
% 'l' - next stim left
% 's' - sound
% 'f' - next stim free
% 'c' - custom
% 'g/h' - increment/decrement perRight by 0.1
% 'z/x' - increment/decrement reward (multiply or divide by 2)
% 'm/n' - increment/decrement antibiasRepeat by 0.1
% --------------------------------------------------

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




if key_press
    key_id_lst = find(key_code);

    switch key_id_lst(1)
        % 'w' - free reward
        case KbName('w')
            if last_press == 0
                psychsr_sound(6);
                fprintf('FREE REWARD\n')
                outdata = data.card.dio.UserData;
                outdata.dt(1) = data.response.reward_time;
                outdata.tstart(1) = NaN;
                data.card.dio.UserData = outdata;
                last_press = 1;
            end
            
        % 'r' - next stim right
        case KbName('r')  
            if last_press == 0
                data.stimuli.loc(k+1) = 2;

                if data.params.actionValue == 0 && data.params.linkStimAction                
                    data.stimuli.id(k+1) = xor(data.stimuli.loc(k+1)-1,data.stimuli.block(k+1)-1)+1;
                end

                data.userFlag = k+1;
                fprintf('NEXT STIM RIGHT\n')
                last_press = 1;
            end
            
        % 'l' - next stim left
        case KbName('l')
            if last_press == 0
                data.stimuli.loc(k+1) = 1;

                if data.params.actionValue == 0 && data.params.linkStimAction                
                    data.stimuli.id(k+1) = xor(data.stimuli.loc(k+1)-1,data.stimuli.block(k+1)-1)+1;
                end

                data.userFlag = k+1;
                fprintf('NEXT STIM LEFT\n')
                last_press = 1;
            end
            
        % 'f' - next stim free
        case KbName('f')
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
            
        % 's' - play sound
        case KbName('s')
            if last_press == 0
                psychsr_sound(6);
                last_press = 1;
            end
            
        % 'c' - custom code
        case KbName('c')
            if last_press == 0
                clear trackball_custom_code;
                trackball_custom_code(k);
                last_press = 1;
            end
            
        % Hold Escape for 1 second to exit
        case KbName('escape')
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
            
        % 'q' - exit
        case KbName('q')
            if last_press == 0
                data.quitFlag = 2;
                disp('QUIT')
                last_press = 1;
            end;
            
        % 'x' - increment reward
        case KbName('x')
            if last_press == 0
                data.params.reward = data.params.reward * 1.25;
                fprintf('reward incremented to %d\n', ...
                    data.params.reward);
                last_press = 1;
            end
            
        % 'z' - decrement reward
        case KbName('z')
            if last_press == 0
                data.params.reward = data.params.reward / 1.25;
                fprintf('reward decremented to %d\n', ...
                    data.params.reward);
                last_press = 1;
            end
            
        % 'h' - increment perRight
        case KbName('h')
            if last_press == 0
                data.params.trainingSide = min(data.params.trainingSide + 0.1, 1);
                fprintf('trainingSide incremented to %.2f\n', ...
                    data.params.trainingSide);
                
                % Re-populate data.stimuli.loc
%                 maxrepeat = floor(log(0.125)/log(abs(data.params.perRight-0.5)+0.5)); 
%                 if maxrepeat<0; maxrepeat = Inf; end;
%                 
%                 data.stimuli.loc((k+1):end) = ...
%     psychsr_rand(1-data.params.perRight,data.params.numTrials - k,0,maxrepeat);
                
                
                last_press = 1;
            end
            
        % 't' - toggle 100% L or 100% R
        case KbName('t')
            if data.stimuli.loc(k) == 1
                data.stimuli.loc(k+1:end) = 2;
                disp('Stimulus type toggled to ALL RIGHT')
            elseif data.stimuli.loc(k) == 2
                data.stimuli.loc(k+1:end) = 1;
                disp('Stimulus type toggled to ALL LEFT')
            end
                
        % 'g' - decrement perRight
        case KbName('g')
            if last_press == 0
                data.params.trainingSide = max(data.params.trainingSide - 0.1, 0);
                fprintf('trainingSide decremented to %.2f\n', ...
                    data.params.trainingSide);
                
                % Re-populate data.stimuli.loc
%                 maxrepeat = floor(log(0.125)/log(abs(data.params.perRight-0.5)+0.5)); 
%                 if maxrepeat<0; maxrepeat = Inf; end;
%                 
%                 data.stimuli.loc((k+1):end) = ...
%     psychsr_rand(1-data.params.perRight,data.params.numTrials - k,0,maxrepeat);
                
                last_press = 1;
            end
            
        % 'm' - increment antibiasRepeat
        case KbName('m')
            if last_press == 0
                data.params.antibiasRepeat = ...
                    min(data.params.antibiasRepeat + 0.1, 1);
                fprintf('antibiasRepeat incremented to %.2f\n', ...
                    data.params.antibiasRepeat);
                last_press = 1;
            end
        
        % 'n' - decrement antibiasRepeat
        case KbName('n')
            if last_press == 0
                data.params.antibiasRepeat = ...
                    max(data.params.antibiasRepeat - 0.1, 0);
                fprintf('antibiasRepeat incremented to %.2f\n', ...
                    data.params.antibiasRepeat);
                last_press = 1;
            end
    end
    
else
    last_press = 0;
    hold = 0;
end
