function catalog = filterCatalogByParams(catalog,params,vinfo)

catalog = filterAnnulusm( catalog, vinfo.lat,vinfo.lon, params.srad); % (e)
catalog = filterDepth(catalog,params.DepthRange);
catalog = filterMag(catalog,params.MagRange);
catalog = filterTime(catalog,datenum(params.YearRange(1),1,1),datenum(params.YearRange(2),1,1));

end