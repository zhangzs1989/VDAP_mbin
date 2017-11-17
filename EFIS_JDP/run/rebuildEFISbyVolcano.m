%% rebuild EFIS per volcano instead of piece-wise

clearvars -except catalogISC catalogJMA

%%
input.gvp_volcanoes='/Users/jpesicek/Dropbox/Research/EFIS/GVP/GVP_volcanoes_v2.mat'; % imported via importEruptionCatalog, originally from S. Ogburn
input.gvp_eruptions='/Users/jpesicek/Dropbox/Research/EFIS/GVP/gvp_eruptions_with_ids_v2.mat';
input.GSHHS = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/data/gshhs_f.b'; %full res;
input.ISCcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/trimISCcatalog2volcs/iscCatalogAll5wFMsTrim2.mat'; % importISCcatalog.m
input.outDir = '/Users/jpesicek/Dropbox/Research/EFIS/global8'; % importISCcatalog.m
input.catalogsDir = input.outDir;
input.localCatDir = '~/Dropbox/Research/EFIS/localCatalogs';
% input.polygonFilter = 'United States';
input.paramFile = '/Users/jpesicek/EFIS_mbin/examp/ISCbuild_inp.txt';
input.JMAcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/JMA/JMAcatalog.mat';

[~,paramsISC] = getInputFiles(input.paramFile);
%% wingPlot params
params.coasts = true;
params.wingPlot = true;
params.topo = true;
params.visible = 'on';
params.srad = [0 50];
params.DepthRange = [-3 40]; % km
params.MagRange = [0 10];
params.YearRange = [1964 2015];
params.McMinN = 100;
params.smoothDayFac = 30*6;
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

% LOAD catalog
if ~exist('catalogISC','var') %&& isstruct(catalog)
    disp('loading catalogISC...')
    load(input.ISCcatalog); %created using importISCcatalog.m
    disp('...catalog loaded')
end
if ~exist('catalogJMA','var') %&& isstruct(catalog)
    disp('loading catalogJMA...')
    load(input.JMAcatalog); %created using importISCcatalog.m
    disp('...catalog loaded')
end

load(input.gvp_volcanoes); % volcanoCat struct imported via importEruptionCatalog.m from OGBURN FILE
load(input.gvp_eruptions); % spits out eruptionCat
%%
ISC_McFile = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/ISC_Mc.csv';
ISC_McInfo = getGlobalISC_McInfo(ISC_McFile);
%% FIND specific volcano if desired
vname = 'Kikai';
vname = 'Sabancaya';
vnames = extractfield(volcanoCat,'Volcano');
vi = find(strcmp(vname,vnames));
volcanoCat = volcanoCat(vi);
% volcanoCat = filterCatalogByCountry(volcanoCat,'Japan');

