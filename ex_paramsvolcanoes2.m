%% SETUP ALASKA CATALOG ANALYSIS
% Run this file before anything from the GitRepository

clearvars -except startUpLocs catalog jiggle

startUpLocs.dir = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/';
startUpLocs.inputFiles = [startUpLocs.dir '/inputFiles.mat'];
startUpLocs.params = [startUpLocs.dir '/params.mat'];

%% INPUT FILES

inputFiles.catalog = '/Volumes/EFIS_seis/ANSScatalog/new2/catsearchV4.mat';
inputFiles.jiggle = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/data/jiggle.mat';
inputFiles.EventTimes = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/data/AKsignificantEvents.csv';
inputFiles.AKstas = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/data/AV_stations.txt';
inputFiles.GSHHS = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/data/gshhs_f.b'; %full res;
%inputFiles.GSHHS = '/Users/jwellik/Documents/JAY-VDAP/AKcatalogAnalysis/share/jpesicek/gshhs_h.b'; %hi res;
inputFiles.volcLocs = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/data/AKvolclatlong2.csv';
inputFiles.HB = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/data/MONITOREDVOLCANO.mat';
% inputFiles.HB = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/data/AVO_VOLCANO_update.mat';
inputFiles.Eruptions = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/data/AVOeruptions2.csv'; % JP created this file from Steph's AGU15 eruption chronologies 
inputFiles.StaDataDir = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/NTWKDownDays/StaMatFiles/'; % where badger station data files exist

save(startUpLocs.inputFiles,'inputFiles');

%% PARAMETERS

% list of volcanoes that you would like to analyze
params.volcanoes = { ...
%     'Veniaminof'; ...
    'Augustine'; ...
%     'Redoubt'; ...
%     'Okmok'; ...
%     'Kasatochi'; ...
%     'Kanaga'; ...
%     'Pavlof'; ...
    };

% params.volcanoes = {}; % you can now do all seismically monitored eruptions by making this empty (JP)

% basic parameters
params.max_depth_threshold = 50; % km
params.srad = [2 30];
params.angle = 30;
params.min_mag = 0;
params.betaBackgroundType = [datenum(2002,01,01) datenum(2013,1,1)]; % currently has no functionality but this will eventually feed into getBetaEmpirical; other acceptable values for this variable are 'all', 'individual', or 'past'
params.BetaPlotPreEruptionTime = 365*2;
params.WingPlotPreEruptionTime = 30*4; %use this to define when anomaly must be relative to eruption for false positive test 
params.visible = 'on';
params.jiggle = false;
params.topo = false;
params.coasts = true;
params.wingPlot = true; 
params.outDir = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/run8b/';
params.VEI_thres = 1; % remember there are some eruptions with VEI = 0, for unassigned by SP.  Need to deal with these eventually

% BETA STATISTICS
params.it=10000; % iterations for empirical beta
params.be_thresPer = 0.05; %S. Prejean triggering study param
params.ndays_all = [7 30 60]; % short term windows over which to test beta
params.dfracThres = 0.75; % percentage of day that must contain data to consider station alive on that day
params.minsta = 4; % min # of stations that must be alive for the network to be considered alive for a given day

save(startUpLocs.params,'params');


%% Run these scripts

volcanoInputsAllTime2 % runs analysis for all volcanoes listed in params.volcanoes
AlaskaAggregateAnalysisJP % run analysis for combined stats

