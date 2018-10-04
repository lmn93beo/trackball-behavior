time=0.2;
amp=0.02;
AssertOpenGL;
InitializePsychSound(1);
PsychPortAudio('Close');
Fs=44100;
pahandle = PsychPortAudio('Open',[],[],1,Fs,1);
tonedata=[amp*sin(2093*2*pi*(0:1/Fs:time-1/Fs)), zeros(1,Fs*0.1)];
noisedata=[amp*rand(1,Fs*time), zeros(1,Fs*0.1)];

noisedata = [noisedata, zeros(1,Fs*0.1)];
noise = PsychPortAudio('CreateBuffer', pahandle, noisedata);
tone = PsychPortAudio('CreateBuffer', pahandle, tonedata);

PsychPortAudio('FillBuffer', pahandle, noisedata*0);
PsychPortAudio('Start',pahandle);
PsychPortAudio('Stop',pahandle,1);

pause(1)
PsychPortAudio('FillBuffer', pahandle, tone);

amps = 0:0.01:0.02;
tic
for i = 1:2*length(amps)      
    
%     if mod(i,2) == 0
%         PsychPortAudio('FillBuffer', pahandle, noise);    
%         %disp(sprintf('Amp:  %2.2f',amps(i/2)))                
%     else
%         PsychPortAudio('FillBuffer', pahandle, tone);
%     end
    a(i) = toc;
    PsychPortAudio('Start',pahandle);%,1,0,0); 
    b(i)=toc;    
    PsychPortAudio('Stop',pahandle,3,0);   
    c(i)=toc;
    pause(1)
    tic
end
close all
hold all;
plot(a)
plot(b-a)
plot(c-b)
shg
hold off;

PsychPortAudio('Close',pahandle);

