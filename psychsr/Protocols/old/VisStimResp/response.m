function data = response(rParams)
tic
fnames = fieldnames(rParams);
for i = 1:length(fnames)        
    eval([fnames{i}, '=getfield(rParams,fnames{i});']);
end
toc*1000
persistent nsampled;
if isempty(nsampled)
    nsampled = 0;
end

persistent trig_last;
if isempty(trig_last)
    trig_last = 0;
end

if ai.SamplesAcquired > nsampled
    n = ai.SamplesAcquired - nsampled;
    data = peekdata(ai,n);
    if (max(data)> 1)%trig_level)
        if ~trig_last
            Beeper(2093)
        end
    end
    nsampled = nsampled + n
else
    data = 0;
end