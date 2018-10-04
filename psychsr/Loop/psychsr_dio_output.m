function psychsr_dio_output(obj, event)

% dt = pulse length
% tstart = time pulse started, NaN means not started
%    negative value means time that pulse will start

outdata = obj.UserData;
n = length(outdata.dt);
stoplines = zeros(1,n);

% check for new digital pulse
for i = 1:n
    if outdata.dt(i) > 0 && isnan(outdata.tstart(i))
        putvalue(obj.Line(i),1); outdata.tstart(i) = GetSecs;
    elseif outdata.dt(i) > 0 && outdata.tstart(i)<0 && -outdata.tstart(i) < GetSecs
        putvalue(obj.Line(i),1); outdata.tstart(i) = GetSecs;
    end    
end

% check if ongoing pulses are near finished (within 50ms)
for i = 1:n        
    if outdata.tstart(i) > 0 && GetSecs-outdata.tstart(i) > outdata.dt(i)-0.05
        stoplines(i) = GetSecs-outdata.tstart(i)-outdata.dt(i);
    end
end

% stop ongoing pulses in order
ind = 1:n;
ind(stoplines==0) = [];
[x, ix] = sort(stoplines(ind),'descend');
ix = ind(ix);
for i = 1:length(ix)
    % stop within 2ms
    while GetSecs-outdata.tstart(ix(i)) < outdata.dt(ix(i)) - 0.001 
    end
    putvalue(obj.Line(ix(i)),0); 
%     fprintf('stopped line %d in %2.1fms\n',ix(i),1000*(GetSecs-outdata.tstart(ix(i))))
    outdata.tstart(ix(i)) = NaN;
    outdata.dt(ix(i)) = 0;    
end

obj.UserData = outdata;