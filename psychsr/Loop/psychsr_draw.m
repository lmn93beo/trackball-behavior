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
persistent last_pos;
persistent dotInfo;
persistent dotInfo2;

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
    last_rand_ori = 0;
    last_pos = [100 100];
end

% stimulus to be drawn (will appear on next loop)
stim = loop.stim + (loop.frame == loop.new_stim);

if stim > data.stimuli.num_stimuli
    new_loop = loop;
    return
end

% adjust contrast
if loop.hide_stim == 0
    con = stimuli.contrast(stim);
    if data.screen.dual
        if isfield(stimuli,'contrast2')
            con2 = stimuli.contrast2(stim);
        else
            con2 = con;
        end
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

if data.screen.dual
    if data.stimuli.blackblank == 1
        Screen('FillRect',win2,data.screen.black);
    else
        Screen('FillRect',win2,data.screen.gray);
    end
end

% draw this frame

%% stimuli
switch stimuli.stim_type{stim}
    case 'grating'
        ori = stimuli.orientation(stim);
        pha = loop.theta;
        % spatial freq in cycles/pixel
        spf = stimuli.spat_freq(stim)/data.screen.pixels_per_degree;
        
        % adjust spf for non-square pixels
        ff=(data.screen.height_cm/data.screen.width_cm)/(data.screen.height_pixels/data.screen.width_pixels);
        o = ori*pi/180;
        spf = spf*(1*abs(cos(o))+ff*abs(sin(o)))./(abs(cos(o))+abs(sin(o)));
       
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
                
                %                     fprintf('%d\n',pha);
                
            elseif con == 0
                Screen('BlendFunction',win,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                Screen('FillRect',win,data.screen.gray);
                if isfield(stimuli,'movie_num')
                    Screen('DrawTexture',win,movie.texs(i),movie.srect,movie.drect,[],[],stimuli.movie_con(stim));
                end
            else % make "negative contrast" increase in brightness
                Screen('BlendFunction',win,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                Screen('FillRect',win,(data.screen.white+data.screen.gray)/2);
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
	case 'fillrect'
		rect = stimuli.rect{stim};
		rect([1 3]) = rect([1 3])*data.screen.width_pixels;
		rect([2 4]) = rect([2 4])*data.screen.height_pixels;
		if isfield(stimuli,'color')
			color = stimuli.color(stim);
		else
			color = data.screen.white;
		end
		Screen('FillRect', win, color, rect)
		
    case 'grating_patch'
        
        ori = stimuli.orientation(stim);
        pha = loop.theta;
        % spatial freq in cycles/pixel
        spf = stimuli.spat_freq(stim)/data.screen.pixels_per_degree;
        
        % adjust spf for non-square pixels
        ff=(data.screen.height_cm/data.screen.width_cm)/(data.screen.height_pixels/data.screen.width_pixels);
        o = ori*pi/180;
        spf = spf*(1*abs(cos(o))+ff*abs(sin(o)))./(abs(cos(o))+abs(sin(o)));
        
        w = data.screen.width_pixels; h = data.screen.height_pixels;
        if stimuli.mousecontrol > 0
            if loop.frame == loop.new_stim || stimuli.mousecontrol == 2
                [x y] = GetMouse;
                last_pos = [x y];
            end            
            pos = last_pos;            
        else
            pos = stimuli.pos{stim};
            pos(1) = pos(1)*w;
            pos(2) = pos(2)*h;
        end
        radius_w = stimuli.radius(stim); 
		radius_h = radius_w/ff;
        rect = zeros(1,4);                
        if pos(1) < 0; pos(1) = 0; elseif pos(1) > w; pos(1) = w; end
        if pos(2) < 0; pos(2) = 0; elseif pos(2) > h; pos(2) = h; end
        
        if radius_w == Inf
            rect = [0 0 w h];
        else
            rect([1 3]) = pos(1)+[-1 1]*radius_w*min([w h]);
            rect([2 4]) = pos(2)+[-1 1]*radius_h*min([w h]);
        end
        new_pos(1) = mean(rect([1 3]))/w;
        new_pos(2) = mean(rect([2 4]))/h;
        data.stimuli.pos{loop.stim} = new_pos;
        
        if con>0 && mod(loop.frame-loop.new_stim,30) == 1
			radius_deg = radius_w*min([w h]);
			if radius_deg == Inf
				radius_deg = max([w h])/2;
			end
			radius_deg = radius_deg/data.screen.pixels_per_degree;
            fprintf('xy = [%1.2f %1.2f], r = %1.2f ~ %1.1f deg\n', new_pos, radius_w, radius_deg)
        end
        
        last_tex = stimuli.grating_tex;
        
        Screen('BlendFunction', win, GL_ONE, GL_ZERO); % disable blending
        Screen('FillRect', win, data.screen.gray);
        
        if con > 0
            if radius_w < Inf
                Screen('Blendfunction', win, GL_ONE, GL_ZERO, [0 0 0 1]);
                Screen('FillRect', win, [0 0 0 0], rect);
                Screen('FillOval', win, data.screen.white, rect);
            end
            Screen('Blendfunction', win, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [1 1 1 1]);
            
            Screen('DrawTexture',win,stimuli.grating_tex,rect,rect,ori,[],[],[],...
                [],kPsychUseTextureMatrixForRotation,[pha; spf; con; 0]);
			
% 			Screen('Blendfunction', win, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [1 1 1 1]);
% 
% 			Screen('DrawTexture',win,stimuli.grating_tex,rect,rect,ori,[],[],[],...
% 				[],kPsychUseTextureMatrixForRotation,[pha; spf; con; 0]);
% 
% 			Screen('Blendfunction', win, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [0 0 0 1]);
% 			Screen('FillRect', win, [data.screen.gray data.screen.gray data.screen.gray 0], rect);
% 			Screen('FillOval', win, data.screen.white, rect);
			
        else
            Screen('BlendFunction',win,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            Screen('FillRect',win,data.screen.gray);           
        end
        
        [x y] = GetMouse;
        pos = [x y];
        if stimuli.mousecontrol == 1 && min(pos==last_pos)==0            
            Screen('FillOval', win, [data.screen.white 0 0], [(pos-5) (pos+5)]);
        end
	case 'grating_annulus'
        
        ori = stimuli.orientation(stim);
        pha = loop.theta;
        % spatial freq in cycles/pixel
        spf = stimuli.spat_freq(stim)/data.screen.pixels_per_degree;
        
        % adjust spf for non-square pixels
        ff=(data.screen.height_cm/data.screen.width_cm)/(data.screen.height_pixels/data.screen.width_pixels);
        o = ori*pi/180;
        spf = spf*(1*abs(cos(o))+ff*abs(sin(o)))./(abs(cos(o))+abs(sin(o)));
        
		if isfield(stimuli,'contrast_out')
			con_out = stimuli.contrast_out(stim);
		else
			con_out = 1; % default contrast for annulus
		end
		
		if isfield(stimuli,'radius_out')
			r_out_w = stimuli.radius_out(stim);
		else
			r_out_w = Inf; % default annulus fills whole screen
		end
		
        w = data.screen.width_pixels; h = data.screen.height_pixels;
        if stimuli.mousecontrol > 0
            if loop.frame == loop.new_stim || stimuli.mousecontrol == 2
                [x y] = GetMouse;
                last_pos = [x y];
            end            
            pos = last_pos;            
        else
            pos = stimuli.pos{stim};
            pos(1) = pos(1)*w;
            pos(2) = pos(2)*h;
        end
        radius_w = stimuli.radius(stim); 
		radius_h = radius_w/ff;
		r_out_h = r_out_w/ff;		
        
		rect = zeros(1,4);                
		rect_out = zeros(1,4);
        if pos(1) < 0; pos(1) = 0; elseif pos(1) > w; pos(1) = w; end
        if pos(2) < 0; pos(2) = 0; elseif pos(2) > h; pos(2) = h; end
		
        if radius_w == Inf
            rect = [0 0 w h];
        else
            rect([1 3]) = pos(1)+[-1 1]*radius_w*min([w h]);
            rect([2 4]) = pos(2)+[-1 1]*radius_h*min([w h]);
		end
		if r_out_w == Inf
			rect_out = [0 0 w h];
		else
			rect_out([1 3]) = pos(1)+[-1 1]*r_out_w*min([w h]);
            rect_out([2 4]) = pos(2)+[-1 1]*r_out_h*min([w h]);
		end
        new_pos(1) = mean(rect([1 3]))/w;
        new_pos(2) = mean(rect([2 4]))/h;
        data.stimuli.pos{loop.stim} = new_pos;
        
        if con+con_out>0 && mod(loop.frame-loop.new_stim,30) == 1
			radius_deg = radius_w*min([w h]);
			if radius_deg == Inf
				radius_deg = max([w h])/2;
			end
			radius_deg = radius_deg/data.screen.pixels_per_degree;
            fprintf('xy = [%1.2f %1.2f], r = %1.2f ~ %1.1f deg\n', new_pos, radius_w, radius_deg)
		end
		
        last_tex = stimuli.grating_tex;
        
		
		
        Screen('BlendFunction', win, GL_ONE, GL_ZERO); % disable blending
        Screen('FillRect', win, data.screen.gray);
        
        if con+con_out > 0
			Screen('Blendfunction', win, GL_ONE, GL_ZERO, [0 0 0 1]);
			if r_out_w < Inf
				Screen('FillRect', win, [0 0 0 0]);
				Screen('FillOval', win, [0 0 0 con_out*data.screen.white], rect_out); % annulus
			end
			if  radius_w < Inf
				Screen('FillOval', win, [0 0 0 con*data.screen.white], rect); % center
			end
			
            Screen('Blendfunction', win, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [1 1 1 1]);
            
            Screen('DrawTexture',win,stimuli.grating_tex,[],[],ori,[],[],[],...
                [],kPsychUseTextureMatrixForRotation,[pha; spf; 1; 0]);
            
        else
            Screen('BlendFunction',win,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            Screen('FillRect',win,data.screen.gray);           
        end
        
        [x y] = GetMouse;
        pos = [x y];
        if stimuli.mousecontrol == 1 && min(pos==last_pos)==0            
            Screen('FillOval', win, [data.screen.white 0 0], [(pos-5) (pos+5)]);
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
            ori_sampled = [0:45:315];
            ori = ori_sampled(randi(length(ori_sampled)));
%             ori = floor(rand*360);
            last_rand_ori = ori;
            pha = floor(rand*360);
            last_rand_phase = pha;
        else
            ori = last_rand_ori;
            pha = last_rand_phase+360/stimuli.randnumframes;
            last_rand_phase = pha;
        end
        
        % spatial freq in cycles/pixel
        spf = stimuli.spat_freq(stim)/data.screen.pixels_per_degree;
        
        % adjust spf for non-square pixels
        ff=(data.screen.height_cm/data.screen.width_cm)/(data.screen.height_pixels/data.screen.width_pixels);
        o = ori*pi/180;
        spf = spf*(1*abs(cos(o))+ff*abs(sin(o)))./(abs(cos(o))+abs(sin(o)));
        
        if isfield(stimuli,'rect')
            rect = stimuli.rect{stim};
            rect([1 3]) = rect([1 3])*data.screen.width_pixels;
            rect([2 4]) = rect([2 4])*data.screen.height_pixels;
        else
            rect = [];
        end
        
        Screen('BlendFunction', win, GL_ONE, GL_ZERO); % disable blending
        Screen('DrawTexture',win,stimuli.grating_tex,rect,rect,ori,[],[],[],...
            [],kPsychUseTextureMatrixForRotation,[pha, spf, con, 0]);
        
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
	case 'movie_patch'
				        
        %%% patch code
        ff=(data.screen.height_cm/data.screen.width_cm)/(data.screen.height_pixels/data.screen.width_pixels);
        
        w = data.screen.width_pixels; h = data.screen.height_pixels;
        if stimuli.mousecontrol > 0
            if loop.frame == loop.new_stim || stimuli.mousecontrol == 2
                [x y] = GetMouse;
                last_pos = [x y];
            end            
            pos = last_pos;            
        else
            pos = stimuli.pos{stim};
            pos(1) = pos(1)*w;
            pos(2) = pos(2)*h;
        end
        radius_w = stimuli.radius(stim); 
		radius_h = radius_w/ff;
        rect = zeros(1,4);                
        if pos(1) < 0; pos(1) = 0; elseif pos(1) > w; pos(1) = w; end
        if pos(2) < 0; pos(2) = 0; elseif pos(2) > h; pos(2) = h; end
        
        if radius_w == Inf
            rect = [0 0 w h];
        else
            rect([1 3]) = pos(1)+[-1 1]*radius_w*min([w h]);
            rect([2 4]) = pos(2)+[-1 1]*radius_h*min([w h]);
        end
        new_pos(1) = mean(rect([1 3]))/w;
        new_pos(2) = mean(rect([2 4]))/h;
        data.stimuli.pos{loop.stim} = new_pos;
        
        if con>0 && mod(loop.frame-loop.new_stim,30) == 1
			radius_deg = radius_w*min([w h]);
			if radius_deg == Inf
				radius_deg = max([w h])/2;
			end
			radius_deg = radius_deg/data.screen.pixels_per_degree;
            fprintf('xy = [%1.2f %1.2f], r = %1.2f ~ %1.1f deg\n', new_pos, radius_w, radius_deg)
		end
        		
		%%% movie code		
		movie = stimuli.movie(stimuli.movie_num(stim));        
        i = find(movie.texs==last_tex,1)+1;
        if isempty(i) || i > length(movie.texs) || loop.frame == loop.new_stim
            i = 1;
		end
		
		%%% blend code
        Screen('BlendFunction', win, GL_ONE, GL_ZERO); % disable blending
        Screen('FillRect', win, data.screen.gray);
        
        if con > 0
            if radius_w < Inf
                Screen('Blendfunction', win, GL_ONE, GL_ZERO, [0 0 0 1]);
                Screen('FillRect', win, [0 0 0 0], [0 0 w h]);
                Screen('FillOval', win, data.screen.white, rect);
            end
            Screen('Blendfunction', win, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [1 1 1 1]);
           			
			Screen('DrawTexture',win,movie.texs(i),movie.srect,movie.drect,[],[],con);
% 			Screen('DrawTexture',win,movie.texs(i),movie.srect,rect,[],[],con);
              
%             Screen('DrawTexture',win,stimuli.grating_tex,rect,rect,ori,[],[],[],...
%                 [],kPsychUseTextureMatrixForRotation,[pha; spf; con; 0]);
			
        else
            Screen('BlendFunction',win,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            Screen('FillRect',win,data.screen.gray);           
        end
        
        last_tex = movie.texs(i);
        last_movie = stimuli.movie_num(stim);
		
        [x y] = GetMouse;
        pos = [x y];
        if stimuli.mousecontrol == 1 && min(pos==last_pos)==0            
            Screen('FillOval', win, [data.screen.white 0 0], [(pos-5) (pos+5)]);
        end
		
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
    
    case 'checker'        
        flip = (mod(loop.theta,360) < 180)+1;
        
        Screen('BlendFunction', win, GL_ONE, GL_ZERO); % disable blending
        
        % background
        if data.stimuli.blackblank == 1
            Screen('FillRect',win,data.screen.black);
        else
            Screen('FillRect',win,data.screen.gray);
        end
        
        if isfield(stimuli,'rect')
            rect = stimuli.rect{stim};
            rect([1 3]) = rect([1 3])*data.screen.width_pixels;
            rect([2 4]) = rect([2 4])*data.screen.height_pixels;
        elseif isfield(stimuli,'rect1')
            % drifting 
            rect1 = stimuli.rect1{stim};
            rect2 = stimuli.rect2{stim};            
            nframes = data.presentation.frame_rate*data.stimuli.duration(stim);
            
            rect = rect1 + (rect2-rect1)*(loop.frame-loop.new_stim)/nframes;
            rect(rect<0) = 0;
            rect(rect>1) = 1;
            
            rect([1 3]) = rect([1 3])*data.screen.width_pixels;
            rect([2 4]) = rect([2 4])*data.screen.height_pixels;
%             fprintf('%1.2f %1.2f %1.2f %1.2f\n',rect)
        else
            rect = [];
        end
        Screen('DrawTexture', win, stimuli.checker_tex{flip}, rect, rect);
        last_tex = stimuli.checker_tex{flip};
                
    case 'dots'
        if loop.hide_stim==0
            if (loop.frame-loop.new_stim)==0
                dotInfo = createDotInfo(1);
                dotInfo.coh = con;
                dotInfo.dir = stimuli.orientation(stim);
                dotInfo.speed = stimuli.temp_freq(stim);
                if isfield(stimuli,'dot_density')
                    dotInfo.dotDensity = stimuli.dot_density(stim);
                else
                    dotInfo.dotDensity = 0.1;
                end
                if isfield(stimuli,'dot_size')
                    dotInfo.dotSize = stimuli.dot_size(stim);
                end
                if isfield(stimuli,'dot_color')
                    dotInfo.dotColor = stimuli.dot_color; % white dots default [255 255 255]
                end

                dotInfo.maxDotsPerFrame = round(dotInfo.dotDensity/...
                    (dotInfo.dotSize^2 / max([data.screen.width_pixels data.screen.height_pixels])^2));
                
                if data.screen.dual && data.stimuli.window(stim)~=2
                    dotInfo2 = dotInfo;
                end
            end
            
            if ~data.screen.dual || data.stimuli.window(stim)>1            
                dotInfo = psychsr_drawdots(loop,win,dotInfo); % draw on right screen
            end
            if data.screen.dual && data.stimuli.window(stim)~=2
                dotInfo2 = psychsr_drawdots(loop,win2,dotInfo2); % draw on left screen
            end
                
        end
    
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
if data.screen.timing_pixels > 0
    rect = zeros(1,4);
    pix = data.screen.timing_pixels;
    rect([1 3]) = [0 pix];%[-pix 0] + data.screen.width_pixels;
    rect([2 4]) = [-pix 0] + data.screen.height_pixels;
    if loop.frame == loop.new_stim
        color = data.screen.white;
    elseif mod(loop.frame,5)==1
        color = data.screen.black;
    else
        color = data.screen.gray;
    end
    Screen('FillRect',win,color,rect);
end

% may optimize timing by telling GPU to begin drawing
Screen('DrawingFinished', win);
if data.screen.dual
    Screen('DrawingFinished', win2);
end

new_loop = loop;
end