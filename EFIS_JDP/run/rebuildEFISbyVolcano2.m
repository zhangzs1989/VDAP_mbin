%% rebuild EFIS per volcano instead of piece-wise

clearvars -except catalogISC catalogJMA catalogGEM
%%
input.gvp_volcanoes='/Users/jpesicek/Dropbox/Research/EFIS/GVP/GVP_volcanoes_v2.mat'; % imported via importEruptionCatalog, originally from S. Ogburn
input.gvp_eruptions='/Users/jpesicek/Dropbox/Research/EFIS/GVP/gvp_eruptions_with_ids_v2.mat';
input.GSHHS = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/data/gshhs_f.b'; %full res;
input.ISCcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/iscCatalogAll6wFMsTrim.mat'; % importISCcatalog.m
input.outDir = '/Users/jpesicek/Dropbox/Research/EFIS/globalV2a'; % importISCcatalog.m
input.catalogsDir = input.outDir;
input.localCatDir = '~/Dropbox/Research/EFIS/localCatalogs';
input.JMAcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/JMA/JMAcatalog.mat';
input.GEMcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/GEM/catalogGEM.mat';
input.BMKGcatalog ='/Users/jpesicek/Dropbox/Research/EFIS/BMKG/catalogBMKG.mat';

%% wingPlot params
params.coasts = true;
params.wingPlot = true;
params.topo = true;
params.visible = 'off';
params.srad = [0 100];
params.DepthRange = [-3 50]; % km
params.MagRange = [0 10];
params.YearRange = [1964 2016];
params.McMinN = 75;
params.smoothDayFac = 30*6;
params.maxEvents2plot = 5000;

params.vname = 'all'; % options are 'vname' or 'all'
params.country = 'Indonesia';

%% set up diary
[~,~,~] = mkdir(input.catalogsDir);
diaryFileName = [input.catalogsDir,filesep,datestr(now,30),'_diary.txt'];
diary(diaryFileName);
disp(mfilename('fullpath'))
disp(' ')
disp(input)
disp(' ')
disp(params)

% LOAD catalog
if ~exist('catalogISC','var') %&& isstruct(catalog)
    disp('loading catalogISC...')
    load(input.ISCcatalog); %created using importISCcatalog.m
    disp('...catalog loaded')
end
if ~exist('catalogGEM','var')
    disp('loading catalogGEM...')
    load(input.GEMcatalog);
    disp('...catalog loaded')
end

load(input.gvp_volcanoes); % volcanoCat struct imported via importEruptionCatalog.m from OGBURN FILE
load(input.gvp_eruptions); % spits out eruptionCat

%% FIND specific volcano or set of volcanoes, if desired
if ~strcmp(params.vname,'all')
    vnames = extractfield(volcanoCat,'Volcano');
    vi = find(strcmp(params.vname,vnames));
    volcanoCat = volcanoCat(vi);
    if isempty(volcanoCat)
        error('bad vname')
    end
