%% Repose v Cum Mag for individual Explosions

load('/Users/jjw2/Documents/MATLAB/VDAP_mbin/dataseries/UnitedStates_explosions/LOG.mat')
OLOG = LOG;

% pre-EFIS eruption dates -- start dates
pEFISt(8) = datetime(1953, 9, 9); % Spurr
pEFISt(6) = datetime(1986, 3,27); % Augustine
pEFISt(7) = datetime(1967,12, 6); % Redoubt
pEFISt(4) = datetime(1990, 3, 5); % Pavlof
pEFISt(5) = datetime(1995,11,15); % Veniaminof
pEFISt(9) = datetime(1857, 4, 15); % St. Helens -- "1857 Apr"
pEFISt(2) = datetime(1760, 6,15); % Kasatochi -- "1760"
pEFISt(1) = datetime(1995, 6, 19); % Kanaga
pEFISt(3) = datetime(1999, 2,  9); % Shishaldin

%%

TESTLOG = LOG(LOG.annulus(:,1)==0 & LOG.annulus(:,2)==30 & LOG.t_window(:,1)==1 & LOG.t_window(:,2)==30 & LOG.use_triggers==0, :);

c = colormap('lines');
s = 'oo**vss^^';
ms = 10; % MarkerSize
maxdays = 14;

% First 4 options search the entire repose period; 5 and beyond only search
% up to n days before the next eruption
v_desc = {'Preceding Max Magnitude'; 'Preceding Cum. Magnitude'; 'Preceding Counts'; 'EQ Rate'; ...
    sprintf('Preceding %i days Max Mag', maxdays); sprintf('Preceding %i days Cum Mag', maxdays); sprintf('Preceding %i days Counts', maxdays)};
v = 6;

f = figure;

for l = 1:height(TESTLOG)
    
    clearvars -except TESTLOG LOG c s l v v_desc pEFISt OLOG spax f ms maxdays
    
    ET = obj2table(TESTLOG.DATA(l).E);
    ess = mergeintervals([ET.start ET.stop]);
    ess = ess(ess(:,2) < TESTLOG.catalog_background_time(l,2), :);
    repose = [NaN; ess(2:end,1) - ess(1:end-1,2)];
    repose(1) = ess(1,1)-pEFISt(l);
    repose.Format = 'dd:hh:mm:ss';
    
    % get the windows before each eruption
    tfind = interinterval(ess, TESTLOG.catalog_background_time(l,1), TESTLOG.catalog_background_time(l,2));
    tfind = tfind(1:end-1, :); % we don't need the last one because it is a time window after the last eruption
    
    % if the repose period is greater than n days, only use the n days
    % before the eruption
    if v >= 5
        d = tfind(:,2) - tfind(:,1);
        tfind(d>days(maxdays),1) = tfind(d>days(maxdays),2) - days(maxdays);
    end
    
    % get the EQs for each pre-explosion window
    for n = 1:numel(tfind(:,1))
        
        i = TESTLOG.DATA(l).CAT.DateTime >= datenum(tfind(n,1)) & TESTLOG.DATA(l).CAT.DateTime < datenum(tfind(n,2));
        % collecting data
        switch v
            case {1 5}
                y(n) = magnitude2moment(max([0 magnitude2moment(TESTLOG.DATA(l).CAT.Magnitude(i))]), 'reverse');
            case {2 6}
                y(n) = magnitude2moment(sum(magnitude2moment(TESTLOG.DATA(l).CAT.Magnitude(i))), 'reverse');
            case {3 4 7 8}
                y(n) = numel(TESTLOG.DATA(l).CAT.DateTime(i));
            otherwise
        end
    end
        
    %%% plotting
    
    % Master Plot
    figure(f)
    switch v
        case {1 2 5 6}
            semilogx(days(repose), y, s(l), 'Color', c(l,:), ...
                'MarkerSize', ms ), hold on
        case {3 7}
            semilogx(days(repose), y, s(l), 'Color', c(l,:), ...
                'MarkerSize', ms), hold on
%             ax = gca; ax.YLim(1) = 1
        case {4 8}
            loglog(days(repose), y'./days(repose), s(l), 'Color', c(l,:), ...
                'MarkerSize', ms), hold on
        otherwise
    end
    
    % Individual Time Series Plot
    
%     figure
%     cat = TESTLOG.DATA(l).CAT; e = TESTLOG.DATA(l).E;
%     r = ps2ts(cat.DateTime, magnitude2moment(cat.Magnitude), ...
%         [datetime(1970,1,1) datetime('now')], 1, maxdays);
%     plot(e), hold on
%     plot(r.tc, r.binCounts, 'k', 'LineWidth', 2)
%     yyaxis right
%     plot(r.tc, magnitude2moment(r.binData, 'reverse'), 'b', 'LineWidth', 2)
%     title(TESTLOG.volcano_name{l})
    
    
    
end

