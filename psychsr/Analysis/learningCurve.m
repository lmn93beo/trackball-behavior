%% select files
psychsr_go_root();
cd ../behaviorData
[filelist, folder] = uigetfile('*.mat','MultiSelect','On');
if ~iscell(filelist)
    filelist = {filelist};
end
filelist(cellfun(@(x) strcmp('P',x(end-4)),filelist))= [];


nfiles = length(filelist);

%% extract behavioral data
rate90_all = cell(length(filelist),1);
rate0_all = cell(length(filelist),1);
t_all = zeros(size(filelist));
for f = 1:length(filelist)
    
    load([folder filelist{f}])

    % extract last lick, performance, orientation, contrast
    laststim = ceil(find(data.presentation.stim_times>max(data.response.licks),1)/3);
    perf = data.response.n_overall;
    ori = data.stimuli.orientation(3:3:end);
    con = data.stimuli.contrast(3:3:end);
    las = data.stimuli.laser_on(3:3:end);
    laststim=min(laststim,length(perf));
    
    firststim = 1;
    
    % clip vectors to last lick
    perf = perf(firststim:laststim);
    ori = round(ori(firststim:laststim));
    con = con(firststim:laststim);
    las = las(firststim:laststim);
    
    if isfield(data.response,'t_ori')
        t_ori = round(data.response.t_ori);
    else
        t_ori = 90;
    end    
    t_all(f) = t_ori==90;
    lick = ~xor((ori == t_ori),perf);
    
    rate90 = lick*1;
    rate90(ori ~= 90) = NaN;
%     rate90 = bsmooth(rate90,10);        
    rate90_all{f} = rate90;
    
    rate0 = lick*1;
    rate0(ori ~= 0) = NaN;
%     rate0 = bsmooth(rate0,10);    
    rate0_all{f} = rate0;
    
    rate90(rate90>0.99) = 0.99;
    rate90(rate90<0.01) = 0.01;
    rate0(rate0>0.99) = 0.99;
    rate0(rate0<0.01) = 0.01;
%     dprime_all{f} = norminv 
end
%%
alldays = cellfun(@(x) datenum(x(1:8),'yyyymmdd'),filelist);
d = unique(alldays);
clear days
for i = 1:length(d)
    days{i} = find(alldays == d(i));
end
clear hits fas dprime

cont = zeros(size(days));

for i = 1:length(days)
    h = nanmean([rate90_all{days{i}}]);
    hits(i) = h;
    f = nanmean([rate0_all{days{i}}]);
    fas(i) = f;
    h(h>0.99) = 0.99; h(h<0.01) = 0.01;
    f(f>0.99) = 0.99; f(f<0.01) = 0.01;
    dprime(i) = norminv(h,0,1)-norminv(f,0,1);
    
    cont(i) = mean(t_all(days{i}));
end

close all
figure
subplot(2,1,1)
plot(hits,'*-b','LineWidth',2,'color',[1 0.5 0])
hold on;
plot(fas,'*-b','LineWidth',2)
plot(find(cont==0,1)*ones(1,2),[0 1],':k')
legend('T','NT','RC')

subplot(2,1,2)
plot(dprime,'*-k','LineWidth',2)
hold on;
plot(xlim,zeros(1,2),':k')
plot(find(cont==0,1)*ones(1,2),[-4.5 4.5],':k')
ylim([-4.5 4.5])
ylabel('D-prime')
xlabel('Days')