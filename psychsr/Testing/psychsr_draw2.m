function new_loop = psychsr_draw(loop)    
    % Draws stimulus.
    % Currently supports: sine-wave gratings, blank screen
    % Need to update to support general stimuli

%% setup
    global data;            
    persistent stimuli;
    persistent last_tex;
    persistent last_movie;
    persistent last_con;
	persistent last_rand_ori;
	persistent last_rand_phase;	
    win = data.screen.win;
    if data.screen.dual
        win2 = data.screen.win2;
    end
        
    if ~isequalwithequalnans(stimuli,data.stimuli)
        stimuli = data.stimuli;
    end          
    
    if isempty(last_movie)
        last_movie = 1;
        last_tex = 0;
        last_con = 0;
        %last_tex = stimuli.movie(last_movie).texs(1);
		last_rand_phase = 0;
    end
    
    % stimulus to be drawn (will appear on next loop)
    stim = loop.stim + (loop.frame == loop.new_stim);    
    
    % adjust contrast
    if loop.hide_stim == 0
        con = stimuli.contrast(stim);
        if data.screen.dual
            con2 = stimuli.contrast2(stim);
        end
    else
        con = 0; con2 = 0;
    end
    
    if isfield(data.stimuli,'fade')
        if data.stimuli.fade(stim) ~= 0
            d_con = con*data.stimuli.fade(stim)/(data.presentation.frame_rate*data.stimuli.duration(stim)-1);
            if loop.frame == loop.new_stim
                if data.stimuli.fade(stim) == -1 % fade out
                    last_con = con-d_con;
                else % fade in
                    last_con = 0-d_con;
                end
            end
            con = last_con+d_con;
            last_con = con;                    
        end
    end        
    
    % draw this frame

