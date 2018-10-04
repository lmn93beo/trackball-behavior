function transferStruct(source_file, source_path, dest_files, dest_path, fields)
if nargin<4    
    disp('Choose source file')
    [source_file source_path] = uigetfile('*.mat');
    disp('Choose destination file(s)')
    [dest_files dest_path] = uigetfile('*.mat','MultiSelect','On');
    if ~iscell(dest_files)
        dest_files = {dest_files};
    end
end

cd(source_path)
load(source_file)
f = fieldnames(data);

if nargin<5 || isempty(fields)
    for i = 1:length(f)
        fprintf('%d: %s\n',i,f{i})
    end

    transfer = [];
    while isempty(transfer) || ~isnumeric(transfer) || min(transfer)<0 || max(transfer)>length(f)
        transfer = input('Choose which fields to transfer: ');
    end
    if transfer == 0 
        return
    end
    
    fields = f(transfer);
end

temp = struct;
for i = 1:length(fields)
    temp.(fields{i}) = data.(fields{i});
end

cd(dest_path)
for i = 1:length(dest_files)
    load(dest_files{i})
    for j = 1:length(fields)
        data.(fields{j}) = temp.(fields{j});        
    end
    save(dest_files{i},'data')
    fprintf('Saved %s\n',dest_files{i})
end
disp('Done')
    
end