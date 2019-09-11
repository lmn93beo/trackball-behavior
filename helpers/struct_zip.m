function structure = struct_zip(varargin)
% 'zip' variables into a structure
structure = struct;

if nargin == 1 && iscell(varargin{1})
    inames = varargin{1};
    for i = 1:length(inames)
        structure = setfield(structure,inames{i},evalin('caller',inames{i}));
    end
else
    for i = 1:nargin
        if strcmp(inputname(i),'')
            continue
        end
        structure = setfield(structure,inputname(i),varargin{i});
    end
end
end
