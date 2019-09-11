[file dir] = uigetfile;
cd(dir)
load(file)

fps = input('Framerate: ');
fullscreen = input('Fullscreen? (0/1): ');
contrast = input('Contrast (0-1): ');

mov = 255/max(max(max(mov)))*mov;

mov = (mov-127.5)*contrast+127.5;

if ~fullscreen
    rect = [0,0,size(mov,1),size(mov,2)];
else
    rect = [];
end
win = Screen('OpenWindow',max(Screen('Screens')),[],rect);

texnums = zeros(1,size(mov,3));                
for j = 1:length(texnums)
    texnums(j) = Screen('MakeTexture',win,mov(:,:,j));
end

if fullscreen

    width = size(mov,2);
    height = size(mov,1);

    rect = Screen('Rect',win);
    ratio = rect(3)/rect(4);                            
    if ratio > width/height % screen wider than movie
        newheight = height/ratio;
        srcRect = [0,(height-newheight)/2,width,newheight];
    else
        newwidth = width*ratio;
        srcRect = [(width-newwidth)/2,0,newwidth,height];
    end  
else
    srcRect = Screen('Rect',texnums(1));
    rect = Screen('Rect',win);
    rect = CenterRectOnPoint(srcRect,rect(3)/2,rect(4)/2);
end

vbl = Screen('Flip',win);

for i = 1:length(texnums)
    Screen('DrawTexture',win,texnums(i),srcRect,rect);
    vbl = Screen('Flip',win,vbl-1/120+1/fps);
end

% Screen('CloseAll')

%% test contrasts
% clc
% [files dir] = uigetfile('MultiSelect','On');
% cd(dir)
% c = zeros(500,length(files));
% for i = 1:length(files)
%     load(files{i})
%     x = reshape(mov,16384,500);
%     c(:,i) = min(x);
%     fprintf('%s %3.0f %3.0f %3.0f\n',files{i},min(c(:,i)),median(c(:,i)),max(c(:,i)))        
%     
%     
% end