% close all
[files, dir] = uigetfile('..\behaviorData\*.mat','MultiSelect','On');
if ~iscell(files) 
    files = {files};
end

raw = [];
perform = [];
rcon = []; 
lcon = [];
side = [];
orth = []; %1 is orthogonal, 0 is same
targ = []; % 1 is target, 0 nontarget
pos = [];
filelengths = [];

for i = 1:length(files)
    load([dir, files{i}]);
%     l = length(data.response.n_overall);
%     data.response.n_overall = data.response.n_overall(1:l-mod(l,5));
%     j = 5:5:length(data.response.n_overall);
%     p = zeros(size(j));
%     for k = 1:length(j)
%         p(k) = mean(data.response.n_overall(j(k)-4:j(k)));
%     end
%     p = reshape(repmat(p,5,1),[],1);    
%     perform = [perform; p];
    perform = [perform; smooth(data.response.n_overall,10)];
    raw = [raw; data.response.n_overall'];
    rcon = [rcon; data.stimuli.contrast(3:3:end)'];
    lcon = [lcon; data.stimuli.contrast2(3:3:end)'];
    side = [side; data.stimuli.stim_side(3:3:end)'];
    targ = [targ; data.stimuli.orientation(3:3:end)'==90];
    if isfield(data.stimuli,'orientation_d')        
        orth = [orth; (data.stimuli.orientation(3:3:end)~=data.stimuli.orientation_d(3:3:end))'];
    else
        orth = [orth; ones(length(data.stimuli.orientation(3:3:end)),1)];
    end
    
    r = [data.stimuli.rect{3:3:end}];
    r1 = r(1:4:end); r1 = (r1==max(r1))';
    r2 = r(2:4:end); r2 = (r2==max(r2))';
    pos = [pos; r2*2+r1+1];    
    
    if length(perform) > length(rcon)
        perform = perform(1:length(rcon));
        raw = raw(1:length(rcon));
    elseif length(perform) < length(rcon)
        rcon = rcon(1:length(perform));
        lcon = lcon(1:length(perform));
        side = side(1:length(perform));
        orth = orth(1:length(perform));
        targ = targ(1:length(perform));
        pos = pos(1:length(perform));
    end        
    filelengths = [filelengths; length(perform)];
end

draw = xor(raw,orth);
dperform = smooth(draw,10);

%% fig 1
% figure
% hold all
% plot(perform)
% plot(rcon)
% plot(lcon)
% ylim([0.05 1.05])
% xlabel('Trial # (multiple days)')
% title('Overall Performance')
% legend('% Correct','R-contrast','L-contrast')

%% fig 2
cons = 0:0.1:1;
rperf = cell(size(cons));
lperf = cell(size(cons));

for i = 1:length(cons)    
    rperf{i} = perform(abs(rcon-cons(i)) < 0.02 & side == 1 & orth == 1);
    lperf{i} = perform(abs(lcon-cons(i)) < 0.02 & side == 2);% & orth == 0);
    
    mean_rperf(i) = mean(rperf{i});
    std_rperf(i) = std(rperf{i})/sqrt(length(rperf{i}));
    
    mean_lperf(i) = mean(lperf{i});
    std_lperf(i) = std(lperf{i})/sqrt(length(lperf{i}));       
end

% figure
% hold all
% % plot(mean_rperf); plot(mean_lperf);
% errorbar(cons,mean_rperf,std_rperf)
% errorbar(cons,mean_lperf,std_lperf)
% legend('Lcon = 1.0', 'Rcon = 1.0')
% title('Performance as function of distractor contrast')
% xlabel('Distractor contrast')

%% fig 3
blockstarts = [0; find(diff(rcon)~=0 | diff(lcon)~=0)] + 1;
blockstarts = sort(union(blockstarts,filelengths(1:end-1)+1));
b = [0; find(diff(side)~=0)]+1;
b = sort(union(b,filelengths+1));

rblock = cell(length(b)-1,max(diff(b)));
lblock = cell(length(b)-1,max(diff(b)));
rconb = cell(length(b)-1,max(diff(b)));
lconb = cell(length(b)-1,max(diff(b)));

for i = 1:length(b)-1
    x = perform(b(i):b(i+1)-1)';
    if rcon(b(i))<lcon(b(i))        
        rblock(i,1:length(x)) = num2cell(x);
        rconb(i,1:length(x)) = num2cell(rcon(b(i):b(i+1)-1));
    else
        lblock(i,1:length(x)) = num2cell(x);
        lconb(i,1:length(x)) = num2cell(lcon(b(i):b(i+1)-1));
    end    
end

mean_rblock = zeros(1,max(diff(b)));
std_rblock = mean_rblock;
mean_lblock = mean_rblock;
std_lblock = mean_rblock;
mean_rconb = mean_rblock;
std_rconb = mean_rblock;
mean_lconb = mean_rblock;
std_lconb = mean_rblock;

for i = 1:size(rblock,2)
    r = [rblock{:,i}]; l = [lblock{:,i}];
    mean_rblock(i) = mean(r);
    std_rblock(i) = std(r)/sqrt(length(r));
    mean_lblock(i) = mean(l);
    std_lblock(i) = std(l)/sqrt(length(l));    
    
    r = [rconb{:,i}]; l = [lconb{:,i}];
    mean_rconb(i) = mean(r);
    std_rconb(i) = std(r)/sqrt(length(r));
    mean_lconb(i) = mean(l);
    std_lconb(i) = std(l)/sqrt(length(l));    
end

figure;
subplot(2,1,1)
hold all
errorbar(1:size(rblock,2),mean_rblock,std_rblock);
errorbar(1:size(rblock,2),mean_lblock,std_lblock);
subplot(2,1,2)
hold all
plot(mean_rconb)
plot(mean_lconb)
legend('Lcon = 1.0','Rcon = 1.0')

%% fig 4
figure
subplot(2,1,1)
orthperf = zeros(length(cons),4);
l = zeros(length(cons),2);
for i = 1:length(cons)
    orthperf(i,1) = mean(raw(orth == 1 & targ == 1 & abs(min(rcon,lcon)-cons(i))<0.02));    
    orthperf(i,2) = mean(raw(orth == 0 & targ == 1 & abs(min(rcon,lcon)-cons(i))<0.02));
    orthperf(i,3) = mean(raw(orth == 1 & targ == 0 & abs(min(rcon,lcon)-cons(i))<0.02));
    orthperf(i,4) = mean(raw(orth == 0 & targ == 0 & abs(min(rcon,lcon)-cons(i))<0.02));
    l(i,1) = length(raw(orth == 1 & abs(min(rcon,lcon)-cons(i))<0.02));
    l(i,2) = length(raw(orth == 0 & abs(min(rcon,lcon)-cons(i))<0.02));
end
h1 = bar(cons,orthperf(:,1:2)); 
set(h1(1),'FaceColor',[0 0 1])
set(h1(2),'FaceColor',[0 0 0.5])
hold on;
h2 = bar(cons,orthperf(:,3:4)-1);
set(h2(1),'FaceColor',[1 0 0])
set(h2(2),'FaceColor',[0.5 0 0])
legend('Hit% orth','Hit% same','FP% orth','FP% same','Location','SouthEast')
text(cons-0.015,0.01*ones(size(cons)),num2cell(l(:,1)),'horizontalalignment','center','fontsize',8,'fontweight','bold','Color',[1 1 1]);
text(cons+0.015,0.01*ones(size(cons)),num2cell(l(:,2)),'horizontalalignment','center','fontsize',8,'fontweight','bold','Color',[1 1 1]);


subplot(2,1,2)
altperf = zeros(length(cons),4);
l = zeros(length(cons),2);
for i = 1:length(cons)
    altperf(i,1) = mean(raw(targ == 1 & abs(min(rcon,lcon)-cons(i))<0.02));    
    altperf(i,2) = mean(draw(xor(targ,orth) == 1 & abs(min(rcon,lcon)-cons(i))<0.02));
    altperf(i,3) = mean(raw(targ == 0 & abs(min(rcon,lcon)-cons(i))<0.02));
    altperf(i,4) = mean(draw(xor(targ,orth) == 0 & abs(min(rcon,lcon)-cons(i))<0.02));
    l(i,1) = length(raw(abs(min(rcon,lcon)-cons(i))<0.02));
    l(i,2) = length(draw(abs(min(rcon,lcon)-cons(i))<0.02));
end
h1 = bar(cons,altperf(:,1:2)); 
set(h1(1),'FaceColor',[0 1 0])
set(h1(2),'FaceColor',[0 0.5 0])
hold on;
h2 = bar(cons,altperf(:,3:4)-1);
set(h2(1),'FaceColor',[1 0 1])
set(h2(2),'FaceColor',[0.5 0 0.5])
legend('Hit% cued','Hit% uncued','FP% cued','FP% uncued','Location','SouthEast')
text(cons-0.015,0.01*ones(size(cons)),num2cell(l(:,1)),'horizontalalignment','center','fontsize',8,'fontweight','bold','Color',[1 1 1]);
text(cons+0.015,0.01*ones(size(cons)),num2cell(l(:,2)),'horizontalalignment','center','fontsize',8,'fontweight','bold','Color',[1 1 1]);

% set(gcf,'OuterPosition',[0 0 1280 800])

%% fig 5
% performance as function of position
if max(pos) ~= mean(pos)
poshits = zeros(2,4);
poscrs = zeros(2,4);
l = zeros(2,4);
for i = 1:2 % sides
    for j = 1:4 % positions
        poshits(i,j) = mean(raw(side==i & pos==j & targ==1));
        poscrs(i,j) = mean(raw(side==i & pos==j & targ==0));
        l(i,j) = length(raw(side==i & pos==j));
    end
end
plotside = [1 1 2 2 1 1 2 2];
plotpos = [1 2 1 2 3 4 3 4];
for i = 1:8
    subplot(2,4,i)
    h = bar(poshits(plotside(i),plotpos(i))); 
    set(h,'FaceColor',[0 0 1])
    hold on;
    h = bar(poscrs(plotside(i),plotpos(i))-1); 
    set(h,'FaceColor',[1 0 0])
    text(1,0.01,num2cell(l(plotside(i),plotpos(i))),'horizontalalignment','center','fontsize',8,'fontweight','bold','Color',[1 1 1]);
    axis([0 2 -1 1])
end

end

%% fig 4
% b2 = [blockstarts; length(rcon)+1];
% % 3D: blocks X trials X contrasts
% rblock2 = cell(length(b2)-1,max(diff(b2)),length(cons)+1);
% lblock2 = cell(length(b2)-1,max(diff(b2)),length(cons)+1);
% 
% for i = 1:length(b2)-1
%     x = perform(b2(i):b2(i+1)-1)';
%     if rcon(b2(i))<lcon(b2(i))        
%         rblock2(i,1:length(x),find(abs(cons-rcon(b2(i)))<0.02,1)) = num2cell(x);
%         rblock2(i,1:length(x),end) = num2cell(x);
%     else
%         lblock2(i,1:length(x),find(abs(cons-lcon(b2(i)))<0.02,1)) = num2cell(x);
%         lblock2(i,1:length(x),end) = num2cell(x);
%     end    
% end
% 
% for i = 1:size(rblock2,2)
%     for j = 1:size(rblock2,3)
%         r = [rblock2{:,i,j}]; l = [lblock2{:,i,j}];
%         mean_rblock2(i,j) = mean(r);
%         std_rblock2(i,j) = std(r)/sqrt(length(r));
%         mean_lblock2(i,j) = mean(l);
%         std_lblock2(i,j) = std(l)/sqrt(length(l));    
%     end
% end

% figure;
% subplot(2,1,1); hold all
% subplot(2,1,2); hold all
% for i = 1:size(rblock2,3)-1
%     subplot(2,1,1);
%     plot(1:size(rblock2,2),mean_rblock2(:,i))
% %     errorbar(1:size(rblock2,2),mean_rblock2(:,i),std_rblock2(:,i));
%     subplot(2,1,2);
%     plot(1:size(rblock2,2),mean_lblock2(:,i))
% %     errorbar(1:size(rblock2,2),mean_lblock2(:,i),std_lblock2(:,i));
% end
% 
