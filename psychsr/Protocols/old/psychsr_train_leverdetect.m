function data = psychsr_train_leverdetect()
% goal = train animal to respond to upward grating (target) using lever
% 
% runs for 60 minutes
% first free_dur seconds are continuous target
% then target alternates off for off_dur, on for on_dur

%% variable parameters

	% define timing (everything in seconds)
    total_dur = (15)*60; % approximate, may be more depending on off/on_dur
	on_dur = 2;    
	free_dur = (0)*60;
    
    % define reward
    response.reward_time = 0.004;
    response.ao_mode = 'putsample';
%     response.grace_period = 1;
    
%% constant parameters
    
    % define your stimuli
	orients = 90;
	sfs = 0.0032;
	tfs = 2;	
	contrast = 1;
    
    % triggering
	card.trigger_mode = 'key';		% 'in', 'out', 'key', or 'none'
    
    % sound
    sound.noise_time = 3;
    sound.tone_amp = 0;
    
    % response parameters
    response.mode = 1;
%     response.timeout_time = 3;
%     response.timeout_color = 'gray';
    
%% generate list of stimuli parameters
    
    % num_loops = ceil((total_dur-free_dur)/(off_dur+on_dur));    
    duration = 0;    
    k = 1;
	% prepare vectors
    while sum(duration)<= total_dur
        
        duration(k) = round(rand*4+4);
        k = k+1;
        duration(k) = on_dur;
        k = k+1;
    end
    
    num_stimuli = length(duration);    
    
    stim_type = cell(1,num_stimuli);
    %duration = zeros(1,num_stimuli);
    orientation = NaN*ones(1,num_stimuli);
    spat_freq = NaN*ones(1,num_stimuli);
    temp_freq = NaN*ones(1,num_stimuli);
    contrasts = NaN*ones(1,num_stimuli);    
    
    k = 1;           
    
    % iterate the stimuli
	for i = 1 : num_stimuli/2                     
        stim_type{k} = 'blank';
        k = k+1;
                
        stim_type{k} = 'grating';
        orientation(k) = orients;
        spat_freq(k) = sfs;
        temp_freq(k) = tfs;
        contrasts(k) = contrast;
        k = k+1;
    end

%% input the parameters
    stimuli = psychsr_zip(num_stimuli,stim_type,duration,orientation,spat_freq,temp_freq,contrasts);       
    
    input = psychsr_zip(stimuli,response,card,sound);
    
	data = psychsr(input);

end