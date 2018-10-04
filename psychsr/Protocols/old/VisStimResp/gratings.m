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

totalduration = 1;

onTime=5;               % Grating display time
offTime=5;              % Length of blanks between gratings
repeats=60/(onTime+offTime)*totalduration;              % Number of times to run all orientations
anglelist = 90;         % List of orientations to show
spatFreq = 0.02;        % cycles/deg
amplitude = 1;
tempFreq = 2;           % cycles/sec

freemins = 1;
free_reward = 0.004;
norm_reward = 0.008;

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

%% Grating parameters and durations
orientations = [];
for i=1:repeats     % Create random stimulus vector
    orientations(:,i)=anglelist(randperm(length(anglelist)));
end
data.orientations=orientations;
orientations = repmat(reshape(orientations,1,[]),2,1);
orientations = reshape(orientations,1,[]);

if (offTime > 0)
    amplitudes = repmat([0, amplitude],1,repeats*length(anglelist));
    stimtimes = cumsum(repmat([offTime, onTime],1,repeats*length(anglelist)));
else
    amplitudes = amplitude*ones(1,repeats*length(anglelist));
    stimtimes = cumsum(onTime*ones(1,repeats*length(anglelist)));
end

% first few minutes stim on continuously
amplitudes(stimtimes<=freemins*60)=amplitude;

nstims = length(amplitudes);
blank = zeros(y_pixel,x_pixel);
blank(1,1) = 255;
blank_tex = Screen('MakeTexture', win, blank); 

%% Animation

% Create grating parameter matrix (phase, freq, amplitude)
% Note that we pad the last argument with a 4th
% component, which is 0. This is required, as this argument must be a
% vector with a number of components that is an integral multiple of 4,
% i.e. in our case it must have 4 components:
auxPars = [phase; freq; amplitudes(1); 0];

disp('Press any key to begin trial')
Screen('TextSize', win, 24);
Screen('DrawText', win, 'Press any key to begin trial', 10, 10, 255);
Screen('Flip', win);
PsychPortAudio('FillBuffer', pahandle, noise);

KbPressWait;    % Wait for key press
KbReleaseWait;

times = zeros(1,nstims+1);
flips = [];
lasti = 1;

start(ai);
tic;
clock
nsampled = 0;
trig_last = 0;
user_last = 0;
hits = [];
misses = [];
i = 1; j = 1; k =1; f=1;
totaldata = [];
blankframe = 180;

% time=0.5;
% amp=0.2;
% AssertOpenGL;
% InitializePsychSound;
% Fs=8192;
% tone = PsychPortAudio('Open',[],[],1,Fs,1);
% noise = PsychPortAudio('Open',[],[],1,Fs,1);
% tonedata=amp*sin(2093*2*pi*(0:1/Fs:time));
% noisedata=amp*rand(1,Fs*time);
% PsychPortAudio('FillBuffer', tone, tonedata);
% PsychPortAudio('FillBuffer', noise, noisedata);

vbl = Screen('Flip', win);
vbl0 = vbl;
clicked = 0;
% Animation loop: Repeats until keypress...
while toc<60*totalduration%i <= nstims
%% draw texture

    % Draw the gratings with given rotation 'angles',
    % sine grating 'phase' shift and amplitude
    if blankframe < 180
        Screen('DrawTexture', win, blank_tex);
        blankframe = blankframe+1; 
    else           
        Screen('DrawTexture', win, gratingtex, [], [], orientations(i), [],...
            [], [], [], kPsychUseTextureMatrixForRotation, auxPars);
    end
    
    % May optimize timing by telling GPU to begin drawing
    Screen('DrawingFinished', win);
 
    ttest = GetSecs;
    
%% check response    
    if ai.SamplesAcquired > nsampled        
        newdata = peekdata(ai,ai.SamplesAcquired-nsampled);   % acquire new data        
        n = length(newdata);
        if max(newdata(:,2)) > 0.5% trig_level % newdata(:,2) for lick             
            if ~trig_last
                % PsychPortAudio('Stop',pahandle,2); % interrupt current sound
                PsychPortAudio('Stop',pahandle,3,0);
                if amplitudes(i) && blankframe == 180                   
                    hits(j) = toc;
                    disp(sprintf('%02d:%02d  %03d',floor(hits(j)/60),floor(mod(hits(j),60)),j))
                    j = j+1;               

                    putsample(ao,5), tstart = tic;                    
%                     putvalue(dio.Line(1),1), tstart = tic;                                                  
                    if i <= freemins*120/(onTime+offTime)                      
                        reward_time = free_reward;
                    else                  
                        reward_time = norm_reward;
                    end
                    while(toc(tstart)<reward_time) %pause for 4ms
                    end
                    putsample(ao,0), toc(tstart)*1000;
%                     putvalue(dio.Line(1),0), toc(tstart)*1000;

%                     PsychPortAudio('FillBuffer', pahandle, tone);    
%                     PsychPortAudio('Start',pahandle,1,0,0);
                    
                else % incorrect                
                    misses(k) = toc;
                    disp(sprintf('%02d:%02d  MISS %03d',floor(misses(k)/60),floor(mod(misses(k),60)),k))
                    k = k+1;                                 
                    if blankframe == 180                    
                        disp('TIMEOUT');
                        PsychPortAudio('Start',pahandle,1,0,0);   
                        blankframe = 0;
                        stimtimes=stimtimes+3;
                        stimtimes(stimtimes>3600)=[];
                    end
                end
            else
                PsychPortAudio('Stop',pahandle,3,0);
            end
            trig_last = 1;        
        else                  
            trig_last = 0;
            PsychPortAudio('Stop',pahandle,3,0); % stop when finished
        end
        
        if max(newdata(:,1)) > 1
            if ~user_last                
                clicked = 1;
                putsample(ao,5), tstart = tic;                                                         
                reward_time = 0.004;
                while(toc(tstart)<reward_time) %pause for 4ms
                end
                putsample(ao,0), toc(tstart)*1000;                
                disp('PRIME')
%                 fprintf('r%4.1f\n',(GetSecs-ttest)*1000);
            end
            user_last = 1;                        
        else
            user_last = 0;
        end
        nsampled = nsampled + n;
        totaldata = [totaldata; newdata];
    end
 
 %% prepare next texture, flip
 
    % Update some grating animation parameters:
    % Increment phase
    phase = phase + phaseincrement;         
    auxPars(1) = phase;
       
    if lasti ~= i % is previous frame different from current?
        times(i) = 1000*(vbl-vbl0); % save prev frame onset time
    end
    lasti = i;
    
    % is onset time of prev frame approaching a new stimulus time?
    if i <= length(stimtimes)
    if (vbl-vbl0) > stimtimes(i)-1.5*ifi
        i = i + 1; % next stimulus
        if i <= nstims
            auxPars(3) = amplitudes(i);
        end
    end 
    end
    
    flips(f) = 1000*(vbl-vbl0); f = f+1;
%     % Turn on/off blinking grating
%     if mod(phase,360/flashFreq)>360/flashFreq*flashDuty
%         auxPars(3) = 0; % amplitude of 2nd grating
%     else
%         auxPars(3) = amplitude;
%     end
    
    if (rand > 0.9) || clicked
%         fprintf('%5.1f\n',(GetSecs-ttest)*1000);
    end
    clicked = 0;

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
