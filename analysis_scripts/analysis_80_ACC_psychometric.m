%% Find all behavior files with varying contrasts
clear all
parent_folder = 'C:\Users\Sur lab\Dropbox (MIT)\trackball-behavior\Data\80_91\91_RACC';
saveFileName = 'Mouse080_behavior.mat';
load_all = 1; %Load all files, regardless of laser
load_laser = 1; %load only files with laser
checkstim = 0;

% Load info
%% Find folders with correct trackball_data
twostim_files = get_twostim_files(parent_folder, load_all);

%% Do checkups on sessions with contrasts
k = 0;
sessions = [];
animals = [];

for i = 1:size(twostim_files,2)
    load(twostim_files{i});
    if checkstim
        [output, output_details(i,:)] = check_twostim(data);
    else
        output = 1;
    end
    fprintf('%d\n', output);

    if output
        animals(end+1) = data.mouse;
        k = k + 1;
        sessions{k} = twostim_files{i};
    end
end


%%
all_animals = unique(animals);
throw_away = [];
for i = 1:numel(throw_away)
    all_animals(all_animals == throw_away(i)) = [];
end
colors = linspecer(2);
colors(3,:) = [0 0 0];

k = 0; all_cons = []; all_perf = [];
figure(2);

%   Average by animals
all_cons = []; all_perf = [];
for i = 1:numel(all_animals)
    curr_animals = animals == all_animals(i);
    curr_files = sessions(curr_animals);
    sess_cons = []; 
    % Looping through the behavior files.
    sess_perfC1 = 0;
    sess_perfC2 = 0;
    
    nrows = round(sqrt(size(curr_files, 2)));
    ncols = ceil(size(curr_files, 2) / nrows);
    
    for ii = 1:size(curr_files,2)
        % Load the file
        load(curr_files{ii});
        
        % Determine if the file belongs to condition 1 or 2
        C = strsplit(curr_files{ii}, '\');
        filename = strsplit(C{end}, '_');

        % Get number correct in incorrect 
        con_perf_NL{i}{ii} = get_twostim_perf(data, 0);
        con_perf_laser{i}{ii} = get_twostim_perf(data, 1);
        
        target_con = 0.64;
        curr_luminance_NL = [con_perf_NL{i}{ii}(:,1)'-target_con target_con-con_perf_NL{i}{ii}(:,1)'];
        [curr_luminance_NL sort_idx] = sort(curr_luminance_NL);
        curr_perf_NL = [1-con_perf_NL{i}{ii}(:,3)' con_perf_NL{i}{ii}(:,2)'];
        Curr_perf_NL{ii} = curr_perf_NL(sort_idx);
        
        curr_luminance_laser = [con_perf_laser{i}{ii}(:,1)'-target_con target_con-con_perf_laser{i}{ii}(:,1)'];
        [curr_luminance_laser sort_idx] = sort(curr_luminance_laser);
        curr_perf_laser = [1-con_perf_laser{i}{ii}(:,3)' con_perf_laser{i}{ii}(:,2)'];
        Curr_perf_laser{ii} = curr_perf_laser(sort_idx);
        
        %figure(ii)
        
        subplot(nrows, ncols, ii);
        l1 = plot(curr_luminance_laser, Curr_perf_laser{ii}, 'r');
        hold on;
        l2 = plot(curr_luminance_NL, Curr_perf_NL{ii}, 'b');
        
        xlabel('Left - right stimulus luminance');
        ylabel('% left selected');
        
        filename = curr_files{ii};
        splits = strsplit(filename, '\');
        date = splits{end}(1:8);
        
        
        title(['Date: ' date]);
        
        if ii == 6
            legend([l1, l2], {'Laser', 'No laser'})
        end
        box off
        set(gca,'tickdir','out','ticklength',[0.01 0],'xTick',[-0.64:0.32:0.64],'yTick',[0:0.5:1],...
            'ColorOrder', colors);
        xlim([-1 1]);
        ylim([-0.1 1]);
        hline(0.5);
        vline(0);

    end
end

%% Perform an average across days

