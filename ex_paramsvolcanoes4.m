%% SETUP ALASKA CATALOG ANALYSIS
% Run this file before anything from the GitRepository

%% StartUp

clearvars -except startUpLocs catalog jiggle

startUpLocs.dir = '/Users/jaywellik/Dropbox/JAY-VDAP/AKcatalogAnalysis';
% startUpLocs.userdir = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/'; Jeremy's path to the research folder
startUpLocs.userdir = '/Volumes/Research-1/Alaska/AKDVTs/'; % Jay's path to the research folder on the shared drive
% startUpLocs.userdir = '...'; % Jay's path to the research folder on his local drive
startUpLocs.inputFiles = [startUpLocs.dir '/inputFiles.mat'];
startUpLocs.params = [startUpLocs.dir '/params.mat'];

%% INPUT FILES

inputFiles.catalog = fullfile(startUpLocs.userdir,'/data/catsearchV4.mat');
inputFiles.jiggle = fullfile(startUpLocs.userdir,'/data/jiggle.mat');
inputFiles.EventTimes = fullfile(startUpLocs.userdir,'/data/AKsignificantEvents.csv');
inputFiles.AKstas = fullfile(startUpLocs.userdir,'/data/AV_stations.txt');
inputFiles.GSHHS = fullfile(startUpLocs.userdir,'/data/gshhs_f.b'); %full res;
%inputFiles.GSHHS = fullfile(startUpLocs.userdir,'jpesicek/gshhs_h.b'); %hi res;
inputFiles.volcLocs = fullfile(startUpLocs.userdir,'/data/AKvolclatlong2.csv');
inputFiles.HB = fullfile(startUpLocs.userdir,'/data/MONITOREDVOLCANO.mat');
inputFiles.Eruptions = fullfile(startUpLocs.userdir,'/data/AVOeruptions3.csv'); % JP created this file from Steph's AGU15 eruption chronologies 
inputFiles.StaDataDir = fullfile(startUpLocs.userdir,'NTWKDownDays/StaMatFiles1/'); % where badger station data files exist

save(startUpLocs.inputFiles,'inputFiles');

%% Volcano & Eruption Parameters

% list of volcanoes that you would like to analyze
params.volcanoes = {
%         'Spurr';
%         'Veniaminof'; ...
%         'Augustine'; ...
%         'Redoubt'; ...
%         'Okmok'; ...
%         'Kasatochi'; ...
%         'Kanaga'; ...
%         'Pavlof'; ...
%         'Shishaldin'
    };

params.volcanoes = {'Shishaldin'};
% params.volcanoes = {};  % you can now do all seismically monitored eruptions by making this empty (JP)
params.minVEI = 2; % remember there are some eruptions with VEI = 0, for unassigned by SP.  Need to deal with these eventually

%% Catalog & Study Parameters

params.max_depth_threshold = 35; % km
params.srad = [2 30];
params.angle = 30;
params.min_mag = 0;
params.betaBackgroundType = [datenum(2002,01,01) datenum(2013,1,1)]; % currently has no functionality but this will eventually feed into getBetaEmpirical; other acceptable values for this variable are 'all', 'individual', or 'past'
params.BetaPlotPreEruptionTime = 365*2;
params.AnomSearchWindow = 365; %for eruption plots and post analysis: use this to define when anomaly must be relative to eruption for false positive test


%% Plotting and Display Parameters

params.visible = 'off';
params.binMagVbinMom = 'mag'; % for swarmPlot7, { 'mag' | 'mom' } for showing cumulative magnitude or moment for each beta bin
params.jiggle = false;
params.topo = false;
params.coasts = false;
params.wingPlot = false;
params.outDir = '/Users/jaywellik/Dropbox/JAY-VDAP/AKcatalogAnalysis2';

%% BETA STATISTIC Parameters

params.retro = 1; % 0 for forward moving bins, 1 for backwards moving bins
params.spacing = NaN; % number of days between beta measurements, NaN results in bins that have no overlap
% NOTE, "the original" way of plotting and conducting the beta analysis is retro = 1 and spacing = NaN;
params.it=10000; % iterations for empirical beta
params.be_thresPer = 0.05; %S. Prejean triggering study param
params.ndays_all = [30 60 90] ; % short term windows over which to test beta
params.dfracThres = 0.75; % percentage of day that must contain data to consider station alive on that day
params.minsta = 4; % min # of stations that must be alive for the network to be considered alive for a given day
params.repose = 10; % repose period in years after previous eruption to start considering anomalies

%% LOAD INPUTFILES AND PARAMS VARIABLES FROM .MAT FILES

save(startUpLocs.params,'params');

load(startUpLocs.inputFiles); % path to inputFiles.mat
load(startUpLocs.params); % path to params.mat

%% LOAD catalogs
if ~exist('catalog','var')
    disp('loading catalog...')
    load(inputFiles.catalog);
    % define preliminary filtering here, and do only once
    [ catalog ] = filterDepth( catalog, params.max_depth_threshold ); % (d)
    [ catalog ] = filterMag( catalog, params.min_mag ); % (e)
    [ catalog ] = filterTime( catalog, datenum('1990/01/01'), datenum('2016/05/01')); % start here to cut out redoubt for now
    disp('...catalog loaded')
end

if ~exist('jiggle','var') && params.jiggle
    disp ('loading jiggle...')
    load(inputFiles.jiggle);
    disp('...jiggle loaded')
else
    jiggle = [];
end

%%
volcanoInputsAllTime2 % runs analysis for all volcanoes listed in params.volcanoes

%% Post Beta Analysis

% JW
% AlaskaAggregateAnalysis
FalsePositives2

% JP
% FalsePositives % run analysis for combined stats
% FPqc % QC FP plots