figure(f)
xlabel('Repose (days)')
ylabel(v_desc{v})
title('Observations during Intra-eruptive episodes')
% xlim([duration(0,0,0) duration(30*24,0,0)])
% xlim([0 30])
% ylim([0 7])
% xlim([10^0 10^6]), ylim([0 7])
axis('square')
L = legend(TESTLOG.volcano_name, 'location', 'eastoutside');
f = gcf;
f.Children(1).FontSize = 15; f.Children(2).FontSize = 15;

%% Add in Information from literature searches -- Iceland

hold on
% LIT = readtable('/Users/jjw2/Dropbox/JAY-DATA/PreExplosionSeismicity_LiteratureSearches.xlsx');
% lit_repose = LIT.EruptionDate - LIT.Repose_Start;
% plot(days(lit_repose), LIT.CumMag, '*k')
% L.String(end) = {'Iceland'};

%% Add in random examples

% %%% Rabaul -- from Jeremy
% plot(18533, 5.24, 'sk')
% text(18533, 5.24, 'Rabaul')
% 
% %%% Raung --
% % 2012 October is roughly when the 2012 activity started
% % 2014-11-11 is when gliding tremor started again
% x = days(datetime(2014,11,11) - datetime(2012,10,15));
% y = magnitude2moment(sum(magnitude2moment([2 2])), 'reverse');
% plot(x, y, 'sk')
% text(x, y, 'Raung 2014-11')
% 
% % 2015-07-09 First ash eruption
% x = days(datetime(2015,07,09) - datetime(2014,11,11));
% y = magnitude2moment(sum(magnitude2moment([2.5 2.5 2.5 2.5])), 'reverse');
% plot(x, y, 'sk')
% text(x, y, 'Raung 2015-07')
% 
% L.String(end-3:end-1) = [];
% L.String(end) = {'Other'};


%% Add in Hawaii based on Chronologies and global8 catalog

% volcanoes
volc(1).name = 'Kilauea';
volc(1).lat = 19.421;
volc(1).lon = -155.287;

volc(2).name = 'Mauna Loa';
volc(2).lat = 19.475;
volc(2).lon = -155.608;

% load chronologies -- Passarelli & Brodsky
% load('~/Dropbox/JAY-DATA/HawaiiChron_PassarelliBrodsky.mat'); % loads table variable 'chron'

% load chronologies -- Passarelli & Brodsky and Orr et al.
chron = readtable('~/Dropbox/JAY-DATA/HawaiiChron_varsources.xlsx');

for n = 1:numel(volc)
    
    % load catalogs
    file = dir(fullfile('~/Dropbox/global8/UnitedStates', strrep(volc(n).name, ' ', ''), 'ANSS_*.mat'));
    if ~isempty(file)
        catalog = global8cat(fullfile(file.folder, file.name));
    else
        break
    end
    
    % radial filter
    radial_d = distance(volc(n).lat, volc(n).lon, catalog.Latitude, catalog.Longitude);
    radial_d = deg2km(radial_d);
    catalog(radial_d > 30, :) = [];
    
    % extract volcano-specific chronology
    chron2 = chron(strcmpi(chron.Volcano, volc(n).name), :);
    
    % pair catalog with chronology
    % * use at least 14 days prior to eruption
%     chron2.runup_start(chron2.runup_days < 14, :) = chron2.eruption_start(chron2.runup_days < 14) - 14;
    % * use up to 14 days prior to the eruption
    chron2.runup_start = chron2.repose_start;
    chron2.runup_days = chron2.eruption_start - chron2.runup_start;
    chron2.runup_start(chron2.repose_days > maxdays) = chron2.eruption_start(chron2.runup_days > maxdays) - maxdays;
    chron2.runup_days = days(chron2.eruption_start - chron2.runup_start);
    for i = 1:height(chron2)
        chron2.MaxMag(i) = NaN; % initialize
        eqmags = catalog{catalog.DateTime >= chron2.runup_start(i) & catalog.DateTime < chron2.eruption_start(i), 'Magnitude'};
        if isempty(eqmags)
            chron2.MaxMag(i) = NaN;
        else
            chron2.MaxMag(i) = max(eqmags);
        end
        chron2.CumMag(i) = magnitude2moment(sum(magnitude2moment(eqmags), 'omitnan'), 'reverse');
    end
    
    plot(chron2.repose_days, chron2.CumMag, 'or', 'MarkerSize', ms)
    text(chron2.repose_days, chron2.CumMag, volc(n).name);
    
end

L.String(end-1) = {'Kilauea'};
L.String(end) = {'Mauna Loa'};

%% Add in Sinabung data ?? not for presentation purposes

