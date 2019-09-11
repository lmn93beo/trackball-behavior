function x = D2GaussFitRot(Z,x0,plotFlag)
if nargin<3
    plotFlag = 0;
end
mgrid = 1:size(Z,1);%-MdataSize/2:MdataSize/2-1;
%         mgrid = mgrid + 0.5;
mmin = min(mgrid);
mmax = max(mgrid);
if nargin<2
    x0 = [1,mean(mgrid),mean(mgrid),mean(mgrid),mean(mgrid),0]; %Inital guess parameters
end
% parameters are: [Amplitude, x0, sigmax, y0, sigmay, angel(in rad)]

[X,Y] = meshgrid(mgrid);
xdata = zeros(size(X,1),size(Y,2),2);
xdata(:,:,1) = X;
xdata(:,:,2) = Y;

% define lower and upper bounds [Amp,xo,wx,yo,wy,fi]
lb = [0,mmin,0,mmin,0,-pi/4];
ub = [realmax('double'),mmax,(mmax)^2,mmax,(mmax)^2,pi/4];
[x,resnorm,residual,exitflag] = lsqcurvefit(@D2GaussFunctionRot,x0,xdata,Z,lb,ub);

%% -----Plot profiles----------------
if plotFlag
% close all
hf2 = figure;
set(hf2, 'Position', [20 20 950 900])
alpha(0)
subplot(4,4, [5,6,7,9,10,11,13,14,15])
imagesc(X(1,:),Y(:,1)',Z)
set(gca,'YDir','reverse')
colormap('jet')

string1 = ['       Amplitude','    X-Coordinate', '    X-Width','    Y-Coordinate','    Y-Width','     Angle'];
string3 = ['Fit      ',num2str(x(1), '% 100.3f'),'             ',num2str(x(2), '% 100.3f'),'         ',num2str(x(3), '% 100.3f'),'         ',num2str(x(4), '% 100.3f'),'        ',num2str(x(5), '% 100.3f'),'     ',num2str(x(6), '% 100.3f')];

text(mmin*0.9,+mmax*1.07,string1,'Color','red')
text(mmin*0.9,+mmax*1.1,string3,'Color','red')

%% -----Calculate cross sections-------------
% generate points along horizontal axis
m = -tan(x(6));% Point slope formula
b = (-m*x(2) + x(4));
xvh = mgrid;
yvh = xvh*m + b;
hPoints = interp2(X,Y,Z,xvh,yvh,'nearest');
% generate points along vertical axis
mrot = -m;
brot = (mrot*x(4) - x(2));
yvv = mgrid;
xvv = yvv*mrot - brot;
vPoints = interp2(X,Y,Z,xvv,yvv,'nearest');

hold on % Indicate major and minor axis on plot

% % plot pints
% plot(xvh,yvh,'r.')
% plot(xvv,yvv,'g.')

% plot lins
plot([xvh(1) xvh(size(xvh))],[yvh(1) yvh(size(yvh))],'r')
plot([xvv(1) xvv(size(xvv))],[yvv(1) yvv(size(yvv))],'g')

hold off
axis([mmin-0.5 mmax+0.5 mmin-0.5 mmax+0.5])
%%

% ymin = - noise * x(1);
% ymax = x(1)*(1+noise);
xdatafit = linspace(mmin-0.5,mmax+0.5,300);
hdatafit = x(1)*exp(-(xdatafit-x(2)).^2/(2*x(3)^2));
vdatafit = x(1)*exp(-(xdatafit-x(4)).^2/(2*x(5)^2));
subplot(4,4, [1:3])
xposh = (xvh-x(2))/cos(x(6))+x(2);% correct for the longer diagonal if fi~=0
plot(xposh,hPoints,'r.',xdatafit,hdatafit,'black')
xlim([mmin-0.5 mmax+0.5])
% axis([mmin-0.5 mmax+0.5 ymin*1.1 ymax*1.1])
subplot(4,4,[8,12,16])
xposv = (yvv-x(4))/cos(x(6))+x(4);% correct for the longer diagonal if fi~=0
plot(vPoints,xposv,'g.',vdatafit,xdatafit,'black')
% axis([ymin*1.1 ymax*1.1 mmin-0.5 mmax+0.5])
ylim([mmin-0.5 mmax+0.5])
set(gca,'YDir','reverse')
figure(gcf) % bring current figure to front
end