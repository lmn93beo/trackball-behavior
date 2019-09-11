%% Find all behavior files with varying contrasts
clear all
parent_folder = 'C:\Users\Sur lab\Dropbox (MIT)\trackball-behavior\Data\96\Dec2018';
saveFileName = 'Mouse096_behavior.mat';
load_all = 1; %Load all files, regarless of laser
load_laser = 0; %load only files with laser

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
% Average by sessions
% for i = 1:numel(all_animals)
%     curr_animals = animals == all_animals(i);
%     curr_files = con_sessions(curr_animals);
%     for ii = 1:size(curr_files,2)
%         load(curr_files{ii});
%         k = k + 1;
%         con_perf{k} = get_con_perf(data); %col order: cons, left stim perf, right stim perf
%         curr_luminance = [0-con_perf{k}(:,1)' con_perf{k}(:,1)'];
%         [curr_luminance sort_idx] = sort(curr_luminance);
%         curr_perf = [1-con_perf{k}(:,3)' con_perf{k}(:,2)'];
%         curr_perf = curr_perf(sort_idx);
% %         plot(curr_luminance,curr_perf,'-o','color',colors(i,:)); hold on
% %         xlabel('Left - right stimulus luminance');
% %         ylabel('% left choices');
%         title(num2str(all_animals(i)));
%         all_cons = cat(2,all_cons, curr_luminance);
%         all_perf = cat(2,all_perf, curr_perf);
%     end
% %     pause;
% %     clf;
% end

%   Average by animals
all_cons = []; all_perf = [];
for i = 1:numel(all_animals)
    curr_animals = animals == all_animals(i);
    curr_files = sessions(curr_animals);
    sess_cons = []; sess_perf = [];
    for ii = 1:size(curr_files,2)
        load(curr_files{ii});
        con_perf{i}{ii} = get_twostim_perf(data,0); %col order: cons, left stim perf, right stim performance
        target_con = unique(data.stimuli.contrast);
        curr_luminance = [con_perf{i}{ii}(:,1)'-target_con target_con-con_perf{i}{ii}(:,1)'];
        [curr_luminance sort_idx] = sort(curr_luminance);
        
        curr_perf = [1-con_perf{i}{ii}(:,3) con_perf{i}{ii}(:,2)];
        curr_perf = curr_perf(sort_idx);
        sess_cons = cat(2,sess_cons, curr_luminance);
        sess_perf = cat(2,sess_perf, curr_perf);
    end
    mu_cons{i} = unique(sess_cons);
    mu_perf = []; stderr_perf = [];
%     sess_cons = single(sess_cons);
  
    for iii = 1:size(mu_cons{i},2);
    
        idx = sess_cons == mu_cons{i}(iii);
        mu_perf{i}(iii) = nanmean(sess_perf(idx));
        stderr_perf{i}(iii) = std(sess_perf(idx))./sqrt(numel(sess_perf(idx)));
    end
    all_cons = cat(2,all_cons, mu_cons{i});
    all_perf = cat(2,all_perf, mu_perf{i});
    plot(mu_cons{i},mu_perf{i},'-o','color',colors(1,:)); hold on
    errorbar(mu_cons{i},mu_perf{i},stderr_perf{i},'color',colors(1,:)); hold on
    xlabel('Left - right stimulus luminance');
    ylabel('% left selected');
    title(num2str(all_animals(i)));
    
    
end

box off
set(gca,'tickdir','out','ticklength',[0.01 0],'xTick',[-0.64:0.32:0.64],'yTick',[0:0.5:1]);
xlim([-1 1]);
ylim([-0.1 1]);
hline(0.5);
vline(0);


%% Average psychometric curve

% mu_cons = unique(all_cons);
% mu_perf = []; stderr_perf = [];
% for i = 1:numel(mu_cons);
%     idx = all_cons == mu_cons(i);
%     mu_perf(i) = mean(all_perf(idx));
%     stderr_perf(i) = std(all_perf(idx))./sqrt(numel(all_perf(idx)));
%     num_animals_per_con(i) = sum(idx);
% end
% 
% figure;
% plot(mu_cons,mu_perf,'-ko'); hold on
% errorbar(mu_cons,mu_perf,stderr_perf,'ko');
% box off
% set(gca,'tickdir','out','ticklength',[0.01 0]);
% xlim([-1.2 1.2]);
% 
% 

%% Plot individual session performance
% Reshape sess_cons and sess_perf
sess_cons_mat = reshape(sess_cons, numel(all_cons), numel(curr_animals));
sess_perf_mat = reshape(sess_perf, numel(all_cons), numel(curr_animals));

figure;
hold on;
for i = 1:numel(curr_animals)
   plot(sess_cons_mat(:,i), sess_perf_mat(:,i));    
end
hline(0.5);
vline(0);


legend();

%% Mean 
