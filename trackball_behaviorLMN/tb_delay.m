n = find(data.response.reward>0,1,'last');
cal = mean(data.response.mvmt_degrees_per_pixel);
choice = data.response.choice(1:n);
rt = nan(1,n);
displacement = nan(1,n);
crossthr = nan(1,n);
peakvel = nan(1,n);

for i = 1:n
    a = data.response.samples_start{i};
    b = data.response.samples_stop{i};
    
    t = data.response.time(a:b);
    dx = data.response.dx(a:b);
    
    t_pc = data.response.timePC{i}(find(data.response.samps{i}~=0,1,'last'));
    t_ard = t(end); t = t-t_ard+t_pc;
    
    x = -cumsum(dx)*cal;
    lat = find(abs(x)>3,1);
    peakvel(i) = max(abs(dx(t<data.params.noMvmtTime)));
    if ~isempty(lat)
        rt(i) = t(lat);
%         if rt(i) < data.params.noMvmtTime
            
%         end
    end    
    thr = find(abs(dx)>data.params.earlyAbort,1);    
    if ~isempty(thr)
        crossthr(i) = t(thr);
    end
%     
%     clf
%     plot(t,x,'b')
%     hold on
%     plot(t(thr),x(thr),'*b')    
%     plot(data.response.timePC{i},data.response.ballX{i}*cal,'r')
%     plot(data.params.noMvmtTime*[1 1],ylim,':k')
%     shg
%     pause
end
%%

fastmvmt = (rt < data.params.noMvmtTime) + 0;

figure
hold on
plot(smooth(fastmvmt,15))
plot(smooth((choice<5)+0,15),'r')
legend(sprintf('%% mvmt in first %1.1f',data.params.noMvmtTime),'% non-miss','location','best')

% figure
% [n,centers] = hist(peakvel,30);
% bar(centers,n,'k')
% hold on
% n2 = hist(peakvel(fastmvmt>0),centers);
% bar(centers,n2,'b')
% plot([10 10],ylim,':r')
% xlabel('Peak velocity (A.U.)')
% title('Early abort velocity threshold')
