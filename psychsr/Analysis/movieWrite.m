function []=movieWrite(data, Filename, FrameRate, Colormap)
%%% Writes movies from a matlab matrix 
%%% Input: data is a x-y-t matrix of video frames
%%% Written GP 1/10/13

% User inputs
if nargin < 4
    Colormap = gray(256);
end
if nargin < 3
    FrameRate=24;
end
if nargin < 2
    Filename='test.avi';
end

% create AVI object
aviobj=avifile(Filename,'FPS',FrameRate,'Compression','none');

% scale data to full range
data = (data-min(data(:)))/(max(data(:))-min(data(:))); % scale range to 0 to 1
data = round(data*(length(Colormap)-1)+1);
keyboard

% Write frames
for i=1:size(data,3)
    
    F = im2frame(ceil((data(:,:,i)+1)*128),Colormap);
    aviobj=addframe(aviobj,F);
end

% Save movie
disp('Saving movie...')
aviobj=close(aviobj);
close