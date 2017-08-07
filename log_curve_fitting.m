%% polyfit in matlab

close all

x = [10.7^-2 10.2^-1 10.2^0 10.3^1 10.7^2 10.1^3 10.5^4 10.4^5]
y = [1 3 2.5 4.9 5.1 8.2 4 10]

figure

loglog(x,y,'Marker','o','LineStyle','none','MarkerSize',6),
P = polyfit(log(x),log(y),1);
yfit = exp(polyval(P,log(x)));
x1 = linspace(min(x),max(x));
y1 = exp(polyval(P,log(x1)));
hold on, loglog(x1,y1,'LineStyle','--','LineWidth',2),grid on , box on

figure

semilogx(x,y,'Marker','o','LineStyle','none','MarkerSize',6),
P = polyfit(log(x),y,1);
yfit = exp(polyval(P,log(x)));
x1 = linspace(min(x),max(x));
y1 = exp(polyval(P,log(x1)));
hold on, plot(x1,log(y1),'LineStyle','--','LineWidth',2),grid on , box on

%%%
    % subplot(sx,sy,p)
%     loglog(x,y,'MarkerEdgeColor',next_color,'Marker','o','LineStyle','none','MarkerSize',6),
%     P = polyfit(log(x),log(y),1);
%     yfit = exp(polyval(P,log(x)));
%     x1 = linspace(min(x),max(x));
%     y1 = exp(polyval(P,log(x1)));
%     hold on,loglog(x1,y1,'LineStyle','--','color',next_color,'LineWidth',2),grid on , box on
%  

