%% rebuild EFIS per volcano instead of piece-wise

clearvars -except catalogStruct %catalogISC catalogJMA catalogGEM catalogBMKG catalogSSN catalogSIL
% catalogs.JMA = []; % do this to save memory if not doing Japan
%%
input.gvp_volcanoes='/Users/jpesicek/Dropbox/Research/EFIS/GVP/GVP_volcanoes_v2.mat'; % imported via importEruptionCatalog, originally from S. Ogburn
input.gvp_eruptions='/Users/jpesicek/Dropbox/Research/EFIS/GVP/gvp_eruptions_with_ids_v2.mat';
input.GSHHS = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/data/gshhs_f.b'; %full res;
% input.ISCcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/iscCatalogAll6wFMsTrim.mat'; % importISCcatalog.m
input.outDir = '/Users/jpesicek/Dropbox/Research/EFIS/globalV4'; % importISCcatalog.m
input.catalogsDir = input.outDir;
input.localCatDir = '~/Dropbox/Research/EFIS/localCatalogs';
input.JMAcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/JMA/JMAcatalog.mat';
input.GEMcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/GEM/catalogGEM.mat';
input.BMKGcatalog ='/Users/jpesicek/Dropbox/Research/EFIS/BMKG/catalogBMKG.mat';
input.SSNcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/SSN/catalogSSN.mat';
input.SILcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/SIL/catalogSIL.mat';
input.IGNcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/IGN/catalogIGN.mat';
input.INGVcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/INGV/catalogINGV.mat';

%% wingPlot params
params.coasts = true;
params.wingPlot = true;
params.topo = true;
params.visible = 'off';
params.srad = [0 75];
params.DepthRange = [-3 75]; % km
params.MagRange = [0 10];
params.YearRange = [1964 2018];
params.McMinN = 75;
params.smoothDays = 90;% in (years,months,days)
params.maxEvents2plot = 7500;
params.McType = 'constantTimeWindow'; % 'constantTimeWindow' or 'constantEventNumber'
params.McTimeWindow = 'year'; %calendarDuration(1,0,0); % in (years,months,days) %
params.vname = 'all'; % options are 'vname' or 'all'
% params.vname = 'Asuncion';
% params.vname = {'St. Helens','Agung','Crater Lake','Augustine','Bogoslof','Rabaul'};
params.country = 'all';
params.getCats = false;
params.getMc = true;

% for filnal cat and plot
paramsF = params;
paramsF.srad = [0 35];
paramsF.DepthRange = [-3 35];
%%
% if isempty(gcp('nocreate'))
%     disp('making parpool...')
%     try
%         parpool(7); %each thread needs about 5GB memory,could prob do 8, but use 6 to be safe
%     catch
%         parpool(4);
%     end
% end
%%
if ~exist('catalogStruct','var') %&& isstruct(catalog)
    catalogStruct = [];
end
catalogStruct = loadCatalogs(input,params,catalogStruct);
%%
load(input.gvp_volcanoes); % volcanoCat struct imported via importEruptionCatalog.m from OGBURN FILE
load(input.gvp_eruptions); % spits out eruptionCat
%% FIND specific volcano or set of volcanoes, if desired
volcanoCat = filterCatalogByVnameList(volcanoCat,params.vname,'in',params.country);
%% set up diary
[~,~,~] = mkdir(input.catalogsDir);
diaryFileName = [input.catalogsDir,filesep,datestr(now,30),'_diary.txt'];
diary(diaryFileName); disp(mfilename('fullpath'));disp(' ');disp(input);disp(' ');disp(params)
tic
%% NOW get and save volcano catalogs
parfor i=1:size(volcanoCat,1)  %% PARFOR APPROVED
    
    [vinfo] = getVolcanoInfo(volcanoCat,[],i);
    vpath = fullfile(input.catalogsDir,fixStringName(vinfo.country),fixStringName(vinfo.name));
    disp([int2str(i),'/',int2str(size(volcanoCat,1)),', ',vinfo.name,', ',vinfo.country])
    disp(datetime)
    einfo = getEruptionInfoFromNameOrNum(vinfo.Vnum,eruptionCat);
    
%     fname=fullfile(vpath,['QC_MASTER_',int2str(vinfo.Vnum),'.fig']);
%     if exist(fname,'file')
%         continue
%     end
    
    volcOutName = fixStringName(vinfo.name);
    outVinfoName=fullfile(vpath,['vinfo_',int2str(volcanoCat(i).Vnum),'.mat']);
    [~,~,~] = mkdir(vpath);
    
    [ outer_ann, inner_ann ] = getAnnulusm( vinfo.lat, vinfo.lon, params.srad);
    mapdata = prep4WingPlot(vinfo,params,input,outer_ann,inner_ann);
    
    if params.getCats
        %% get ISC catalog
        %     catalog_ISC = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catalogs.ISC,'ISC');
        catalog_ISC = getISCcat(input,params,vinfo,mapdata);
        
        % look for and plot GEM events < 1964
        catalog_gem = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catalogStruct.GEM,'GEM');
        [catalog_ISC,~] = mergeTwoCatalogs(catalog_gem,catalog_ISC);
        
        % LOCAL
        catalog_local = getLocalCatalog(catalogStruct,input,params,vinfo,mapdata,vinfo.country);
    
        % compute MASTER catalog or load
        catMaster = mkMasterCatalog(vinfo,vpath,input,params,mapdata,catalog_ISC,catalog_local,params.getCats,paramsF);
    end
        
%     [CatalogStatus,catNames] = check4catalogs(vpath,vinfo.Vnum,input.localCatDir);
    if params.wingPlot && params.getCats
        disp('Map figs...')
        F2 = catalogQCmap(catMaster,vinfo,params,mapdata);
        print(F2,fullfile(vpath,['QC_MASTER_',int2str(vinfo.Vnum),'_map']),'-dpng')
%         mkEruptionMapQCfigs(catMaster,einfo,vinfo,mapdata,params,vpath)
    end
    %%
    if params.getMc %  NOW DONE MAKING CATALOG, now Mc
        %% GET Mc
        disp('Compute Mc...')
        if ~params.getCats
            outCatName=fullfile(vpath,['cat_ISC_',int2str(vinfo.Vnum),'.mat']);
            catalog = load(outCatName); catalog_ISC = catalog.catalog;
            catalog_local = getLocalCatalog(catalogStruct,input,params,vinfo,mapdata,vinfo.country);
            catName=fullfile(vpath,['cat_MASTER_',int2str(vinfo.Vnum),'.mat']);
            catMaster = load(catName); catMaster = catMaster.catalog;
        end
        % NOTE: or just do this on demand when answering a question ???!!! or both!!
        [McG,McL,MasterMc] = buildMcbyVolcano(catMaster,catalog_ISC,catalog_local,vinfo,einfo,params,vpath);
        %%
        F1 = catalogQCfig(catMaster,vinfo,einfo,MasterMc.McDaily,params.visible);
        fname=fullfile(vpath,['QC_MASTER_',int2str(vinfo.Vnum),'']);
        print(F1,fname,'-dpng')
        try savefig(F1,fname); catch; warning('savefig error'); end
    end
    if strcmpi(params.vname,'all')
        close all
    end
end
%% check DB integrity
toc
if strcmpi(params.vname,'all')
    [CatalogStatus,catNames,result,offenderCountries,offenderVolcanoes,I] = check4catalogs(input.catalogsDir,volcanoCat,input.localCatDir);
end