%% stimuli
    switch stimuli.stim_type{stim}            
        case 'grating'
            ori = stimuli.orientation(stim);
            pha = loop.theta;
            % spatial freq in cycles/pixel
            spf = stimuli.spat_freq(stim)/data.screen.pixels_per_degree*2*pi;

            if isfield(stimuli,'rect')
                rect = stimuli.rect{stim};
                rect([1 3]) = rect([1 3])*data.screen.width_pixels;
                rect([2 4]) = rect([2 4])*data.screen.height_pixels;
            else
                rect = [];
            end 
            if ~data.screen.dual || stimuli.stim_side(stim) == 2 
                if isfield(stimuli,'movie_num')
					movie = stimuli.movie(stimuli.movie_num(stim-1));        
					i = find(movie.texs==last_tex,1)+1;
					if isempty(i) || i > length(movie.texs) %|| loop.frame == loop.new_stim
						i = 1;        
					end
				end
                if data.screen.dual        
                    if isfield(stimuli,'movie_num')                        
                        Screen('BlendFunction',win2,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                        Screen('FillRect',win2,data.screen.gray);
                        Screen('DrawTexture',win2,movie.texs(i),movie.srect,movie.drect,[],[],stimuli.movie_con(stim));        
                        last_tex = movie.texs(i);
                        last_movie = stimuli.movie_num(stim-1);                        
                    else
                        Screen('BlendFunction',win2,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                        Screen('FillRect',win2,data.screen.gray);
                    end                    
                else
                    last_tex = stimuli.grating_tex;
                end    
    %             Screen('BlendFunction',win,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    %             Screen('FillRect',win,data.screen.gray);      
                if con > 0
                    Screen('BlendFunction', win, GL_ONE, GL_ZERO); % disable blending
                    Screen('DrawTexture',win,stimuli.grating_tex,rect,rect,ori,[],[],[],...
                        [],kPsychUseTextureMatrixForRotation,[pha; spf; con; 0]);                    
                else
                    Screen('BlendFunction',win,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                    Screen('FillRect',win,data.screen.gray);                        
					if isfield(stimuli,'movie_num')
						Screen('DrawTexture',win,movie.texs(i),movie.srect,movie.drect,[],[],stimuli.movie_con(stim));
					end
                end

            else
                if isfield(stimuli,'movie_num')
                    movie = stimuli.movie(stimuli.movie_num(stim-1));
                    i = find(movie.texs==last_tex,1)+1;
                    if isempty(i) || i > length(movie.texs) || loop.frame == loop.new_stim
                        i = 1;        
                    end

                    
                else
                    Screen('BlendFunction', win2, GL_ONE, GL_ZERO); % disable blending
                    Screen('FillRect',win2,data.screen.gray);            
                end
                if con2 > 0
                    Screen('BlendFunction', win2, GL_ONE, GL_ZERO); % disable blending
                    Screen('DrawTexture',win2,stimuli.grating_tex,rect,rect,ori,[],[],[],...
                        [],kPsychUseTextureMatrixForRotation,[pha; spf; con2; 0]);                                
                else
                    Screen('BlendFunction', win2,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);                    
                    Screen('FillRect',win2,data.screen.gray);                                
					if isfield(stimuli,'movie_num')
						Screen('DrawTexture',win2,movie.texs(i),movie.srect,movie.drect,[],[],stimuli.movie_con(stim));        
					end
                end

                if isfield(stimuli,'movie_num')
                    Screen('DrawTexture',win,movie.texs(i),movie.srect,movie.drect,[],[],stimuli.movie_con(stim));        
                    last_tex = movie.texs(i);
                    last_movie = stimuli.movie_num(stim-1);        
                end
            end
            
        case 'rot_grating'
            deg_per_frame = stimuli.rot_freq(stim)*360/data.presentation.frame_rate;
            ori = stimuli.orientation(stim) + (loop.frame-loop.new_stim)*deg_per_frame;
%             fprintf('%3.2f\n',ori);
            pha = loop.theta;
            spf = stimuli.spat_freq(stim)/data.screen.pixels_per_degree*2*pi;
            if isfield(stimuli,'rect')
                rect = stimuli.rect{stim};
                rect([1 3]) = rect([1 3])*data.screen.width_pixels;
                rect([2 4]) = rect([2 4])*data.screen.height_pixels;
            else
                rect = [];
            end 
            Screen('BlendFunction', win, GL_ONE, GL_ZERO); % disable blending
            Screen('DrawTexture',win,stimuli.grating_tex,rect,rect,ori,[],[],[],...
                [],kPsychUseTextureMatrixForRotation,[pha; spf; con; 0]);                            
            
        case 'rand_grating'
            if mod(loop.frame,stimuli.randnumframes) == 0
				ori = floor(rand*360);
				last_rand_ori = ori;
				pha = floor(rand*360);
				last_rand_phase = pha;
			else
				ori = last_rand_ori;
				pha = last_rand_phase+360/stimuli.randnumframes;
				last_rand_phase = pha;
			end			
            
            % spatial freq in cycles/pixel
            spf = stimuli.spat_freq(stim)/data.screen.pixels_per_degree*2*pi;

            if isfield(stimuli,'rect')
                rect = stimuli.rect{stim};
                rect([1 3]) = rect([1 3])*data.screen.width_pixels;
                rect([2 4]) = rect([2 4])*data.screen.height_pixels;
            else
                rect = [];
			end 
% 			keyboard;
			
            Screen('BlendFunction', win, GL_ONE, GL_ZERO); % disable blending
            Screen('DrawTexture',win,stimuli.grating_tex,rect,rect,ori,[],[],[],...
                [],kPsychUseTextureMatrixForRotation,[pha; spf; con; 0]);
        case 'grating2'

            movie = stimuli.movie(stimuli.movie_num(stim));        

            i = find(movie.texs==last_tex,1)+1;
            if isempty(i) || i > length(movie.texs) %|| loop.frame == loop.new_stim
                i = 1;        
            end
            last_tex = movie.texs(i);
            last_movie = stimuli.movie_num(stim);

            spf = stimuli.spat_freq(stim)/data.screen.pixels_per_degree*2*pi;
            xoffset = mod(loop.theta,360)/(360*spf);

            srcRect = [xoffset 0 xoffset+1600 1200];
            dstRect = CenterRect([0 0 1600 1200],Screen('Rect',win));                
            spfs = unique(stimuli.spat_freq);
            spfs(isnan(spfs)) = [];
            j = find(spfs == stimuli.spat_freq(stim),1);
            
            Screen('BlendFunction', win, GL_ONE, GL_ZERO); % disable blending
            Screen('FillRect', win, data.screen.gray);
            if data.screen.dual
                Screen('BlendFunction', win2, GL_ONE, GL_ZERO); % disable blending
                Screen('FillRect', win2, data.screen.gray);
            end
            
            if loop.cue > 0                
                if stimuli.cue_tone(stim-1) == 4 || stimuli.cue_tone(stim-1) == 2                    
                    if loop.cue > 1
                        if isfield(stimuli,'rect')
                            rect = stimuli.rect{stim};
                            rect([1 3]) = rect([1 3])*data.screen.width_pixels;
                            rect([2 4]) = rect([2 4])*data.screen.height_pixels;
                            Screen('FrameRect',win,data.screen.white,rect,20);
                        else
                            Screen('FrameArc',win,data.screen.white,[120 0 904 784],0,360,10,10);
                        end
                    end                        
                end
                if data.screen.dual                    
                    if stimuli.cue_tone(stim-1) == 5 || stimuli.cue_tone(stim-1) == 2                        
                        if isfield(stimuli,'rect')
                            rect = stimuli.rect{stim};
                            rect([1 3]) = rect([1 3])*data.screen.width_pixels;
                            rect([2 4]) = rect([2 4])*data.screen.height_pixels;
                            Screen('FrameRect',win2,data.screen.white,rect,20);
                        else
                            Screen('FrameArc',win2,data.screen.white,[120 0 904 784],0,360,10,10);
                        end
                    end
                end
                loop.cue = loop.cue - 1;
            end
            
            if ~data.screen.dual || stimuli.stim_side(stim) == 2 %con>con2                
                Screen('BlendFunction',win,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);                
                Screen('DrawTexture',win,movie.texs(i),movie.srect,movie.drect,[],[],stimuli.movie_con(stim));        
                Screen('Blendfunction', win, GL_ONE, GL_ZERO, [0 0 0 1]);
                Screen('FillRect', win, [0 0 0 0], dstRect);
                Screen('DrawTexture', win, stimuli.mask_tex,[],[],[],[],con)                            
                Screen('Blendfunction', win, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [1 1 1 1]);
                Screen('DrawTexture', win, stimuli.grating2_tex{j}, srcRect, dstRect, stimuli.orientation(stim));
            
                if data.screen.dual
                    Screen('BlendFunction',win2,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                    Screen('FillRect',win2,data.screen.gray);
                    Screen('DrawTexture',win2,movie.texs(i),movie.srect,movie.drect,[],[],stimuli.movie_con(stim));                            
                end
            else                
                Screen('BlendFunction',win2,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                Screen('FillRect', win2, data.screen.gray);
                Screen('DrawTexture',win2,movie.texs(i),movie.srect,movie.drect,[],[],stimuli.movie_con(stim));        
                Screen('Blendfunction', win2, GL_ONE, GL_ZERO, [0 0 0 1]);
                Screen('FillRect', win2, [0 0 0 0], dstRect);
                Screen('DrawTexture', win2, stimuli.mask_tex,[],[],[],[],con2)                                            
                Screen('Blendfunction', win2, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [1 1 1 1]);
                Screen('DrawTexture', win2, stimuli.grating2_tex{j}, srcRect, dstRect, stimuli.orientation(stim));

                Screen('BlendFunction',win,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                Screen('FillRect',win,data.screen.gray);
                Screen('DrawTexture',win,movie.texs(i),movie.srect,movie.drect,[],[],stimuli.movie_con(stim));                            
            end                                   
        case 'grating3'
            ori = stimuli.orientation(stim);
            pha = loop.theta;
            % spatial freq in cycles/pixel
            spf = stimuli.spat_freq(stim)/data.screen.pixels_per_degree*2*pi;

            if isfield(stimuli,'rect')
                rect = stimuli.rect{stim};
                rect([1 3]) = rect([1 3])*data.screen.width_pixels;
                rect([2 4]) = rect([2 4])*data.screen.height_pixels;
            else
                rect = [];
            end 
            Screen('BlendFunction', win, GL_ONE, GL_ZERO); % disable blending
            Screen('BlendFunction', win2, GL_ONE, GL_ZERO); % disable blending
                        
            if stimuli.stim_side(stim) == 2
                ori1 = ori; 
                if isfield(stimuli,'orientation_d')
                    ori2 = stimuli.orientation_d(stim);
                else
                    ori2 = 90.01-ori;
                end
            else
                ori2 = ori; 
                if isfield(stimuli,'orientation_d')
                    ori1 = stimuli.orientation_d(stim);
                else
                    ori1 = 90.01-ori;
                end
            end
                        
            Screen('DrawTexture',win,stimuli.grating_tex,rect,rect,ori1,[],[],[],...
                [],kPsychUseTextureMatrixForRotation,[pha; spf; con; 0]);                    
            
            Screen('DrawTexture',win2,stimuli.grating_tex,rect,rect,ori2,[],[],[],...
                [],kPsychUseTextureMatrixForRotation,[pha; spf; con2; 0]);                    
            
            last_tex = stimuli.grating_tex;
            
        case 'movie'
                       
            movie = stimuli.movie(stimuli.movie_num(stim));        

            i = find(movie.texs==last_tex,1)+1;
            if isempty(i) || i > length(movie.texs) || loop.frame == loop.new_stim
                i = 1;        
            end            
            Screen('BlendFunction',win,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            Screen('DrawTexture',win,movie.texs(i),movie.srect,movie.drect,[],[],con);        
            if data.screen.dual                
                Screen('BlendFunction',win2,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                Screen('FillRect',win2,data.screen.gray);
                Screen('DrawTexture',win2,movie.texs(i),movie.srect,movie.drect,[],[],con2);        
            end
            
            if loop.cue > 0      
                if stimuli.stim_side(stim+1) == 2
%                 if stimuli.cue_tone(stim) == 4 || stimuli.cue_tone(stim) == 2
                    Screen('BlendFunction', win, GL_ONE, GL_ZERO); % disable blending
                    Screen('FillRect',win,data.screen.gray);
                    if loop.cue > 1
                        if isfield(stimuli,'rect')
                            rect = stimuli.rect{stim+1};                            
                            if strcmp(stimuli.cue_type(stim),'invalid')
                                % move rect to opposite diagonal
                                shiftrect = repmat([diff([rect(1) 1-rect(3)]) diff([rect(2) 1-rect(4)])],1,2);
                                rect = rect + shiftrect;
                            end
                            
                            rect([1 3]) = rect([1 3])*data.screen.width_pixels;
                            rect([2 4]) = rect([2 4])*data.screen.height_pixels;
                            Screen('FrameRect',win,data.screen.white,rect,20);
                        else
                            Screen('FrameArc',win,data.screen.white,[120 0 904 784],0,360,10,10);
                        end
                    end                        
                end
                if data.screen.dual     
                    if stimuli.stim_side(stim+1) == 1
%                     if stimuli.cue_tone(stim) == 5 || stimuli.cue_tone(stim) == 2
                        Screen('BlendFunction', win2, GL_ONE, GL_ZERO); % disable blending
                        Screen('FillRect',win,data.screen.gray);
                        if loop.cue > 1
                            if isfield(stimuli,'rect')
                                rect = stimuli.rect{stim+1};                                
                                if strcmp(stimuli.cue_type(stim),'invalid')  
                                    % move rect to opposite diagonal
                                    shiftrect = repmat([diff([rect(1) 1-rect(3)]) diff([rect(2) 1-rect(4)])],1,2);
                                    rect = rect + shiftrect;                                    
                                end
                                
                                rect([1 3]) = rect([1 3])*data.screen.width_pixels;
                                rect([2 4]) = rect([2 4])*data.screen.height_pixels;
                                Screen('FrameRect',win2,data.screen.white,rect,20);
                            else
                                Screen('FrameArc',win2,data.screen.white,[120 0 904 784],0,360,10,10);
                            end
                        end
                    end
                end
                loop.cue = loop.cue - 1;
            end
            
            last_tex = movie.texs(i);
            last_movie = stimuli.movie_num(stim);
        case 'image'

            movie = stimuli.movie(stimuli.movie_num(stim));           
            i = find(movie.texs==last_tex,1);
            if isempty(i)
                i = 1;        
            end		
            Screen('BlendFunction',win,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            Screen('DrawTexture',win,movie.texs(i),movie.srect,movie.drect,[],[],con);            
            if data.screen.dual
                Screen('BlendFunction',win2,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                Screen('FillRect',win2,data.screen.gray);
                Screen('DrawTexture',win2,movie.texs(i),movie.srect,movie.drect,[],[],con2);        
            end
            last_tex=movie.texs(i);
            last_movie = stimuli.movie_num(stim);            
        otherwise    
            if data.stimuli.blackblank == 1
                Screen('FillRect',win,data.screen.black);
                if data.screen.dual
                    Screen('FillRect',win2,data.screen.black);
                end
            else
                Screen('FillRect',win,data.screen.gray);
                if data.screen.dual
                    Screen('FillRect',win2,data.screen.gray);
                end
            end            
    end
    
    % may optimize timing by telling GPU to begin drawing
    Screen('DrawingFinished', win);
    
    new_loop = loop;
end