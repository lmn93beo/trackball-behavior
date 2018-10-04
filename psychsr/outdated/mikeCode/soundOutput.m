time=0.5;
amplitude=0.2;
AssertOpenGL;
InitializePsychSound;
Fs=8192;
pahandle = PsychPortAudio('Open',[],[],1,Fs,1);
wavedata=amplitude*rand(1,Fs*time);
PsychPortAudio('FillBuffer', pahandle, wavedata);

for i=1:10
    pause(1)
    if rem(i,2)==0
        tStart=tic;
        t1=PsychPortAudio('Start',pahandle,1,0,0,double(tStart)+time);
        toc(tStart)
        PsychPortAudio('Stop',pahandle,1);
    end
end

PsychPortAudio('Close', pahandle);
