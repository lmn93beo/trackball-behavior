% Setup PsychToolbox windows/screens

function psychsr_screen_setup()
% opens psychtoolbox window and sets parameters

	global data;
	
	AssertOpenGL;
    
%% set pc-specific information
    data.screen.pc = getenv('computername');
    if strcmp(data.screen.pc,'BEHAVIOR1')
        data.screen.id = 1;      
        data.screen.id2 = 2;
        psychsr_set('screen','width_cm', 15.2);
        psychsr_set('screen','height_cm', 9.2);
        psychsr_set('screen','distance_cm', 9);
        psychsr_set('screen','gammacorrect',1);
		if data.screen.gammacorrect
			load GammaB1
        end
        Screen('Preference', 'SkipSyncTests', 1);
        
    elseif strcmp(data.screen.pc,'BEHAVIOR2')
        data.screen.id = 2;
        data.screen.id2 = 1;
        psychsr_set('screen','width_cm', 15.2);
        psychsr_set('screen','height_cm', 9.2);
        psychsr_set('screen','distance_cm', 9);
        psychsr_set('screen','gammacorrect',1);
		if data.screen.gammacorrect
			load GammaB2
        end
        
        if data.response.mode == 8
            psychsr_set('card','ai_chan',[3 0]);
        end
        
    elseif strcmp(data.screen.pc,'BEHAVIOR3')
% *** 07/15/2016 HS ***
        data.screen.id  = 2; 
        data.screen.id2 = 1;    
%         data.screen.id = 3; 
%         data.screen.id2 = 2;    
% *** 07/15/2016 HS ***
        psychsr_set('screen','width_cm', 15.2);
        psychsr_set('screen','height_cm', 9.2);
        psychsr_set('screen','distance_cm', 9);
        psychsr_set('screen','gammacorrect',1);
		if data.screen.gammacorrect
			load GammaB3
		end
        
    elseif strcmp(data.screen.pc,'RAINBOW')
        data.card.id = 'Dev3';
		if max(Screen('Screens')) > 0
			data.screen.id = 2;
		else
			data.screen.id = 0;			
	        data.screen.keep  = 0;
		end
		data.presentation.frame_rate = 30;
        data.presentation.lag = 0.03;
		psychsr_set('card','trigger_port',1);
        psychsr_set('card','trigger_line',0);

		psychsr_set('screen','width_cm', 15.2);
        psychsr_set('screen','height_cm', 9.2);
        psychsr_set('screen','distance_cm', 4.5);
		
%         psychsr_set('screen','width_cm', 51);
%         psychsr_set('screen','height_cm', 29);%30.2);
%         psychsr_set('screen','distance_cm', 14.3);%28);
		psychsr_set('screen','gammacorrect',1);
		if data.screen.gammacorrect
			load Gamma2P3
		end
        
    elseif strcmp(data.screen.pc,'GERALD-THINK')        
        data.card.name = 'winsound';
        data.card.id = 0;
        data.card.ai_chan = 1;
        data.card.ai_fs = 8000;
        data.screen.id = max(Screen('Screens'));
        Screen('Preference', 'SkipSyncTests', 1);
        
    elseif strcmp(data.screen.pc,'VISSTIM-2P4')
%         data.screen.id = 0;			
%         data.screen.keep  = 0;
        data.card.id = 'Dev1';
        data.presentation.frame_rate = 30;        
        psychsr_set('presentation','lag', 0.025);
        psychsr_set('screen','width_cm', 15.2);
        psychsr_set('screen','height_cm', 9.2);
        psychsr_set('screen','distance_cm', 9);
        
        psychsr_set('screen','gammacorrect',1);
		if data.screen.gammacorrect
			load Gamma2P4
        end
        
        if data.response.mode == 8
            psychsr_set('card','ai_chan',[1 3]);
        end
    elseif strcmp(data.screen.pc,'BEHAVE-BALL1');
        data.screen.id = 2;
        data.card.dio_ports = [1,2];
        data.card.dio_lines = [0 4];
        Screen('Preference', 'SkipSyncTests', 1);

    elseif strcmp(data.screen.pc,'BEHAVE-BALL2')
        data.screen.id = 1;
        data.card.dio_ports = [1 2]; % test second solenoid
        data.card.dio_lines = [1 4];
        Screen('Preference', 'SkipSyncTests', 1);
        
    elseif strcmp(data.screen.pc,'BEHAVE-BALL3')
        data.screen.id = 1;
        data.card.dio_ports = [1 2]; % test second solenoid
        data.card.dio_lines = [0 4];
        
    elseif strcmp(data.screen.pc,'WFSTIM')
        data.screen.id = 1;
        
        data.card.id = 'Dev1';
        data.presentation.frame_rate = 30;        
        psychsr_set('presentation','lag', 0.025);
        psychsr_set('screen','width_cm', 15.2);
        psychsr_set('screen','height_cm', 9.2);
        psychsr_set('screen','distance_cm', 9);
        
        Screen('Preference', 'SkipSyncTests', 1);
    end

