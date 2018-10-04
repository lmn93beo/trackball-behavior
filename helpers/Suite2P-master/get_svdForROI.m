function [ops, U, Sv, V, Fs, sdmov] = get_svdForROI(ops)

% iplane = ops.iplane;

[Ly, Lx] = size(ops.mimg1);

ntotframes          = ceil(sum(ops.Nframes));
ops.NavgFramesSVD   = min(ops.NavgFramesSVD, ntotframes);
nt0 = ceil(ntotframes / ops.NavgFramesSVD);


ops.NavgFramesSVD = floor(ntotframes/nt0);
nimgbatch = nt0 * floor(2000/nt0);

ix = 0;
fid = fopen(ops.RegFile, 'r');

mov = zeros(Ly, Lx, ops.NavgFramesSVD, 'single');

while 1
    data = fread(fid,  Ly*Lx*nimgbatch, '*int16');
    if isempty(data)
       break; 
    end
    data = single(data);
    data = reshape(data, Ly, Lx, []);
    
%     data = data(:,:,1:30:end);
    % subtract off the mean of this batch
    data = bsxfun(@minus, data, mean(data,3));
%     data = bsxfun(@minus, data, ops.mimg1);
    
    irange = 1:nt0*floor(size(data,3)/nt0);
    data = data(:,:, irange);
    
    data = reshape(data, Ly, Lx, nt0, []);
    davg = single(squeeze(mean(data,3)));
      
    mov(:,:,ix + (1:size(davg,3))) = davg;
        
    ix = ix + size(davg,3);    
end
fclose(fid);
%%
mov(:, :, (ix+1):end) = [];

mov = mov(ops.yrange, ops.xrange, :);
% mov = mov - repmat(mean(mov,3), 1, 1, size(mov,3));
%% SVD options

ops.nSVDforROI = min(ops.nSVDforROI, size(mov,3));

if ops.sig>0.05
	for i = 1:size(mov,3)
	   I = mov(:,:,i);
	   I = my_conv2(I, ops.sig, [1 2]); %my_conv(my_conv(I',ops.sig)', ops.sig);
	   mov(:,:,i) = I;
	end
end

mov             = reshape(mov, [], size(mov,3));
sdmov           = mean(mov.^2,2).^.5;
mov             = mov./repmat(sdmov, 1, size(mov,2));
COV             = mov' * mov/size(mov,1);

ops.nSVDforROI = min(size(COV,1)-2, ops.nSVDforROI);

if ops.useGPU && size(COV,1)<1.2e4
    [V, Sv, ~]      = svd(gpuArray(double(COV)));
    V               = single(V(:, 1:ops.nSVDforROI));
    Sv              = single(diag(Sv));
    Sv              = Sv(1:ops.nSVDforROI);
    %
     Sv = gather(Sv);
     V = gather(V);
else
    [V, Sv]          = eigs(double(COV), ops.nSVDforROI);
    Sv              = single(diag(Sv));
end

U               = normc(mov * V);
U               = single(U);
%%
fid = fopen(ops.RegFile, 'r');

ix = 0;
Fs = zeros(ops.nSVDforROI, sum(ops.Nframes), 'single');
while 1
    data = fread(fid,  Ly*Lx*nimgbatch, '*int16');
    if isempty(data)
        break;
    end
    data = single(data);
    data = reshape(data, Ly, Lx, []);
    
    % subtract off the mean of this batch
    data = bsxfun(@minus, data, mean(data,3));
%     data = bsxfun(@minus, data, ops.mimg1);
    data = data(ops.yrange, ops.xrange, :);
    Fs(:, ix + (1:size(data,3))) = U' * reshape(data, [], size(data,3));
    
    ix = ix + size(data,3);
end
fclose(fid);

%%
U = reshape(U, numel(ops.yrange), numel(ops.xrange), []);
if ~exist(ops.ResultsSavePath, 'dir')
   mkdir(ops.ResultsSavePath); 
end
if getOr(ops, {'writeSVDroi'}, 0)
    save(sprintf('%s/SVDroi_%s_%s_plane%d.mat', ops.ResultsSavePath, ...
        ops.mouse_name, ops.date, ops.iplane), 'U', 'Sv', 'V', 'ops');
end
