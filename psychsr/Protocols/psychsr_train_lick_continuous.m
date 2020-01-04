function psychsr_train_lick_continuous()
psychsr_go_root();

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
    nopen = 200;
    
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
             
    
    psychsr_card_setup();
    
    
          
    
    
    %% output water
    rewardAmt = input('Water amount: ');
    [amt time b] = psychsr_set_reward(rewardAmt); %was hardset to 4
    data.response.reward_time = time;
    
    input('Press when ready: ');    
    for i = 1:nopen
        
        psychsr_sound(6);
        pause(0.2);
        psychsr_reward(loop,0);
        
        
        pause(10)

    end
    for i = 1:3
        psychsr_sound(6);
        pause (0.2)
    end
    pause(5)

    disp('Protocol finished');
    stop(data.card.ai)
    delete(data.card.ai)    
    stop(data.card.dio)
    delete(data.card.dio)
end
    
    
