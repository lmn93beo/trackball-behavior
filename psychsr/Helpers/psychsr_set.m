function value = psychsr_set(struct_name,field_name,default)
% set parameter to default value, if not already set
    global data;
    
    if ~isfield(data,struct_name)
        data.(struct_name).(field_name) = default;
        value = default;
    elseif ~isfield(data.(struct_name),field_name)
        data.(struct_name).(field_name) = default;
        value = default;
    else
        value = data.(struct_name).(field_name);
    end
    
end