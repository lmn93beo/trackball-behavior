function data = psychsr(params)
% 
% PsychSR = Psych(Toolbox) S(timulation) (and) R(esponse)
% Real-time visual stimulation with behavioral readout using MATLAB, 
% PsychToolbox and Data Acquisition Toolbox
% 
% Gerald Pho 2011-02-04
    global data;
    if strcmp(getenv('computername'),'WFSTIM')
        % trigger camera INSTEAD of prairie
        params.card.trigger_port = 0;
        params.card.trigger_line = 0;
        params.card.inter_trigger_interval = 1;
        params.presentation.lag = 0;
        data = psychsr_WFscope(params);
    else
        % start a new data structure
        
        data = params;
        
        % add psychsr functions
        psychsr_go();
        
        % setup
        psychsr_screen_setup();
        psychsr_response_setup();   % configure response parameters
        psychsr_card_setup();
        psychsr_sound_setup();
        psychsr_prepare_stimuli();
        
        % run
        psychsr_present(); % calls psychsr_start_presentation() after a trigger
        
        % stop
        psychsr_cleanup();
        
        
    end
end