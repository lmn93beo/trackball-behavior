function new_loop = psychsr_check_response(loop)    
    % checks for animal response using DAQ
    % returns loop.response depending on lick/no-lick

    global data;       
    persistent nsampled;
    persistent ai;
    persistent samples_per_frame;
    if loop.frame == 1
        samples_per_frame = [];
    end
    
    if data.response.mode>0
        
        if isempty(data.response.totaldata)
            prime_last = 0;
            nsampled = 0;
            ai = data.card.ai;            
        end

        % if new samples available
        if ai.SamplesAcquired > nsampled 
            
            % acquire new data        
            newdata = peekdata(ai,ai.SamplesAcquired-nsampled);   
            n = size(newdata,1);
            
            testdata = newdata; % testdata is newdata plus previous data point
            if ~isempty(data.response.totaldata)
                testdata = [data.response.totaldata(end,:);testdata]; 
            end
%             if data.response.mode == 8
%                 loop.response = [0 0];
%             else
%                 loop.response = 0;
%             end
            % check for rising edge
            for i = 1:size(testdata,2)
                [m mi] = max(diff(testdata(:,i)));
                if m > data.response.trig_level && ...
                        testdata(mi,size(testdata,2)-i+1) < data.response.trig_level % other channel should be LOW
                    loop.response(i) = true;
                else
                    loop.response(i) = false;
                end                    
            end            
            if sum(loop.response) > 0
                if isempty(data.response.licks)
                    data.response.licks = loop.response*loop.prev_flip_time;
                else
                    data.response.licks(end+1,loop.response) = repmat(loop.prev_flip_time,1,sum(loop.response));                
                end
                
                offset = loop.prev_flip_time-(mi+length(data.response.totaldata))/data.card.ai_fs;
                if ~isfield(data.response,'lick_offset')
                    data.response.lick_offset(1) = offset;
                else
                    data.response.lick_offset(end+1) = offset;
                end
%                 fprintf('offset = %2.3f ms\n',offset*1000);                
                
            end
            
            % store data
            nsampled = nsampled + n;
            data.response.totaldata = [data.response.totaldata; newdata];
            
            samples_per_frame = [samples_per_frame; n];
%             if rand > 0.8
%                 fprintf('%1.3f %1.3f %1.3f\n', loop.prev_flip_time-length(data.response.totaldata)/data.card.ai_fs, ...
%                     mean(samples_per_frame(samples_per_frame>0)), mean(samples_per_frame>0))
%             end
            
        else
            loop.response = false;
            samples_per_frame = [samples_per_frame; 0];            
        end           
       
        if data.response.mode == 8 && isfield(data.card,'ax')
            data.response.spout_pos(loop.frame) = data.card.ax.GetPosition_Position(0);
        end
            
    end
    new_loop = loop;
end