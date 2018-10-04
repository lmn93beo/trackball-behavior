function new_loop = psychsr_user_input(loop)
    
    global data;
    persistent last_press;
    if isempty(last_press)
        last_press = 0;
    end
    KbName('UnifyKeyNames');
    [key_press, time, key_code] = KbCheck;
    
    key_1 = [KbName('control'), KbName('shift'), KbName('r')];
    key_2 = [KbName('control'), KbName('shift'), KbName('=+')];
    key_3 = KbName('escape');
    key_4 = [KbName('control'), KbName('shift'), KbName('-_')];
    key_5 = [KbName('control'), KbName('shift'), KbName('l')];
    key_6 = [KbName('control'), KbName('shift'), KbName('t')];
    key_7 = [KbName('control'), KbName('shift'), KbName('n')];
    key_8 = [KbName('control'), KbName('shift'), KbName('c')];
    key_9 = [KbName('control'), KbName('shift'), KbName('q')];
    key_10 = [KbName('control'), KbName('shift'), KbName('f')];
    key_11 = [KbName('control'), KbName('shift'), KbName('s')];
    key_12 = [KbName('control'), KbName('shift'), KbName('p')];
    key_13 = [KbName('control'), KbName('shift'), KbName('1!')];
    key_14 = [KbName('control'), KbName('shift'), KbName('2@')];
    key_15 = [KbName('control'), KbName('shift'), KbName('i')];
    key_16 = [KbName('alt'), KbName('shift'), KbName('l')];
    key_17 = [KbName('alt'), KbName('shift'), KbName('r')];
    
    if key_press   
%         disp(KbName(key_code))
        % Ctrl+R = reward
        if min(key_code(key_1))            
            if last_press == 0
                if data.response.mode == 8    % dual lick - next stim RIGHT
                    ix = loop.stim+3-mod(loop.stim,3);
                    data.stimuli.stim_id(ix) = 2;
                    fnames = fieldnames(data.stimuli.stimparams);
                    for f = 1:length(fnames)
                        data.stimuli.(fnames{f})(ix) = data.stimuli.stimparams(2).(fnames{f});
                    end
                    disp('NEXT STIM: RIGHT')
                    last_press = 1;
                else
                    fprintf('%s FREE',datestr(loop.prev_flip_time/86400,'MM:SS'));
                    if data.response.mode == 2
                        psychsr_reward(loop,0,2);
                    else
                        psychsr_reward(loop,0);
                    end
                    data.response.primes(end+1) = loop.prev_flip_time;
                    disp('PRIME');
                    last_press = 1;
                end
            end
        elseif min(key_code(key_2))
            if last_press == 0
                if strcmp('free',data.stimuli.stim_type{loop.stim})
                    data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)+30;
                    data.stimuli.end_time = cumsum(data.stimuli.duration);
                    fprintf('EXTENDED FREE TO %d\n',data.stimuli.duration(loop.stim))
                end
                last_press = 1;
            end
            
            % Hold Escape for 1 second to exit
        elseif min(key_code(key_3)) 
            if last_press > data.presentation.frame_rate
                psychsr_sound(3);
                data.stimuli.total_duration = loop.prev_flip_time;
                last_press = 1;
            end
            last_press = last_press+1;            
            data.response.notify = '0';
            % ctrl+shift+q to exit
        elseif min(key_code(key_9))
            if last_press == 0
                psychsr_sound(3);
                data.stimuli.total_duration = loop.prev_flip_time;
                last_press = 1;
            end
            data.response.notify = '0';
        
        elseif min(key_code(key_4))
            if last_press == 0
                if strcmp('free',data.stimuli.stim_type{loop.stim})                    
                    time_shift = data.stimuli.end_time(loop.stim)-loop.prev_flip_time;
                    data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)-time_shift;
                    data.stimuli.end_time = cumsum(data.stimuli.duration);
                    fprintf('STOPPED FREE TIME AT %d\n',round(data.stimuli.duration(loop.stim)))
                end
                last_press = 1;        
            end
        elseif min(key_code(key_5))
            if last_press == 0
                if data.response.mode == 8    % dual lick - next stim LEFT
                    ix = loop.stim+3-mod(loop.stim,3);
                    data.stimuli.stim_id(ix) = 1;
                    fnames = fieldnames(data.stimuli.stimparams);
                    for f = 1:length(fnames)
                        data.stimuli.(fnames{f})(ix) = data.stimuli.stimparams(1).(fnames{f});
                    end
                    disp('NEXT STIM: LEFT')
                    last_press = 1;
                else                
                    loop.response = 1;
                    data.response.licks(end+1,1) = loop.prev_flip_time;
                    last_press = 1;
                    if isfield(data.response,'manualLick')
                        data.response.manualLick(end+1) = loop.prev_flip_time;
                    end
                end
            end
        elseif min(key_code(key_6))
            if last_press == 0
                ix = loop.stim+3-mod(loop.stim,3);
                data.stimuli.stim_type{ix} = 'grating';
                
                if isfield(data.stimuli,'stimparams')                                        
                    data.stimuli.stim_id(ix) = 1;
                    fnames = fieldnames(data.stimuli.stimparams);
                    for f = 1:length(fnames)
                        data.stimuli.(fnames{f})(ix) = data.stimuli.stimparams(1).(fnames{f});
                    end
                else
                    data.stimuli.orientation(ix)=data.response.t_ori;
                    if data.stimuli.contrast(ix) == -1
                        data.stimuli.contrast(ix) = 1;
                    end
                    data.stimuli.temp_freq(ix)=max(data.stimuli.temp_freq);
                end
                
                disp('NEXT STIM: TARGET')
                last_press = 1;
            end
        elseif min(key_code(key_7))
            if last_press == 0
                ix = loop.stim+3-mod(loop.stim,3);
                data.stimuli.stim_type{ix} = 'grating';    
                if isfield(data.stimuli,'stimparams')                                        
                    data.stimuli.stim_id(ix) = 2;
                    fnames = fieldnames(data.stimuli.stimparams);
                    for f = 1:length(fnames)
                        data.stimuli.(fnames{f})(ix) = data.stimuli.stimparams(2).(fnames{f});
                    end
                else
                    if min(data.stimuli.contrast) == -1 && max(data.stimuli.orientation~=data.response.t_ori & data.stimuli.contrast~=-1) == 0
                        data.stimuli.contrast(ix) = -1;
                    end
                    ntori = data.stimuli.orientation(~isnan(data.stimuli.orientation) & data.stimuli.orientation~=data.response.t_ori);
                    data.stimuli.orientation(ix)=ntori(randi(length(ntori)));
                    data.stimuli.temp_freq(ix)=min(data.stimuli.temp_freq(3:3:end));
                end
                
                disp('NEXT STIM: NONTARGET')
                last_press = 1;
            end
            
        elseif min(key_code(key_8))
            if last_press ==0
                clear psychsr_custom_code;
                loop = psychsr_custom_code(loop);
                last_press = 1; 
            end
        elseif min(key_code(key_10))
            if last_press == 0
                fprintf('%s FREE',datestr(loop.prev_flip_time/86400,'MM:SS'));    
                psychsr_reward(loop,0,1);
                last_press = 1;
            end       
            
        elseif min(key_code(key_11))
            if last_press == 0
                fprintf('%s BEEP\n',datestr(loop.prev_flip_time/86400,'MM:SS'));    
                psychsr_sound(6);
                last_press = 1;
