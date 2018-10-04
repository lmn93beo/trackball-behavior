function psychsr_present()

	global data;

    psychsr_sound(3); % play low tone
    WaitSecs(0.01); % initialize WaitSecs to avoid delays
    
	% OPTION 1: OUT = PsychSR sends a trigger to others, and starts
	% trigger other systems that we are starting and start
	if strcmp(data.card.trigger_mode, 'out') || strcmp(data.card.trigger_mode, 'out-hold')
       
		if data.response.mode
            start(data.card.ai);
        end
        psychsr_start_presentation();
	
	% OPTION 2: IN = PsychSR starts and listens to a trigger on AI0
	% it then starts the board, listening for trigger
	% once started, the board will call the function 'psychsr_start_presentation'
	elseif strcmp(data.card.trigger_mode, 'in')
		start(data.card.ai);
	
    % OPTION 3: KEY = PsychSR waits for keypress (and release)    
    elseif strcmp(data.card.trigger_mode, 'key')        
        
        disp('Press any key to begin')
%         DisableKeysForKbCheck([13 44 122 123]); % temp fix for problem on Rig 3
        KbPressWait;    
        KbReleaseWait;        
        if data.response.mode
            start(data.card.ai);
        end
        psychsr_start_presentation();
        
	% OPTION 4: no triggers, just start as soon as possible
    else
        if data.response.mode
            start(data.card.ai);
        end
        psychsr_start_presentation();
	end
	
end