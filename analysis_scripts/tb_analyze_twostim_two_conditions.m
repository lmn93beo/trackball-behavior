%% Find all behavior files with varying contrasts
clear all
parent_folder = 'C:\Users\Sur lab\Dropbox (MIT)\trackball-behavior\Data\96\102318_to_102518_analysis_reward0-4';
saveFileName = 'Mouse096_behavior.mat';
load_all = 1; %Load all files, regarless of laser
load_laser = 0; %load only files with laser

condition1 = {'20181023', '20181024', '20181025', '20181026'};
condition2 = {'20181027', '20181028', '20181029', '20181030'};

% Load info
%% Find folders with correct trackball_data

cd(parent_folder);


k = 0;
h = waitbar(0,'Progress...');
all_files = dir;
n_files = size(all_files,1);
for i = 3:n_files
    waitbar(i/n_files,h);
    curr_f = all_files(i).name;
    if contains(curr_f,"_trackball_") & contains(curr_f,".mat");
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
            continue
        end
    end
end


delete(h);
clear h;
%% Do checkups on sessions with contrasts

k = 0;
sessions = [];
animals = [];
for i = 1:size(twostim_files,2)
    load(twostim_files{i});
    [output, output_details(i,:)] = check_twostim(data);
    
    % By-passing the check-twostim
    output = 1;
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
    
    for ii = 1:size(curr_files,2)
        % Load the file
        load(curr_files{ii});
        
        % Determine if the file belongs to condition 1 or 2
        C = strsplit(curr_files{ii}, '\');
        filename = strsplit(C{end}, '_');
        
       
        
        % Get number correct in incorrect        
        con_perf{i}{ii} = get_twostim_corrNumbers(data,0); %col order: cons, left stim perf, right stim performance
        target_con = unique(data.stimuli.contrast);
        curr_luminance = [con_perf{i}{ii}(:,1)'-target_con target_con-con_perf{i}{ii}(:,1)'];
        [curr_luminance sort_idx] = sort(curr_luminance);
        
        sess_cons = cat(2,sess_cons, curr_luminance);
        
        % Add to the appropriate aggregate
        if ismember(filename{1}, condition1)
            sess_perfC1 = sess_perfC1 + con_perf{i}{ii}(:,2:end);
        elseif ismember(filename{1}, condition2)
            sess_perfC2 = sess_perfC2 + con_perf{i}{ii}(:,2:end);
        end
        
    end
    mu_cons{i} = unique(sess_cons);
    mu_perf = []; stderr_perf = [];
%     sess_cons = single(sess_cons);

    C1_l_perf = sess_perfC1(:,1) ./ (sess_perfC1(:,1) + sess_perfC1(:,2));
    C1_r_perf = sess_perfC1(:,3) ./ (sess_perfC1(:,3) + sess_perfC1(:,4));
    C2_l_perf = sess_perfC2(:,1) ./ (sess_perfC2(:,1) + sess_perfC2(:,2));
    C2_r_perf = sess_perfC2(:,3) ./ (sess_perfC2(:,3) + sess_perfC2(:,4));
    
    C1_perf = [1 - C1_r_perf' fliplr(C1_l_perf')];
    C2_perf = [1 - C2_r_perf' fliplr(C2_l_perf')];
    
    % Plot!
    l1 = plot(mu_cons{i},C1_perf,'-o','color',colors(1,:)); hold on
    l2 = plot(mu_cons{i},C2_perf,'-o','color',colors(2,:)); hold on
    %errorbar(mu_cons{i},mu_perf{i},stderr_perf{i},'color',colors(1,:)); hold on
    xlabel('Left - right stimulus luminance');
    ylabel('% left selected');
    title(num2str(all_animals(i)));
    
    
end

legend([l1, l2], {'Reward = 4', 'Reward = 8'})
box off
set(gca,'tickdir','out','ticklength',[0.01 0],'xTick',[-0.64:0.32:0.64],'yTick',[0:0.5:1]);
xlim([-1 1]);
ylim([-0.1 1]);
hline(0.5);
vline(0);