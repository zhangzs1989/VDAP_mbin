function catalog = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catalog,str)

vpath = fullfile(input.catalogsDir,fixStringName(vinfo.country),fixStringName(vinfo.name));
catName=fullfile(vpath,['cat_',str,'_',int2str(vinfo.Vnum)]);

if params.getCats && ~exist([catName,'.mat'],'file')
    
    catalog = filterAnnulusm( catalog, vinfo.lat,vinfo.lon, params.srad); % (e)
    catalog = filterDepth(catalog,params.DepthRange);
    catalog = filterMag(catalog,params.MagRange);
    parsave_catalog(catName,catalog); %%DO we still need parsave if in subroutine??
    
    if params.wingPlot %&& ~isempty(catalog)
%         dts = datenum(extractfield(catalog,'DateTime'));
%         t1=floor(datenum(min(dts))); t2=ceil(datenum(max(dts)));
        t1=datenum(params.YearRange(1),1,1);
        t2=datenum(params.YearRange(2)+1,1,1);
        figname=fullfile(vpath,['map_',str,'_',fixStringName(vinfo.name)]);
        fh_wingplot = wingPlot1(vinfo, t1, t2, catalog, mapdata, params,1);
        print(fh_wingplot,'-dpng',[figname,'.png'])
        if strcmpi(params.visible,'off'); close(fh_wingplot); end
    end
    
else
    
    if exist([catName,'.mat'],'file')
        disp('loading pre-existing catalog')
        catalog = load(catName); catalog = catalog.catalog;
    else
        error('catalog file Does Not Exist')
    end
    
end


end