%% NOW get and save volcano catalogs
% if isempty(gcp('nocreate'))
%     try
%         parpool(6); %each thread needs about 5GB memory,could prob do 8, but use 6 to be safe
%     catch
%         parpool(4);
%     end
% end
% tic
% parfor i=1:size(volcanoCat,1)
for i=1:size(volcanoCat,1)
    
    [vinfo] = getVolcanoInfo(volcanoCat,[],i);
    einfo = getEruptionInfoFromNameOrNum(vinfo.Vnum,eruptionCat);
    disp([int2str(i),'/',int2str(size(volcanoCat,1)),', ',vinfo.name,', ',vinfo.country])
    
    vpath = fullfile(input.catalogsDir,fixStringName(vinfo.country),fixStringName(vinfo.name));
    volcOutName = fixStringName(vinfo.name);
    outVinfoName=fullfile(vpath,['vinfo_',int2str(volcanoCat(i).Vnum),'.mat']);
    
    [~,~,~] = mkdir(vpath);
    McPath = fullfile(vpath,'Mc');
    [~,~,~] = mkdir(McPath);
    localMc = [];
    catalog_local = [];
    
    %% compute ISC Mc by local full copy of ISC catalog out to larger radius (not updated regularly)
    [catalog_ISC1,~, ~ ]= filterAnnulusm(catalogISC,vinfo.lat,vinfo.lon,paramsISC.srad);
    vISC_Mc = getVolcanoMc(vinfo,catalog_ISC1,McPath,paramsISC.McMinN,'ISC',2,paramsISC.smoothDayFac);
    outMcInfoName=fullfile(McPath,['ISC_McInfo_',int2str(vinfo.Vnum),'.mat']);
    %     save(outMcInfoName,'-struct','vISC_Mc');
    parsave_struct(outMcInfoName,vISC_Mc);
    %% make time vs Mc plot
    mags = extractfield(catalog_ISC1,'Magnitude');
    dtimes = datenum(extractfield(catalog_ISC1,'DateTime'));
    H = mkMcFig(vISC_Mc,mags,dtimes,params.visible);
    set(get(H(1).Children(2),'title'),'String',[vinfo.name,', ',vinfo.country,'  (',int2str(length(mags)),' events, window = ',int2str(paramsISC.McMinN),' events, smoothing = ',num2str(paramsISC.smoothDayFac/365),' yrs, radius = ',int2str(paramsISC.srad(2)),' km'])
    print(H,'-dpng',fullfile(McPath,['ISC','_Mc_',fixStringName(vinfo.name)]))
    savefig(H,fullfile(McPath,['ISC','_Mc_',fixStringName(vinfo.name)]))
    %full catalog wingplot?
    t1a=datenum(params.YearRange(1),1,1);
    t2a=datenum(params.YearRange(2)+1,1,1);
    figname=fullfile(vpath,['ISC_',fixStringName(vinfo.name)]);
    [ outer_ann, inner_ann ] = getAnnulusm( vinfo.lat, vinfo.lon, paramsISC.srad);
    mapdata = prep4WingPlot(vinfo,paramsISC,input,outer_ann,inner_ann);
    fh_wingplot = wingPlot1(vinfo, t1a, t2a, catalog_ISC1, mapdata, paramsISC,1);
    print(fh_wingplot,'-dpng',[figname,'.png'])
        
    %% get ISC catalog
    [ outer_ann, inner_ann ] = getAnnulusm( vinfo.lat, vinfo.lon, params.srad);
    mapdata = prep4WingPlot(vinfo,params,input,outer_ann,inner_ann);
    %     catalog_ISC2 = getISCcat(input,params,vinfo,mapdata); %by wget call (more up2date, but slower)
    catalog_ISC2 = filterAnnulusm(catalog_ISC1,vinfo.lat,vinfo.lon,params.srad); % or by radius filter of static ISC catalog, fast but outdated
    catalog_ISC2 = filterDepth(catalog_ISC2,params.DepthRange);
    outCatName=fullfile(vpath,['ISC_',int2str(vinfo.Vnum)]);
    catalog = catalog_ISC2;
    %     save(outCatName,'catalog');
    parsave_catalog(outCatName,catalog);
    
    %% get ANSS
    if strcmp(vinfo.country,'United States')
        catalog_local = getANSScat(input,params,vinfo,mapdata);
    end
    
    %% get JMA
    if strcmp(vinfo.country,'Japan')
        catalog_local = filterAnnulusm(catalogJMA,vinfo.lat,vinfo.lon,params.srad); %
        catalog_local = filterDepth(catalog_local,params.DepthRange);
        outCatName=fullfile(vpath,['JMA_',int2str(vinfo.Vnum)]);
        catalog = catalog_local;
        %         save(outCatName,'catalog');
        parsave_catalog(outCatName,catalog);
    end
    
    %% get local catalog
    % NOTE: not dealt with case where there is regional and local catalog
    % yet - assuming for now there will not be both
    LocalCatalogFile = fullfile(input.localCatDir,['local_',int2str(vinfo.Vnum),'.mat']);
    if exist(LocalCatalogFile,'file')
        catalog_local = load(LocalCatalogFile);
        catalog_local = catalog_local.catalog;
        outCatName=fullfile(vpath,['local_',int2str(vinfo.Vnum)]);
        parsave_catalog(outCatName,catalog_local);
    end
    
    [CatalogStatus,catNames] = check4catalogs(vpath,vinfo.Vnum,input.localCatDir);
    
    if ~isempty(catalog_local)
        %% compute local Mc
        localMc = getVolcanoMc(vinfo,catalog_local,McPath,params.McMinN,'local',2,params.smoothDayFac);
        outMcInfoName=fullfile(McPath,['local_McInfo_',int2str(vinfo.Vnum),'.mat']);
        %         save(outMcInfoName,'-struct','localMc');
        parsave_struct(outMcInfoName,localMc);
        %% make time vs Mc plot
        mags = extractfield(catalog_local,'Magnitude');
        dtimes = datenum(extractfield(catalog_local,'DateTime'));
        H = mkMcFig(localMc,mags,dtimes,params.visible);
        set(get(H(1).Children(2),'title'),'String',[vinfo.name,', ',vinfo.country,'  (',int2str(length(mags)),' events, window = ',int2str(params.McMinN),' events, smoothing = ',num2str(params.smoothDayFac/365),' yrs, radius = ',int2str(params.srad(2)),' km'])
        print(H,'-dpng',fullfile(McPath,['local','_Mc_',fixStringName(vinfo.name)]))
        savefig(H,fullfile(McPath,['local','_Mc_',fixStringName(vinfo.name)]))
        
        %% compute MASTER catalog
        [catMASTER,H] = mergeTwoCatalogs(catalog_ISC2,catalog_local,'yes');
        if ~isempty(H); print(H,fullfile(vpath,'MASTER_MergeQC'),'-dpng'); end;
        catalog = catMASTER;
    end
    if ~isempty(catalog)
        %% FINAL CATALOG
        catalog = filterDepth( catalog, params.DepthRange); % (d)
        catalog = filterMag( catalog, params.MagRange); % (e)
        %    catalog = filterTime( catalog, datenum('1990/01/01'), params.catalogEndDate); % start here to cut out redoubt for now
        catalog = filterAnnulusm( catalog, vinfo.lat,vinfo.lon, params.srad); % (e)
    end
    % check for dups?
    [ percentDuplicates, ID ] = check4duplicateEvents(catalog);
    if percentDuplicates > 0
        warning('Duplicates exist')
    end
    
    outCatName=fullfile(vpath,['MASTER_',int2str(vinfo.Vnum),'.mat']);
    %     save(outCatName,'catalog');
    parsave_catalog(outCatName,catalog);
    
    %% compute MASTER Mc
    [MasterMc,H] = mkMasterMc(vinfo,ISC_McInfo,vISC_Mc,localMc);
    print(H,'-dpng',fullfile(McPath,['MASTER_Mc_',fixStringName(vinfo.name)]))
    savefig(H,fullfile(McPath,['MASTER_Mc_',fixStringName(vinfo.name)]))
    outMcInfoName=fullfile(McPath,['MASTER_McInfo_',int2str(vinfo.Vnum),'.mat']);
    %     save(outMcInfoName,'-struct','MasterMc');
    parsave_struct(outMcInfoName,MasterMc);
    
    %% check DB integrity
    [McStatus,catNames2]= check4catalogMcs(vpath,vinfo.Vnum);
    
    %% make QC plots
    if params.wingPlot
        F2 = catalogQCmap(catalog,vinfo,params,mapdata);
        print(F2,fullfile(vpath,['MASTER_',int2str(vinfo.Vnum),'_QC2']),'-dpng')
        %         close(F2)
        
        %full catalog
        t1a=datenum(params.YearRange(1),1,1);
        t2a=datenum(params.YearRange(2)+1,1,1);
        figname=fullfile(vpath,['MASTER_',fixStringName(vinfo.name)]);
        fh_wingplot = wingPlot1(vinfo, t1a, t2a, catalog, mapdata, params,1);
        print(fh_wingplot,'-dpng',[figname,'.png'])
        
        %loop over eruptions
        %1
        t1=t1a;
        t2=datenum(einfo(1).StartDate);
        figname=fullfile(vpath,['MASTER_',fixStringName(vinfo.name),'_',datestr(t2,'yyyymmdd')]);
        fh_wingplot = wingPlot1(vinfo, t1, t2, catalog, mapdata, params,1);
        print(fh_wingplot,'-dpng',[figname,'.png'])
        % middle
        for e=2:numel(einfo)
            t1=datenum(einfo(e-1).EndDate);
            t2=datenum(einfo(e).StartDate);
            figname=fullfile(vpath,['MASTER_',fixStringName(vinfo.name),'_',datestr(t2,'yyyymmdd')]);
            fh_wingplot = wingPlot1(vinfo, t1, t2, catalog, mapdata, params,1);
            print(fh_wingplot,'-dpng',[figname,'.png'])
        end
        %last
        t1 = datenum(einfo(e).EndDate);
        t2 = t2a;
        figname=fullfile(vpath,['MASTER_',fixStringName(vinfo.name),'_',datestr(t2,'yyyymmdd')]);
        fh_wingplot = wingPlot1(vinfo, t1, t2, catalog, mapdata, params,1);
        print(fh_wingplot,'-dpng',[figname,'.png'])
        
    end
    %
    if ~isempty(catalog)
        F1 = catalogQCfig(catalog,vinfo,einfo,MasterMc.McDaily,params.visible);
        print(F1,fullfile(vpath,['MASTER_',int2str(vinfo.Vnum),'_QC1']),'-dpng')
        try
            savefig(F1,fullfile(vpath,['MASTER_',int2str(vinfo.Vnum),'_QC1']));
        catch
            warning('savefig error')
        end
        %         close(F1)
    end
    close all
end
toc
[result,status,offenderCountries,offenderVolcanoes,I] = checkCatalogDBintegrity(input.catalogsDir,volcanoCat);
