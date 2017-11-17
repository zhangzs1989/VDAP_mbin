clearvars -except catalog

input.gvp_volcanoes='/Users/jpesicek/Dropbox/Research/EFIS/GVP/GVP_volcanoes_v2.mat'; % imported via importEruptionCatalog, originally from S. Ogburn
input.gvp_eruptions='/Users/jpesicek/Dropbox/Research/EFIS/GVP/gvp_eruptions_with_ids_v2.mat';
input.GSHHS = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/data/gshhs_f.b'; %full res;
input.catalogsDir = '/Users/jpesicek/Dropbox/Research/EFIS/global7'; % importISCcatalog.m
input.outDir = '~/Dropbox/Research/EFIS/global7';

%% general params
params.srad = [0 50];
params.DepthRange = [-3 35]; % km
params.MagRange = [0 10];
params.YearRange = [1964 2015];
% params.polygonFilterSwitch = 'out';
% params.polygonBuffer = 2; % in degrees

%% wingPlot params
params.coasts = true;
params.wingPlot = true;
params.topo = true;
params.visible = 'on';

load(input.gvp_volcanoes)
load(input.gvp_eruptions)
% [volcanoCat,~,~]= regionalCatalogFilter(input,volcanoCat,params);
% volcanoCat = filterCatalogByCountry(volcanoCat,input.polygonFilter,params.polygonFilterSwitch);
%%
% [result,status,probCountries,probVolcanoes] = checkCatalogDBintegrity(input.catalogsDir,volcanoCat);

%% FIND specific volcano if desired
vname = 'Pinatubo';
vnames = extractfield(volcanoCat,'Volcano');
vi = find(strcmp(vname,vnames));
volcanoCat = volcanoCat(vi);

for i=1:numel(volcanoCat)
    
    [vinfo] = getVolcanoInfo(volcanoCat,[],i);
    vname = fixStringName(vinfo.name);
    vpath = fullfile(input.catalogsDir,fixStringName(vinfo.country),vname);
    outDir = fullfile(input.outDir,fixStringName(vinfo.country),vname);
    [~,~,~] = mkdir(outDir);
    einfo = getEruptionInfoFromNameOrNum(vinfo.Vnum,eruptionCat);
    %     if isempty(einfo)
    %         continue
    %     end
    load(fullfile(vpath,['MASTER_',int2str(vinfo.Vnum),'.mat']));
    load(fullfile(vpath,['Mc/MASTER_McInfo_',int2str(vinfo.Vnum),'.mat']));
    
    disp([int2str(i),'/',int2str(numel(volcanoCat)),', ',vinfo.name,', ',vinfo.country])
    %% QC
    if params.wingPlot
        [ outer_ann, inner_ann ] = getAnnulusm( volcanoCat(i).Latitude, volcanoCat(i).Longitude, params.srad);
        mapdata = prep4WingPlot(vinfo,params,input,outer_ann,inner_ann);
        t1a=datenum(params.YearRange(1),1,1);
        t2a=datenum(params.YearRange(2)+1,1,1);
        figname=fullfile(outDir,['MASTER_',fixStringName(vinfo.name)]);
        fh_wingplot = wingPlot1(vinfo, t1a, t2a, catalog, mapdata, params,1);
        print(fh_wingplot,'-dpng',[figname,'.png'])
        
        F2 = catalogQCmap(catalog,vinfo,params,mapdata);
        print(F2,fullfile(outDir,['MASTER_',int2str(vinfo.Vnum),'_QC2']),'-dpng')
    end
    %
    if ~isempty(catalog)
        F1 = catalogQCfig(catalog,vinfo,einfo,McDaily,params.visible);
%         set(get(F1.Children(end),'Title'),'String',vinfo.name)
        set(F1,'PaperPositionMode','auto')
        print(F1,fullfile(outDir,['MASTER_',int2str(vinfo.Vnum),'_QC1']),'-dpng')
        try % matlab version bug
            savefig(F1,fullfile(outDir,['MASTER_',int2str(vinfo.Vnum),'_QC1']));
        end
    end
    try
        close(F1);
        close(fh_wingplot)
        close(F2);
    end
end
