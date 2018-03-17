function catMaster = mkMasterCatalog(vinfo,vpath,input,params,mapdata,catalog1,catalog2,getCats,paramsF)

catName=fullfile(vpath,['cat_MASTER_',int2str(vinfo.Vnum)]);
if getCats
    disp('merge catalogs...')
    [catMaster,H] = mergeTwoCatalogs(catalog1,catalog2,'yes');
    if ~isempty(H); print(H,fullfile(vpath,'QC_MASTER_Merge_map'),'-dpng'); end;
    catMaster = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catMaster,'MASTER');
    
    % FINAL CATALOG if different from Mc catalog
    [ outer_annF, inner_annF ] = getAnnulusm( vinfo.lat, vinfo.lon, paramsF.srad);
    mapdataF = prep4WingPlot(vinfo,paramsF,input,outer_annF,inner_annF);
    catFinal = getVolcCatFromLargerCat(input,paramsF,vinfo,mapdataF,catMaster,'FINAL');
    
else
    if exist([catName,'.mat'],'file')
        warning('loading pre-existing catalog')
        catMaster = load(catName); catMaster = catMaster.catalog;
    else
        error('catalog DNE')
    end
end

end