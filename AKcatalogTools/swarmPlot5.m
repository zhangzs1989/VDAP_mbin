% test for "swarminess"

function swarmPlot5(Magnitude,DateTime,vname,vx,vy,x,y,Depth,vxo,vyo,outname,maxz,t1,t2)

%% Prep
global timeLineLocs
ievents = find(strcmp(timeLineLocs(:,3),vname));

date_time = datetime(datestr(DateTime)); % change to datetime variable type

[cum_mag, cum_moment] = cumMag(Magnitude);  % Calculate cumulative Magnitude

    % vector of current maximum magnitudes
maxmags = runningMax(Magnitude);
maxmag = max(maxmags);

maxfac = 1.25;
I = Magnitude >= (maxmag-maxfac) ;
totBig = sum(I)-1;

%fraction of day for count binning
dfrac = 1/24;
date1 = floor(DateTime(1)); % grabs the date of the first entry
date2 = floor(DateTime(end)); % grabs the date of the last entry


%%

scrsz = get(groot,'ScreenSize');
figure('Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2])

    % plot 1
% sp1 = subplot(5,1,1);
% plot(date_time, Magnitude, 'k.', date_time, maxmags, 'ro', 'MarkerFace','r'), hold on;
% plot(date_time, cum_mag, 'r');
% zoom('xon')
% legend('all events','new max mags','cum Mag','Location','best')
% ylabel('Magnitude')
% xlim([t1 t2]);


    % plot 2
date_range = date1:dfrac:date2; 
events_per_dfrac = hist((DateTime), date_range); % nbins equals the number of days in the time series; NOTE: must do histogram of dates, not anything else
cepr= cumsum(events_per_dfrac);

% size(date_time)
% size(Magnitude)
% size(maxmags)

sp2 = subplot(5,1,1:2);
[axh, hline1, hline2] = plotyy([date_time, date_time, date_time], [cum_mag', Magnitude', maxmags'],...
    datetime(datestr(date_range)), events_per_dfrac);


% hline1
% size(hline1)
% hline2

hline1(1).Color = 'r';

hline1(2).LineStyle = 'none';
hline1(2).Marker = '.';
hline1(2).Color = 'k';

hline1(3).LineStyle = 'none';
hline1(3).Marker = 'o';
hline1(3).Color = 'r';

hline2.LineWidth = 2;
hline2.Color = 'b';

axh(1).YColor = 'k';
axh(2).YColor = 'k';

ylabel(axh(1),'Magnitude');
ylabel(axh(2),'Events Per Hour');

zoom('xon');
xlim(axh(1),[t1 t2]);
xlim(axh(2),[t1 t2]);

title({['Max Mag: ' num2str(maxmag) ' | Cumulative Mag: ' num2str(max(cum_mag)) ],...
    [int2str(totBig),' events within ',num2str(maxfac), ' mag units of max mag']})

    % plot 3
sp3 = subplot(5,1,3);
[axh, hline1, hline2] = plotyy(datetime(datestr(date_range)), cepr, ...
                                date_time, maxmags);
hline2.Marker = 'o';
axh(1).YColor = 'k';
axh(2).YColor = 'k';
ylabel(axh(1),'Events Per Hour');
ylabel(axh(2),'Magnitude');
zoom('xon');
xlim(axh(1),[t1 t2]);
xlim(axh(2),[t1 t2]);

% linkaxes([sp2 sp3],'x');

%% JP add
sp4 = subplot(5,1,4); hold on;
% horiz distance to summit
hdist = sqrt( (x-vx).^2 + (y-vy).^2 );
hdistv = sqrt( (vx-vxo).^2 + (vy-vyo).^2 );

hdist = hdist/1000;
hdistv=hdistv/1000;
I = ~isnan(maxmags);

% for i=1:length(hdistv)
% plot([t1 t2],[hdistv(i) hdistv(i)],'r--')
% end
plot(date_time,hdist,'k.',date_time(I),hdist(I),'ro')
% datetick('x','mm/dd','keeplimits')
xlim([t1 t2]);
ylabel('Horiz distance to summit')
yax=[0 ceil(max(hdist))];
ylim(yax);
% ytextpos = yax(1)+1:yax(2)/length(ievents)-2:yax(2)-1;
ytextpos = yax(2)-1:-yax(2)/length(ievents)-2:yax(1)+1;

for i=1:length(ievents)
    tA = datevec(timeLineLocs(ievents(i),1));
    plot([datetime(tA) datetime(tA)],yax,'b--')
    text(datenum(tA),ytextpos(i),timeLineLocs(ievents(i),4),'FontSize',12,'Color','b');
end

sp5 = subplot(5,1,5);
plot(date_time,-Depth,'k.',date_time(I),-Depth(I),'ro')
% datetick('x','mm/dd','keeplimits')
xlim([t1 t2]);
ylabel('EQ Depth')
xlabel('Date')
ylim([maxz*-1 -4*-1])

linkaxes([sp2 sp3 sp4 sp5],'x');

print(gcf,'-dpng',[outname,'_Swarminess'])

% figure
% plot(date_time,NbSta,'k.')