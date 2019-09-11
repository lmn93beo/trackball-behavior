function new_loop = psychsr_next_stim(loop)

    global data;
    
    persistent stim_type;
    persistent flip_int;
    persistent wait_frames;
    
    end_time = data.stimuli.end_time;
    stim_type = data.stimuli.stim_type; 
    
    if loop.frame == 1    
        flip_int = data.screen.flip_int;    
        wait_frames = data.presentation.wait_frames;
    end   
        
    % next frame: change stimuli for predicted frame
    if loop.frame == loop.new_stim
        loop.stim = loop.stim + 1; 
        loop.hide_stim = 0;
        if isfield(data.stimuli,'sound_id') && data.stimuli.sound_id(loop.stim)>0
            psychsr_sound(data.stimuli.sound_id(loop.stim));
            fprintf('SOUND %d: %1.4f\n',data.stimuli.sound_id(loop.stim),loop.prev_flip_time)
        end
    end        
    
    % next frame: for grating, increment theta
    if ~isempty(strfind(stim_type{loop.stim},'grating')) || strcmp(stim_type{loop.stim},'checker')
        loop.theta = loop.theta + data.stimuli.temp_freq(loop.stim)*360*flip_int*wait_frames;
    end
    
    % next frame: predict new stimulus onset if end_time is approaching
    if loop.prev_flip_time > end_time(loop.stim)-2.5*flip_int*wait_frames
        loop.new_stim = loop.frame+1;
        if isfield(data.stimuli,'rand_phase') && loop.stim < data.stimuli.num_stimuli && data.stimuli.rand_phase(loop.stim+1)
            loop.theta = floor(rand*360);
        end
    end
    
    new_loop = loop;    
end