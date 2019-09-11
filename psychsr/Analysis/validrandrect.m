[files, dir] = uigetfile('..\behaviorData\*.mat','MultiSelect','On');

if ~iscell(files) 
    files = {files};
end

for i = 1:length(files)
    load([dir, files{i}]);
    % for each trial, binary variables representing:
    
    % performed correctly?
    perf = data.response.n_overall;
    
    % target stimulus?
    targ = data.stimuli.orientation(3:3:end)==90;
    targ = targ(1:length(perf));        
    
    % valid cue?
    valid = strcmp(data.stimuli.cue_type(2:3:end),'valid');
    
    % location of stimulus (1-4)    
    r = [data.stimuli.rect{3:3:end}];
    r1 = r(1:4:end); r1 = (r1==max(r1));
    r2 = r(2:4:end); r2 = (r2==max(r2));    
    pos = r2*2+r1+1;  
    
    % reaction time
    rewards = data.response.rewards;
    punishs = data.response.punishs;
    stims = data.presentation.stim_times;
    rt = NaN*ones(size(perf));
    for j = 1:length(rewards)
        x = find(stims<rewards(j),1,'last');
        rt(ceil(x/3)) = rewards(j)-stims(x);        
    end
    for j = 1:length(punishs)
        x = find(stims<punishs(j),1,'last');
        if ~isnan(rt(ceil(x/3))); disp('whoops.'); end;
        rt(ceil(x/3)) = punishs(j)-stims(x);        
    end
    
    % plot
    perfpos = zeros(2,max(pos));
    for j = 1:max(pos)
        perfpos(1,j) = mean(perf(pos==j & valid));
        k = j+2*abs(j-2.5)*(2*(j<2.5)-1);
        perfpos(2,j) = mean(perf(pos==k & ~valid));
    end        
    
    vRT = rt(~targ & valid);
    iRT = rt(~targ & ~valid);
    [vf vx] = ecdf(vRT);
    [i_f ix] = ecdf(iRT);
    
    hold all;
    stairs(vx,vf)
    stairs(ix,i_f)
    xlim([0.2 1])
        
end
    