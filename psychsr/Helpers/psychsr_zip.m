function structure = psychsr_zip(varargin)
    % 'zip' variables into a structure
    structure = struct;
    for i = 1:nargin
        structure = setfield(structure,inputname(i),varargin{i});
    end
end 
