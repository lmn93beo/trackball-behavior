% calculate a bootstrapped error for proportion of cells
function [n_ci, n_mean, ncells] = bootprop(celltype, session, alpha, mincells)
if nargin<4 || isempty(mincells)
    mincells = 20;
end

if nargin<3 || isempty(alpha)
    alpha = 0.05;    
end


utypes = unique(celltype);
ntypes = length(utypes);

usess = hist(session,1:max(session));
usess = find(usess>=mincells);
nsess = length(usess);

if size(celltype,2) == 1
    ncells = zeros(nsess,ntypes);
    for i = 1:nsess
        for j = 1:ntypes
            ncells(i,j) = mean(celltype(session == usess(i))== utypes(j));
        end
    end
    n_mean = mean(ncells)*100;
    if nsess>1
        [nboot, bsamp] = bootstrp(10000,@(x) mean(ncells(x,:)),1:nsess);
        n_ci = (prctile(nboot,100*(1-alpha/2))-prctile(nboot,100*alpha/2))/2*100;
    else
        n_ci = nan(size(n_mean));
    end
    
else
    ncells = zeros(nsess,ntypes,size(celltype,2));
    for i = 1:nsess
        for j = 1:ntypes
            ncells(i,j,:) = mean(celltype(session == usess(i),:)== utypes(j));
        end
    end
    n_mean = squeeze(mean(ncells)*100);
    if nsess>1
        [nboot, bsamp] = bootstrp(10000,@(x) mean(ncells(x,:,:)),1:nsess);
        nboot = reshape(nboot,[10000 size(ncells,2), size(ncells,3)]);
        
        n_ci = squeeze((prctile(nboot,100*(1-alpha/2))-prctile(nboot,100*alpha/2))/2*100);
    else
        n_ci = nan(size(n_mean));
    end
        
end

