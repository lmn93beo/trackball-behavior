time=0.5;
amp=0.1;
AssertOpenGL;
InitializePsychSound(1);
Fs=44100;
pahandle = PsychPortAudio('Open',[],[],1,Fs,1,[],.01);
tonedata=amp*sin(2093*2*pi*(0:1/Fs:time-1/Fs));
noisedata=amp*rand(1,Fs*time);
noise = PsychPortAudio('CreateBuffer', pahandle, noisedata);
tone = PsychPortAudio('CreateBuffer', pahandle, tonedata);

for i = 1:60*10    
    ti = GetSecs;
    if mod(i,60) == 1
        KbPressWait;    % Wait for key press
        if mod(i,120) == 1
            PsychPortAudio('FillBuffer', pahandle, noise);
        else
            PsychPortAudio('FillBuffer', pahandle, tone);
        end
        PsychPortAudio('Start',pahandle,1,0,0);
        %PsychPortAudio('Start',pahandle,1,ti+1/60,0,ti+1/60+time);
        disp(sprintf('On:  %3.0f',(GetSecs-ti)*1000))        
        
    end

%     if mod(i,60) == 30
%         PsychPortAudio('Stop',noise);        
%         disp(sprintf('Off: %3.0f',(GetSecs-ti)*1000))
%     end
%         
    while GetSecs-ti<1/60
    end
    flips(i) = (GetSecs-ti)*1000;
end

PsychPortAudio('Close',pahandle);

plot(flips);shg