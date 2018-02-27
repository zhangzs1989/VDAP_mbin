%% rebuild EFIS per volcano instead of piece-wise

clearvars -except catalogISC catalogJMA catalogGEM catalogBMKG catalogSSN
catalogJMA = []; % do this to save memory if not doing Japan
%%
input.gvp_volcanoes='/Users/jpesicek/Dropbox/Research/EFIS/GVP/GVP_volcanoes_v2.mat'; % imported via importEruptionCatalog, originally from S. Ogburn
input.gvp_eruptions='/Users/jpesicek/Dropbox/Research/EFIS/GVP/gvp_eruptions_with_ids_v2.mat';
input.GSHHS = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/data/gshhs_f.b'; %full res;
input.ISCcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/iscCatalogAll6wFMsTrim.mat'; % importISCcatalog.m
input.outDir = '/Users/jpesicek/Dropbox/Research/EFIS/testNewMc5'; % importISCcatalog.m
input.catalogsDir = input.outDir;
input.localCatDir = '~/Dropbox/Research/EFIS/localCatalogs';
input.JMAcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/JMA/JMAcatalog.mat';
input.GEMcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/GEM/catalogGEM.mat';
input.BMKGcatalog ='/Users/jpesicek/Dropbox/Research/EFIS/BMKG/catalogBMKG.mat';
input.SSNcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/SSN/catalogSSN.mat';

%% wingPlot params
params.coasts = true;
params.wingPlot = false;
params.topo = false;
params.visible = 'off';
params.srad = [0 100];
params.DepthRange = [-3 70]; % km
params.MagRange = [0 10];
params.YearRange = [1964 2016];
params.McMinN = 100; 
params.smoothDays = 30;
params.maxEvents2plot = 10000;
params.McType = 'constantTimeWindow'; % 'constantTimeWindow' or 'constantEventNumber'
params.McTimeWindow = 'year'; %
params.vname = 'all'; % options are 'vname' or 'all'
% params.vname = 'St. Helens';
params.country = 'United States';
params.getCats = true;

% for filnal cat and plot
paramsF = params;
paramsF.srad = [0 35];
paramsF.DepthRange = [-3 35];

%% set up diary
[~,~,~] = mkdir(input.catalogsDir);
diaryFileName = [input.catalogsDir,filesep,datestr(now,30),'_diary.txt'];
diary(diaryFileName);
disp(mfilename('fullpath'));disp(' ');disp(input);disp(' ');disp(params)
%%
% LOAD catalogs % must be preloaded vars for PARFOR, not on demand
if ~exist('catalogISC','var') %&& isstruct(catalog)
    disp('loading catalogISC...') %this could be avoided by alternatively calling on demand from ISC (getISCcat.m)
    load(input.ISCcatalog); %created using importISCcatalog.m
    disp('...catalog loaded')
end
if ~exist('catalogGEM','var')
    disp('loading catalogGEM...')
    load(input.GEMcatalog);
    disp('...catalog loaded')
end
if ~exist('catalogJMA','var') %&& isstruct(catalog)
    disp('loading catalogJMA...')
    load(input.JMAcatalog); %created using importISCcatalog.m
    disp('...catalog loaded')
end
if ~exist('catalogBMKG','var') %&& isstruct(catalog)
    disp('loading catalogBMKG...')
    load(input.BMKGcatalog); %created using importISCcatalog.m
    disp('...catalog loaded')
end
if ~exist('catalogSSN','var') %&& isstruct(catalog)
    disp('loading catalogSSN...')
    load(input.SSNcatalog); %created using importISCcatalog.m
    disp('...catalog loaded')
end

load(input.gvp_volcanoes); % volcanoCat struct imported via importEruptionCatalog.m from OGBURN FILE
load(input.gvp_eruptions); % spits out eruptionCat
%%
if isempty(gcp('nocreate'))
    disp('making parpool...')
    try
        parpool(6); %each thread needs about 5GB memory,could prob do 8, but use 6 to be safe
    catch
        parpool(4);
    end
end
%% FIND specific volcano or set of volcanoes, if desired
if ~strcmpi(params.vname,'all')
    vnames = extractfield(volcanoCat,'Volcano');
    vi = find(strcmp(params.vname,vnames));
    volcanoCat = volcanoCat(vi);
    if isempty(volcanoCat);error('bad vname');end
end
if ~strcmpi(params.country,'all')
    volcanoCat = filterCatalogByCountry(volcanoCat,params.country);
