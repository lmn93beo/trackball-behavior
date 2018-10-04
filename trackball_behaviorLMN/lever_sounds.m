psychsr_go_root();
cd gerald/newbehavior
tone_amp = 1;
tone_time = 0.25;
Fs = 44.1e3;

t = (0:1/Fs:tone_time-1/Fs);
f1 = 1000; f2 = 7500; T = tone_time;
chirp_up = tone_amp*chirp(t,f1,T,f2);
chirp_dn = tone_amp*chirp(t,f2,T,f1);

chirps = cat(2,zeros(1,1.5*Fs),chirp_dn,zeros(1,1.5*Fs),chirp_up);
audiowrite('chirps.wav',chirps,Fs)

lowcue = tone_amp*sin(1000*2*pi*(0:1/Fs:tone_time-1/Fs));    
highcue = tone_amp*sin(7500*2*pi*(0:1/Fs:tone_time-1/Fs));

tones = cat(2,zeros(1,1.5*Fs),highcue,zeros(1,1.5*Fs),lowcue);
audiowrite('tones.wav',tones,Fs)

subplot(2,2,1)
spectrogram(chirp_dn,512,500,512,Fs,'yaxis')

subplot(2,2,2)
spectrogram(chirp_up,512,500,512,Fs,'yaxis')

subplot(2,2,3)
spectrogram(highcue,512,500,512,Fs,'yaxis')

subplot(2,2,4)
spectrogram(lowcue,512,500,512,Fs,'yaxis')

for i = 1:4
    subplot(2,2,i)
    axis([0 0.25 0 1e4])
    set(gca,'xtick',[0 0.25])
    set(gca,'ytick',0:2e3:1e4);
    set(gca,'yticklabel',0:2:10)
    ylabel('Frequency (kHz)')
end