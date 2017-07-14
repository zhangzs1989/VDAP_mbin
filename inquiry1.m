%% Repose v Cum Mag for individual Explosions

load('/Users/jjw2/Documents/MATLAB/VDAP_mbin/dataseries/UnitedStates_explosions/LOG.mat')
OLOG = LOG;

% pre-EFIS eruption dates -- start dates
pEFISt(7) = datetime(1953, 9, 9); % Spurr
pEFISt(5) = datetime(1986, 3,27); % Augustine
pEFISt(6) = datetime(1967,12, 6); % Redoubt
pEFISt(3) = datetime(1990, 3, 5); % Pavlof
pEFISt(4) = datetime(1995,11,15); % Veniaminof
pEFISt(8) = datetime(1857, 4, 15); % St. Helens -- "1857 Apr"
pEFISt(2) = datetime(1760, 6,15); % Kasatochi -- "1760"
pEFISt(1) = datetime(1995, 6, 19); % Kanaga

%%

TESTLOG = LOG(LOG.annulus(:,1)==0 & LOG.annulus(:,2)==30 & LOG.t_window(:,1)==1 & LOG.t_window(:,2)==30 & LOG.use_triggers==0, :);

c = colormap('lines');
s = 'oo**ss^^';

% First 4 options search the entire repose period; 5 and beyond only search
% up to n days before the next eruption
v_desc = {'Preceding Max Magnitude'; 'Preceding Cum. Magnitude'; 'Preceding Counts'; 'EQ Rate'; ...
    'Preceding n days Max Magnitude'; 'Preceding n days Cum Magnitude'; 'Prec. n days Counts'};
v = 6;

figure;

for l = 1:height(TESTLOG)
    
    clearvars -except TESTLOG LOG c s l v v_desc pEFISt OLOG
    
    ET = obj2table(TESTLOG.DATA(l).E);
    ess = mergeintervals([ET.start ET.stop]);
    ess = ess(ess(:,2) < TESTLOG.catalog_background_time(l,2), :);
    repose = [NaN; ess(2:end,1) - ess(1:end-1,2)];
    repose(1) = ess(1,1)-pEFISt(l);
    repose.Format = 'dd:hh:mm:ss';
    
    % get largest earthquake before each event
    tfind = interinterval(ess, TESTLOG.catalog_background_time(l,1), TESTLOG.catalog_background_time(l,2));
    tfind = tfind(1:end-1, :); % we don't need the last one because it is a time window after the last eruption
    
    % if the repose period is greater than n days, only use the n days
    % before the eruption
    if v >= 5
        maxdays = 14;
        d = tfind(:,2) - tfind(:,1);
        tfind(d>days(maxdays),1) = tfind(d>days(maxdays),2) - days(maxdays);
    end
    
    
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
        
    % plotting
    switch v
        case {1 2 5 6}
            semilogx(days(repose), y, s(l), 'Color', c(l,:) ), hold on
        case {3 7}
            semilogx(days(repose), y, s(l), 'Color', c(l,:) ), hold on
%             ax = gca; ax.YLim(1) = 1
        case {4 8}
            loglog(days(repose), y'./days(repose), s(l), 'Color', c(l,:) ), hold on
        otherwise
    end
    
end

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

%% Add in Information from literature searches

hold on
LIT = readtable('/Users/jjw2/Dropbox/JAY-DATA/PreExplosionSeismicity_LiteratureSearches.xlsx');
lit_repose = LIT.EruptionDate - LIT.Repose_Start;
plot(days(lit_repose), LIT.CumMag, '*k')
L.String(end) = {'Iceland'};

%% Add in random examples from Jeremy

%%% Rabaul
plot(18533, 5.24, 'sk')
L.String(end) = {'Rabaul'};


%% Add in Hawaii based on Chronologies and global8 catalog

% volcanoes
v(1).name = 'Kilauea';
v(1).lat = 19.421;
v(1).lon = 155.287;

v(2).name = 'Mauna Loa';
v(2).lat = 19.475;
v(2).lon = 155.608;

% load chronologies
load('~/Dropbox/JAY-DATA/HawaiiChron_PassarelliBrodsky.mat'); % loads table variable 'chron'

for n = 1:numel(v)
    
    % load catalogs
    catalog = global8cat(fullfile('~/Dropbox/global8/UnitedStates', v(n).name, 'ANSS_332010.mat'));
    
    % radial filter
    radial_d = distance(v(n).lat, v(n).lon, catalog.Latitude, catalog.Longitude);
    radial_d = deg2km(radial_d);
    catalog(radial_d > 30, :) = [];
    
    % extract volcano-specific chronology
    chron2 = chron(strcmpi(chron.Volcano, v(n).name), :);
    
    % pair catalog with chronology
    % * use at least 14 days prior to eruption
    if chron2.runup_days < 14, chron2.runup_start = chron2.eruption_start - 14; end
    for i = 1:height(chron2)
        chron2.EQMags = catalog(catalog.DateTime >= chron2.runup_start & catalog.DateTime < chron2.eruption_start, 'Magnitude');        
    end
    
end


