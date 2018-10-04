% Prepares stimuli and makes textures

function psychsr_prepare_stimuli()
    
    global data;
    
    clear psychsr_draw;
    
    % load parameters
    win = data.screen.win;
    w = data.screen.width_pixels;    
    h = data.screen.height_pixels;  
    flip_int = data.screen.flip_int;
    
    % set end times for each stimulus
    psychsr_set('stimuli','total_duration',sum(data.stimuli.duration));
    data.stimuli.end_time = cumsum(data.stimuli.duration);    
    
    psychsr_set('stimuli','blackblank',0);
    
    
    
%% grating    
    if max(strcmp(data.stimuli.stim_type,'grating')) || max(strcmp(data.stimuli.stim_type,'rand_grating')) || max(strcmp(data.stimuli.stim_type,'grating3')) || max(strcmp(data.stimuli.stim_type,'rot_grating'))
        bg_color_offset = [0.5, 0.5, 0.5, 1];
        contrast_multiplier = 0.5;
        radius = []; % full screen grating

%         h = h*(data.screen.width_cm/data.screen.height_cm*data.screen.height_pixels/data.screen.width_pixels);
        
        data.stimuli.grating_tex = CreateProceduralSineGrating(win,w,h,...
            bg_color_offset,radius,contrast_multiplier);
    end
%% grating2
    if max(strcmp(data.stimuli.stim_type,'grating2'))
        % create one texture for each spatial frequency
        spfs = unique(data.stimuli.spat_freq);
        spfs(isnan(spfs)) = [];
        
        for i = 1:length(spfs)
            f = spfs(i)/data.screen.pixels_per_degree*2*pi;
            p=ceil(1/f); % pixels/cycle, rounded up.
            fr=f*2*pi;
            texsize = data.screen.width_pixels/2;
            [x,y]=meshgrid(-texsize:texsize + p, 1);
            grating=data.screen.gray + data.screen.inc*cos(fr*x);       
            data.stimuli.grating2_tex{i}=Screen('MakeTexture', win, grating);
        end
        
        rects = data.stimuli.rect;
        unique_rects = cell(0);
        for i = 1:length(rects)
            if length(rects{i}) == 4                   
                k = 1;
                for j = 1:length(unique_rects)
                    if rects{i} == unique_rects{j}
                        k = 0;
                    end
                end                    
                if k; unique_rects{end+1} = rects{i}; end;
            end
        end
        
        % make a gaussian mask for each rect
%         for i = 1:length(unique_rects)            
            xgrid = (unique_rects{1}(3)-unique_rects{1}(1))*data.screen.width_pixels/2;
            ygrid = (unique_rects{1}(4)-unique_rects{1}(2))*data.screen.height_pixels/2;
            mask = ones(2*ygrid+1,2*xgrid+1,2) * data.screen.gray;
            [x,y]=meshgrid(-xgrid:xgrid,-ygrid:ygrid);
            texsize = min([xgrid ygrid]);
            std = psychsr_set('stimuli','mask_std',0.5);
            alphamask = data.screen.white*(exp(-(x.^2/(2*(std*texsize)^2))-(y.^2/(2*(std*texsize)^2)))).*(x.^2 + y.^2 <= texsize^2);    
%             alphamask(alphamask>0) = alphamask(alphamask>0) - min(alphamask(alphamask>0));    
%             alphamask = alphamask*data.screen.white/max(max(alphamask));
            mask(:,:,2) = alphamask;
            data.stimuli.mask_tex=Screen('MakeTexture', win, mask);                        
%         end
    end
%% movie/image  
    if max(strcmp(data.stimuli.stim_type,'movie')) || max(strcmp(data.stimuli.stim_type,'image')) ...
            || max(strcmp(data.stimuli.stim_type,'grating2'))
        
        files = unique(data.stimuli.movie_file);
        files(strcmp(files,''))=[];
        
        psychsr_set('stimuli','crop_movie',0);
        
        for i = 1:length(files)
            if strcmp(files{i}(end-3:end),'.mat')
                load(files{i});                
                
                % normalize brightness
                mov = 255/max(max(max(mov)))*mov;
                
                texnums = zeros(1,size(mov,3));                
                for j = 1:length(texnums)
                    texnums(j) = Screen('MakeTexture',win,mov(:,:,j));
                end
                
                movieduration = length(texnums)*flip_int;
                wid = size(mov,2);
                height = size(mov,1);
                
            else
%                 % load textures from movie
%                 [movie movieduration fps width height nframes] = Screen('OpenMovie', win, files{i});                        
%                 texids = zeros(1,nframes);
%                 texpts = zeros(1,nframes);
%                 for j = 1:nframes
%                     [texids(j) texpts(j)] = Screen('GetMovieImage', win, movie, 1);
%                 end                        
%                 Screen('CloseMovie', movie);                        
% 
%                 % get tex numbers
%                 fliptimes = 0:flip_int:ceil(movieduration/flip_int)*flip_int;                        
%                 texnums = zeros(size(fliptimes));
%                 for j = 1:length(fliptimes)
%                     [x k] = min(abs(fliptimes(j)-texpts));
%                     texnums(j) = texids(k);
%                 end                
%                 
            end

            % resize movie
            ratio = w/h;       
            if data.stimuli.crop_movie
                if ratio > wid/height % screen wider than movie, crop top/bottom
                    dheight = (height-height/ratio)/2;
                    srcRect = [0,dheight,wid,height-dheight];                    
                else
                    dwid = (wid - wid*ratio)/2;
                    srcRect = [dwid,0,wid-dwid,height];
                end            
                dstRect = [0,0,w,h];
            else
                if ratio > wid/height % screen wider than movie, add gray on sides
                    dw = (w-wid*h/height)/2;
                    dstRect = [dw,0,w-dw,h];
                else
                    dh = (h-height*w/wid)/2;
                    dstRect = [0,dh,w,h-dh];
                end
                srcRect = [0,0,wid,height];
            end
            
            % store movie number
            data.stimuli.movie_num(strcmp(data.stimuli.movie_file,files{i})) = i;
            
            % store into movie structure
            data.stimuli.movie(i).file = files{i};
            data.stimuli.movie(i).dur = ceil(movieduration/flip_int)*flip_int;
            data.stimuli.movie(i).texs = texnums; 
            data.stimuli.movie(i).srect = srcRect;
            data.stimuli.movie(i).drect = dstRect;
        end        
        
    end
    
end