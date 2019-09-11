function new_loop = psychsr_scroll_feedback(loop)
    
    global data;  
    persistent mousex mousey;
    if isempty(mousex)
        [mousex mousey] = GetMouse;        
    end
    
    [x y] = GetMouse;    
    speed = (mousey-y)/20;    
%     if speed ~= 0
%         fprintf('%d    %2.1f\n',y,speed)
%     end
    data.stimuli.temp_freq = speed;    
    mousex = x;
    mousey = y;
    
    if y == 0 && speed > 0
        mousey = data.screen.height_pixels-1;
        SetMouse(x,mousey);
        WaitTicks(1)
%         disp('bottom')
    elseif y==data.screen.height_pixels-1 && speed < 0
        mousey = 0;
        SetMouse(x,mousey);
        WaitTicks(1)
%         disp('top')
    end
    
    
    new_loop = loop;
end