function psychsr_sound_extra_setup()
    global data;
    
    % sound waveform parameters    
    noise_time = psychsr_set('sound','noise_time',0.5);
    noise_amp = psychsr_set('sound','noise_amp',0);
    tone_time = psychsr_set('sound','tone_time',0.5);
    tone_amp = psychsr_set('sound','tone_amp',0);    
        
    blank_time = 0.1;        
    Fs=44100;
    
    % pad end of waveforms with zeros    
    blank = zeros(1,Fs*blank_time);
    
    noisedata = [noise_amp*rand(1,Fs*noise_time), blank];
    noisedata = [noisedata; noisedata];
    
    noise2 = [noise_amp*2*(sin(2*2*pi*(0:1/Fs:noise_time-1/Fs))>0).*rand(1,Fs*noise_time), blank];
    noise2 = [noise2; noise2];
        
    shortnoise = [noise_amp*rand(1,Fs*0.1), blank];
    shortnoise = [shortnoise; shortnoise];
    
    % used to be 2093Hz
    tonedata = [tone_amp*sin(5000*2*pi*(0:1/Fs:tone_time-1/Fs)), blank];    
    tonedata1 = [zeros(size(tonedata));tonedata]; % right
    tonedata2 = [tonedata;zeros(size(tonedata))]; % left    
    tonedata = [tonedata;tonedata];
    
    mod_tone_amp = tone_amp+0.2*sin(2*2*pi*(0:1/Fs:tone_time-1/Fs));
    tonedata3 = [mod_tone_amp.*sin(5000*2*pi*(0:1/Fs:tone_time-1/Fs)), blank];
    tonedata3 = [tonedata3;tonedata3];
    
    low_tonedata = [tone_amp*sin(220*2*pi*(0:1/Fs:tone_time-1/Fs)), blank];
    low_tonedata = [low_tonedata;low_tonedata];
        
    %0.1s, 10kHz
    click = [tone_amp*sin(10000*2*pi*(0:1/Fs:0.1-1/Fs)), blank];
    click = [click;click];
    
    dblclick = [click, click];
    
    click2 = [tone_amp*sin(8000*2*pi*(0:1/Fs:0.1-1/Fs)), blank];
    click2 = [click2;click2];    
    
    gosound = [2*tone_amp*sin(4000*2*pi*(0:1/Fs:0.1-1/Fs)), blank]; 
    goleft = [gosound;zeros(size(gosound))];
    goright = [zeros(size(gosound));gosound];
    gosound = [gosound;gosound];
    
    % complex tone
    complextone = 0;
    for i = 2:2:20 % 2kHz to 20kHz
        complextone = complextone+sin(i*2000*pi*(0:1/Fs:tone_time-1/Fs));
    end
    complextone = [complextone/max(complextone), blank];
    complextone1 = [zeros(size(complextone)); tone_amp*complextone]; %right
    complextone2 = [tone_amp*complextone; zeros(size(complextone))]; %left
    dualcomplex = complextone1+complextone2;
       
    % low frequency cue (RH)
    lowcue_RH = [tone_amp*sin(1000*2*pi*(0:1/Fs:tone_time-1/Fs)), blank];        
    lowcue_RH = [lowcue_RH;lowcue_RH];
    
    highcue_RH = [tone_amp*sin(7500*2*pi*(0:1/Fs:tone_time-1/Fs)), blank];        
    highcue_RH = [highcue_RH;highcue_RH];
    
    midcue_RH = [tone_amp*sin(4000*2*pi*(0:1/Fs:tone_time-1/Fs)), blank];        
    midcue_RH = [midcue_RH;midcue_RH];
    
    vhighcue = [tone_amp*sin(17000*2*pi*(0:1/Fs:tone_time-1/Fs)), blank];        
    vhighcue = [vhighcue;vhighcue];
    
    % chirps
    t = (0:1/Fs:tone_time-1/Fs); 
    f1 = 1000; f2 = 7500; T = tone_time;
%     chirp_up = [tone_amp*sin(2*pi*t.*(f1+(f2-f1)/T*t)), blank];

chirp_flag = true;
try
    chirp_up = [tone_amp*chirp(t,f1,T,f2), blank];
    chirp_up = [chirp_up;chirp_up];    
