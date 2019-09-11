clear all; clc; daqreset;

%% parameters

duration = 60*60; % total length of acquisition
plot_dur = 1.024; % length of plot (helps if plot_dur*fs is multiple of 64)
trig_win = 0.128; % length of trigger window (helps if trig_win*fs is multiple of 64)
trig_level = 1; 
fs = 1000;
sound_freq = 2093;
sound_level = 0.02;
sound_dur = 0.5;
tone_freq = 440;
tone_dur = 1;

blip = sound_level*sin(sound_freq*2*pi*(0:1/44100:sound_dur));
tone = 0.02*sin(tone_freq*2*pi*(0:1/44100:tone_dur));

%% device/plot setup

ai = analoginput('nidaq','Dev1');
chan = addchannel(ai,[2 1]); % [0 2] for lick
set(ai, 'SampleRate', fs)
fs = get(ai, 'SampleRate');
set(ai, 'SamplesPerTrigger', fs*duration)

subplot(211)
P = plot(0:1/fs:plot_dur-1/fs, zeros(plot_dur*fs,1));
% hold all  
% Q = plot(0:1/fs:plot_dur-1/fs, zeros(plot_dur*fs,1));
% hold off
axis([0 plot_dur -6 6]);  grid on
title('Preview Data')
xlabel('Time (Seconds)')
ylabel('Signal Level (Volts)')
% legend('Lick','Lever')
% shg

ao=analogoutput('nidaq','Dev1');
ochan=addchannel(ao,1);
putsample(ao,0);
% 
% dio = digitalio('nidaq','Dev1');
% addline(dio,0,1,'out');
% putvalue(dio.Line(1),0)

disp('Press any key to begin trial')
KbPressWait;    % Wait for key press
KbReleaseWait;

%% recording
start(ai)
tic
sound(tone,44100)
i = 1;
j = 1;

while ai.SamplesAcquired < plot_dur*fs
end
data = peekdata(ai,plot_dur*fs);
data = data(:,1);
nsampled = plot_dur*fs;
set(P,'ydata',data(:,1))
%set(Q,'ydata',data(:,2))
drawnow

times(i) = toc;
ns(i) = nsampled;
i = i+1;
trigs = 0;

trig_last = 0; % indicates whether level was high last time
prime_last = 0;
while ai.SamplesAcquired < duration*fs
    if ai.SamplesAcquired < nsampled+trig_win*fs
    else        
        newdata = peekdata(ai,ai.SamplesAcquired-nsampled);   % acquire new data        
        n = length(newdata);
        if max(newdata(:,1)) > trig_level % newdata(:,2) for lick
            if ~trig_last
                trigs(j) = toc;
                disp(sprintf('%02d:%02d  %03d',floor(trigs(j)/60),floor(mod(trigs(j),60)),j))
                j = j+1;
%                 sound(blip,44100)
                putsample(ao,5), tstart = tic;
                while(toc(tstart)<0.004) %pause for 4ms
                end
                putsample(ao,0), toc(tstart)*1000;                
            end
            trig_last = 1;
        else                  
            trig_last = 0;
        end
        
        if max(newdata(:,2)) > trig_level % prime
            if ~prime_last
                disp('PRIME')
                putsample(ao,5), tstart = tic;
                while(toc(tstart)<0.004) %pause for 4ms
                end
                putsample(ao,0), toc(tstart)*1000;  
            end
            prime_last = 1;
        else
            prime_last = 0;
        end 
        
        nsampled = nsampled + n;

        data = circshift(data,-n);
        data(end-n+1:end,:)=newdata(:,1); % update graph

        set(P,'ydata',data(:,1))
        %set(Q,'ydata',data(:,2))
        drawnow
        
        ns(i) = n;
        times(i) = toc;
        i = i+1;
    end
end

wait(ai,duration+1)
data = getdata(ai);
subplot(212), plot(0:1/fs:duration-1/fs,data), grid on
ylim([-6 6])
if (max(trigs)>0)
    hold all, plot(trigs,trig_level*ones(size(trigs)),'*'), hold off
end
title('All Acquired Data')
xlabel('Time (seconds)')
ylabel('Signal level (volts)')

sound(tone,44100)

delete(ai)
clear ai
delete(ao)
clear ao