function laseralignment(amp,reps)
if nargin<2
    reps = 40;
end
if nargin<1
    amp = 2;
end
pause(1)
for i = 1:reps
    tstart = tic;
    while toc(tstart) < 5
        key = KbCheck;
        if key
            disp('Done.')
            return
        end
        pause(0.05)
    end    
lasertest(amp,2)
end
disp('Done.')