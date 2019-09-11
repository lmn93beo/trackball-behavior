function eval_string = struct_cat(structure,dim,cellFlag)  
    % unzips a structure and places variables in workspace of caller 
    if nargin < 2 || isempty(dim);
        dim = 1;
    end
    if nargin < 3 || isempty(cellFlag)
        cellFlag = 1;
    end
    if dim > 0
        n = cellfun(@(x) size(x,dim),struct2cell(structure));    
    end
    fnames = fieldnames(structure);
    
    eval_string = '';
    for i = 1:length(fnames)
        if dim > 0 && n(i) == mode(n) % find modal number of elements (= #cells)
            if evalin('caller',sprintf('~exist(''%s'',''var'')',fnames{i}))
                eval_string = sprintf('%s%s=[];',eval_string,fnames{i});
            end
            
            eval_string = sprintf('%s%s=cat(%d,%s,%s.%s);\n',eval_string,...
                fnames{i},dim,fnames{i},inputname(1),fnames{i});
        elseif cellFlag % if not same, make into cell array
            if evalin('caller',sprintf('~exist(''%s'',''var'')',fnames{i}))
                eval_string = sprintf('%s%s={};',eval_string,fnames{i});
            end
            
            eval_string = sprintf('%s%s=cat(%d,%s,{%s.%s});\n',eval_string,...
                fnames{i},dim,fnames{i},inputname(1),fnames{i});
        end
    end
    evalin('caller',eval_string);
    
end