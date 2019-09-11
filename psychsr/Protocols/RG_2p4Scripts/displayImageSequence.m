function displayImageSequence( texgray,tex,Params, waitframes, ifi, vbl,vbl0, win)
m = 1;

% first a blank screen.........................................
% loop until TIME has elapsed
grayFrames = 1;
while vbl-vbl0 < m*Params.durBlank + (m-1)*Params.durStim - 1.5*waitframes*ifi
    Screen('DrawTexture', win, texgray(grayFrames), [0, 0, Params.width, Params.height]);
    vbl = Screen('Flip', win, vbl + (waitframes-0.5)* ifi);
    if grayFrames == 1
        fprintf('Gray #%d START: %3.3f\n',i,vbl-vbl0)
    end
    grayFrames = grayFrames +1;
end

fprintf('Gray #%d STOP:  %3.3f -- %d frames\n',i,vbl-vbl0,grayFrames)
% then a movie................................................
nFrames = 1;
while vbl-vbl0 < m*(Params.durBlank+Params.durStim) - 1.5*waitframes*ifi
    Screen('DrawTexture', win, tex(m, nFrames), [], Params.Dims);
    vbl = Screen('Flip', win, vbl + (waitframes-0.5)*ifi);
    if nFrames == 1;
        fprintf('Mov  #%d START: %3.3f\n',m,vbl-vbl0)
    end
    nFrames = nFrames + 1;
end
fprintf('Mov  #%d STOP:  %3.3f -- %d frames\n',m,vbl-vbl0,nFrames)

