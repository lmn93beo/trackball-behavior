% d-prime

hits = 0.7:0.05:1;
hits(end) = 0.99;

falarms = 0:0.1:0.9;
falarms(1) = 0.01;

dprime = zeros(length(falarms),length(hits));
diff_hfa = dprime;

for i = 1:length(hits)
    for j = 1:length(falarms)
        dprime(j,i) = norminv(hits(i),0,1)-norminv(falarms(j),0,1);
        diff_hfa(j,i) = hits(i)-falarms(j);
    end
end

figure
surf(hits,falarms,dprime)
xlabel('Hit%')
ylabel('FA%')
zlabel('D-prime')
shg

figure
plot(diff_hfa(2:10,1:6),dprime(2:10,1:6));
legend('0.7','0.75','0.8','0.85','0.9','0.95','Location','SouthEast')

hold on;
a = polyfit(diff_hfa(2:10,1:6),dprime(2:10,1:6),1);
b = polyfit(dprime(2:10,1:6),diff_hfa(2:10,1:6),1);
diffs = -0.2:0.1:0.9;
plot(diffs,a(1)*diffs+a(2),'k--','LineWidth',3)
xlabel('Hit%-FA%')
ylabel('D-prime')
title(sprintf('D-prime = %1.3f * (Diff%%) + %1.3f',a(1),a(2)))
