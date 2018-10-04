function status = psychsr_sound_test()
    
    global data;
    
    data.sound.tone_amp = 0.25;
    data.sound.tone_time = 2;
    data.sound.noise_amp = 0.5;
    data.sound.noise_time = 1;
        
    psychsr_sound_setup();    
    sound = data.sound;
    psychsr_unzip(sound);
    PsychPortAudio('FillBuffer', pahandle, buffers(2));
    
    clear status;
    for i = 1:100
        tic      
        if mod(i,2) == 1
            psychsr_sound(13);%mod(i-1,5)+1);]        
        else
            psychsr_sound(14);
        end
%         disp(i)
%         status(3*i-2) = PsychPortAudio('GetStatus', pahandle);
%         pause(0.6);
%         status(3*i-1) = PsychPortAudio('GetStatus', pahandle);
%         pause(0.6);
%         status(3*i) = PsychPortAudio('GetStatus', pahandle);

        tstart = tic;
        while toc(tstart)<4
            pause(0.1);
            if KbCheck
                return
            end
        end
%         psychsr_sound(1);
%         fprintf('%4.1f\n',toc*1000);
%         %PsychPortAudio('Stop',pahandle,3);        
% %         pause(1.5);
% %         psychsr_sound(6);
%         pause(1.25)
    end
end