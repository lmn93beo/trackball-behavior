function psychsr_start_presentation_WFscope()

	global data;

%% setup
	% load screen variables    
	win = data.screen.win;
	flip_int = data.screen.flip_int;
    refresh_rate_hz = data.screen.refresh_rate_hz;    
    
    % set presentation frame rate (<= screen refresh rate)
    frame_rate = psychsr_set('presentation','frame_rate',refresh_rate_hz);    
    wait_frames = round(refresh_rate_hz/frame_rate);     
    frame_rate = refresh_rate_hz/wait_frames; % actual frame rate
    data.presentation.frame_rate = frame_rate;
    data.presentation.wait_frames = wait_frames;	    
    
	% time variables
	data.presentation.flip_times = [];
	data.presentation.stim_times = [];
    
	% loop variables
    loop.prev_flip_time = 0; % represents flip time of previous frame
	loop.frame = 0;  % represents current frame # (frame 1 is blank)
	loop.stim = 1;   % represents currently displayed stimulus # 
	loop.theta = 0; % phase of grating
    loop.response = 0; % did animal lick during this frame?
    loop.new_stim = -1; % represents first frame of the current stimulus  
    loop.hide_stim = 0; % hide current stimulus?
    loop.cue = 0; % number of frames for cue
    loop.times = zeros(1,7);
    loop.mean_times = zeros(10,7);
    
	% mark the time
	data.presentation.exact_start = GetSecs;
	data.presentation.start_time = clock;    
    disp(clock)        
	
    vbl = Screen('Flip', win,[],[],[],data.screen.dual*2);    
    % lag = delay between behavior and acquisition
    vbl = vbl + data.presentation.lag; 
    vbl0 = vbl; 
    
%       disp('Press any key to begin')
% %         DisableKeysForKbCheck([13 44 122 123]); % temp fix for problem on Rig 3
%         KbPressWait;    
%         KbReleaseWait;   
	    outputSingleScan(data.StartTrigger,1);
        disp('Triggered')

%% animation loop
	while loop.stim <= data.stimuli.num_stimuli && vbl-vbl0 < data.stimuli.total_duration-1.5*wait_frames*flip_int...
%             && length(data.response.rewards) < data.response.max_rewards
        
        loop.frame = loop.frame + 1;   
        if vbl-vbl0-loop.prev_flip_time>1.5*wait_frames*flip_int
            fprintf('MISSED FLIP')
            fprintf('  %02.1f',1000*(diff(loop.times)-diff(mean(loop.mean_times))))
            fprintf('\n');
        else
            loop.mean_times(mod(loop.frame,10)+1,:) = loop.times;
        end
        loop.prev_flip_time = vbl-vbl0; loop.times(1) = GetSecs;        
        loop = psychsr_prev_stim(loop); % save time points
        
        % draw this frame
        loop = psychsr_draw(loop); loop.times(2) = GetSecs;        
        assignin('base','data',data); 
        
        loop = psychsr_check_response(loop); loop.times(3) = GetSecs; % check for animal response        
        loop = psychsr_user_input(loop); loop.times(4) = GetSecs; % check for keyboard input        		
        loop = data.response.feedback_fn(loop); loop.times(5) = GetSecs; % response feedback       
        loop = psychsr_next_stim(loop); loop.times(6) = GetSecs; % prepare next stimulus
        
        % show current frame at next retrace
        if loop.new_stim == loop.frame 
            % if stimulus onset time, use most accurate flip time
            vbl = Screen('Flip', win, vbl0 + data.stimuli.end_time(loop.stim-1)-0.5*flip_int,[],[],data.screen.dual*2);
            if data.response.mode < 1
                fprintf('STIM %d: %1.4f\n',loop.stim-1,vbl-vbl0)
            end
        else
            vbl = Screen('Flip', win, vbl + (wait_frames-0.5)*flip_int,[],[],data.screen.dual*2);
        end
        
        loop.times(7) = GetSecs;
    end
    
%% cleanup
    % save last flip time
    data.presentation.flip_times(loop.frame+1) = vbl-vbl0;
    
    % final flip
    if data.screen.dual
        Screen('FillRect',data.screen.win2,data.screen.gray);
    end
    vbl = Screen('Flip', win, vbl + (wait_frames-0.5)*flip_int,[],[],data.screen.dual*2);
    data.presentation.end_time = clock;
    data.presentation.flip_times(loop.frame+2) = vbl-vbl0;
	data.presentation.stim_times(loop.stim) = vbl-vbl0;    

end