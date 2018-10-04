for z = 1:3
    engagementTraining;
% close all
level = (nmovies>1)+(nmovies>3)+(tspeed<2);

figure(3);
subplot(3,1,z)
hold on;
shade = [0.9 0.9 0.9];
area([engaged,max(d)+0.5],[5 5],-1,'FaceColor',shade,'EdgeColor',shade)
plot(d(x),mean_dprime(x),'k-')
plot(d(x & level==0),mean_dprime(x & level==0),'k^','MarkerFaceColor','w')
plot(d(x & level==1),mean_dprime(x & level==1),'ks','MarkerFaceColor',[0.5 0.5 0.5])
plot(d(x & level>1),mean_dprime(x & level>1),'ko','MarkerFaceColor','k','MarkerSize',8)
% plot([0 max(d)],[0 0],'--k')
% plot([0 max(d)],[1.2 1.2],'--b')
set(gca,'XTick',[1,5:5:max(d)],'YTick',0:4);
set(gca,'Layer','top')
xlim([1 max(d)])
ylim([-0.5 3.5])
ylabel('D-prime')
xlabel('Day #')

end