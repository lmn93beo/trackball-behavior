function data = psychsr_test_mic()

	% define your stimuli
	orientation_list = [0 60 90 120];
	spat_freqs = 0.0032;
	temp_freqs = 2;	
	contrast_list = 0.25:0.25:1;
	
	% define timing
	off_duration = 3;
	on_duration = 2;
	num_loops = 1;
	
	% iterate the stimuli
	num_orientations = length(orientation_list);
    num_stimuli = num_loops*num_orientations*2;
    k = 1;   
    stim_type = cell(1,num_stimuli);
    duration = zeros(1,num_stimuli);
    orientation = NaN*ones(1,num_stimuli);
    spat_freq = NaN*ones(1,num_stimuli);
    temp_freq = NaN*ones(1,num_stimuli);
    contrasts = NaN*ones(1,num_stimuli);
    
	for i = 1 : num_loops
		for j = 1 : num_orientations            
            duration(k) = off_duration;
            stim_type{k} = 'blank';
            k = k+1;
            
            duration(k) = on_duration;
            stim_type{k} = 'grating';
            orientation(k) = orientation_list(j);
            spat_freq(k) = spat_freqs;
            temp_freq(k) = temp_freqs;
            contrasts(k) = contrast_list(j);
            k = k+1;
		end
    end    
    
    stimuli = psychsr_zip(num_stimuli,stim_type,duration,orientation,spat_freq,temp_freq,contrasts);
    response.mode = 1;
    response.trig_level = 0.1;
    response.ao_mode = 'none';
    
    card.trigger_mode = 'none';		% 'in', 'out', 'key', or 'none'         
    card.name = 'winsound'; 
    card.id = 0; 
    card.ai_chan = 1;
    card.ai_fs = 5000; 
        
    input = psychsr_zip(stimuli,response,card);
    
	% deliver the stimuli
	data = psychsr(input);

end