end
tic
%% NOW get and save volcano catalogs
parfor i=1:size(volcanoCat,1)  %% PARFOR APPROVED
    
    [vinfo] = getVolcanoInfo(volcanoCat,[],i);
    disp([int2str(i),'/',int2str(size(volcanoCat,1)),', ',vinfo.name,', ',vinfo.country])
    einfo = getEruptionInfoFromNameOrNum(vinfo.Vnum,eruptionCat);
    
    vpath = fullfile(input.catalogsDir,fixStringName(vinfo.country),fixStringName(vinfo.name));
    volcOutName = fixStringName(vinfo.name);
    outVinfoName=fullfile(vpath,['vinfo_',int2str(volcanoCat(i).Vnum),'.mat']);
    [~,~,~] = mkdir(vpath);
    
    [ outer_ann, inner_ann ] = getAnnulusm( vinfo.lat, vinfo.lon, params.srad);
    mapdata = prep4WingPlot(vinfo,params,input,outer_ann,inner_ann);
    
    %% get ISC catalog
    catalog_ISC = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catalogISC,'ISC');
    
    %% look for and plot GEM events < 1964
    catalog_gem = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catalogGEM,'GEM');
    
    [catalog_ISC,~] = mergeTwoCatalogs(catalog_gem,catalog_ISC);
    catalog_local = [];
    %% ANSS
    if strcmpi(vinfo.country,'United States')
        catalog_local = getANSScat(input,params,vinfo,mapdata); %wget
    end
    %% GNS
    if strcmpi(vinfo.country,'New Zealand')
        catalog_local = getGNScat(input,params,vinfo,mapdata); %wget
    end
    %% JMA
    if strcmpi(vinfo.country,'Japan') || strcmp(vinfo.country,'Japan - administered by Russia')
        catalog_local = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catalogJMA,'JMA');
    end
    %% BMKG
    if strcmpi(vinfo.country,'Indonesia')
        catalog_local = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catalogBMKG,'BMKG');
    end
    %% SSN
    if strcmpi(vinfo.country,'Mexico') || strcmp(vinfo.country,'Mexico-Guatemala')
        catalog_local = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catalogSSN,'SSN');
    end
    %% local catalog
    LocalCatalogFile = fullfile(input.localCatDir,['local_',int2str(vinfo.Vnum),'.mat']);
    if exist(LocalCatalogFile,'file')
        if ~isempty(catalog_local)
            error('You may be overwriting regional catalog here') % merge later
        end
        catalog_local = load(LocalCatalogFile); catalog_local = catalog_local.catalog;
        catalog_local = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catalog_local,'LOCAL');
    end
    %     [CatalogStatus,catNames] = check4catalogs(vpath,vinfo.Vnum,input.localCatDir);
    
    %% compute MASTER catalog
    catName=fullfile(vpath,['cat_MASTER_',int2str(vinfo.Vnum)]);
    if params.getCats
        disp('merge catalogs...')
        [catMaster,H] = mergeTwoCatalogs(catalog_ISC,catalog_local,'yes');
        if ~isempty(H); print(H,fullfile(vpath,'QC_MASTER_Merge_map'),'-dpng'); end;
        catMaster = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catMaster,'MASTER');
    else
        if exist([catName,'.mat'],'file')
            warning('loading pre-existing catalog')
            catMaster = load(catName); catMaster = catMaster.catalog;
        else
            error('catalog DNE')
        end
    end
    %%  NOW DONE MAKING CATALOG, now Mc
    if ~isempty(catMaster)
        %% GET Mc
        disp('Compute Mc...')
        [McG,McL,MasterMc] = buildMcbyVolcano(catMaster,catalog_ISC,catalog_local,vinfo,params,vpath);
        %%
        F1 = catalogQCfig(catMaster,vinfo,einfo,MasterMc.McDaily,params.visible);
        fname=fullfile(vpath,['QC_MASTER_',int2str(vinfo.Vnum),'']);
        print(F1,fname,'-dpng')
        try savefig(F1,fname); catch; warning('savefig error'); end

        %% make QC plots
        if params.wingPlot
            disp('Map figs...')
            F2 = catalogQCmap(catMaster,vinfo,params,mapdata);
            print(F2,fullfile(vpath,['QC_MASTER_',int2str(vinfo.Vnum),'_map']),'-dpng')
            mkEruptionMapQCfigs(catMaster,einfo,vinfo,mapdata,params,vpath)
        end
        
        %% FINAL CATALOG if different from Mc catalog
        disp('Finalize...')
        [ outer_ann, inner_ann ] = getAnnulusm( vinfo.lat, vinfo.lon, paramsF.srad);
        mapdata = prep4WingPlot(vinfo,paramsF,input,outer_ann,inner_ann);
        catFinal = getVolcCatFromLargerCat(input,paramsF,vinfo,mapdata,catMaster,'FINAL');
    end
    close all
    % check DB integrity
    %     [McStatus,catNames2]= check4catalogMcs(vpath,vinfo.Vnum);
end
toc
% [result,status,offenderCountries,offenderVolcanoes,I] = checkCatalogDBintegrity(input.catalogsDir,volcanoCat);
