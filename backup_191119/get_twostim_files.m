function twostim_files = get_twostim_files(parent_folder, load_all)
% Get the names of two-stim files in the folder
cd(parent_folder);
k = 0;
h = waitbar(0,'Progress...');
all_files = dir;
n_files = size(all_files,1);
for i = 3:n_files
    waitbar(i/n_files,h);
    curr_f = all_files(i).name;
    if ~isempty(strfind(curr_f,'_trackball_')) & ~isempty(strfind(curr_f,'.mat'))
        load(curr_f);
        try
            if data.params.simultaneous & numel(data.params.opp_contrast) > 1
                if load_all
                    k = k + 1;
                    twostim_files{k} = [parent_folder '\' curr_f];
                elseif load_laser & data.params.laser
                    k = k + 1;
                    twostim_files{k} = [parent_folder '\' curr_f];
                end
            end
        catch
            fprintf('Warning: File skipped');
            continue
        end
    end
end
delete(h);
clear h;
end

