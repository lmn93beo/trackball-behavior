function str = trackball_dispperf(truncateFlag)
global data
str = '';
if nargin<1 || isempty(truncateFlag)
    truncateFlag = 1;
end

if truncateFlag
    ntrials = find(data.response.reward>0,1,'last');
else
    ntrials = length(data.response.choice);
end

if ntrials == 0    
    return
end

%%
choice = data.response.choice(1:ntrials);
loc = data.stimuli.loc(1:ntrials);
block = data.stimuli.block(1:ntrials);
if data.params.laser
    laser = data.stimuli.laser(1:ntrials);
else
    laser = ones(1,ntrials);
end
leverFlag = data.params.lever;
if leverFlag
    sound = data.stimuli.sound(1:ntrials);
end
con = data.stimuli.contrast(1:ntrials);
ucon = unique(con);


blankFlag = sum(ucon==0)>0;
conFlag = length(ucon(ucon>0))>1;
blockFlag = length(unique(block))>1 & data.params.actionValue & data.params.freeForcedBlocks;
laserFlag = length(unique(laser))>1 & data.params.laser;

%% lever program
if leverFlag
    label={'HIGH%% ','LOW%%  '};
    if strcmp(data.params.stims{1},'grating') || length(unique(sound))==1
        sound = loc;
        usound = [2 1];        
    elseif isfield(data.params,'lev_chirp') && data.params.lev_chirp
        usound = [22 21];%
    else
        usound = [14 13]; %[22 21];%
    end
    if laserFlag
        str = [str,sprintf('        LAST10     NO LASER        LASER\n')];
    else
        str = [str,sprintf('        LAST10      ALL\n')];
    end
    for s = 1:2 % sound
        
        % last 10
        clear vals
        ix = find(sound==usound(s),10,'last');        
        vals = round(mean(choice(ix)==2)*100);
        str = [str,sprintf('%s  %3d%%',label{s},vals)];
        
        % all trials
        if ~laserFlag
            clear vals
            ix = sound==usound(s);
            vals(1) = round(mean(choice(ix)==2)*100);
            vals(2) = sum(ix);
            str = [str,sprintf('    %3d%% of %3d\n',vals)];
        else
            clear vals
            ix = sound==usound(s) & laser==1;
            vals(1) = round(mean(choice(ix)==2)*100);
            vals(2) = sum(ix);
            str = [str,sprintf('    %3d%% of %3d',vals)];

            clear vals
            ix = sound==usound(s) & laser==2;
            vals(1) = round(mean(choice(ix)==2)*100);
            vals(2) = sum(ix);
            str = [str,sprintf('    %3d%% of %3d\n',vals)];
        end
    end
    
%% action value
elseif data.params.actionValue && data.params.freeForcedBlocks
    choice = data.response.choice;
    if truncateFlag
        n = find(data.response.reward>0,1,'last');
        choice = choice(1:n);
    end
    if ~isempty(choice)
        stim = data.stimuli.loc(1:length(choice));
        block = data.stimuli.block(1:length(choice));
        if data.params.blockRewards && length(data.params.reward)>1
            nb = 3;
        else
            nb = length(unique(data.stimuli.block));
        end
        if isfield(data.response,'timePC')
            rt = cellfun(@(x) x(end),data.response.timePC);
        else
            rt = [];
        end
        
        results = cell(1,3);
        label={'LEFT%% ','RIGHT%%','FREE%% '};
        rt_all = zeros(2,nb);
        
        for s = 1:3
            for b = 1:nb
                for c = [1 2 5]
                    if nb == 1
                        results{s} = cat(1,results{s}, round(mean(choice(stim==s)==c)*100));
                    else
                        results{s} = cat(1,results{s}, round(mean(choice(stim==s & block==b)==c)*100));
                    end
                end
                if nb == 1
                    results{s} = cat(1,results{s}, sum(stim==s));
                else
                    results{s} = cat(1,results{s}, sum(stim==s & block==b));
                end
                if s < 3
                    rt_all(s,b) = mean(rt(choice==s & stim==s & block==b));
                end
            end
        end
        
        reward = data.params.reward;
        if length(reward)==1; reward(2) = NaN; end;
        
        str = '';
        if nb > 1
            str = [str, sprintf('               LEFT=%d                    LEFT=%d   ',reward)];
        end
        if nb ~= 2
            str = [str, '               EQUAL'];
        end
        str = [str,sprintf('\n')];
        for s = 1:3
            str = [str, label{s}, sprintf('  %3d%%/%3d%%/%3d%% of %3d  ',results{s}), sprintf('\n')];
        end
%         str = [str, sprintf('RT(L/R)    ')];
%         for b = 1:nb
%             str = [str,sprintf('  %01.3f/%01.3f             ',rt_all(:,b))];
%         end
        str = [str, sprintf('\n')];
        
    else
        str = '';
    end
    
