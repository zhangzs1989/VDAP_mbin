% import eruption and event data and plot it
% Now imports from list of all GVP Holocene volcanoes, not just ones with
% eruptions
% J. PESICEK Winter 2016/17

clear
% clearvars -except catalog
warning('on','all')

%% READ inputs
% [input,params] = getInputFiles('/Users/jpesicek/Dropbox/Research/efis/ISC/input2.txt');
%% input files
input.gvp_volcanoes='/Users/jpesicek/Dropbox/Research/EFIS/GVP/GVP_volcanoes_v2.mat'; % imported via importEruptionCatalog, originally from S. Ogburn
input.GSHHS = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/data/gshhs_f.b'; %full res;
input.catalogsDir = '/Users/jpesicek/Dropbox/Research/EFIS/global7/'; % importISCcatalog.m
% input.polygonFilter = '/Users/jpesicek/dropbox/Research/Alaska/AKDVTs/draft/v1/poly.xy'; % x y coords for filter a catalog to AK
%input.polygonFilter = '/Users/jpesicek/Dropbox/Research/EFIS/Japan/JapanPolygon.txt'; % JAPAN x y coords
% input.polygonFilter = 'United States'; % is this full US???

%% general params
params.srad = [0 50];
params.DepthRange = [-3 70]; % km
params.MagRange = [0 10];
params.YearRange = [1964 2015];
params.polygonFilterSwitch = 'in';
params.polygonBuffer = 1; % in degrees
params.McMinEventCt = 50;

%% wingPlot params
params.coasts = true;
params.wingPlot = false;
params.topo = false;
params.visible = 'on';
params.maxEvents2plot = 10000;

%% set up diary
[~,~,~] = mkdir(input.catalogsDir);
diaryFileName = [input.catalogsDir,filesep,datestr(now,30),'_diary.txt'];
diary(diaryFileName);
disp(mfilename('fullpath'))
disp(' ')
disp(input)
disp(' ')
disp(params)

%% LOAD catalog
% if ~exist('catalog','var') %&& isstruct(catalog)
%     disp('loading catalog...')
%     load(input.catalog); %created using importISCcatalog.m
%     %     [ catalog ] = filterDepth( catalog, params.DepthRange(2)); % (d)
%     %     [ catalog ] = filterMag( catalog, params.MagRange(1) ); % (e)
%     %     [ catalog ] = filterTime( catalog, datenum('1990/01/01'), params.catalogEndDate); % start here to cut out redoubt for now
%     disp('...catalog loaded')
% end

%% read in GVP data
load(input.gvp_volcanoes); % volcanoCat struct imported via importEruptionCatalog.m from OGBURN FILE
% [volcanoCat,vinfo] = filterVolcanoes(volcanoCat,input,params);
% volcanoCat = filterCatalogByCountry(volcanoCat,input.polygonFilter,params.polygonFilterSwitch);

%% FIND specific volcano if desired
vname = 'Arshan';
vnames = extractfield(volcanoCat,'Volcano');
vi = find(strcmp(vname,vnames));
volcanoCat = volcanoCat(vi);
%% NOW get and save volcano catalogs
for i=1:size(volcanoCat,1)
    
    [vinfo] = getVolcanoInfo(volcanoCat,[],i);
%     [ vinfoF,vinfoF.outerAnnulus,vinfoF.innerAnnulus] = filterAnnulusm(vinfo, vinfo.lat, vinfo.lon, params.srad);
%     vinfoF.Radius = params.srad(2);
    disp([int2str(i),'/',int2str(size(volcanoCat,1)),', ',vinfo.name,', ',vinfo.country])
    
    volcOutName = fixStringName(vinfo.name);
    outDirName=fullfile(input.catalogsDir,fixStringName(vinfo.country),volcOutName);
    outVinfoName=fullfile(outDirName,['vinfo_',int2str(volcanoCat(i).Vnum),'.mat']);
    
%     if exist([outDirName,'/iscMT_',fixStringName(vinfoF.name),'.csv'],'file')
%         disp('skip repeat')
%         continue
%     end
    
    if ~exist(outDirName,'dir')
        [~,~,~] = mkdir(outDirName);
    end
    
    if params.wingPlot
        mapdata = prep4WingPlot(vinfoF,params,input,vinfoF.outerAnnulus,vinfoF.innerAnnulus);
    else
        mapdata = [];
    end
    %% get ISC catalog
    
    catalog_ISC = getISCcat(input,params,vinfo,mapdata);
    
    %% get ANSS
    %     catalog_NEIC = getComcatCat(input,params,vinfo,mapdata);
    catalog_ANSS = getANSScat(input,params,vinfo,mapdata);
    
    %% now filter more and save for later analysis
%     save(outVinfoName,'-struct','vinfoF','-append');
    
end
%%
diary OFF