% file = '/Users/jjw2/Dropbox/JAY-DATA/SinabungData/EKUM_VA_VB_2011-2013.csv';
% SinabungCatalog = readtable(file, 'HeaderLines', 6, 'ReadVariableNames', false);
% SinabungCatalog.Properties.VariableNames{3} = 'DateTime';
% SinabungCatalog.Properties.VariableNames{8} = 'Magnitude';
% SinabungCatalog.Properties.VariableNames{11} = 'Type';
% SinabungCatalog.DateTime = datetime(SinabungCatalog.DateTime);
% SinabungCatalog.Magnitude = str2double(SinabungCatalog.Magnitude);
% SinabungCatalog(1:10, :)
% 
% %%% Sinabung eruptions from "Sinabung-timeline" Excel spreadsheet (info
% %%% only down to the hour) -- caveat emptor!!! --
% estart = [datetime(2010,8,15)-years(400), ...
%     datetime(2010,8,15), ... % "erupted in August after had been inactive for 400 years"
%     datetime(2013,9,15,2,51,00), ... % time zone WIB
%     datetime(2013,9,17), ...
%     datetime(2013,9,18), ...
%     datetime(2013,10,15), ...
%     datetime(2013,10,23), ...
%     datetime(2013,10,24), ...
%     datetime(2013,10,25), ...
%     datetime(2013,10,26), ...
%     datetime(2013,10,29), ...
%     datetime(2013,10,30), ...
%     datetime(2013,10,31), ...
%     datetime(2013,11,1), ...
%     datetime(2013,11,3), ...
%     datetime(2013,11,4), ...
%     datetime(2013,11,5), ...
%     datetime(2013,11,17), ...
%     datetime(2013,11,23), ...
%     datetime(2013,12,6), ...
%     datetime(2013,12,19), ... % dome appears
%     datetime(2014,1,8), ...
%     datetime(2014,1,15)];
% 
% ess = [estart' estart']; % turn vector of eruption dates into start/stop pairs
% tfind = interinterval(ess, ess(1), ess(end)); % find interevent times
% tfind(tfind(:,2)-tfind(:,1) > 14,1) = tfind(tfind(:,2)-tfind(:,1) > 14, 2) - 14; % truncate intervals to max of 14 days 
% 
% [~, ~, idx_mat] = withininterval(SinabungCatalog.DateTime, tfind, 3);
% idx_mat(idx_mat==0) = NaN;
% mag_mat = SinabungCatalog.Magnitude'.*idx_mat;
% mom_mat = 10.^(1.5.*mag_mat+16.1);
% max_mag = max(mag_mat, [], 2);
% cum_mom = sum(mom_mat, 2, 'omitnan');
% cum_mag = (log10(cum_mom)-16.1)/1.5;
% cum_mag(cum_mag==-Inf) = NaN;
% 
% repose = days(diff(estart));
% semilogx(repose,cum_mag, '^k');
% L.String(end) = {'Sinabung'};


%% Add Regression Line

% f = gcf;
% ax = f.Children(2);
% XData = [];
% YData = [];
% 
% for l = 1:numel(ax.Children)
%     
%    if isa(ax.Children(l), 'matlab.graphics.chart.primitive.Line')
%     
%        XData = [XData ax.Children(l).XData];
%        YData = [YData ax.Children(l).YData];
%        
%    end
%     
% end
% 
% XData(isnan(YData)) = [];
% YData(isnan(YData)) = [];
% 
% P = polyfit(log(XData), YData,1);
% yfit = exp(polyval(P,log(XData)));
% x1 = linspace(min(XData),max(XData));
% y1 = log(exp(polyval(P,log(x1))));
% hold on, plot(x1, y1,'LineStyle','--','color',[1 0 0],'LineWidth',2),grid on , box on
% 
% yresid = YData - log(yfit);
% SSresid = sum(yresid.^2);
% SStotal = (length(YData)-1) * var(YData);
% rsq(i) = 1 - SSresid/SStotal;
% text(max(x1),max(y1),['R^2 = ',num2str(rsq(i),'%3.2f')],'VerticalAlignment','bottom','HorizontalAlignment','right','FontSize',10,'FontWeight','Normal')
% L.String(end) = [];

%% Add Regression Line (v2)

f = gcf;
ax = f.Children(2);
XData = [];
YData = [];

for l = 1:numel(ax.Children)
    
   if isa(ax.Children(l), 'matlab.graphics.chart.primitive.Line')
    
       XData = [XData ax.Children(l).XData];
       YData = [YData ax.Children(l).YData];
       
   end
    
end

XData = XData'; YData = YData';
XData(isnan(YData)) = [];
YData(isnan(YData)) = [];
YData(XData==0) = [];
XData(XData==0) = [];

% [XData, sI] = sort(XData);
% YData = YData(sI);

logXData = log10(XData);
A = [ones(size(YData)), logXData];
c = A\YData;
YFit = A*c;
plot(XData, YFit, 'r-', 'LineWidth', 2)

yresid = YData - log(YFit);
SSresid = sum(yresid.^2);
SStotal = (length(YData)-1) * var(YData);
rsq = 1 - SSresid/SStotal;
text(max(XData),max(YData),sprintf('R^2 = %3.2f', rsq),'VerticalAlignment','bottom','HorizontalAlignment','right','FontSize',10,'FontWeight','Normal')

L.String(end) = [];

