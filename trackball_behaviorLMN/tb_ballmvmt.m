%psychsr_go_root;
% cd('../behaviorData/trackball/mouse 0010')
% load('20160513_trackball_0010_SC_yellow_20mW.mat')

%%
ntrials = length(data.response.trialtime);

factor = data.response.mvmt_degrees_per_pixel; % conversion factor
thresh = data.params.threshold(1); % threshold

% raw arduino data
dx = -data.response.dx*factor;
time = data.response.time;

% fix and remove bad samples
pos = find(diff(time)>20);
while length(pos)>1
    time(pos(2)+1:end,1) = time(pos(2)+1:end,1) - 2^16/1000;
    pos = find(diff(time)>20);
end
bad = find(abs(diff(time))>1,1);
while ~isempty(bad)
    time(bad+1) = mean(time([bad,bad+2])); % interpolate
    dx(bad+1) = 0;
    bad = find(abs(diff(time))>1,1);
end
blank = find(diff(time)==0,1);
while ~isempty(blank)
    if dx(blank) == 0
        time(blank) = [];
        dx(blank) = [];
    else
        time(blank+1) = [];
        dx(blank+1) = [];
    end
    blank = find(diff(time)==0,1);
end


% create trial structure
stim = data.stimuli.loc(1:ntrials)';
if isfield(data,'choice')
    choice = data.choice(1:ntrials)';
else
    choice = data.response.choice(1:ntrials)';
end
contrast = data.stimuli.contrast(1:ntrials)';
time_pc = data.response.timePC';
ballX_pc = cellfun(@(x) x*factor,data.response.ballX,'uniformoutput',0)';
screenX_pc = cellfun(@(x) x/data.response.gain(1)*factor,data.response.screenX,'uniformoutput',0)';
gains = nan(ntrials,2);

samples_start = [data.response.samples_start{:}]';
samples = nan(ntrials,3); % start, stop, reward
triallength = nan(ntrials,1); % trial time
time_ard = cell(ntrials,1);
ballX_ard = cell(ntrials,1);
licks = cell(ntrials,1);

time_rs = cell(ntrials,1); % resampled at 100hz
ballX_rs = cell(ntrials,1);

for i = 1:ntrials
    if i == 1
        first_sample = 1;
        lick_start = 1;
    else
        first_sample = data.response.samples_reward{i-1};
        lick_start = data.response.licksamples{i-1}+1;
    end
    
    samples(i,:) = [data.response.samples_start{i}, data.response.samples_stop{i}, data.response.samples_reward{i}]...
        -first_sample+1;
    
    time_ard{i} = time(first_sample:first_sample+samples(i,3)-1);
    time_ard{i} = time_ard{i} - time_ard{i}(samples(i,1)); % set trial start to 0
    ballX_ard{i} = cumsum(dx(first_sample:first_sample+samples(i,3)-1));
    ballX_ard{i} = ballX_ard{i} - ballX_ard{i}(samples(i,1)); % set trial start to 0
    
    % find exact start point
    %     x = find(ballX_pc{i}~=0,1);
    %     n = data.samps{i}(x);
    %     y = find(ballX_ard{i}(samples(i,1):end)~=0,1)+samples(i,1)+n-2;
    %     lag = time_ard{i}(y) - time_pc{i}(x); % arduino timestamp lag rel. to pc
    %     [~,samples(i,1)] = min(abs(time_ard{i}-lag));
    %     time_ard{i} = time_ard{i} - time_ard{i}(samples(i,1)); % set trial start to 0
    %     ballX_ard{i} = ballX_ard{i} - ballX_ard{i}(samples(i,1)); % set trial start to 0
    
    triallength(i) = diff(time_ard{i}(samples(i,1:2)));
    
    % extract lick times
    lickdata = data.response.lickdata(lick_start:data.response.licksamples{i});
    abovetrs = lickdata > 1;
    crosstrs = find([0;abovetrs(2:end)-abovetrs(1:end-1)] > 0);
    licks{i} = (crosstrs-length(lickdata))/64 + time_ard{i}(samples(i,3));
    
    % resample at 100hz
    time_rs{i} = floor(min(time_ard{i})*100)/100:1/100:ceil(max(time_ard{i})*100)/100;
    t = [1;diff(time_ard{i})>0]>0;
    ballX_rs{i} = int
    erp1(time_ard{i}(t),ballX_ard{i}(t),time_rs{i});
    
    % find "easygain"
    dball = [0 diff(ballX_pc{i})];
    dscreen = [0 diff(screenX_pc{i})];
    x = dball<0 & thresh-abs(screenX_pc{i})>0.1;
    gains(i,1) = median(dscreen(x)./dball(x));
    x = dball>0 & thresh-abs(screenX_pc{i})>0.1;
    gains(i,2) = median(dscreen(x)./dball(x));
end

trials = struct_zip(stim,choice,time_pc,ballX_pc,screenX_pc,samples_start,samples,...
    triallength,time_ard,ballX_ard,licks);
%%



colors = [1 0.5 0.5; 0.5 0.5 1];
symbols = {'o','p'};
str = {'Left trials','Right trials'};
close all
figure
set(gcf,'position',[ 9   133   687   864])
for j = 1:2
    for i = 1:ntrials
        s = stim(i);
        correct = (stim(i) == choice(i))+1;
        subplot(2,1,j)
        if s == j && choice(i) ~=5 && contrast(i)>0
            %     clf
            ix = time_ard{i}>-1 & time_ard{i}<0;
            if max(abs(ballX_ard{i}(ix))) < 5

                hold on                                
%                 plot(time_ard{i},ballX_ard{i},'color',[0.7 0.7 0.7])
%                 tsamples = samples(i,1):samples(i,2);
%                 plot(time_ard{i}(tsamples),ballX_ard{i}(tsamples),'color',colors(s,:))

                ix = find(time_ard{i}>-1,1):find(abs(ballX_ard{i})>thresh,1);
                plot(time_ard{i}(ix),-ballX_ard{i}(ix),'color',colors(s,:))
                
                %     plot(time_pc{i},screenX_pc{i},'color',colors(s,:))

%                 plot(time_ard{i}(samples(i,2)),ballX_ard{i}(samples(i,2)),symbols{correct},...
%                     'color',colors(s,:),'markersize',10,'markerfacecolor',colors(s,:))
            end 
        end
    end
    axis([-1 3.5 -30 30])
    plot([0 0],ylim,':k')
    plot(data.params.responseTime*[1 1],ylim,':k')
    plot(xlim,thresh*[1 1],':','color',colors(2,:))
    plot(xlim,-thresh*[1 1],':','color',colors(1,:))
    ylabel('Leftward motion (degrees)')
    xlabel('Time from trial start (s)')
    ix = stim==j & choice<5 & contrast>0;
    title(sprintf('%s: %2.0f%% / %2.0f%%',str{j},mean(choice(ix)==j)*100,...
        mean(choice(ix)==3-j)*100))
    shg
end
%     pause

psychsr_go_root;
cd('../behaviorData/trackball/figures')
saveas(gcf,sprintf('%s ballmvmt.fig',datestr(today,'yymmdd')))
saveas(gcf,sprintf('%s ballmvmt.eps',datestr(today,'yymmdd')))
saveas(gcf,sprintf('%s ballmvmt.tif',datestr(today,'yymmdd')))