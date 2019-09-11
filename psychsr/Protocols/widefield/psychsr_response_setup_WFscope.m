function psychsr_response_setup_WFscope()
    
    global data;
    
    psychsr_set('response','mode',1);
	psychsr_set('response','feedback_fn',@psychsr_feedback_WFscope);
    
    if data.response.mode

        data.response.totaldata = [];
        data.response.licks = [];
        data.response.rewards = [];
        data.response.punishs = [];
        data.response.tones = [];
        data.response.primes = [];
        
        if max(data.response.mode == [5, 6, 7])
            data.response.extends = [];
            data.response.retracts = [];
        end
        if data.response.mode == 7
            data.response.laser_on = [];
        end
        
        psychsr_set('response','trig_level',1);
        psychsr_set('response','reward_time',0.004);    
        psychsr_set('response','reward_type','water');    
        psychsr_set('response','auto_reward',0);
        psychsr_set('response','punish_time',0.1);
        psychsr_set('response','abort',0);
        psychsr_set('response','punish',0);        
        psychsr_set('response','max_rewards',Inf);
        
        psychsr_set('response','notify','0');
        
        if max(strcmp(data.response.notify,{'g','m','a','b'})) || (isfield(data.response,'alert_gp') && data.response.alert_gp==1)
            % send text to gerald            
            setpref('Internet', 'E_mail', 'surcalendar@gmail.com');
            setpref('Internet', 'SMTP_Username', 'surcalendar@gmail.com');
            setpref('Internet', 'SMTP_Password', 'GolgivCajal');
            setpref('Internet', 'SMTP_Server', 'smtp.gmail.com');
            props = java.lang.System.getProperties;
            props.setProperty('mail.smtp.auth','true');
            props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
            props.setProperty('mail.smtp.socketFactory.port', '465');            
        end
        
    end
end