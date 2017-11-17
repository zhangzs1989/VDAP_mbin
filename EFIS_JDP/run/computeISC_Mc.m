%% This computes the Mc from the ISC catalog for a bigger radius and requires
% you to load the full ISC catalog, but only load it once. In contrast, for
% the local version you load each volcano catalog on demand.

clearvars -except catalogISC

input.gvp_volcanoes='/Users/jpesicek/Dropbox/Research/EFIS/GVP/GVP_volcanoes_v2.mat'; % imported via importEruptionCatalog, originally from S. Ogburn
input.GSHHS = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/data/gshhs_f.b'; %full res;
input.ISCcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/trimISCcatalog2volcs/iscCatalogAll5wFMsTrim.mat'; % importISCcatalog.m
input.catStrName='ISC';
input.catalogsDir = '/Users/jpesicek/Dropbox/Research/EFIS/global7'; % importISCcatalog.m
% input.polygonFilter = 'United States';

%% general params
params.srad = [0 500];
params.DepthRange = [-3 70]; % km
params.MagRange = [0 10];
params.YearRange = [1964 2015];
params.polygonFilterSwitch = 'in';
params.polygonBuffer = 1; % in degrees %NOTE: CAREFUL: helps get volancoes offshore but also in neighboring countries
params.McMinN = 100;
params.smoothDayFac = round(365*1);

%% wingPlot params
params.coasts = false;
params.wingPlot = false;
params.topo = false;
params.visible = 'off';
%%
disp(mfilename('fullpath'))
disp(' ')
disp(input)
disp(' ')
disp(params)

% LOAD catalog
if ~exist('catalogISC','var') %&& isstruct(catalog)
    disp('loading catalogISC...')
    load(input.ISCcatalog); %created using importISCcatalog.m
    %     [ catalog ] = filterDepth( catalog, params.DepthRange(2)); % (d)
    %     [ catalog ] = filterMag( catalog, params.MagRange(1) ); % (e)
    %     [ catalog ] = filterTime( catalog, datenum('1990/01/01'), params.catalogEndDate); % start here to cut out redoubt for now
    disp('...catalog loaded')
end

%% 
load(input.gvp_volcanoes)
% [volcanoCat,XV,YV]= regionalCatalogFilter(input,volcanoCat,params);
% volcanoCat = filterCatalogByCountry(volcanoCat,input.polygonFilter);
%% FIND specific volcano if desired
vname = 'Kilauea';
vnames = extractfield(volcanoCat,'Volcano');
vi = find(strcmp(vname,vnames));
volcanoCat = volcanoCat(vi);
%%
for i=1:numel(volcanoCat)
    
 
    [vinfo] = getVolcanoInfo(volcanoCat,[],i);
    vpath = fullfile(input.catalogsDir,fixStringName(vinfo.country),fixStringName(vinfo.name));
    outDir = fullfile(vpath,'Mc');
    [~,~,~] = mkdir(outDir);
    disp([int2str(i),'/',int2str(numel(volcanoCat)),', ',vinfo.name,', ',vinfo.country])

    [catalog_v,outer_ann, inner_ann ]= filterAnnulusm(catalogISC,vinfo.lat,vinfo.lon,params.srad);

    if params.wingPlot
        mapdata = prep4WingPlot(vinfo,params,input,outer_ann,inner_ann);
        t1a=datenum(params.YearRange(1),1,1);
        t2a=datenum(params.YearRange(2)+1,1,1);
        figname=fullfile(outDir,[input.catStrName,'_MAP_',fixStringName(vinfo.name)]);
        fh_wingplot = wingPlot1(vinfo, t1a, t2a, catalog_v, mapdata, params,1);
        print(fh_wingplot,'-dpng',[figname,'.png'])
        close(fh_wingplot)
    end
    
%     %% TEMP!!
%     if numel(catalog_v) >= params.McMinN
%         continue
%     end
    %%
    McInfo = getVolcanoMc(vinfo,catalog_v,outDir,params.McMinN,input.catStrName,2,params.smoothDayFac);
%     H = mkMcFig(McInfo,'on');
%     McInfo = getVolcanoMcByTime(vinfo,catalog_v,outDir,params.McMinN,input.catStrName);
    outMcInfoName=fullfile(outDir,[input.catStrName,'_McInfo_',int2str(vinfo.Vnum),'.mat']);
    save(outMcInfoName,'-struct','McInfo');
end
