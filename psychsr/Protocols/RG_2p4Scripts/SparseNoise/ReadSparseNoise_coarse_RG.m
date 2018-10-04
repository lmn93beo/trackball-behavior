function [] = ReadSparseNoise_coarse_RG() 

cd('C:\Dropbox\MouseAttention\Matlab\psychsr\Protocols\RG_2p4Scripts\SparseNoise');
prot        = 'astro';
imageFlag   = 0;
load('StimSparseCoarse.mat');
Stim = Stim';

if strcmp(prot,'soma')
    tempFreq  = 1/4;
    reb = 10;  %40
    duration  = 800;
elseif strcmp(prot,'astro')
    tempFreq  = 1/6;
    reb = 8;  %40
    duration  = 1200; 
else
    tempFreq  = 1/2;
    reb = 20; %40
    duration  = 600;
end

trial_len = 1/tempFreq;

ntrial    = round(duration*tempFreq);

% monitor characteristics
screens=Screen('Screens');
screenNumber=max(screens);                    % Window used for stimulus
[x_pixel,y_pixel]= Screen('WindowSize',screenNumber); % Pixel resolution
sq_size   = round(y_pixel/4);
if imageFlag
        imageArray=zeros(y_pixel,x_pixel);
end

% Find the color values which correspond to white, black, and gray
white=WhiteIndex(screenNumber);
black=BlackIndex(screenNumber);
gray=round((white+black)/2);

% Prepare daq for trigger
card.trigger_mode = 'out';  
card.id = 'Dev1';
card.name = 'nidaq';

if strcmp(card.trigger_mode, 'out')
    if ~isfield(card,'dio')
        card.dio = digitalio(card.name, card.id);
    end              
    card.trigger_port = 2;
    card.trigger_line = 5;

    addline(card.dio, card.trigger_line, card.trigger_port, 'out');
    card.trigger = card.dio.Line(end);

    putvalue(card.trigger,0);       
    start(card.dio);
end

% Display
try
    % Take control of display
    AssertOpenGL;    
    
    % Open a double buffered fullscreen window, measure flip interval
    w=Screen('OpenWindow',screenNumber,0);
    [ifi]=Screen('GetFlipInterval',w,100,0.0001,20);
    blankscreen = Screen('MakeTexture',w,gray*ones(y_pixel,x_pixel));
    %Screen('LoadNormalizedGammaTable')
	
    % Use realtime priority for better timing precision:
	priorityLevel=MaxPriority(w);
	Priority(priorityLevel);
    %hidecursor;
	
    % Start flip, Output pulse to acquisition computer
    vbl=Screen('Flip',w);
    k = 1;        
    putvalue(card.trigger,0);
    pause(0.05);
    tic
    putvalue(card.trigger,1);                        
    while k <= ntrial & ~KbCheck 
        pos_x = (Stim(k,1)-1)*sq_size;
        pos_y = (Stim(k,2)-1)*sq_size;
        pol   = 255;
		if mod(k,reb) == 0 %45
			add_one = 1;
		else
			add_one = 0;
		end
        q=0;
        while q < round(0.2/ifi)+add_one ~ KbCheck;         
            Screen('DrawTexture',w,blankscreen);
            Screen('FillRect',w,pol,[pos_x,pos_y,pos_x+sq_size,pos_y+sq_size])
            vbl = Screen('Flip', w, vbl + 0.5 * ifi);
            q = q + 1;
            if imageFlag
                if k==1
                    tempArray = Screen('GetImage',w);
                    imageArray = tempArray(:,:,1);
                    imwrite(imageArray,'screenOutput.tif')
                else
                    tempArray = Screen('GetImage',w);
                    imageArray = tempArray(:,:,1);
                    imwrite(imageArray,'screenOutput.tif','WriteMode','append')
                end
                
            end
        end
        q = 0;
        while q < round((trial_len-0.2)/ifi) ~ KbCheck;            
            Screen('DrawTexture',w,blankscreen);
            vbl = Screen('Flip', w, vbl + 0.5 * ifi);
            q = q + 1;
             if imageFlag
                if k==1
                    tempArray = Screen('GetImage',w);
                    imageArray = tempArray(:,:,1);
                    imwrite(imageArray,'screenOutput.tif')
                else
                    tempArray = Screen('GetImage',w);
                    imageArray = tempArray(:,:,1);
                    imwrite(imageArray,'screenOutput.tif','WriteMode','append')
                end
                
            end
        end   
       
        k = k + 1;
        toc
    end
    % Clean up
    Priority(0);
    Screen('CloseAll');
		
catch
    % Return in case of error
    Screen('CloseAll');
    Priority(0);
    psychrethrow(psychlasterror);
end


