%% read ISC Catalog

clear all, close all, clc

file = '/Users/jaywellik/Documents/MATLAB/VDAP_mbin/dataseries/SanSalvador/ElSalvadorEQsLT30km_1970-20Apr2017.txt';
opts = detectImportOptions(file);
opts.Delimiter = ',';
opts.VariableNamesLine = 13;
opts.DataLine = 14;

T = readtable(file,opts);
T(end-6:end, :) = [];

CAT.EventID = T{:,1};
date = datetime(T.Var3);
time = timeofday(datetime(T.ExtraVar1, 'Format', 'HH:mm:ss.SSS'));
time(isnan(time)) = 0;
CAT.DATETIME = date + time;
CAT.LAT = str2double(T.ExtraVar2);
CAT.LON = str2double(T.ExtraVar3);
CAT.DEPTH = str2double(T.ExtraVar4);
CAT.MAG = max(str2double(T{:,11:3:end}), [], 2);

CAT = struct2table(CAT);

%% Filter Catalog

vlat = 13.734; vlon = -89.294;
minmag = 3;
t_win = 60;

CAT(isnat(CAT.DATETIME), :) = [];

% filter by annulus
CAT.dkm = deg2km(...
    distance(vlat, vlon, ...
    CAT.LAT, CAT.LON));
CAT = CAT( CAT.dkm >= 0 & CAT.dkm <= 30, : );
ALLCAT = CAT;

% filter by magnitude
CAT(CAT.MAG < minmag, :) = [];

% extract variables
eqt = datenum(CAT.DATETIME);
eqMo = magnitude2moment(CAT.MAG); eqMo(isnan(eqMo)) = 0;
eqDepth = CAT.DEPTH;
eqLat = CAT.LAT;
eqLon = CAT.LON;

% define background
background_time = datetime2([datenum(2000,1,1) datenum(2017,4,30)]);

%%% Conduct Analysis
DATA = ps2ts(eqt, eqMo, background_time, 1, 30);

% Add beta values to 'BETA'
a = datenum(background_time);
BETA.N = sum(sum( (eqt'>=a(:,1)) .* (eqt'<a(:,2)) )); % total # of eqs in entire study period
BETA.T = sum(a(:,2)-a(:,1)); % Total amount of time in entire study period
BETA.bv = betas(DATA.binCounts, BETA.N, t_win, BETA.T);
BETA.be = empiricalbeta(DATA.tc, BETA.bv, background_time, 0.95);

%% plot

ax(1) = subplot(2,1,1)
p(1) = plot(DATA.tc, DATA.binCounts, 'k'), hold on
p(2) = plot(background_time, ...
    [beta2counts(BETA.be,BETA.N,t_win,BETA.T) beta2counts(BETA.be,BETA.N,t_win,BETA.T)], 'r--')
xlim([datetime(1970,1,1) datetime('today')])
title(['San Salvador | ' num2str(t_win) ' day window | M_c = ' num2str(minmag)])
ylabel('Counts')

legend(p(2), 'Empirical beta counts equivalent','Location','northwest')

ax(2) = subplot(2,1,2)
title('All Earthquakes in ISC catalog within 30km')
plot(ALLCAT.DATETIME, ALLCAT.MAG, 'ok')
title('All Earthquakes in ISC catalog within 30km')
ylabel('Magnitude')

linkaxes(ax, 'x')