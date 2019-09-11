function psychsr_passive_sounds()
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

data.sound.tone_amp = 0.7;
data.sound.tone_time = onTime;
data.sound.noise_amp = 0.7;
data.sound.noise_time = onTime;

psychsr_sound_setup();
sound = data.sound;
psychsr_unzip(sound);
PsychPortAudio('FillBuffer', pahandle, buffers(2));

clear status;

% card setup
data.card.dio = digitalio(data.card.name, data.card.id);
psychsr_set('card','trigger_port',2);
psychsr_set('card','trigger_line',5);
addline(data.card.dio, data.card.trigger_line, data.card.trigger_port, 'out');
data.card.trigger = data.card.dio.Line(end);

putvalue(data.card.trigger,0);
putvalue(data.card.trigger,1);
tstart = tic;
WaitSecs(0.005);
putvalue(data.card.trigger,0);
disp('Triggered')

k=1;
while toc(tstart) < (onTime+offTime)*nstimuli
    
    if k <= nstimuli && toc(tstart)>stimtime(k)
%         i = mod(k-1,length(sounds))+1;
        i = order(k);
        
        psychsr_sound(sounds(i));
        disp(i)
        k = k+1;
    end
    pause(0.05);
    
end

end