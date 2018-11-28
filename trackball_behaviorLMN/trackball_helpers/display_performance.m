global data
if lastblock ~= data.stimuli.block(k)
    fprintf('\n\nSWITCH TO BLOCK %d: ',data.stimuli.block(k)); 
    if data.stimuli.block(k)==3 || length(data.params.reward) == 1
        fprintf('EQUAL\n')
    elseif data.params.actionValue
        fprintf('LEFT = %d\n',data.params.reward(data.stimuli.block(k)));
    elseif data.params.linkStimAction            
        fprintf('LEFT-%s = %d\n',upper(data.params.stims{data.stimuli.block(k)}),data.params.reward(data.stimuli.block(k)));
    else
        fprintf('%s = %d\n',upper(data.params.stims{1}),data.params.reward(data.stimuli.block(k)));
    end

    lastblock = data.stimuli.block(k);        
end        
str = trackball_dispperf(0);
fprintf('%s',str);       

if data.params.blockRewards && length(data.params.reward) > 1
    fprintf('BLOCK %d: %d rewards of %d\n',data.stimuli.block(k),nrewards,rewardSwitch)
    fprintf('NEXT BLOCK: %d\n',bs(mod(nblocks+1,length(bs))+1))
end

if k>1 && mod(k,3) == 1
    i = str2num(data.screen.pc(end));
    if ~isempty(strfind(lower(data.screen.pc),'ball'))
        i = i+4;
    end
    fid = fopen(sprintf('rig%1d.txt',i),'w');
    str = [sprintf('RIG %1d\nMOUSE %2d\n%s TRIAL %d\n',i,...
        data.mouse,datestr(toc(tstart)/86400,'MM:SS'),k), str];
    fprintf(fid,'%s',str);
    fclose(fid);
end