end
if ~strcmp(params.country,'all')
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
    
    %% get ISC catalog
    [catalog_ISC1,~, ~ ]= filterAnnulusm(catalogISC,vinfo.lat,vinfo.lon,params.srad);
    if params.wingPlot
        [ outer_ann, inner_ann ] = getAnnulusm( vinfo.lat, vinfo.lon, params.srad);
        mapdata = prep4WingPlot(vinfo,params,input,outer_ann,inner_ann);
        t1=datenum(params.YearRange(1),1,1);
        t2=datenum(params.YearRange(2)+1,1,1);
        fh_wingplot = wingPlot1(vinfo, t1, t2, catalog_ISC1, mapdata, params,1);
        figname=fullfile(vpath,['map_ISC_',fixStringName(vinfo.name)]);
        print(fh_wingplot,'-dpng',[figname,'.png'])
    end
    outCatName=fullfile(vpath,['cat_ISC_',int2str(vinfo.Vnum)]);
    catalog = catalog_ISC1;
    parsave_catalog(outCatName,catalog);
    
    %% look for and plot GEM events < 1964
    catalog_gem = filterAnnulusm( catalogGEM, vinfo.lat,vinfo.lon, params.srad); % (e)
    if ~isempty(catalog_gem)
        dts = datenum(extractfield(catalog_gem,'DateTime'));
        t1=floor(datenum(min(dts)));
        t2=ceil(datenum(max(dts)));
        if params.wingPlot
            figname=fullfile(vpath,['map_GEM_',fixStringName(vinfo.name)]);
            fh_wingplot = wingPlot1(vinfo, t1, t2, catalog_gem, mapdata, params,1);
            print(fh_wingplot,'-dpng',[figname,'.png'])
        end
        outCatName=fullfile(vpath,['cat_GEM_',int2str(vinfo.Vnum),'.mat']);
        parsave_catalog(outCatName,catalog_gem);
    end
    %%
    getLocalCatalog
    %%
    %% get local catalog
    % NOTE: not dealt with case where there is regional and local catalog
    % yet - assuming for now there will not be both
    LocalCatalogFile = fullfile(input.localCatDir,['local_',int2str(vinfo.Vnum),'.mat']);
    if exist(LocalCatalogFile,'file')
        warning('You may be overwriting regional catalog here') % merge later
        catalog_local = load(LocalCatalogFile); %this will overwrite regional catalog
        catalog_local = catalog_local.catalog;
        dts = datenum(extractfield(catalog_local,'DateTime'));
        t1=floor(datenum(min(dts)));
        t2=ceil(datenum(max(dts)));
        figname=fullfile(vpath,['map_LOCAL_',fixStringName(vinfo.name)]);
        fh_wingplot = wingPlot1(vinfo, t1, t2, catalog_local, mapdata, params,1);
        print(fh_wingplot,'-dpng',[figname,'.png'])
        outCatName=fullfile(vpath,['local_',int2str(vinfo.Vnum)]);
        parsave_catalog(outCatName,catalog_local);
    end
    %%
    [CatalogStatus,catNames] = check4catalogs(vpath,vinfo.Vnum,input.localCatDir);
    
    if ~isempty(catalog_local)
        %% compute MASTER catalog
        [catMASTER,H] = mergeTwoCatalogs(catalog_ISC1,catalog_local,'yes');
        if ~isempty(H); print(H,fullfile(vpath,'QC_MASTER_Merge_map'),'-dpng'); end;
        catalog = catMASTER;
    end
    
    if ~isempty(catalog)
        %% FINAL CATALOG
        catalog = filterDepth( catalog, params.DepthRange); % (d)
        catalog = filterMag( catalog, params.MagRange); % (e)
        catalog = filterAnnulusm( catalog, vinfo.lat,vinfo.lon, params.srad); % (e)
    end
    % check for dups
    [ percentDuplicates, ID ] = check4duplicateEvents(catalog);
    if percentDuplicates > 0
        warning('Duplicates exist')
    end
    
    outCatName=fullfile(vpath,['cat_MASTER_',int2str(vinfo.Vnum),'.mat']);
    parsave_catalog(outCatName,catalog);
    
    %% make QC plots
    if params.wingPlot
        F2 = catalogQCmap(catalog,vinfo,params,mapdata);
        print(F2,fullfile(vpath,['QC_MASTER_',int2str(vinfo.Vnum),'_map']),'-dpng')
        
        %full catalog
        t1a=datenum(params.YearRange(1),1,1);
        t2a=datenum(params.YearRange(2)+1,1,1);
        figname=fullfile(vpath,['map_MASTER_',fixStringName(vinfo.name)]);
        fh_wingplot = wingPlot1(vinfo, t1a, t2a, catalog, mapdata, params,1);
        print(fh_wingplot,'-dpng',[figname,'.png'])
        
        if ~isempty(einfo)
            %loop over eruptions
            %1
            t1=t1a;
            t2=datenum(einfo(1).StartDate);
            figname=fullfile(vpath,['map_MASTER_',fixStringName(vinfo.name),'_',datestr(t2,'yyyymmdd')]);
            fh_wingplot = wingPlot1(vinfo, t1, t2, catalog, mapdata, params,1);
            print(fh_wingplot,'-dpng',[figname,'.png'])
            % middle
            if numel(einfo)>1
                for e=2:numel(einfo)
                    t1=datenum(einfo(e-1).EndDate);
                    t2=datenum(einfo(e).StartDate);
                    figname=fullfile(vpath,['map_MASTER_',fixStringName(vinfo.name),'_',datestr(t2,'yyyymmdd')]);
                    fh_wingplot = wingPlot1(vinfo, t1, t2, catalog, mapdata, params,1);
                    print(fh_wingplot,'-dpng',[figname,'.png'])
                end
                %last
                t1 = datenum(einfo(e).EndDate);
                t2 = t2a;
                figname=fullfile(vpath,['map_MASTER_',fixStringName(vinfo.name),'_',datestr(t2,'yyyymmdd')]);
                fh_wingplot = wingPlot1(vinfo, t1, t2, catalog, mapdata, params,1);
                print(fh_wingplot,'-dpng',[figname,'.png'])
            end
        end
    end
    close all
    %% GET Mc
    [Mc, MasterMc] = buildMcbyVolcano(catalog,vinfo,params,input);
    
    if ~isempty(catalog)
        F1 = catalogQCfig(catalog,vinfo,einfo,MasterMc.McDaily,params.visible);
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
    [McStatus,catNames2]= check4catalogMcs(vpath,vinfo.Vnum);
end
toc
[result,status,offenderCountries,offenderVolcanoes,I] = checkCatalogDBintegrity(input.catalogsDir,volcanoCat);
