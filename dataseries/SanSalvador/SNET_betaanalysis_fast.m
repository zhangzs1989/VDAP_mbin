%% read San Salvador SNET Catalog - fast

clear all, close all, clc

rdSNETCatalog;

%% Filter Catalog

vlat = 13.734; vlon = -89.294;
minmag = 2;
t_win = 60;
catalog_background = datetime2([datenum(1995,1,1) datenum(2016,7,1)])

catalog(isnat(catalog.DATETIME), :) = [];

% filter by annulus
catalog.dkm = deg2km(...
    distance(vlat, vlon, ...
    catalog.LAT, catalog.LON));
catalog = catalog( catalog.dkm >= 0 & catalog.dkm <= 30, : );
ALLcatalog = catalog;

% filter by magnitude
catalog(catalog.MAG < minmag, :) = [];

% extract variables
eqt = datenum(catalog.DATETIME);
eqMo = magnitude2moment(catalog.MAG); eqMo(isnan(eqMo)) = 0;
eqDepth = catalog.DEPTH;
eqLat = catalog.LAT;
eqLon = catalog.LON;

% define background
background_time = catalog_background;

%%% Conduct Analysis
DATA = ps2ts(eqt, eqMo, background_time, 1, 30);

% Add beta values to 'BETA'
a = datenum(background_time);
BETA.N = sum(sum( (eqt'>=a(:,1)) .* (eqt'<a(:,2)) )); % total # of eqs in entire study period
BETA.T = sum(a(:,2)-a(:,1)); % Total amount of time in entire study period
BETA.bv = betas(DATA.binCounts, BETA.N, t_win, BETA.T);
BETA.be = empiricalbeta(DATA.tc, BETA.bv, background_time, 0.95);

%% plot

ax(1) = subplot(2,4,[1:3])
p(1) = plot(DATA.tc, DATA.binCounts, 'k'), hold on
p(2) = plot(background_time, ...
    [beta2counts(BETA.be,BETA.N,t_win,BETA.T) beta2counts(BETA.be,BETA.N,t_win,BETA.T)], 'r--')
xlim([datetime(1970,1,1) datetime('today')])
title(['San Salvador | ' num2str(t_win) ' day window | M_c = ' num2str(minmag)])
ylabel('Counts')

legend(p(2), {'Empirical threshold'}, 'Location','northwest', 'FontSize', 12)

ax(2) = subplot(2,4,[5:7])
p2(1) = plot(ALLcatalog.DATETIME, ALLcatalog.MAG, 'ok')
title('All Earthquakes in SNET catalog within 30km')
ylabel('Magnitude')

yyaxis(ax(1), 'right')
ax(1).YAxis(2).Color = 'k'
ax(1).YAxis(2).TickLabelFormat = '%2.1f'
% ax(1).YAxis(2).TickValues = ax(1).YAxis(1).TickValues
ax(1).YAxis(2).TickValues = [beta2counts(BETA.be,BETA.N,t_win,BETA.T) ax(1).YAxis(1).TickValues(end)]
ax(1).YLim = [0 600]
ax(1).YAxis(2).TickLabels = betas(ax(1).YAxis(2).TickValues, BETA.N, t_win, BETA.T)
ax(1).YAxis(2).Label.String = 'Beta'

linkaxes(ax, 'x')

ax(2).NextPlot = 'add';
swarmdt = catalog.DATETIME(catalog.DATETIME > datetime(2001,1,12) & catalog.DATETIME < datetime(2001,4,25), :)
swarmcummag = magnitude2moment(cumsum(magnitude2moment(catalog.MAG(catalog.DATETIME > datetime(2001,1,12) & catalog.DATETIME < datetime(2001,4,25), :)), 'omitnan'), 'reverse')
p2(2) = plot(ax(2), swarmdt, swarmcummag, 'r', 'LineWidth', 2)

legend([p2(1) p2(2)], {'EQ magnitudes'; 'Cumulative Mag per Swarm'}, 'Location', 'southoutside', 'Orientation', 'horizontal', 'FontSize', 12)

% Map plot
[latann1, lonann1] = reckon(vlat(1), vlon(1), km2deg(2), 0:360);
[latann2, lonann2] = reckon(vlat(1), vlon(1), km2deg(30), 0:360);

ptime = catalog.DATETIME;
plat = catalog.LAT;
plon = catalog.LON;

axm = subplot(2,4,[4 8]);
axmb(1) = timemap(datetime2(ptime), plat, plon, 'ok', 'Tag', 'In-view earthquakes');
axmb(2) = timemapoverlay(axm, vlat, vlon, '^r', 'MarkerFaceColor', 'r', 'Tag', 'Volcano overlay');
axmb(3) = timemapoverlay(axm, latann1, lonann1, 'r', 'LineWidth', 2, 'Tag', 'annulus overlay 1');
axmb(4) = timemapoverlay(axm, latann2, lonann2, 'r', 'LineWidth', 2, 'Tag', 'annulus overlay 2');
axmb(5) = timemapunderlay(axm, [plat], [plon], ...
    'o', 'Color', [0.67 0.67 0.67], 'Tag', 'all eathquakes');
axm.Color = 'none';
for n = 1:numel(axmb)-1, axmb(n).Color = 'none'; end
linkaxes([ax(1) axm], 'x')

        % highly specific, ugly code
        f = gcf;
        fax = f.Children;
        axmb = fax([1 2 3 4 9]);
        for n = 1:numel(axmb), axmb(n).ZLim = [min(latann2) max(latann2)]; axmb(n).YLim = [min(lonann2) max(lonann2)]; end
        axm.ZLim = [min(latann2) max(latann2)]; axm.YLim = [min(lonann2) max(lonann2)];
        
        % highly specific - beautifying
        axmb(end-1).ZTick = [axmb(end-1).ZTick(1) axmb(end-1).ZTick(end)];
        axmb(end-1).YTick = [axmb(end-1).YTick(1) axmb(end-1).YTick(end)];
        axmb(end-1).Box = 'on';
        
        axm.Title.String = 'All earthquakes r = 2 & 30km';
        