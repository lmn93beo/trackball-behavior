factor = data.response.mvmt_degrees_per_pixel; % conversion factor
n = find(data.response.reward>0,1,'last');
time_pc = data.response.timePC(1:n)';
ballX_pc = cellfun(@(x) -x,data.response.ballX(1:n)','uniformoutput',0);
samps_pc = data.response.samps(1:n)';

time_ard = cell(size(time_pc));
ballX_ard = cell(size(ballX_pc));
for i = 1:n    
    a = data.response.samples_start{i};
    b = data.response.samples_stop{i};    
    
    time_ard{i} = data.response.time((a+1):b);
    ballX_ard{i} = cumsum(data.response.dx((a+1):b));
    time_ard{i} = time_ard{i}-time_ard{i}(1);
        
    t_pc = time_pc{i}(find(samps_pc{i}~=0,1,'last'));    
    t_ard = time_ard{i}(end);
    time_ard{i} = time_ard{i}-t_ard+t_pc;
%     
%     
%     matchpt = intersect(ballX_pc{i},ballX_ard{i});
%     matchpt = matchpt(find(matchpt>0,1));
%     if ~isempty(matchpt)
%         t_pc = time_pc{i}(find(ballX_pc{i}==matchpt,1));
%         t_ard = time_ard{i}(find(ballX_ard{i}==matchpt,1));    
%         time_ard{i} = time_ard{i}-t_ard+t_pc;
%     else
%         time_ard{i} = time_ard{i}-time_ard{i}(1);
%     end
    
end

%%
for i = 1:n
    clf
    plot(time_pc{i},ballX_pc{i},'-o')
    hold all
    plot(time_ard{i},ballX_ard{i},'.-')
    shg
    pause
end
    
%%
figure
m = 3;
hold all
plot(time_pc{m},ballX_pc{m},'-o')
plot(time_ard{m},ballX_ard{m},'.-')
ls = data.response.samples_start{m}; % last sample
x = 0; y=0;
for i = 1:length(samps_pc{m})    
    n = samps_pc{m}(i);
    if samps_pc{m}(i)>0
        ls = ls+n/2;        
        ix = ls-n+1:ls;
        newdata = data.response.mvmtdata(ix);
        x = sum(newdata)+x;
        
        ix = ls-n/2+1:ls;
        newdata = data.response.mvmtdata(ix);
        y = sum(newdata)+y;
    end
    plot(time_pc{m}(i),x,'or')
    plot(time_pc{m}(i),y,'oc')
end

%%
x=cellfun(@sum,data.response.samps);
y=cellfun(@(x,y) x-y,data.response.samples_stop,data.response.samples_start);
plot(x,y,'o')
