clear

input.catalogsDir = '/Users/jpesicek/Dropbox/Research/EFIS/globalV4';
input.gvp_volcanoes='/Users/jpesicek/Dropbox/Research/EFIS/GVP/GVP_volcanoes_v2b.mat'; % imported via importEruptionCatalog, originally from S. Ogburn
input.gvp_eruptions='/Users/jpesicek/Dropbox/Research/EFIS/GVP/gvp_eruptions_with_ids_v2.mat';
input.outDir = '~/Dropbox/VDAP/Responses/ElSalvador/';

params.coasts = true;
params.wingPlot = true;
params.topo = true;
params.visible = 'on';
params.srad = [0 30];
params.DepthRange = [-3 30]; % km
params.MagRange = [0 10];
params.YearRange = [1964 2018];
params.maxEvents2plot = 7500;
params.vname = 'Ilopango'; % options are 'vname' or 'all'
params.country = 'all';

%%
load(input.gvp_volcanoes); % volcanoCat struct imported via importEruptionCatalog.m from OGBURN FILE
load(input.gvp_eruptions); % spits out eruptionCat
[~,~,~] = mkdir(input.outDir);

%% FIND specific volcano or set of volcanoes, if desired
volcanoCat = filterCatalogByVnameList(volcanoCat,params.vname,'in',params.country);

[vinfo] = getVolcanoInfo(volcanoCat,[],1);
einfo = getEruptionInfoFromNameOrNum(vinfo.Vnum,eruptionCat);

[ outer_ann, inner_ann ] = getAnnulusm( vinfo.lat, vinfo.lon, params.srad);
mapdata = prep4WingPlot(vinfo,params,input,outer_ann,inner_ann);

vpath = fullfile(input.catalogsDir,fixStringName(vinfo.country),fixStringName(vinfo.name));
catName=fullfile(vpath,['cat_MASTER_',int2str(vinfo.Vnum)]);
outMcInfoName=fullfile(vpath,['Mc_MASTER_',int2str(vinfo.Vnum),'.mat']);

if exist([catName,'.mat'],'file')
    disp('loading pre-existing catalog')
    catMaster = load(catName); catMaster = catMaster.catalog;
    Mc = load(outMcInfoName);
else
    error('catalog DNE')
end

catalog = filterCatalogByParams(catMaster,params,vinfo);

F1 = catalogQCfig(catalog,vinfo,einfo,Mc.McDaily,params.visible);
fname=fullfile(input.outDir,['QC_MASTER_',int2str(vinfo.Vnum),'']);
print(F1,fname,'-dpng')

F2 = catalogQCmap(catalog,vinfo,params,mapdata);
print(F2,fullfile(input.outDir,['QC_MASTER_',int2str(vinfo.Vnum),'_map']),'-dpng')

str='MASTER';
if params.wingPlot %&& ~isempty(catalog)
    t1=datenum(params.YearRange(1),1,1);
    t2=datenum(params.YearRange(2)+1,1,1);
    figname=fullfile(input.outDir,['map_',str,'_',fixStringName(vinfo.name)]);
    fh_wingplot = wingPlot1(vinfo, t1, t2, catalog, mapdata, params,1);
    print(fh_wingplot,'-dpng',[figname,'.png'])
    if strcmpi(params.visible,'off'); close(fh_wingplot); end
end