%% open windows
    % which and how many screens?
    psychsr_set('screen','dual',0); % default is 0
	id = psychsr_set('screen','id',max(Screen('Screens')));
    if data.screen.dual
        id2 = psychsr_set('screen','id2',max(Screen('Screens'))-1);
        % refresh rate, screen resolution and color depth must be the same!
    end
    
    % get refresh rate
    data.screen.refresh_rate_hz = Screen('FrameRate', id); 
        
	% define the screen resolution
	[data.screen.width_pixels, data.screen.height_pixels] = Screen('WindowSize', id);
    
	% define color values
	data.screen.white = WhiteIndex(id);
	data.screen.black = BlackIndex(id);
	data.screen.gray = round((data.screen.white + data.screen.black)/2);	
    data.screen.inc=data.screen.white-data.screen.gray;
	
	% define the screen size and position	
    if ~isfield(data.screen,'pixels_per_degree')    
        psychsr_set('screen','width_cm', 37.6); %15.2
        psychsr_set('screen','height_cm', 30.1); %9.1
        psychsr_set('screen','distance_cm', 57); %9.9   
        psychsr_calibrate_screen(); % converts pixels to degrees
    end  
    
    % use screen timing pixels?
    psychsr_set('screen','timing_pixels',0);
                
%% keep windows open?
    % keep screen open after program runs?
    keep = psychsr_set('screen','keep',0);    
    
    % get currently open windows
    win = Screen('Windows');     
    for i = 1:length(win) % close all offscreen windows
        if Screen(win(i),'IsOffScreen')
            Screen('Close',win(i)); 
            win(i) = 0;
        end
    end
    win(win==0) = [];
    
    % keep window 1?
    if keep && ~isempty(win) && Screen('WindowScreenNumber', win(1))==id
        data.screen.win = win(1);        
    else
        if ~isempty(win)
            Screen('CloseAll');
            win = [];
        end
        data.screen.win = Screen('OpenWindow', id, data.screen.gray);
		pause(2)
    end
    
    % keep window 2?
    if keep && length(win)>1 && data.screen.dual && Screen('WindowScreenNumber', win(2))==id2
        data.screen.win2 = win(2);
    else         
        if length(win)>1
            Screen('Close',win(2));        
        end
        if data.screen.dual
            data.screen.win2 = Screen('OpenWindow', id2, data.screen.gray);
        end
    end
    if data.screen.dual
        Screen('FillRect',data.screen.win2,data.screen.gray);
    end
    Screen('Flip', data.screen.win,[],[],[],data.screen.dual*2);
%% gamma correction
    if exist('gammaTable','var')
		BackupCluts;
        Screen('LoadNormalizedGammaTable', data.screen.win, gammaTable*[1 1 1]);
		disp('Corrected gamma')
		pause(2)
    end

%% other misc setup    
    AssertGLSL;  

    if max(Screen('Screens')) < 2 % imaging computer
        HideCursor;
    end
    
	% get flip interval
	data.screen.flip_int = 1/data.screen.refresh_rate_hz;
    % more accurate, but takes time (up to 20 sec):
    % flip_int = Screen('GetFlipInterval', win, 100, 0.0001, 20);     

    % lag between the behavior and acquisition
    % this is to be used if the acquisition reports early stimulus onsets
	psychsr_set('presentation','lag',0);	
	
	% use higher priority for better timing precision (maybe?)
	Priority(1);    

end