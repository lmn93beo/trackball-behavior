% Test to see if Nucleus Basalis stimulation is desynchronizing EEG
function []=NBstimTest_immediate(stimFlag)

daqreset

if nargin==0
    stimFlag=0;
end

% parameters
plotFlag=1;      % set plot option
powerspecFlag=1; % set whether powerspectrum is measured
fftFlag=1;       % set whether FFT is measured
sampRate=10000;  % set sample rate

EEGsamp=10001;   % number of EEG samples to analyze
totalLen=3;      % total length (sec)
delay=0.7;       % delay between stim and post analysis (sec)

% create input channel
ai=analoginput('nidaq','Dev1');
aiChan=addchannel(ai,[2]);
set(aiChan,'HwChannel',2)
set(ai,'SampleRate',sampRate,'SamplesPerTrigger',totalLen*sampRate,'TriggerType','immediate');

% create output channel
ao=analogoutput('nidaq','Dev1');
addchannel(ao,[1]);
set(ao,'SampleRate',10000,'TriggerType','immediate');
if stimFlag==1
    putdata(ao,[zeros(EEGsamp+1,1); 10; zeros(totalLen*sampRate-EEGsamp-2,1)]);
else  putdata(ao,[zeros(totalLen*sampRate,1)]);
end

% run
start(ai);
start(ao);
data=getdata(ai);

% analyze powerspectrum
if powerspecFlag==1;
    postBegin=EEGsamp+delay*sampRate-1;
    postEnd=postBegin+EEGsamp-1;

    preXcorr=xcorr(data(1:EEGsamp),data(1:EEGsamp),(EEGsamp-1)/2);
    postXcorr=xcorr(data(postBegin:postEnd),data(postBegin:postEnd),(postEnd-postBegin)/2);
    pre=fft(preXcorr);
    post=fft(postXcorr);
    
    preMean=mean(abs(pre(2:101))); postMean=mean(abs(post(2:101)));
    deltaLow=mean(abs(post(2:11))/postMean)/mean(abs(pre(2:11))/preMean)*100;
    deltaHigh=mean(abs(post(12:101))/postMean)/mean(abs(pre(12:101))/preMean)*100;


    if plotFlag==1
        figure; plot(data); title('raw trace');

        figure; subplot(1,2,1)
        loglog(linspace(1,100,100),abs(pre(2:101)),'b',linspace(1,100,100),abs(post(2:101)),'r')
        legend('preNBstim','postNBstim'); title('Effect of NB stim on powerspectrum')
        ylabel('magnitude'); xlabel('frequency (Hz)'); axis square

        disp(' ')
        disp('Effect of NB stim on powerspectrum:')
        disp(['Low frequencies (1-10 Hz): ' num2str(deltaLow)])
        disp(['High frequencies (10-100 Hz): ' num2str(deltaHigh)])
        disp(' ')
    end
end

% analyze fft
if fftFlag==1
    postBegin=EEGsamp+delay*sampRate-1;
    postEnd=postBegin+EEGsamp-1;

    pre2=fft(data(1:EEGsamp));
    post2=fft(data(postBegin:postEnd));
    
    preMean2=mean(abs(pre2(2:101))); postMean2=mean(abs(post2(2:101)));
    deltaLow2=mean(abs(post2(2:11))/postMean2)/mean(abs(pre2(2:11))/preMean2)*100;
    deltaHigh2=mean(abs(post2(12:101))/postMean2)/mean(abs(pre2(12:101))/preMean2)*100;


    if plotFlag==1
        subplot(1,2,2)
        loglog(linspace(1,100,100),abs(pre2(2:101)),'b',linspace(1,100,100),abs(post2(2:101)),'r')
        legend('preNBstim','postNBstim'); title('Effect of NB stim on FFT magnitude')
        ylabel('magnitude'); xlabel('frequency (Hz)'); axis square

        disp('Effect of NB stim on FFT magnitude:')
        disp(['Low frequencies (1-10 Hz): ' num2str(deltaLow2)])
        disp(['High frequencies (10-100 Hz): ' num2str(deltaHigh2)])
        disp(' ')
    end
end
