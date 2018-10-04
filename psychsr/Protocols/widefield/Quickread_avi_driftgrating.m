function [] = Quickread_avi_driftgrating()

%%% get info
fname = ['retinotopicmap_09102015_5x5y_top_1.avi'];
VideoInput = VideoReader(fname);
VideoFrames = VideoInput.NumberOfFrames;

%%% parameters
repeats = 30;
numstim = 10;
offtime = 3;
ontime = 1;
basetime = 2;
program_rate = 10; % programmed frame rate
actual_rate = VideoFrames/(repeats*(offtime+ontime)*numstim); % actual frame rate
program_frames = program_rate*(repeats*(offtime+ontime)*numstim);


%%% stimulus vector
IneffectiveTime=1;
recsamp = (offtime-basetime)*program_rate;
basesamp = basetime*program_rate;
stimsamp = ontime*program_rate;

base_rep = [zeros(1,recsamp) -ones(1,basesamp) ones(1,stimsamp)];
one_rep = [];
for s = 1:numstim
    one_rep = [one_rep base_rep*s];
end
all_rep = repmat(one_rep,1,repeats);

%%% initialize
m = VideoInput.height;
n = VideoInput.width;
base = zeros(m,n,numstim);
stim = zeros(m,n,numstim);
basecount = zeros(1,numstim);
stimcount = zeros(1,numstim);
frameavg = zeros(1,program_frames);

% MaxFrame_stim=zeros(m,n);
% MaxFrame_base=zeros(m,n);
%%% run
for i = 1:program_frames
    idx = round(i*actual_rate/program_rate);
    currframe = mean(read(VideoInput,idx),3);
    frameavg(i) = mean(mean(currframe));
    %     for s = 1:numstim
    %         if all_rep(i)==-s
    %             base(:,:,s) = base(:,:,s)+currframe;
    %             basecount(s) = basecount(s)+1;
    %         elseif all_rep(i)==s
    %             stim(:,:,s) = stim(:,:,s)+currframe;
    %             stimcount(s) = stimcount(s)+1;
    %         end
    %     end
    
    s=all_rep(i);
    
    if s>0
        stim(:,:,s) = stim(:,:,s)+currframe;
        stimcount(s) = stimcount(s)+1;
        %            temp=cat(3,MaxFrame_stim,currframe);
        %     MaxFrame_stim=max(temp,[],3);
        
    elseif s<0
        base(:,:,-s) = base(:,:,-s)+currframe;
        basecount(-s) = basecount(-s)+1;
        %                   temp=cat(3,MaxFrame_base,currframe);
        %     MaxFrame_base=max(temp,[],3);
    end;
    
    
    progressbar(i/program_frames);
end
close all;

%%% Subtract baseline
stimresp = zeros(m,n,numstim);
for s = 1:numstim
    stimresp(:,:,s) = (stim(:,:,s)/stimcount(s))-(base(:,:,s)/basecount(s));
end

%%% normalize and reorder

normresp = zeros(size(stimresp));
for s = 1:numstim
    normresp(:,:,s) = stimresp(:,:,s)/max(max(stimresp(:,:,s)));
    normresp(normresp<0) = 0;
end

%% Save
save responses_2 stim stimcount base basecount stimresp normresp frameavg numstim m n % MaxFrame_stim MaxFrame_base

%% simple plot
figure(1);
for s = 1:numstim
    subplot(2,5,s);
    imagesc(normresp(:,:,s))
    axis square
end
set(gcf,'color',[1 1 1])
set(gcf,'position',[400 100 800 800])
saveas(gcf,'responses_drifting')


%% colors gradient used for contour plot
[x,y]=meshgrid(-399:400,-399:400);

colorScheme= [0.819607843137255 0.0980392156862745 1;...
    0.0980392156862745 0.458823529411765 1;...
    0.0980392156862745 1 0.458823529411765;...
    1 0.847058823529412 0.0941176470588235;...
    1 0.0980392156862745 0.0980392156862745;
    ];

colorScheme_rep=repmat(colorScheme,2,1);

%% contour plot
figure;
for i=1:10,
    subplot(2,5,i);
    temp=flipud(normresp(:,:,i));
    temp(temp<0*max(max(temp)))=0;
    contour(x,y,rot90(temp,-1),[0.7 0.7],'LineColor',colorScheme_rep(i,:));
    colormap('jet');
    set(gca, 'XTickLabel',[]);
    set(gca, 'YTickLabel',[]);
    axis square
end;
shg;
return;
%%
% %%
% colormat = [0 0 1; 0 1 0; 1 0 0];
% screen_map_x = zeros(3,3,3);
% screen_map_y = zeros(3,3,3);
% for i = 1:3
%     screen_map_x(i,1,:) = [0 0 1];
%     screen_map_x(i,2,:) = [0 1 0];
%     screen_map_x(i,3,:) = [1 0 0];
%     screen_map_y(1,i,:) = [1 0 0];
%     screen_map_y(2,i,:) = [0 1 0];
%     screen_map_y(3,i,:) = [0 0 1];
% end
%
% x_resp(:,:,1) = mean(cat(3,normresp(:,:,1),normresp(:,:,4),normresp(:,:,7)),3);
% x_resp(:,:,2) = mean(cat(3,normresp(:,:,2),normresp(:,:,5),normresp(:,:,8)),3);
% x_resp(:,:,3) = mean(cat(3,normresp(:,:,3),normresp(:,:,6),normresp(:,:,9)),3);
%
% y_resp(:,:,1) = mean(cat(3,normresp(:,:,1),normresp(:,:,2),normresp(:,:,3)),3);
% y_resp(:,:,2) = mean(cat(3,normresp(:,:,4),normresp(:,:,5),normresp(:,:,6)),3);
% y_resp(:,:,3) = mean(cat(3,normresp(:,:,7),normresp(:,:,8),normresp(:,:,9)),3);
%
% merge_x = cat(3,x_resp(:,:,3),x_resp(:,:,2),x_resp(:,:,1));
% merge_y = cat(3,y_resp(:,:,1),y_resp(:,:,2),y_resp(:,:,3));
%
% figure(2)
% subplot(5,8,2:3);
% image(screen_map_x)
% axis square
% subplot(5,8,[9:12 17:20 25:28 33:36]);
% image(rot90(merge_x))
% axis square
% subplot(5,8,6:7);
% image(screen_map_y)
% axis square
% subplot(5,8,[13:16 21:24 29:32 37:40]);
% image(rot90(merge_y))
% axis square
% set(gcf,'color',[1 1 1])
% set(gcf,'position',[200 100 1500 800])
% %saveas(gcf,'merge')
%
% clear merge_x merge_y
% %%
%
% [max_amp_x,max_idx_x] = max(x_resp,[],3);
% [max_amp_y,max_idx_y] = max(y_resp,[],3);
% for x = i:n
%     for y = 1:m
%         merge_x(y,x,4-max_idx_x(y,x)) = max_amp_x(y,x);
%         merge_y(y,x,max_idx_y(y,x)) = max_amp_y(y,x);
%     end
% end
%
% figure(3)
% subplot(5,8,2:3);
% image(screen_map_x)
% axis square
% subplot(5,8,[9:12 17:20 25:28 33:36]);
% image(rot90(merge_x))
% axis square
% subplot(5,8,6:7);
% image(screen_map_y)
% axis square
% subplot(5,8,[13:16 21:24 29:32 37:40]);
% image(rot90(merge_y))
% axis square
% set(gcf,'color',[1 1 1])
% set(gcf,'position',[200 100 1500 800])
% saveas(gcf,'merge_thresh')



