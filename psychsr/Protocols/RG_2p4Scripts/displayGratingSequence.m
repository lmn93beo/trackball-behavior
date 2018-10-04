function displayGratingSequence(rotateMode, Nnew, texgray, Params, waitframes, ifi, vbl,vbl0, win)

m = 1;

for m =  1:12
    amplitude       = Params.contrast; % contrast value.
    angle           = Nnew(m,1);
    freq            = Nnew(m,2);
    % phase increment..................................................
    phase = 90;
    phaseincrement = (Params.cyclespersecond * 360) * ifi;
    
    % Build grating texture....................................................
    gratingtex = CreateProceduralSineGrating(win, 256, 256, [0.5 0.5 0.5 0.0], inf, Params.contrast);
    % then a movie................................................
    nFrames = 1;
    
    grayFrames = 1;

    while vbl-vbl0 < m*Params.durBlank_Grats + (m-1)*Params.durGratings - 1.5*waitframes*ifi
        Screen('DrawTexture', win, texgray(grayFrames), [0, 0, Params.width, Params.height]);
        vbl = Screen('Flip', win, vbl + (waitframes-0.5)* ifi);
        if grayFrames == 1
            fprintf('Gray #%d START: %3.3f\n',i,vbl-vbl0)
        end
        grayFrames = grayFrames +1;
    end
    fprintf('Gray #%d STOP:  %3.3f -- %d frames\n',i,vbl-vbl0,grayFrames)
    

    while vbl-vbl0 < m*(Params.durBlank_Grats+Params.durGratings) - 1.5*waitframes*ifi
        % Draw the grating,
        Screen('DrawTexture', win, gratingtex, [], Params.Dims, angle, [], [], [], [], rotateMode, [phase, freq, amplitude, 0]);
        vbl = Screen('Flip', win, vbl + (waitframes-0.5)*ifi);
        if nFrames == 1;
            fprintf('Mov  #%d START: %3.3f\n',m,vbl-vbl0)
        end;
        nFrames = nFrames + 1;
        phase   = phase + phaseincrement;
    end;
end;

