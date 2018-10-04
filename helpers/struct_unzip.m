function eval_string = struct_unzip(structure,idx)  
    % unzips a structure and places variables in workspace of caller 
    if nargin < 2
        idx = 1;
    end
    
    fnames = fieldnames(structure);
    eval_string = '';
    for i = 1:length(fnames)
        eval_string = sprintf('%s%s=[%s(%d).%s];\n',eval_string,fnames{i},inputname(1),idx,fnames{i});
%         eval_string=[eval_string,fnames{i}, '=[',inputname(1),'(.',fnames{i},']; '];
    end
    evalin('caller',eval_string);
    
end