function psychsr_reward_test()
psychsr_go_root();

    global data;
    data = struct;
    %% setup
    data.sound.pahandle = 0;
    data.sound.tone = 0;
    data.sound.tone_amp = 0.15;        
	data.sound.tone_time = 0.5;
    data.sound.buffers = 0;
    
    data.response.mode = 1;
    
    data.response.prime = 0;
    data.response.ao_mode = 'putsample';
    data.response.rewards = [];	
    data.response.reward_type = 'water';
	
    data.response.punishs = [];
    data.response.punish_time = 0.25;
   
    psychsr_sound_setup();

    loop.prev_flip_time = 0;
  
    %% user input
    quinine = input('Reward ([0]) or Quinine (1)?: '); 
    
    if isempty(quinine) || ~quinine
        load psychsr_reward_params;
    else
        load psychsr_quinine_params;
        if strcmp(getenv('computername'),'VISSTIM-2P4')
            data.card.dio_ports = [0 2]; % test second solenoid
            data.card.dio_lines = [1 4];            
        else
            data.card.dio_ports = [2 2]; % test second solenoid
            data.card.dio_lines = [5 4];
        end
    end
    psychsr_card_setup();
    
    
    amt = input('Amount (uL): ');     
    
    if isempty(quinine) || ~quinine        
        [amt time] = psychsr_set_reward(amt);
    else
%         time = 0.25;
        [amt time] = psychsr_set_quinine(amt);       
    end    
    
    if isnan(amt)
        return;
    end    
    
    data.response.reward_time = time;
%     data.response.reward_amt = amt;

    KbName('UnifyKeyNames');
    for i = 1:100
        psychsr_reward(loop,0);    
%         pause(0.5);
        tstart = tic;
        while toc(tstart)<0.5
            [key,~,keyCode] = KbCheck;
            pause(0.05)
            if keyCode(KbName('escape'))
                disp('Done.')
                return
            end
        end
%         psychsr_punish(loop,1);
%         if(data.card.ao.SamplesOutput==0) % just in case ao already running
%             start(data.card.ao);            
%         end
%         pause(2)
    end
    
    stop(data.card.ai)
    delete(data.card.ai)
    stop(data.card.dio)
    delete(data.card.dio)
%     delete(data.card.ao)
end
    
    