%                 data.stimuli.num_licks(loop.stim) = 0;    
%                 if isfield(data.response,'lickside')
%                     if data.response.lickside == 0
%                         data.response.lickside = 2;
%                     else
%                         data.response.lickside = 3-data.response.lickside;
%                     end
%                 end
            end
            
        elseif min(key_code(key_12))
            if last_press == 0
                disp('PAUSE')
                tstart = tic;
                while true
                    [key,x,keyCode] = KbCheck;
                    pause(0.05)
                    if keyCode(KbName('escape'))
                        disp('Done.')
                        break
                    end
                end
                timeout = toc(tstart);
                data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)+timeout;
                data.stimuli.end_time = cumsum(data.stimuli.duration);
                data.stimuli.total_duration = data.stimuli.total_duration+timeout;
            end           
            
            
        elseif min(key_code(key_13)) && data.response.mode == 8           
            if last_press == 0
                fprintf('%s FREE LEFT',datestr(loop.prev_flip_time/86400,'MM:SS'));                
                psychsr_reward(loop,0,[],1);
                data.response.primes(end+1,1) = loop.prev_flip_time;
                disp('PRIME');                      
                last_press = 1;                 
            end
        elseif min(key_code(key_14)) && data.response.mode == 8           
            if last_press == 0
                fprintf('%s FREE RIGHT',datestr(loop.prev_flip_time/86400,'MM:SS'));                
                psychsr_reward(loop,0,[],2);
                data.response.primes(end+1,2) = loop.prev_flip_time;
                disp('PRIME');                      
                last_press = 1;                 
            end
        elseif min(key_code(key_15)) && data.response.mode == 8
            if last_press == 0
                if mod(loop.stim,3) == 1
                    fprintf('%s MANUAL EXTEND ITI\n',datestr(loop.prev_flip_time/86400,'MM:SS'));
                    timeout = 2;
                    data.stimuli.duration(loop.stim) = data.stimuli.duration(loop.stim)+timeout;
                    data.stimuli.end_time = cumsum(data.stimuli.duration);
                    data.stimuli.total_duration = data.stimuli.total_duration+timeout;
                    last_press = 1;
                end
            end
        elseif min(key_code(key_16)) && data.response.mode == 8
            if last_press == 0
                loop.response = [1 0];
                data.response.licks(end+1,:) = [loop.prev_flip_time 0];
                last_press = 1;
                if isfield(data.response,'manualLick')
                    data.response.manualLick(end+1,:) = [loop.prev_flip_time 0];
                end                
            end
        elseif min(key_code(key_17)) && data.response.mode == 8
            if last_press == 0
                loop.response = [0 1];
                data.response.licks(end+1,:) = [0 loop.prev_flip_time];
                last_press = 1;
                if isfield(data.response,'manualLick')
                    data.response.manualLick(end+1,:) = [0 loop.prev_flip_time];
                end                
            end
            
        % reset
        else
            last_press = 0;        
        end
        
    else
        last_press = 0;
    end
    
    new_loop = loop;
    
end