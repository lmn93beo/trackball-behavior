function psychsr_reward_test2()

    global data;
    
%     reward = input('Reward (uL): ');
%         disp('Set reward amount manually; press enter when finished.')
%         pause;
        data.response.reward_time = .004;%0.025; 
%         data.response.reward_amt = reward;

%         time_s = [10 , 8.0, 6.0, 4.0]/1000;
%         rew_ul = [8.0, 6.5, 5.0, 2.5];
%         b = polyfit(rew_ul,time_s,1);    
%         data.response.reward_time = reward*b(1)+b(2);
%         data.response.reward_time = round(data.response.reward_time*2000)/2000;
%         data.response.reward_amt = (data.response.reward_time-b(2))/b(1);
%         fprintf('Reward set to %2.1fms --> %3.2fuL; press enter to confirm.\n',...
%             data.response.reward_time*1000,data.response.reward_amt);
%         pause;
    
    data.sound.pahandle = 0;
    data.sound.tone = 0;
    data.sound.tone_amp = 0.5;        
	data.sound.tone_time = 0.5;
    data.sound.buffers = 0;
    
    data.response.mode = 2;
    data.response.prime = 0;
    data.response.ao_mode = 'putsample';
    data.response.rewards = [];	
    data.response.reward_type = 'water';
	
    data.response.punishs = [];
    data.response.punish_time = 0.05;
    
%     data.card.ao_chan = 1;

    psychsr_sound_setup();
    psychsr_card_setup();
    loop.prev_flip_time = 0;
    
    for i = 1:100
%         psychsr_reward(loop,0,1);                
%         psychsr_punish(loop,6,1);
%         pause(0.5)
        psychsr_reward(loop,0,2);                
%         psychsr_punish(loop,0,2);
        pause(0.2)
    end
    
    stop(data.card.ai)
    delete(data.card.ai)
    delete(data.card.ao)
end
    
    
