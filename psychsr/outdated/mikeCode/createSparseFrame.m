function tex_stim=createSparseFrame(spotPixels,x_pixel,y_pixel,white,black,gray)
% Creates a sparse noise movie frame from the input coordinates
% Called by mouseTV for sparseNoise stimulation
% Original: MG 11/22/10, Latest update: MG 11/18/10

tex_stim=ones(y_pixel,x_pixel)*gray;                            % initalize frame
[x,y]=meshgrid(1:x_pixel,1:y_pixel);                            % make meshgrid
spot_polarity=rem(randperm(size(spotPixels,1)),2)*white+black;  
for i=1:size(spotPixels,1)
    xy_map=sqrt((x-spotPixels(i,2)).^2+(y-spotPixels(i,1)).^2);
    tex_stim(xy_map<=spotPixels(i,3))=spot_polarity(i);
end