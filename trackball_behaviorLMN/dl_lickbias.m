spout = data.response.spout_pos;
flips = data.presentation.flip_times(1:length(spout));
licks = data.response.licks;

ds = 0.5;

spoutvals = mode(spout):ds:max(spout);
spoutvals = [spoutvals(2:end),mode(spout):-ds:min(spout)];
spoutvals = sort(spoutvals);

i = 1;
lickprob = nan(length(spout),2);
bias = nan(length(spout),1);

all_licks = zeros(length(spoutvals),2);
all_dur = zeros(length(spoutvals),1);
all_bias = cell(length(spoutvals),1);
while i <= length(spout)
    
    [x,ix] = min(abs(spout(i) - spoutvals));    
    n = find(abs(diff(spout(i:end)))>0,1);        
    if isempty(n) 
        n = length(diff(spout(i:end)))+1;
    end
    dt = flips(i+n-1)-flips(i);
    if x<0.001 && dt > 1
        
        nlicks = sum(licks > flips(i) & licks <= flips(i+n-1));
        
                
        all_licks(ix,:) = all_licks(ix,:) + nlicks;
        all_dur(ix) = all_dur(ix) + dt;

        lickprob(i:i+n-1,1) = nlicks(1)/dt;
        lickprob(i:i+n-1,2) = nlicks(2)/dt;
        
        if sum(nlicks) > 0
            bias(i:i+n-1) = nlicks(2)/sum(nlicks);
            all_bias{ix} = [all_bias{ix},nlicks(2)/sum(nlicks)];
        end
    end
    x = find(abs(diff(spout(i+n-1:end)))==0,1);
    if ~isempty(x)
        i = i+n+x-2;
    else
        i = length(spout)+1;
    end
end


%% 
spoutvals = round(spoutvals/ds)*ds;

figure
subplot(1,4,1:3)
h = plotyy(flips,spout,flips,bias);
set(get(h(2),'children'),'marker','*')
% ylim([min(spoutvals) max(spoutvals)])
set(gca,'ytick',spoutvals)

subplot(1,4,4)
plot(all_licks(:,2)./sum(all_licks,2),spoutvals,'-*')
hold on
plot([0.5 0.5],ylim,':k')
set(gca,'ytick',spoutvals)
