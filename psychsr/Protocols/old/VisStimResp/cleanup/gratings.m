function data = gratings(dParams,rParams)
%% User parameters
fnames = fieldnames(dParams);
for i = 1:length(fnames)
    eval([fnames{i}, '=getfield(dParams,fnames{i});']);
end

fnames = fieldnames(rParams);
for i = 1:length(fnames)        
    eval([fnames{i}, '=getfield(rParams,fnames{i});']);
end

repeats=4;              % Number of times to run all orientations
onTime=5;               % Grating display time
offTime=5;              % Length of blanks between gratings
anglelist = 90;%0:60:300;   % List of orientations to test
spatFreq = 0.02;        % cycles/deg
amplitude = 1;
tempFreq = 2;           % cycles/sec

data.stimType='gratings';
data.onTime=onTime;
data.offTime=offTime;
data.spatialFreq=spatFreq;
data.temporalFreq=tempFreq;

freq=spatFreq*degPerPixel*2*pi;         % spatial freq in cycles per pixel

%% Make textures
% Build a procedural sine grating texture with a circular aperture
% and a RGB color offset of 0.5 -- a 50% gray. Last argument scales
% contrast from 0 to 1.
gratingtex = CreateProceduralSineGrating(win, w, h,[0.5 0.5 0.5 0.0],[],0.5);

% Phase is the phase shift in degrees (0-360 etc.)applied to the sine grating:
phase = 0;

% Compute increment of phase shift per redraw:
phaseincrement = tempFreq * 360 * ifi * waitframes;

% Create grating parameter matrix (phase, freq, amplitude)
% Note that we pad the last argument with a 4th
% component, which is 0. This is required, as this argument must be a
% vector with a number of components that is an integral multiple of 4,
% i.e. in our case it must have 4 components:
auxPars = [phase; freq; 0; 0];

%% Grating parameters and durations
orientations = [];
for i=1:repeats     % Create random stimulus vector
    orientations(:,i)=anglelist(randperm(length(anglelist)));
end
data.orientations=orientations;
orientations = repmat(reshape(orientations,1,[]),2,1);
orientations = reshape(orientations,1,[]);

amplitudes = repmat([0, amplitude],1,repeats*length(anglelist));
stimtimes = cumsum(repmat([offTime, onTime],1,repeats*length(anglelist)));

nstims = length(amplitudes);
    
%% Animation
disp('Press any key to begin trial')
Screen('TextSize', win, 24);
Screen('DrawText', win, 'Press any key to begin trial', 10, 10, 255);
Screen('Flip', win);

KbPressWait;    % Wait for key press
KbReleaseWait;

times = zeros(1,nstims+1);
flips = [];
lasti = 1;

start(ai);
tic
nsampled = 0;
trig_last = 0;
hits = 0;
misses = 0;
i = 1; j = 1; k =1; f=1;
totaldata = [];

time=0.5;
amp=0.2;
AssertOpenGL;
InitializePsychSound;
Fs=8192;
pahandle = PsychPortAudio('Open',[],[],1,Fs,1);
wavedata=amp*rand(1,Fs*time);
PsychPortAudio('FillBuffer', pahandle, wavedata);

vbl = Screen('Flip', win);
vbl0 = vbl;

% Animation loop: Repeats until keypress...
while i <= nstims
 
    % Draw the gratings with given rotation 'angles',
    % sine grating 'phase' shift and amplitude
    Screen('DrawTexture', win, gratingtex, [], [], orientations(i), [],...
        [], [], [], kPsychUseTextureMatrixForRotation, auxPars);
    
    % May optimize timing by telling GPU to begin drawing
    Screen('DrawingFinished', win);
    
    if ai.SamplesAcquired > nsampled
        n = ai.SamplesAcquired-nsampled;
        newdata = peekdata(ai,n);   % acquire new data        
        if max(newdata) > 0.2% trig_level % newdata(:,2) for lick            
            if ~trig_last
                if amplitudes(i)
                hits(j) = toc;
                disp(sprintf('%02d:%02d',floor(hits(j)/60),round(mod(hits(j),60))))
                j = j+1;                

    %                 putvalue(dio.Line(1),1), tstart = tic;
                %putsample(ao,5), tstart = tic;
                while(toc(tstart)<0.005) %pause for 5ms
                end
                putsample(ao,0), toc(tstart)*1000;
    %                 putvalue(dio.Line(1),0), toc(tstart)*1000
                else % incorrect
                    misses(k) = toc;
                    k = k+1;
                    tStart=tic;
                    t1=PsychPortAudio('Start',pahandle,1,0,0,double(tStart)+time);
                    toc(tStart);
                    PsychPortAudio('Stop',pahandle,1);
                end
            end
            trig_last = 1;
        else                  
            trig_last = 0;
        end
        nsampled = nsampled + n;
        totaldata = [totaldata; newdata];
    end
            
    % Update some grating animation parameters:
    % Increment phase
    phase = phase + phaseincrement;         
    auxPars(1) = phase;
       
    if lasti ~= i % is previous frame different from current?
        times(i) = 1000*(vbl-vbl0); % save prev frame onset time
    end
    lasti = i;
    
    % is onset time of prev frame approaching a new stimulus time?
    if (vbl-vbl0) > stimtimes(i)-1.5*ifi
        i = i + 1; % next stimulus
        if i <= nstims
            auxPars(3) = amplitudes(i);
        end
    end
    
    flips(f) = 1000*(vbl-vbl0); f = f+1;
%     % Turn on/off blinking grating
%     if mod(phase,360/flashFreq)>360/flashFreq*flashDuty
%         auxPars(3) = 0; % amplitude of 2nd grating
%     else
%         auxPars(3) = amplitude;
%     end
    
    % Show it at next retrace:
    vbl = Screen('Flip', win, vbl + (waitframes - 0.5) * ifi);
end
times(i) = 1000*(vbl - vbl0);
flips(length(flips)+1) = 1000*(vbl-vbl0);

data.flips = flips;
data.times = times;
data.hits = hits;
data.misses = misses; 
data.totaldata = totaldata;
stop(ai);

return
