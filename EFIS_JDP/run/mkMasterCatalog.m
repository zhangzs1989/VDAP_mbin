function catMaster = mkMasterCatalog(vinfo,vpath,input,params,mapdata,catalog1,catalog2,getCats,paramsF)

% ISC max pull param
evmax = 40000; 
reducFac = 2/3;
nc1 = numel(catalog1);
nc2 = numel(catalog2);
catName=fullfile(vpath,['cat_MASTER_',int2str(vinfo.Vnum)]);

if getCats && ~exist([catName,'.mat'],'file')
    
    if nc1 + nc2 > evmax || nc1 > params.maxEvents2plot || nc2 > params.maxEvents2plot 
       warning('TOO MANY EVENTS! reducing...') 
       catalog1 = filterDepth(catalog1,params.DepthRange(2)*reducFac);
       catalog1 = filterAnnulusm( catalog1, vinfo.lat,vinfo.lon, params.srad(2)*reducFac); % (e)
       catalog2 = filterDepth(catalog2,params.DepthRange(2)*reducFac);
       catalog2 = filterAnnulusm( catalog2, vinfo.lat,vinfo.lon, params.srad(2)*reducFac); % (e)
    end  
    %%
    disp('merge catalogs...')
    [catMaster,H] = mergeTwoCatalogs(catalog1,catalog2,'yes');
    if ~isempty(H); print(H,fullfile(vpath,'QC_MASTER_Merge_map'),'-dpng'); end; close(H);
    catMaster = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catMaster,'MASTER');
    
    % FINAL CATALOG if different from Mc catalog
    [ outer_annF, inner_annF ] = getAnnulusm( vinfo.lat, vinfo.lon, paramsF.srad);
    mapdataF = prep4WingPlot(vinfo,paramsF,input,outer_annF,inner_annF);
    catFinal = getVolcCatFromLargerCat(input,paramsF,vinfo,mapdataF,catMaster,'FINAL');
    
else
    if exist([catName,'.mat'],'file')
        disp('loading pre-existing catalog')
        catMaster = load(catName); catMaster = catMaster.catalog;
    else
        error('catalog DNE')
    end
end

end