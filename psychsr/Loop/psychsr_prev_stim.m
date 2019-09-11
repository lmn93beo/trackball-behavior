function new_loop = psychsr_prev_stim(loop)
    
    global data;
    
    % previous frame: store flip time
    data.presentation.flip_times(loop.frame) = loop.prev_flip_time;            

    % previous frame: store stim completion time
    if loop.frame - loop.new_stim == 1 
        data.presentation.stim_times(loop.stim-1) = loop.prev_flip_time;     
    end
    
    new_loop = loop;
end