function allvec = append_vector(vec)
% looks in workspace of caller for a variable named "all_X"
% appends X to all_X
% works only for 1D or 2D vectors

vecname = inputname(1);
allvecname = ['all_',vecname];

allvecexists = evalin('caller',sprintf('exist(''%s'')',allvecname));

if allvecexists
    % extract vector from caller workspace
    allvec = evalin('caller',allvecname);
    
    if sum(size(allvec)==size(vec)) == 0
        vec = vec'; % transpose
    end
        
    switch sum(size(allvec)==size(vec))
        case 1 % if one of the dimensions match            
            if find(size(allvec)==size(vec)) == 1
                % append columns
                allvec = [allvec,vec];
            else
                % append rows
                allvec = [allvec;vec];
            end
        case 2 % if both dimensions match
            [x ix] = min(size(allvec));
            if ix == 1
                % append columns
                allvec = [allvec,vec];
            else
                % append rows
                allvec = [allvec;vec];
            end
        otherwise % if neither dimension matches, even after transpose
            disp('Dimensions do not match');
    end            
else
    % start a new vector
    allvec = vec;    
end

assignin('caller',allvecname,allvec);

