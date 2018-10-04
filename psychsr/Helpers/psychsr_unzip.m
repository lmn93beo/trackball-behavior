function eval_string = psychsr_unzip(structure)  
    % unzips a structure and places variables in workspace of caller 

    fnames = fieldnames(structure);
    eval_string = [];
    for i = 1:length(fnames)
        eval_string=[eval_string,fnames{i}, '=[',inputname(1),'.',fnames{i},']; '];
    end
    evalin('caller',eval_string);
    
end