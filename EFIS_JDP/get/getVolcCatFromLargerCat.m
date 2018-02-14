function catalog = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catalog,str)

vpath = fullfile(input.catalogsDir,fixStringName(vinfo.country),fixStringName(vinfo.name));

catalog = filterAnnulusm( catalog, vinfo.lat,vinfo.lon, params.srad); % (e)
catalog = filterDepth(catalog,params.DepthRange);

outCatName=fullfile(vpath,['cat_',str,'_',int2str(vinfo.Vnum)]);
parsave_catalog(outCatName,catalog); %%DO we still need parsave if in subroutine??

if params.wingPlot && ~isempty(catalog)
    dts = datenum(extractfield(catalog,'DateTime'));
    t1=floor(datenum(min(dts))); t2=ceil(datenum(max(dts)));
    figname=fullfile(vpath,['map_',str,'_',fixStringName(vinfo.name)]);
    fh_wingplot = wingPlot1(vinfo, t1, t2, catalog, mapdata, params,1);
    print(fh_wingplot,'-dpng',[figname,'.png'])
end

end
