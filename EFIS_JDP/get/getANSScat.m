function catalog = getANSScat(input,params,vinfo,mapdata)

volcOutName = fixStringName(vinfo.name);
outDirName=fullfile(input.catalogsDir,fixStringName(vinfo.country),volcOutName);
outCatName=fullfile(outDirName,['cat_ANSS_',int2str(vinfo.Vnum)]);

if exist([outCatName,'.mat'],'file')
    disp('loading old m-catalog...')
    catalog = load(outCatName);
    catalog = catalog.catalog;
    return
end
warning('on','all')
catalog = [];

if ~strcmp(vinfo.country,'United States')
    warning('only for US')
   return
end
%%
shscript='~/bin/catalog-search2.pl';
odir = outDirName;
ofile = fullfile(odir,['ANSS_',volcOutName,'.csv']);
s = dir(ofile);
%%
if ~exist(ofile,'file') || s.bytes == 0
    disp(['getting catalog from ANSS...'])
    
    cmd = sprintf('%s %f %f %d %d %d %f %f > %s',shscript,vinfo.lat,vinfo.lon, ...
        params.srad(2),params.DepthRange(1),params.DepthRange(2),params.MagRange(1),params.MagRange(2),ofile);
    [status,result] = system(cmd);
    disp(result)
    if status ~= 0
        error('wget issue')
    end
    
    cmd2 = sprintf('echo "%s" > %s/ANSS_Request.sh',cmd,odir);
    [status,result] = system(cmd2);
    disp(result)
    
    if ~exist(ofile,'file')
        warning('problem with ANSS request')
        disp(result)
    end
    
end
%%
s = dir(ofile);
if ~exist(ofile,'file') || s.bytes == 0
    catalog = [];
    return
end

disp('importing ANSS formatted catalog...')
[catalog] = import1ANSSfile(ofile);
if numel(catalog)>1
    catalog = rmDuplicateEvents(catalog,0);
end
save(outCatName,'catalog');
%%
if params.wingPlot
    if numel(catalog) > params.maxEvents2plot
        warning('wingplot: too many events to plot all')
        catalog = catalog(2:round(numel(catalog)/params.maxEvents2plot):end);
    end
    %% make kml file
    %         kmlName=['ANSS_',int2str(vinfo.Vnum)];
    %         try
    %             mkKMLfileFromCatalog(catalog,fullfile(outDirName,kmlName));
    %         catch
    %             %             tmpName=regexprep(volcanoCat(i).Volcano,'\W','');
    %             %             mkKMLfileFromCatalog(catalog_a,kmlName);
    %             %             cmd=sprintf('mv %s.kml %s',kmlName,fullfile(outDirName,kmlName));
    %             %             [status,result] = system(cmd);
    %             warning('KML file trouble')
    %         end
    
    t1a=datenum(params.YearRange(1),1,1);
    t2a=datenum(params.YearRange(2)+1,1,1);
    catalog = filterTime( catalog, t1a, t2a);% wingplot ISC
    figname=fullfile(outDirName,['map_ANSS_',volcOutName]);
    fh_wingplot = wingPlot1(vinfo, t1a, t2a, catalog, mapdata, params,1);
    print(fh_wingplot,'-dpng',[figname,'.png'])
    close(fh_wingplot)
end

end