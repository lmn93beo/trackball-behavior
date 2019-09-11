function newdata = trackball_getdata(flag)
global data
% flag:
% 1 = licks
% 2 = movement
% 3 = both
persistent bytes
if isempty(bytes)
    bytes = 0;
end

temp = [];
if flag == 3
    newdata = cell(1,2);
else
    newdata = [];
end
if data.params.lever>0
   if data.params.lever == 1; chans = 2; else chans = [2 3]; end;   
   if data.card.ai.SamplesAcquired > data.response.nsampled
       temp = peekdata(data.card.ai,data.card.ai.SamplesAcquired-data.response.nsampled);
       n = size(temp,1);
       data.response.nsampled = data.response.nsampled + n;
       data.response.lickdata = [data.response.lickdata; temp(:,1)];
       data.response.mvmtdata = [data.response.mvmtdata; temp(:,chans)-repmat(data.params.lev_baseline,size(temp,1),1)];
       
%        if data.params.lev_touch
           data.response.touchdata = [data.response.touchdata; temp(:,end)];
%        end
   end 
   
   if ~isempty(temp)
       if flag == 1
           newdata = temp(:,1);
       elseif flag == 2
           newdata = temp(:,chans)-repmat(data.params.lev_baseline,size(temp,1),1);
       else
           newdata{1} = temp(:,1);
           newdata{2} = temp(:,chans)-repmat(data.params.lev_baseline,size(temp,1),1);
       end
   end
       
else    
    if flag == 1 || flag == 3
        if data.card.ai.SamplesAcquired > data.response.nsampled
            temp = peekdata(data.card.ai,data.card.ai.SamplesAcquired-data.response.nsampled);
            n = size(temp,1);
            data.response.nsampled = data.response.nsampled + n;
            data.response.lickdata = [data.response.lickdata; temp];
        end
        if ~isempty(temp)
            if flag == 3
                newdata{1} = temp(:,1);
            else
                newdata = temp(:,1);
            end
        end
    end
    
    if flag == 2 || flag == 3
        if bytes > 4
            [d,b] = fscanf(data.serial.in,'%d');
            bytes = bytes-b;            
            if length(d) == 2
                data.response.mvmtdata(end+1,:) = d([2 1]);
                temp = d';
            end               
        else
            bytes = data.serial.in.BytesAvailable;
        end
        if flag == 3
            newdata{2} = temp;
        else
            newdata = temp;
        end
    end

end
