% This script reads the raw .mat files in the specified folder
% and pools all trials from the different sessions.
% It plots the empirical performance and saves the pooled data
% as a .mat file

%% Find all behavior files with varying contrasts
clear all
mouse = input('Enter mouse number: ');

switch getenv('computername')
    case 'DESKTOP-FN1P6HD'
        root = 'C:\Users\Sur lab\Dropbox (MIT)\trackball-behavior';
    otherwise
        root = 'C:\Users\Le\Dropbox (MIT)\trackball-behavior';
end


switch mouse
    case '001'
        parent_folder = sprintf('%s%s', root, '\Data\001');
    case '003'
        parent_folder = sprintf('%s%s', root, '\Data\003');
    case 91
        parent_folder = sprintf('%s%s', root, '\Data\80_91_ACC\91_RACC');
    case 80
        parent_folder = sprintf('%s%s', root, '\Data\80_91_ACC\80_LACC');
    case '13L'
        parent_folder = sprintf('%s%s', root, '\Data\C13\laser_analys_FebMar2019_left');
    case '13R'
        parent_folder = sprintf('%s%s', root, '\Data\C13\laser_analys_FebMar2019_right');
    case '13Apr'
        parent_folder = sprintf('%s%s', root, '\Data\C13\Apr2019');
    case '13Jun'
        parent_folder = sprintf('%s%s', root, '\Data\C13\Jun2019');
    case 87
        parent_folder = sprintf('%s%s', root, '\Data\87_89_SC\87_RSC');
    case 89
        parent_folder = sprintf('%s%s', root, '\Data\87_89_SC\89_LSC');
    case '13L_first3'
        parent_folder = sprintf('%s%s', root, '\Data\C13\C13_leftACCSTR');
    case '13R_first3'
        parent_folder = sprintf('%s%s', root, '\Data\C13\C13_rightACCSTR');
    case 111
        parent_folder = sprintf('%s%s', root, '\Data\Bilateral ACC Inactivation ALL\111');
    case 113
        parent_folder = sprintf('%s%s', root, '\Data\Bilateral ACC Inactivation ALL\113');
    case 200001
        parent_folder = sprintf('%s%s', root, '\Data\Bilateral ACC Inactivation ALL\200001');
    case 200003
        parent_folder = sprintf('%s%s', root, '\Data\Bilateral ACC Inactivation ALL\200003');
    case 146
        parent_folder = sprintf('%s%s', root, '\Data\146_all');
    
    otherwise
        error('Invalid mouse number');
end


saveFileName = 'Mouse080_behavior.mat';
load_all = 1; %Load all files, regardless of laser
load_laser = 1; %load only files with laser
checkstim = 0;

colors = linspecer(2);
colors(3,:) = [0 0 0];
addpath(pwd);

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

    if output
        fprintf('Adding file %s...\n', twostim_files{i});
        if ischar(data.mouse)
            data.mouse = str2double(data.mouse);
        end
        animals(end+1) = data.mouse;
        k = k + 1;
        sessions{k} = twostim_files{i};
    else
        fprintf('REJECTED: %s...\n', twostim_files{i});
    end
end


%%
all_animals = unique(animals);
throw_away = [];
for i = 1:numel(throw_away)
    all_animals(all_animals == throw_away(i)) = [];
end


k = 0; all_cons = []; all_perf = [];
figure;

%   Average by animals
all_cons = []; all_perf = [];
for i = 1:numel(all_animals)
    curr_animals = animals == all_animals(i);
    curr_files = sessions(curr_animals);
    sess_cons = []; 
    % Looping through the behavior files.
    sess_perfC1 = 0;
    sess_perfC2 = 0;
    
    nrows = ceil(sqrt(size(curr_files, 2)));
    ncols = ceil(size(curr_files, 2) / nrows);
    
    for ii = 1:size(curr_files,2)
        % Load the file
        load(curr_files{ii});
        
        % Determine if the file belongs to condition 1 or 2
        C = strsplit(curr_files{ii}, '\');
        filename = strsplit(C{end}, '_');

        % Get number correct in incorrect 
        con_perf_NL = get_twostim_perf(data, 0);
        con_perf_laser = get_twostim_perf(data, 1);
        
        target_con = data.params.contrast;
        disp(target_con);
        
        if target_con ~= 0.64
            fprintf('Target contrast is not 0.64, skipping...\n');
            continue;
        end
        
        [luminanceNL, perfNL, ntrialsNL, nleftNL] = get_perf_from_arr(con_perf_NL, target_con);
        [luminanceL, perfL, ntrialsL, nleftL] = get_perf_from_arr(con_perf_laser, target_con);
        
        Curr_perf_NL{ii} = perfNL;
        Curr_perf_laser{ii} = perfL;
        NtrialsNL{ii} = ntrialsNL';
        NleftNL{ii} = nleftNL';
        NtrialsL{ii} = ntrialsL';
        NleftL{ii} = nleftL';
         
        
        subplot(nrows, ncols, ii);
        l1 = plot(luminanceL, perfL, 'r');
        hold on;
        l2 = plot(luminanceNL, perfNL, 'b');
        
        xlabel('Luminance diff.');
        ylabel('% left selected');
        
        filename = curr_files{ii};
        splits = strsplit(filename, '\');
        date = splits{end}(1:8);
        
        if isfield(data.params, 'laser_power')
            title(sprintf('Date: %s, power: %s', date, data.params.laser_power));
        else
            title(sprintf('Date: %s', date));
        end
        
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
ntrialsNL_arr = cell2mat(NtrialsNL);
ntrialsL_arr = cell2mat(NtrialsL);
nleftNL_arr = cell2mat(NleftNL);
nleftL_arr = cell2mat(NleftL);

ntrialsNL_total = sum(ntrialsNL_arr, 2);
ntrialsL_total = sum(ntrialsL_arr, 2);
nleftNL_total = sum(nleftNL_arr, 2);
nleftL_total = sum(nleftL_arr, 2);

perfNL_total = nleftNL_total ./ ntrialsNL_total;
perfL_total = nleftL_total ./ ntrialsL_total;

% Plot the aggregate performance
figure;
hold on
l1 = plot(luminanceL, perfL_total, 'o', 'Color', colors(1,:));
l2 = plot(luminanceNL, perfNL_total, 'o', 'Color', colors(2,:));
legend([l1, l2], {'Laser', 'No laser'});


%% Save the parameters
filename = input('Enter the name of the file, 0 to skip saving: ');
if ischar(filename)
    save(filename, 'luminanceL', 'luminanceNL', ...
        'nleftNL_total', 'nleftL_total',...
        'ntrialsNL_total', 'ntrialsL_total',...
        'Curr_perf_NL', 'Curr_perf_NL',...
        'Curr_perf_laser', 'Curr_perf_laser');
end

