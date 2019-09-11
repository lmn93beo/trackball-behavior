function samples = psychsr_rand(p, n, replacement, max_repeats, prev_data)
% p = if number, binary probability of 1 (vs 2)
%   = if vector, probability of samples 1 to length(probs)
% n = number of samples
% replacement = if 0 completely random; if 1 ensures proportion matches
%               probabilites
% max_repeats = maximum number of repeated indices in a row

if nargin<5
    prev_data = [];
end

if length(p) < 2
    p(2) = 1-p;
end

samples = zeros(1,n);

switch replacement 
case 0
    p = cumsum(p);
    for i = 1:n        
        % check for max repeat rule
        x = length(samples(1:i-1));
        if max_repeats > 0 && i > max_repeats && std(samples(i-max_repeats:i-1)) == 0
            repeat = samples(i-1);
        elseif max_repeats > 0 && i+length(prev_data) > max_repeats && ...
                std([prev_data(end-max_repeats+x+1:end), samples(1:i-1)]) == 0
            repeat = prev_data(end);
        else
            repeat = 0;
        end
            
        while samples(i) == 0 || samples(i) == repeat
            s = rand;
            for j = 1:length(p)
                if s < p(j)
                    break;
                end
            end               
            samples(i) = j;
        end
    end
    
otherwise
    s = [];
    for i = 1:length(p)
        s = [s,i*ones(1,round(p(i)*n))];
    end
    while length(s)>length(samples)
        remainders = p*n-floor(p*n);
        remove = find(remainders == min(remainders(remainders>=0.5)),1);
        s(find(s==remove,1)) = [];
    end
    while length(s)<length(samples)
        remainders = p*n-floor(p*n);
        add = find(remainders == max(remainders(remainders<0.5)),1);
        s = [s,add];
    end
    
    for i = 1:n
        % check for max repeat rule
        x = length(samples(1:i-1));
        if max_repeats > 0 && i > max_repeats && std(samples(i-max_repeats:i-1)) == 0
            repeat = samples(i-1);
        elseif max_repeats > 0 && i+length(prev_data) > max_repeats && ...
                std([prev_data(end-max_repeats+x+1:end), samples(1:i-1)]) == 0
            repeat = prev_data(end);
        else
            repeat = 0;
        end
        
        loop = 0;
        while samples(i) == 0 || samples(i) == repeat
            if i > 1 && samples(i) == 0
               % remove previous
               s(r) = [];
            end
            % randomly sample from s
            r = randi(length(s),1);            
            samples(i) = s(r);
            loop = loop+1;
            if loop > 50 
                keyboard; end
        end
    end
end
        
                
    
    
    