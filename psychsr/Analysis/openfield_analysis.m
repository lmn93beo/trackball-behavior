bwthresh = 0.5;

% Load movie file.
[file folder] = uigetfile('*.mov','Load Movie File');
movObj = VideoReader([folder file]);
nFrames = movObj.NumberOfFrames;
vidHeight = movObj.Height;
vidWidth = movObj.Width;

% Preallocate movie structure.
mov(1:nFrames) = ...
    struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),...
           'colormap', []);

% Read one frame at a time.
for k = 1 : nFrames
    mov(k).cdata = read(movObj, k);
    disp(k)
end

calibrated = false;
figure
% Calibrate length.
while ~calibrated
    imagesc(mov(1).cdata)
    axis equal; axis tight; axis off; shg
    title('Draw a line with known real length. (double-click when finished)')
    h = imline;
    pos = wait(h);
    linepix = sqrt(sum(diff(pos).^2));
    linecm = str2double(inputdlg('Enter real length of line (cm):','Enter length'));
    pixelspercm = linepix/linecm;
    msg = sprintf('Length (px) = %1.1f\nLength (cm) = %1.1f\nPixels/cm = %1.2f\n',linepix,linecm,pixelspercm);
    calibrated = strcmp(questdlg([msg 'Is this OK?'],'Confirm calibration','Yes','No','Yes'),'Yes');
end

cropped = false;
% Crop image
while ~cropped
    imagesc(mov(1).cdata)
    axis equal; axis tight; axis off; shg
    title('Draw a rectangle to crop image. (double-click when finished)')    
    h = imrect;
    rect = wait(h);
    xmax = floor(rect(1)+rect(3));
    ymax = floor(rect(2)+rect(4));
    xmin = floor(rect(1));
    ymin = floor(rect(2));
    
    if xmin > 0 && ymin > 0 && xmax<=vidWidth && ymax<=vidHeight
        imagesc(mov(1).cdata(ymin:ymax,xmin:xmax,:))
        title('Cropped Image')
        axis equal; axis tight; axis off; shg
        cropped = strcmp(questdlg('Cropped Image OK?','Confirm cropping','Yes','No','Yes'),'Yes');
    end
end
for k = 1 : nFrames
    mov(k).cdata = mov(k).cdata(ymin:ymax,xmin:xmax,:);
end


thresholded = false;
% Confirm threshold for black and white image.
while ~thresholded
    subplot(1,2,1)
    imagesc(mov(1).cdata)
    axis equal; axis tight; axis off;
    subplot(1,2,2)
    imagesc(im2bw(mov(1).cdata,bwthresh))
    title(sprintf('Threshold = %1.2f',bwthresh));
    colormap('gray')
    axis equal; axis tight; axis off; shg
    thresholded = strcmp(questdlg('Thresholded Image OK?','Confirm threshold','Yes','No','Yes'),'Yes');
    if ~thresholded
        bwthresh = str2double(inputdlg('Pick new threshold [0-1]:','Pick new threshold',1,{num2str(bwthresh)}));
    end
end

vidHeight = ymax-ymin+1;
vidWidth = xmax-xmin+1;
bwdata = zeros(vidHeight,vidWidth,nFrames);
for k = 1:nFrames
    bwdata(:,:,k) = im2bw(mov(k).cdata,bwthresh);
end

% find centroid
xpos = zeros(1,nFrames);
ypos = zeros(1,nFrames);
for k = 1:nFrames
    [r c] = find(~bwdata(:,:,k));
    xpos(k) = mean(c);
    ypos(k) = mean(r);
end

% play back movie
for k = 1:5:nFrames
    subplot(1,1,1)
    hold off;
    imagesc(mov(k).cdata)
    axis equal; axis tight; axis off;
    hold on;
    plot(xpos(k),ypos(k),'ob','MarkerSize',10,'MarkerFaceColor',[0 0 1])
    plot(xpos(1:k),ypos(1:k))
    title(sprintf('Frame %d of %d',k,nFrames))
    shg    
end

% Calculate total distance in pixels.
figure
plot(xpos,ypos)
axis equal;
distpx = 0;
for k = 2:nFrames
    distpx = distpx + sqrt((xpos(k)-xpos(k-1))^2+(ypos(k)-ypos(k-1))^2);
end
distcm = distpx/pixelspercm;
title(sprintf('Distance travelled (px): %1.1f\nDistance travelled (cm): %1.1f',distpx,distcm))
