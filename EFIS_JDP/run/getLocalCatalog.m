    catalog_local = [];
    %% ANSS
    if strcmpi(vinfo.country,'United States')
        catalog_local1 = getANSScat(input,params,vinfo,mapdata); %wget
        catalog_local2 = getComcatCat(input,params,vinfo,mapdata); %wget
        [catalog_local,~] = mergeTwoCatalogs(catalog_local2,catalog_local1);
    end
    %% GNS
    if strcmpi(vinfo.country,'New Zealand')
        catalog_local = getGNScat(input,params,vinfo,mapdata); %wget
    end
    %% JMA
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
    %% SIL
    if strcmpi(vinfo.country,'Iceland') 
        catalog_local = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catalogSIL,'SIL');
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