%% sensory task
else
    label={'LEFT%% ','RIGHT%%','FREE%% ','BLANK%%'};
    if laserFlag
        str = [str,sprintf('               NO LASER                 LASER\n')];
    end 
    
    for s = 1:4 % stimulus        
        if sum(loc==s)>0 || (s==4 && sum(con==0)>0)
            
            str = [str,sprintf('%s',label{s})];
            for l = 1:2 % laser
                if laserFlag || l<2
                    clear vals
                    if s < 4
                        ix = loc==s & laser==l & con>0;
                    else % blank trials
                        ix = laser==l & con==0;
                    end
                    vals(1) = round(mean(choice(ix)==1)*100);
                    vals(2) = round(mean(choice(ix)==2)*100);
                    vals(3) = round(mean(choice(ix)==5)*100);
                    vals(4) = sum(ix);
                    
                    str = [str,sprintf('  %3d%%/%3d%%/%3d%% of %3d  ',vals)];
                end
            end
            str = [str,sprintf('\n')];
        end
    end
    
    if conFlag
        str = [str, sprintf('\nCON:      '),sprintf('%3d      ',round(ucon*100))];
        str = [str,sprintf('\n')];
        for s = 1:2
            str = [str,sprintf('%s',label{s})];
            for c = 1:length(ucon)
                clear vals
                if ucon(c) > 0
                    ix = loc == s & con == ucon(c);
                else
                    ix = con == ucon(c);
                end
                vals(1) = round(mean(choice(ix)==1)*100);
                vals(2) = round(mean(choice(ix)==2)*100);
                
                str = [str,sprintf(' %3d/%3d ',vals)];
            end
            str = [str,sprintf('\n')];
        end
    end
        
end    

% elseif isfield(data.stimuli,'laser')
%     choice = data.response.choice;
%     if truncateFlag
%         n = find(data.response.reward>0,1,'last');
%         choice = choice(1:n);
%     end
%     if ~isempty(choice)
%         stim = data.stimuli.loc(1:length(choice));
%         laser = data.stimuli.laser(1:length(choice));
%         
%         if isfield(data.response,'timePC')
%             rt = cellfun(@(x) x(end),data.response.timePC);
%         else
%             rt = [];
%         end
%         
%         results = cell(1,3);
%         label={'LEFT%% ','RIGHT%%','FREE%% '};
%         rt_all = zeros(2,2);
%         
%         for s = 1:3
%             for l = 1:2
%                 for c = [1 2 5]
%                     results{s} = cat(1,results{s}, round(mean(choice(stim==s & laser==l)==c)*100));
%                 end
%                 results{s} = cat(1,results{s}, sum(stim==s & laser==l));
%                 if s < 3
%                     rt_all(s,l) = mean(rt(choice==s & stim==s & laser==l));
%                 end
%             end
%         end
%         
%         str = '';
%         str = [str, sprintf('               NO LASER                  LASER\n')];
%         for s = 1:3
%             str = [str, label{s}, sprintf('  %3d%%/%3d%%/%3d%% of %3d  ',results{s}), sprintf('\n')];
%         end
%         str = [str, sprintf('RT(L/R)    ')];
%         for l = 1:2
%             str = [str,sprintf('  %01.3f/%01.3f             ',rt_all(:,l))];
%         end
%         str = [str, sprintf('\n')];
%     else
%         str = '';
%     end
%     
%     
% else
%     
%     choice = data.response.choice;
%     if truncateFlag
%         n = find(data.response.reward>0,1,'last');
%         choice = choice(1:n);
%     end
%     stim = data.stimuli.loc(1:length(choice)); block=data.stimuli.id(1:length(choice));
%     left = [mean(choice(stim==1 & block==1)==1), mean(choice(stim==1 & block==1)==2), mean(choice(stim==1 & block==1)==5); ...
%         mean(choice(stim==1 & block==2)==1), mean(choice(stim==1 & block==2)==2), mean(choice(stim==1 & block==2)==5)];
%     left = cat(2, round(left*100), [sum(stim==1 & block==1); sum(stim==1 & block==2)])';
%     right = [mean(choice(stim==2 & block==1)==1), mean(choice(stim==2 & block==1)==2), mean(choice(stim==2 & block==1)==5); ...
%         mean(choice(stim==2 & block==2)==1), mean(choice(stim==2 & block==2)==2), mean(choice(stim==2 & block==2)==5)];
%     right = cat(2, round(right*100), [sum(stim==2 & block==1); sum(stim==2 & block==2)])';
%     block=data.response.choice_id;
%     free = [mean(choice(stim==3)==1), mean(choice(stim==3)==2), mean(choice(stim==3)==5); ... % left/right bias
%         mean(block(stim==3)==1), mean(block(stim==3)==2), mean(block(stim==3)==5)];   % square/diamond bias
%     free = cat(2, round(free*100), [sum(stim==3); sum(stim==3)])';
%     str = '';
%     str = [str, sprintf('           SQUARE                    DIAMOND\n')];
%     str = [str, sprintf('LEFT%%  %3d%%/%3d%%/%3d%% of %3d    %3d%%/%3d%%/%3d%% of %3d\n',left)];
%     str = [str, sprintf('RIGHT%% %3d%%/%3d%%/%3d%% of %3d    %3d%%/%3d%%/%3d%% of %3d\n',right)];
%     str = [str, sprintf('         LEFT-RIGHT               SQUARE-DIAMOND\n')];
%     str = [str, sprintf('FREE%%  %3d%%/%3d%%/%3d%% of %3d    %3d%%/%3d%%/%3d%% of %3d\n',free)];
%     
% end