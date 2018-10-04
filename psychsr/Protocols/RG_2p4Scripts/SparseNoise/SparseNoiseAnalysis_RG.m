%%
clear

filename = 'Soma1.txt';

duration = 800;
sf       = 8;
stim_dur = 4;
load('StimSparseCoarse.mat');

temp = importdata(filename);
f    = temp.data(:,2:end);
dff  = zeros(size(f));
dff_inter = zeros([duration*sf,size(f,2)]);
Spk       = zeros([duration*sf,size(f,2)]);
P.lam = .95;
P.gam = .95;

for i=1:size(f,2)
   [y,x] = ksdensity(f(:,i));
   [C,I] = max(y);
   baseline = x(I);
   dff(:,i) = (f(:,i) - baseline)/baseline;
   dff_inter(:,i) = detrend(interp1((1:size(f,1))',dff(:,i),linspace(1,size(f,1),sf*duration)));
   Spk(:,i) = smooth(fast_oopsi(dff_inter(:,i)+.6,[],P),5);
end

dff_inter = circshift(dff_inter,[0,0]);
Spk = circshift(Spk,[5,0]);

resh_dff = reshape(dff_inter,[stim_dur*sf,duration*sf/(sf*stim_dur),size(f,2)]);
resh_Spk = reshape(Spk,[stim_dur*sf,duration*sf/(sf*stim_dur),size(f,2)]);

RF_dff = zeros(stim_dur*sf,5,4,duration/(stim_dur*20),size(f,2));
RF_Spk = zeros(stim_dur*sf,5,4,duration/(stim_dur*20),size(f,2));
count = ones(5,4);

for tr=1:duration/stim_dur
  xs = Stim(1,tr); 
  ys = Stim(2,tr);
  
  for i=1:size(f,2)
    RF_dff(:,xs,ys,count(xs,ys),i) = resh_dff(:,tr,i);
    RF_Spk(:,xs,ys,count(xs,ys),i) = resh_Spk(:,tr,i);
  end  
  count(xs,ys) = count(xs,ys) + 1;    
end


%%
sm = 1;
RF = RF_dff(:,:,:,:,sm);

figure()
for xs=1:5
    for ys=1:4
        subplot(4,5,xs + 5*(ys-1))
        imagesc(squeeze(RF(:,xs,ys,:))')
        colormap(hot)
        caxis([-0.5,1])       
    end
end

figure()
for xs=1:5
    for ys=1:4
        subplot(4,5,xs + 5*(ys-1))
        errorbar(linspace(0,4,32),nanmean(RF(:,xs,ys,:),4),nanstd(RF(:,xs,ys,:),[],4)/sqrt(10))        
        xlim([0,2])
        ylim([-.5,3])
    end
end

