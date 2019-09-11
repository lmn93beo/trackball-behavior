function status = psychsr_sound_GP()
repeats = 15;
offTime = 2;
onTime = 1;

sounds = [13 14 21 22];
nstimuli = repeats*length(sounds);
stimtime = offTime:(onTime+offTime):(onTime+offTime)*nstimuli;

total_duration = nstimuli*(offTime+onTime);
disp(total_duration);
%%
    global data;
    
    data.sound.tone_amp = 0.7;
    data.sound.tone_time = 0.25;
    data.sound.noise_amp = 0.5;
    data.sound.noise_time = 1;
        
    psychsr_sound_setup();    
    sound = data.sound;
    psychsr_unzip(sound);
    PsychPortAudio('FillBuffer', pahandle, buffers(2));
    
    clear status;
    
    psychsr_set('card','name','nidaq');
    psychsr_set('card','id','Dev1');    
    daqreset    
    data.card.dio = digitalio(data.card.name, data.card.id);
    psychsr_set('card','trigger_port',2);
    psychsr_set('card','trigger_line',5);
    
    addline(data.card.dio, data.card.trigger_line, data.card.trigger_port, 'out');
    data.card.trigger = data.card.dio.Line(end);
    
    putvalue(data.card.trigger,0);
    start(data.card.dio);
    
%     %%% trigger for starting or stopping Arduino loop
%     data.StartTrigger=daq.createSession('ni');
%     addDigitalChannel(data.StartTrigger,'USB6000',{'Port0/Line0'},'OutputOnly');
%     outputSingleScan(data.StartTrigger,0);
    tstart = tic;
%     outputSingleScan(data.StartTrigger,1);
    putvalue(data.card.trigger,1);
    WaitSecs(0.005);
    putvalue(data.card.trigger,0);
    disp('Triggered')
    
    k=1;
    while toc(tstart) < (onTime+offTime)*nstimuli
                
        if k <= nstimuli && toc(tstart)>stimtime(k)
            psychsr_sound(sounds(mod(k-1,length(sounds))+1));
            k = k+1;
        end
        pause(0.02);
%         disp(i)
%         status(3*i-2) = PsychPortAudio('GetStatus', pahandle);
%         pause(0.6);
%         status(3*i-1) = PsychPortAudio('GetStatus', pahandle);
%         pause(0.6);
%         status(3*i) = PsychPortAudio('GetStatus', pahandle);

        
%         psychsr_sound(1);
%         fprintf('%4.1f\n',toc*1000);
%         %PsychPortAudio('Stop',pahandle,3);        
% %         pause(1.5);
% %         psychsr_sound(6);
%         pause(1.25)
    end
    
%     outputSingleScan(data.StartTrigger,0);
% release(data.StartTrigger);
% 
% data.StartTrigger=[];
% clear data.StartTrigger
end