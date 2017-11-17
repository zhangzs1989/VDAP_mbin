clearvars -except

input.gvp_volcanoes='/Users/jpesicek/Dropbox/Research/EFIS/GVP/GVP_volcanoes_v2.mat'; % imported via importEruptionCatalog, originally from S. Ogburn
input.GSHHS = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/data/gshhs_f.b'; %full res;
input.catStrName='local';
input.catalogsDir = '/Users/jpesicek/Dropbox/Research/EFIS/global5'; % importISCcatalog.m
% input.polygonFilter = 'United States';
input.outDir = '~/Dropbox/Research/EFIS/global7';

%% general params
params.srad = [0 50];
params.DepthRange = [-3 35]; % km
params.MagRange = [0 10];
params.YearRange = [1964 2015];
params.polygonFilterSwitch = 'in';
params.polygonBuffer = 1; % in degrees
params.McMinN = 100;
params.smoothDayFac = 30*6;

%% wingPlot params
params.coasts = true;
params.wingPlot = false;
params.topo = false;
params.visible = 'off';
%%
disp(mfilename('fullpath'))
disp(' ')
disp(input)
disp(' ')
disp(params)

%%
load(input.gvp_volcanoes)
[volcanoCat,XV,YV]= regionalCatalogFilter(input,volcanoCat,params);

%% FIND specific volcano if desired
% vname = 'Soufrière Hills';
% vnames = extractfield(volcanoCat,'Volcano');
% vi = find(strcmp(vname,vnames));
% volcanoCat = volcanoCat(vi);
%%
for i=1:numel(volcanoCat)
    
    [vinfo] = getVolcanoInfo(volcanoCat,[],i);
    vpath = fullfile(input.catalogsDir,fixStringName(vinfo.country),fixStringName(vinfo.name));
    outDir = fullfile(input.outDir,fixStringName(vinfo.country),fixStringName(vinfo.name),'Mc');
    disp([int2str(i),'/',int2str(numel(volcanoCat)),', ',vinfo.name,', ',vinfo.country])
    
    [CatalogStatus,catNames] = check4catalogs(vpath,vinfo.Vnum);
    
    if CatalogStatus(3)==0 && CatalogStatus(2) == 0
        disp('no local catalog')
        continue
    end
    
    if CatalogStatus(3)
        localCat = load(fullfile(vpath,char(catNames(3))));
        localCat = localCat.catalog;
    elseif CatalogStatus(2)
        localCat = load(fullfile(vpath,char(catNames(2))));
        localCat = localCat.catalog;
    else
        %there is no local or ANSS catalog
    end
    
    catalog = filterAnnulusm(localCat,vinfo.lat,vinfo.lon,params.srad);
    [ outer_ann, inner_ann ] = getAnnulusm( vinfo.lat, vinfo.lon, params.srad);
    catalog = filterTime( catalog, datenum(params.YearRange(1),1,1),datenum(params.YearRange(2),1,1));
    %     catalog = filterDepth( catalog, params.DepthRange); % (d)
    %     catalog = filterMag( catalog, params.MagRange); % (e)
    
    [~,~,~] = mkdir(outDir);
    if params.wingPlot
        mapdata = prep4WingPlot(vinfo,params,input,outer_ann,inner_ann);
        t1a=datenum(params.YearRange(1),1,1);
        t2a=datenum(params.YearRange(2)+1,1,1);
        figname=fullfile(outDir,[input.catStrName,'_MAP_',fixStringName(vinfo.name)]);
        fh_wingplot = wingPlot1(vinfo, t1a, t2a, catalog, mapdata, params,1);
        print(fh_wingplot,'-dpng',[figname,'.png'])
        close(fh_wingplot)
    end
    
    McInfo = getVolcanoMc(vinfo,catalog,outDir,params.McMinN,input.catStrName,2,params.smoothDayFac);
%     H = mkMcFig(McInfo,'on');
% if there is a local catalog but not enough events for Mc, do we still
% want to save an empty Mc file?
    outMcInfoName=fullfile(outDir,[input.catStrName,'_McInfo_',int2str(vinfo.Vnum),'.mat']);
    save(outMcInfoName,'-struct','McInfo');
end
