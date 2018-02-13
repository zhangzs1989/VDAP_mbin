%% rebuild EFIS per volcano instead of piece-wise

clearvars -except catalogISC catalogJMA catalogGEM catalogBMKG catalogSSN
%%
input.gvp_volcanoes='/Users/jpesicek/Dropbox/Research/EFIS/GVP/GVP_volcanoes_v2.mat'; % imported via importEruptionCatalog, originally from S. Ogburn
input.gvp_eruptions='/Users/jpesicek/Dropbox/Research/EFIS/GVP/gvp_eruptions_with_ids_v2.mat';
input.GSHHS = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/data/gshhs_f.b'; %full res;
input.ISCcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/iscCatalogAll6wFMsTrim.mat'; % importISCcatalog.m
input.outDir = '/Users/jpesicek/Dropbox/Research/EFIS/globalV2c'; % importISCcatalog.m
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
params.McMinN = 50;
params.smoothDayFac = 365*3;
params.maxEvents2plot = 5000;

params.vname = 'Rabaul'; % options are 'vname' or 'all'
params.country = 'all';

% for filnal cat and plot
paramsF = params;
paramsF.srad = [0 35];
paramsF.DepthRange = [-3 35];

%% set up diary
[~,~,~] = mkdir(input.catalogsDir);
diaryFileName = [input.catalogsDir,filesep,datestr(now,30),'_diary.txt'];
diary(diaryFileName);
disp(mfilename('fullpath'))
disp(' ')
disp(input)
disp(' ')
disp(params)

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
for i=1:size(volcanoCat,1)  %% PARFOR APPROVED
    
    [vinfo] = getVolcanoInfo(volcanoCat,[],i);
    einfo = getEruptionInfoFromNameOrNum(vinfo.Vnum,eruptionCat);
    disp([int2str(i),'/',int2str(size(volcanoCat,1)),', ',vinfo.name,', ',vinfo.country])
    
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
    
    [catalog_ISC,H] = mergeTwoCatalogs(catalog_gem,catalog_ISC);
    
    %% get local catalog
    catalog_local = []; catMaster = [];
    %% get ANSS
    if strcmpi(vinfo.country,'United States')
        catalog_local = getANSScat(input,params,vinfo,mapdata); %wget
    end
    %% GNS
    if strcmpi(vinfo.country,'New Zealand')
        catalog_local = getGNScat(input,params,vinfo,mapdata); %wget
    end
    %% get JMA
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
    %%
    % NOTE: not dealt with case where there is regional and local catalog
    % yet - assuming for now there will not be both
    LocalCatalogFile = fullfile(input.localCatDir,['local_',int2str(vinfo.Vnum),'.mat']);
    if exist(LocalCatalogFile,'file')
        warning('You may be overwriting regional catalog here') % merge later
        catalog_local = load(LocalCatalogFile); %this will overwrite regional catalog
        catalog_local = catalog_local.catalog;
        if params.wingPlot
            dts = datenum(extractfield(catalog_local,'DateTime'));
            t1=floor(datenum(min(dts))); t2=ceil(datenum(max(dts)));
            figname=fullfile(vpath,['map_LOCAL_',fixStringName(vinfo.name)]);
            fh_wingplot = wingPlot1(vinfo, t1, t2, catalog_local, mapdata, params,1);
            print(fh_wingplot,'-dpng',[figname,'.png'])
        end
        outCatName=fullfile(vpath,['local_',int2str(vinfo.Vnum)]);
        parsave_catalog(outCatName,catalog_local);
    end
    %%
    %     [CatalogStatus,catNames] = check4catalogs(vpath,vinfo.Vnum,input.localCatDir);
    %% compute MASTER catalog
    [catMaster,H] = mergeTwoCatalogs(catalog_ISC,catalog_local,'yes');
    if ~isempty(H); print(H,fullfile(vpath,'QC_MASTER_Merge_map'),'-dpng'); end;
    
    % check for dups
    [ percentDuplicates, ID ] = check4duplicateEvents(catMaster);
    if percentDuplicates > 0
        warning('Duplicates exist')
    end
    
    outCatName=fullfile(vpath,['cat_MASTER_',int2str(vinfo.Vnum),'.mat']);
    parsave_catalog(outCatName,catMaster);
    %%  NOW DONE MAKING CATALOG
    
    if ~isempty(catMaster)
        %% make QC plots
        if params.wingPlot
            F2 = catalogQCmap(catMaster,vinfo,params,mapdata);
            print(F2,fullfile(vpath,['QC_MASTER_',int2str(vinfo.Vnum),'_map']),'-dpng')
            
            %full catalog
            dts = datenum(extractfield(catMaster,'DateTime'));
            t1min = min(dts);
            t1a = min([t1min,datenum(params.YearRange(1),1,1)]); t2a=datenum(params.YearRange(2)+1,1,1);
            figname=fullfile(vpath,['map_MASTER_',fixStringName(vinfo.name)]);
            fh_wingplot = wingPlot1(vinfo, t1a, t2a, catMaster, mapdata, params,1);
            print(fh_wingplot,'-dpng',[figname,'.png'])
            
            if ~isempty(einfo)
                %loop over eruptions
                %1
                t1=t1a; t2=datenum(einfo(1).StartDate);
                figname=fullfile(vpath,['map_MASTER_',fixStringName(vinfo.name),'_',datestr(t2,'yyyymmdd')]);
                fh_wingplot = wingPlot1(vinfo, t1, t2, catMaster, mapdata, params,1);
                print(fh_wingplot,'-dpng',[figname,'.png'])
                % middle
                if numel(einfo)>1
                    for e=2:numel(einfo)
                        t1=datenum(einfo(e-1).EndDate); t2=datenum(einfo(e).StartDate);
                        figname=fullfile(vpath,['map_MASTER_',fixStringName(vinfo.name),'_',datestr(t2,'yyyymmdd')]);
                        fh_wingplot = wingPlot1(vinfo, t1, t2, catMaster, mapdata, params,1);
                        print(fh_wingplot,'-dpng',[figname,'.png'])
                    end
                    %last
                    t1 = datenum(einfo(e).EndDate); t2 = t2a;
                    figname=fullfile(vpath,['map_MASTER_',fixStringName(vinfo.name),'_',datestr(t2,'yyyymmdd')]);
                    fh_wingplot = wingPlot1(vinfo, t1, t2, catalog, mapdata, params,1);
                    print(fh_wingplot,'-dpng',[figname,'.png'])
                end
            end
        end
        
        %% GET Mc
        [Mc, MasterMc] = buildMcbyVolcano(catMaster,vinfo,params,input);
        
        F1 = catalogQCfig(catMaster,vinfo,einfo,MasterMc.McDaily,params.visible);
        fname=fullfile(vpath,['QC_MASTER_',int2str(vinfo.Vnum),'']);
        print(F1,fname,'-dpng')
        try
            savefig(F1,fname);
        catch
            warning('savefig error')
        end
        %         close(F1)
    end    
    %% check DB integrity
    %     [McStatus,catNames2]= check4catalogMcs(vpath,vinfo.Vnum);
    
    % HERE save reduced catalog for later use, i.e. with more restrictive
    % filters.
    if ~isempty(catMaster)
        %% FINAL CATALOG if different from Mc catalog
        catalog = filterDepth( catMaster, paramsF.DepthRange); % (d)
        %         catalog = filterMag( catalog, paramsF.MagRange); % (e)
        catalog = filterAnnulusm( catalog, vinfo.lat,vinfo.lon, paramsF.srad); % (e)
        outCatName=fullfile(vpath,['cat_FINAL_',int2str(vinfo.Vnum),'.mat']);
        parsave_catalog(outCatName,catalog);
        if params.wingPlot && ~isempty(catalog)
            [ outer_ann, inner_ann ] = getAnnulusm( vinfo.lat, vinfo.lon, paramsF.srad);
            mapdata = prep4WingPlot(vinfo,paramsF,input,outer_ann,inner_ann);
            dts = datenum(extractfield(catalog,'DateTime'));
            t1min = min(dts);
            t1a = min([t1min,datenum(paramsF.YearRange(1),1,1)]); t2a=datenum(paramsF.YearRange(2)+1,1,1);
            figname=fullfile(vpath,['map_FINAL_',fixStringName(vinfo.name)]);
            fh_wingplot = wingPlot1(vinfo, t1a, t2a, catalog, mapdata, paramsF,1);
            print(fh_wingplot,'-dpng',[figname,'.png'])
        end
    end
    close all
end
toc
[result,status,offenderCountries,offenderVolcanoes,I] = checkCatalogDBintegrity(input.catalogsDir,volcanoCat);
