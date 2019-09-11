function []=animate_textures(w,tex_stim,stimFrames,stimIndices,tex_blank,blankFrames,blankIndices)

%% Animation loop:
if nargin==3        % for constant stimulation
    vbl=Screen('Flip', w);
    for i=1:stimFrames
        % Draw image
        Screen('DrawTexture',w,tex_stim(stimIndices(i)));
        vbl=Screen('Flip',w,vbl+(waitframes-0.5)*ifi);
    end
    
elseif nargin==6    % for stimulus interleaved with blank frames
    vbl=Screen('Flip', w);
    for i=1:stimFrames
        % Draw image
        Screen('DrawTexture',w,tex_stim(stimIndices(i)));
        vbl=Screen('Flip',w,vbl+(waitframes-0.5)*ifi);
    end
    for i=1:blankFrames
        % Draw image:
        Screen('DrawTexture', w, tex_blank(blankIndices(i)));
        vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
    end
end