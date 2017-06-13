%% PLOT CATALOG and TRIGGER SIDE by SIDE

%% get unlocated triggered events

% ! load command only works if the LOG is limited to 1 volcano

load(fullfile('~/Documents/MATLAB/VDAP_mbin/dataseries/UnitedStates_explosions/data/',LOG.volcano_name{1},'trigger.mat'))
trigger2 = trigger(isnan(trigger.LAT), :);
triggerLP = trigger2(strcmpi(trigger2.TYPE, 'longperiod'), :);
triggerVT = trigger2(strcmpi(trigger2.TYPE, 'local'), :);

[TLP, NLP, ~] = histcountst(triggerLP.DATETIME);

%% get unlocated VTs and add it to located VTs
% (assume all located events are VTs; this is mostly true)

j = 5;

[tVT, nVT, ~] = histcountst([triggerVT.DATETIME; datetime2(LOG.DATA(j).CAT.DateTime);]);
[tTrig, nTrig] = histcountst(triggerVT.DATETIME);
[tLoc, nLoc] = histcountst(datetime2(LOG.DATA(j).CAT.DateTime));

%% get RSAM data

% ds = datasource('winston', 'localhost', 16022);
% tag = ChannelTag('D.REF.--.EHZ');
% R = quickRSAM(ds, tag, datetime(2009,2,15), datetime(2009,06,01), 'rms', 10);
load(fullfile('~/Documents/MATLAB/VDAP_mbin/dataseries/UnitedStates_explosions/data/', LOG.volcano_name{1}, '/R0.mat'))

%% Plot

R = R0;

f = figure;

plot(LOG.DATA(j).E); hold on

r = get(R, 'data');
t = datetime2(get(R, 'timevector'));
p(1) = plot(t,r,'Color', 'g'); % RSAM

% p(1) = stairs(LOG.DATA(j).tc, LOG.DATA(j).binCounts, 'Color', [0.5 0.5 0.5], 'LineWidth', 2); hold on
yyaxis('right');
p(2) = stairs(tLoc(1:end-1), nLoc, 'Color', [0.5 0.5 0.5], 'LineWidth', 2, 'LineStyle', '-'); hold on
p(3) = stairs(tVT(1:end-1), nVT, 'k', 'LineWidth', 2, 'LineStyle', '-');
p(4) = stairs(TLP(1:end-1), NLP, 'b', 'LineWidth', 2);

ax = f.Children;
ax.Title.String = LOG.volcano_name{j};
ax.YAxis(1).TickValues = ax.YAxis(1).Limits(1):100:ax.YAxis(1).Limits(end);
ax.YAxis(2).Color = 'b';
ax.YAxis(1).Label.String = 'VT counts';
ax.YAxis(2).Label.String = 'Unlocated LP counts';


l = legend(p, 'RSAM', 'Located VTs', 'Located + Unlocated VTs', 'Unlocated LPs', 'Location', 'northwest')