function psychsr_reward_calibrate()
folder = psychsr_go_root();

    global data;
    data = struct;
    %% setup
    data.sound.pahandle = 0;
    data.sound.tone = 0;
    data.sound.tone_amp = 0.15;        
	data.sound.tone_time = 0.5;
    data.sound.buffers = 0;
    
    data.response.mode = 6;
    
    data.response.prime = 0;
    data.response.ao_mode = 'putsample';
    data.response.rewards = [];	
    data.response.reward_type = 'water';
	
    data.response.punishs = [];
    data.response.punish_time = 0.1;
   
    psychsr_sound_setup();

    loop.prev_flip_time = 0;
    
    repeat = 1;
    w = [];
    nopen = 50;
    
    %% test airpuff    
%     airpuff = input('Test airpuff? (0/[1]): ');    
%     if isempty(airpuff)
%         airpuff = 1;
%     end
%     if airpuff
%         for i = 1:10
%             data.response.punish_time = 0.1;
%             psychsr_punish(loop,0);
%             pause(2.2)
%             
%             data.response.punish_time = 1;
%             psychsr_punish(loop,1);
%             pause(2.2)
%         end
%     end
    
    %% user input
       
    quinine = input('Reward ([0]) or Quinine (1)?: '); 
    
    if isempty(quinine) || ~quinine
        load(fullfile(folder, 'psychsr/psychsr_reward_paramsLMN.mat'));
    else
        load psychsr_quinine_params;
    end        
    ndt = 4;
    psychsr_card_setup();
    
    id = find(strcmp(getenv('computername'),{params.pc}));
    if isempty(id)
        id = length(params)+1;
        params(id).pc = getenv('computername');
    end
    fprintf('%s\n',params(id).pc);
    fprintf('dt    dw\n');
    fprintf('--    --\n');
    fprintf('%2d    %2.1f\n',[params(id).dt;params(id).dw]);
    fprintf('\n');
            
    prev_dt = input('Use previous dt values? (0/[1]): ');    
    if isempty(prev_dt) || prev_dt
        dt = params(id).dt(1:ndt);
    else
        for i = 1:ndt
            dt(i) = input(sprintf('dt(%d): ',i));
        end
    end      
    
    
    %% output water
    while repeat
        output_water = input('Output water? (0/[1]): ');
        if isempty(output_water) || output_water
            for j = 1:length(dt)
                if isempty(quinine) || ~quinine
                    data.response.reward_time = dt(j)/1000;
                else
                    data.response.punish_time = dt(j)/1000;
                end
                input('Press when ready: ');    
                for i = 1:nopen
                    if isempty(quinine) || ~quinine
                        psychsr_reward(loop,0);
                    else
                        psychsr_punish(loop,0);
                    end
                    pause(0.5)
                    
                end
                for i = 1:3
                    psychsr_sound(6);
                    pause (0.2)
                end
                pause(5)
            end
        end
        disp('Enter cumulative water amounts (mL):')
        for i = 1:ndt
            w = [w, input(sprintf('w(%d): ',i))];
        end
        w(end-ndt+1:end) = diff([0 w(end-ndt+1:end)]);
        repeat = input('Repeat measurements? ([0]/1): ');    
        if isempty(repeat)
            repeat = 0;
        end
    end    
    dt = repmat(dt,1,length(w)/length(dt));
    
    %% calculate and save
    dw = w / nopen * 1000;    
    b = polyfit(dw,dt,1);
    close all
    figure
    plot(dt,dw,'*')
    hold on;
    x = [min(dw),max(dw)];
    plot(x*b(1)+b(2),x,'--');
    
    if ~isempty(params(id).dw)
        x2 = [min(params(id).dw),max(params(id).dw)];
        plot(x2*params(id).b(1)+params(id).b(2),x2,'r--')
    end
    axis normal
    xlabel('Solenoid ON time (ms)')
    ylabel('Water amount (uL)')
    legend('Data',sprintf('t = %1.2f*w+%1.2f',b(1),b(2)),'Location','SouthEast')
    
    s = input('Save? (0/[1]): ');
    if isempty(s) || s
        params(id).date = clock;
        params(id).dt = dt;
        params(id).w = w;
        params(id).dw = dw;
        params(id).b = b;        
        if isempty(quinine) || ~quinine
            save('./psychsr/psychsr_reward_paramsLMN','params');
        else
            save('./psychsr/psychsr_quinine_params','params');            
        end
    end    
    
    stop(data.card.ai)
    delete(data.card.ai)    
    stop(data.card.dio)
    delete(data.card.dio)
end
    
    
