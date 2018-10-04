function status = psychsr_sound_WFscope()
repeats = 20;
offTime = 3.5;
onTime = 0.5;

sounds = [21 22 13 14 15 1]; %[1 13 14 25 21 23 22 24];
nstimuli = repeats*length(sounds);
stimtime = offTime:(onTime+offTime):(onTime+offTime)*nstimuli;

order = randomizeStims(mfilename('fullpath'),length(sounds),repeats);

total_duration = (onTime+offTime)*nstimuli
%%
global data;

data.sound.tone_amp = 0.5;
data.sound.tone_time = onTime;
data.sound.noise_amp = 0.5;
data.sound.noise_time = onTime;

psychsr_sound_setup();
sound = data.sound;
psychsr_unzip(sound);
PsychPortAudio('FillBuffer', pahandle, buffers(2));

clear status;

%%% trigger for starting or stopping Arduino loop
data.StartTrigger=daq.createSession('ni');
addDigitalChannel(data.StartTrigger,'NI6229',{'Port0/Line2'},'OutputOnly');
outputSingleScan(data.StartTrigger,0);

tstart = tic;
outputSingleScan(data.StartTrigger,1);

k=1;
while toc(tstart) < (onTime+offTime)*nstimuli
    
    if k <= nstimuli && toc(tstart)>stimtime(k)
        %             i = mod(k-1,length(sounds))+1;
        i = order(k);
        
        psychsr_sound(sounds(i));
        disp(i)
        k = k+1;
    end
    pause(0.05);
end

outputSingleScan(data.StartTrigger,0);
release(data.StartTrigger);

data.StartTrigger=[];
clear data.StartTrigger
end