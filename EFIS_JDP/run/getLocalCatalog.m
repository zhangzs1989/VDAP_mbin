function catalog_local = getLocalCatalog(catalogs,input,params,vinfo,mapdata,country)

catalog_local = [];
%% ANSS
if strcmpi(country,'United States')
    % ANSS
    catalog_local1 = getANSScat(input,params,vinfo,mapdata); %wget
    % COMCAT
    catalog_local2 = getComcatCat(input,params,vinfo,mapdata); %wget
    
    [catalog_local,~] = mergeTwoCatalogs(catalog_local2,catalog_local1);
end
%% GNS
if strcmpi(country,'New Zealand')
    catalog_local = getGNScat(input,params,vinfo,mapdata); %wget
    catalog_local = filterAnnulusm( catalog_local, vinfo.lat,vinfo.lon, params.srad); % (e)
    catalog_local = filterDepth(catalog_local,params.DepthRange);
    catalog_local = filterMag(catalog_local,params.MagRange);    
end
%% JMA
if strcmpi(country,'Japan') || strcmp(country,'Japan - administered by Russia')
    catalog_local = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catalogs.JMA,'JMA');
end
%% BMKG
if strcmpi(country,'Indonesia')
    catalog_local = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catalogs.BMKG,'BMKG');
end
%% SSN
if strcmpi(country,'Mexico') || strcmp(country,'Mexico-Guatemala')
    catalog_local = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catalogs.SSN,'SSN');
end
%% SIL
if strcmpi(country,'Iceland')
    catalog_local = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catalogs.SIL,'SIL');
end
%% IGN
if strcmpi(country,'Spain')
    catalog_local = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catalogs.IGN,'IGN');
end
%% INGV
if strcmpi(country,'Italy')
    catalog_local = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catalogs.INGV,'INGV');
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

end