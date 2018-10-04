folder = 'C:\dropbox\mouseattention\Matlab\movies';
movs = cell(10,1);
for i = 1:10
load(sprintf('%s\\image%d.mat',folder,i));
movs{i} = mov;
end
movs = movs([3 1 6 2 4 5 7:10]);

totalmov = cell2mat(reshape(movs,5,2)');

figure;
% subplot(1,2,2)
imagesc(totalmov); colormap(gray)
axis equal
axis off
a = axis;

subplot(1,2,1)
for i = 1:12
grating(:,:,i) = repmat(-cos(2*pi/12*i+0.1*(1:128))',1,128);
end
imagesc(size(totalmov,2)/2-64,size(totalmov,1)/2-64,grating);colormap(gray);
axis(a)
axis off


%% test
totalmov = cell2mat(movs(1:5)')

totalmov = movs{1};
