function order = randomizeStims(filepath, nstims, nrepeats, rerandomize) %, offTime,onTime, params, labels)
% if nargin > 3
% 	param_struct = struct_zip(offtime,onTime,params,labels);
% end
if nargin<4
    rerandomize = false;
end

newfile = 0;
oldfile = exist([filepath '.mat'],'file');
if oldfile
	load(filepath);
else
	newfile = 1;
	order = [];
end
    
if rerandomize
    newfile = 1;
	order = [];
    oldfile = 0;
end

if size(order,1) == nstims
	newperms = nrepeats - size(order,2);
	while newperms > 0
		order(:,end+1) = randperm(nstims);
		newperms = newperms-1;
		newfile = 1;
	end
else
	order = zeros(nstims,nrepeats);
	for i = 1:nrepeats
		order(:,i) = randperm(nstims);
	end
	newfile = 1;
end
% 
% if oldfile && ~newfile && nargin>3
% 	
% end

if newfile && ~strcmp(filepath,'')
	if oldfile % rename old file
		movefile([filepath '.mat'],[filepath '_' creation_date '.mat'])
	end
	creation_date = datestr(now,'yymmdd_HHMM');
	save(filepath,'creation_date','order')
	fprintf('saved new stim order in %s.mat\n',filepath)
end
end