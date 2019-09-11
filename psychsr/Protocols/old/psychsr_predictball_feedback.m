function new_loop = psychsr_predictball_feedback(loop)
    
    global data;  
    
    if loop.frame - loop.new_stim == 1
        if mod(loop.stim,2) == 0
            if strcmp(data.stimuli.movie_file{loop.stim},'movies\\predictStim_norm.mat')
                psychsr_sound(10);
            elseif strcmp(data.stimuli.movie_file{loop.stim},'movies\\predictStim_bounce.mat')
                psychsr_sound(10);
            end
        end
    end
    
    new_loop = loop;
end