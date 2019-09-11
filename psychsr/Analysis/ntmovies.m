% load file
[file dir] = uigetfile('MultiSelect','On');

for j = 1:length(file)

load([dir file{j}])

% extract last lick, performance, orientation, contrast
laststim = ceil(find(data.presentation.stim_times>max(data.response.licks),1)/3);
perf = data.response.n_overall;
if laststim > length(perf)
    laststim = length(perf);
end
ori = data.stimuli.orientation(3:3:end);

m = zeros(1,length(data.stimuli.movie_file));
for i = 1:length(data.stimuli.movie_file)
    if strcmp(data.stimuli.stim_type(i),'image')
        mtemp = data.stimuli.movie_file{i}(end-5);
        if isempty(str2num(mtemp))
            m(i) = str2num(data.stimuli.movie_file{i}(end-4));
        else
            m(i) = str2num(data.stimuli.movie_file{i}(end-5:end-4));
        end
    else
        m(i) = 0;
    end
end
mov = m(3:3:end);

% clip vectors to last lick
perf = perf(1:laststim);
ori = ori(1:laststim);
mov = mov(1:laststim);

% intialize vectors
m = unique(mov);
m = m(m~=0);
hits = zeros(size(m));
fas = hits;
dprime = hits;

% calculate performance
for i = 1:length(m)    
    h = mean(perf(ori == 90));
    f = 1-mean(perf(ori ~= 90 & mov == m(i)));
    f_all{m(i)} = [f_all{m(i)}, perf(ori ~= 90 & mov == m(i))];
    
    hits(i) = h;
    fas(i) = f;
    
    if h>0.99; h = 0.99; end
    if f<0.01; f = 0.01; end
    
    % calculate d-prime
    dprime(i) = norminv(h,0,1)-norminv(f,0,1);
    
end

end

% plot hits/FAs
figure
subplot(4,1,[1 2])
hold on;
plot(c,hits,'*-b')
plot(c,fas,'*-r')
if l_on
    plot(c,hits_l,'*:b')
    plot(c,fas_l,'*:r')
end
axis([-0.2 1.2 0 1])
legend('Hit%','FA%','Location','SouthEast')
title(sprintf('Mouse %2s: %8s',file(end-5:end-4),file(1:8)))

% plot d-prime
subplot(4,1,[3 4])
hold on;
plot(c,dprime,'*-k')
if l_on
    plot(c,dprime_l,'*:k')
end
axis([-0.2 1.2 -1 3])
ylabel('D-prime')
xlabel('Contrast')
legend('Laser OFF%','Laser ON%','Location','NorthOutside')