[files, dir] = uigetfile('..\behaviorData\*.mat','MultiSelect','On');

if ~iscell(files) 
    files = {files};
end

removeid = [];

for i = 1:length(files)
    load([dir files{i}]);
    if ~isfield(data.response,'n_overall')
        removeid = [removeid i];
    end 
end
params = struct;

files(removeid)=[];

for i = 1:length(files)
    load([dir files{i}]);
    
    cues = unique(data.stimuli.cue_type);
    params(i).num_cuetypes = length(cues(~strcmp(cues,'')));
    
    sides = data.stimuli.stim_side(3:3:end);
    params(i).blocksize = 1/mean(abs(diff(sides))); %if =Inf, then one side
    
    rects = [data.stimuli.rect{1:end}];
    rects = unique(rects(2:4:end));
    params(i).rectsize = 1-mean(rects)*2;
    params(i).numrects = length(rects)^2;
        
    
end

close all;
figure;
hold all;
plot([params.num_cuetypes])
plot([params.numrects])
plot([params.rectsize])
plot([params.blocksize]/10)
legend('cue','#rects','rect','bl')