%     chirp_dn = [tone_amp*sin(2*pi*t.*(f2+(f1-f2)/T*t)), blank];
    chirp_dn = [tone_amp*chirp(t,f2,T,f1), blank];
    chirp_dn = [chirp_dn;chirp_dn];
    
    f1 = 7500; f2 = 17000; T = tone_time;
    hchirp_up = [tone_amp*chirp(t,f1,T,f2), blank];
    hchirp_up = [hchirp_up;hchirp_up];  
    hchirp_dn = [tone_amp*chirp(t,f2,T,f1), blank];
    hchirp_dn = [hchirp_dn;hchirp_dn];
catch
    chirp_flag = false;
end
    % single channel noise
    silence = zeros(1, length(noise2));
    left_noise = [silence; noise2(1, :)];
    right_noise = [noise2(1, :); silence];
    
    % setup PsychPortAudio
	try 
		sound(0)
		InitializePsychSound();	
		PsychPortAudio('Close');
		pahandle = PsychPortAudio('Open',[],[],2,Fs,2);
		
		data.sound.pahandle = pahandle;
		data.sound.buffers(1) = PsychPortAudio('CreateBuffer', pahandle, noisedata);
		data.sound.buffers(2) = PsychPortAudio('CreateBuffer', pahandle, tonedata);
		data.sound.buffers(3) = PsychPortAudio('CreateBuffer', pahandle, low_tonedata);
		data.sound.buffers(4) = PsychPortAudio('CreateBuffer', pahandle, tonedata1);
		data.sound.buffers(5) = PsychPortAudio('CreateBuffer', pahandle, tonedata2);
		data.sound.buffers(6) = PsychPortAudio('CreateBuffer', pahandle, click);
		data.sound.buffers(7) = PsychPortAudio('CreateBuffer', pahandle, click2);
		data.sound.buffers(8) = PsychPortAudio('CreateBuffer', pahandle, complextone1);
		data.sound.buffers(9) = PsychPortAudio('CreateBuffer', pahandle, complextone2);
		data.sound.buffers(10) = PsychPortAudio('CreateBuffer', pahandle, dualcomplex);
		data.sound.buffers(11) = PsychPortAudio('CreateBuffer', pahandle, tonedata3);
        data.sound.buffers(12) = PsychPortAudio('CreateBuffer', pahandle, shortnoise);
        data.sound.buffers(13) = PsychPortAudio('CreateBuffer', pahandle, lowcue_RH);
        data.sound.buffers(14) = PsychPortAudio('CreateBuffer', pahandle, highcue_RH);
		data.sound.buffers(15) = PsychPortAudio('CreateBuffer', pahandle, midcue_RH);
        data.sound.buffers(16) = PsychPortAudio('CreateBuffer', pahandle, dblclick);
        data.sound.buffers(17) = PsychPortAudio('CreateBuffer', pahandle, gosound);
        data.sound.buffers(18) = PsychPortAudio('CreateBuffer', pahandle, noise2);
        data.sound.buffers(19) = PsychPortAudio('CreateBuffer', pahandle, goleft);
        data.sound.buffers(20) = PsychPortAudio('CreateBuffer', pahandle, goright);
        if chirp_flag
        data.sound.buffers(21) = PsychPortAudio('CreateBuffer', pahandle, chirp_up);
        data.sound.buffers(22) = PsychPortAudio('CreateBuffer', pahandle, chirp_dn);        
        data.sound.buffers(23) = PsychPortAudio('CreateBuffer', pahandle, hchirp_up);
        data.sound.buffers(24) = PsychPortAudio('CreateBuffer', pahandle, hchirp_dn);
        end
        data.sound.buffers(25) = PsychPortAudio('CreateBuffer', pahandle, vhighcue);
        data.sound.buffers(26) = PsychPortAudio('CreateBuffer', pahandle, left_noise);
        data.sound.buffers(27) = PsychPortAudio('CreateBuffer', pahandle, right_noise);
		% play blank sound to initialize
		PsychPortAudio('FillBuffer',pahandle,zeros(2,0.1*Fs));
		PsychPortAudio('Start',pahandle);
		PsychPortAudio('Stop',pahandle,1);
		
		clear psychsr_sound;
		psychsr_set('sound','on',1);    
	catch
		disp('No Sound!')
		psychsr_set('sound','on',0);    
	end
end