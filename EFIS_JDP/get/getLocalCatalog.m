
%% get ANSS
if strcmp(vinfo.country,'United States')
    catalog_local = getANSScat(input,params,vinfo,mapdata);
end

%% get JMA
if strcmp(vinfo.country,'Japan')
    
    if ~exist('catalogJMA','var') %&& isstruct(catalog)
        disp('loading catalogJMA...')
        load(input.JMAcatalog); %created using importISCcatalog.m
        disp('...catalog loaded')
    end
    
    catalog_local = filterAnnulusm(catalogJMA,vinfo.lat,vinfo.lon,params.srad); %
    catalog_local = filterDepth(catalog_local,params.DepthRange);
    outCatName=fullfile(vpath,['cat_JMA_',int2str(vinfo.Vnum)]);
    catalog = catalog_local;
    %         save(outCatName,'catalog');
    parsave_catalog(outCatName,catalog);
    
    if params.wingPlot
        dts = datenum(extractfield(catalog_local,'DateTime'));
        t1=floor(datenum(min(dts)));
        t2=ceil(datenum(max(dts)));
        figname=fullfile(vpath,['map_JMA_',fixStringName(vinfo.name)]);
        fh_wingplot = wingPlot1(vinfo, t1, t2, catalog_local, mapdata, params,1);
        print(fh_wingplot,'-dpng',[figname,'.png'])
    end
end

%% GNS
if strcmp(vinfo.country,'New Zealand')
    catalog_local = getGNScat(input,params,vinfo,mapdata);
end

%% BMKG
if strcmp(vinfo.country,'Indonesia')
    
    if ~exist('catalogBMKG','var') %&& isstruct(catalog)
        disp('loading catalogBMKG...')
        load(input.BMKGcatalog); %created using importISCcatalog.m
        disp('...catalog loaded')
    end
    
    catalog_local = filterAnnulusm(catalogBMKG,vinfo.lat,vinfo.lon,params.srad); %
    catalog_local = filterDepth(catalog_local,params.DepthRange);
    outCatName=fullfile(vpath,['cat_BMKG_',int2str(vinfo.Vnum)]);
    catalog = catalog_local;
    parsave_catalog(outCatName,catalog);
    
    if params.wingPlot
        dts = datenum(extractfield(catalog_local,'DateTime'));
        t1=floor(datenum(min(dts)));
        t2=ceil(datenum(max(dts)));
        figname=fullfile(vpath,['map_BMKG_',fixStringName(vinfo.name)]);
        fh_wingplot = wingPlot1(vinfo, t1, t2, catalog_local, mapdata, params,1);
        print(fh_wingplot,'-dpng',[figname,'.png'])
    end
end
