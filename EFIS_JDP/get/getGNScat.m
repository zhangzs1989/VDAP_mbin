function catalog = getGNScat(input,params,vinfo,mapdata)

volcOutName = fixStringName(vinfo.name);
outDirName=fullfile(input.catalogsDir,fixStringName(vinfo.country),volcOutName);
outCatName=fullfile(outDirName,['cat_GNS_',int2str(vinfo.Vnum)]);

if exist([outCatName,'.mat'],'file')
    disp('loading old m-catalog...')
    catalog = load(outCatName);
    catalog = catalog.catalog;
    return
end
warning('on','all')
catalog = [];

if ~strcmp(vinfo.country,'New Zealand')
    warning('only for NZ')
    return
end
%%
shscript='/Users/jpesicek/Dropbox/Research/EFIS/GNS/getGNZcat.sh';
odir = outDirName;
ofile = fullfile(odir,['GNS_',volcOutName,'.csv']);
s = dir(ofile);

if ~exist(ofile,'file') || s.bytes == 0
    disp(['getting catalog from GNS...'])
    
    cmd = sprintf('%s %s %f %f %d %d %s',shscript,volcOutName,vinfo.lat,vinfo.lon,params.srad(2),params.DepthRange(2),odir);
    [status,result] = system(cmd);
    disp(result)
    if status > 1  %what does 1 mean? seems ok
        error('wget issue')
    end
    
    cmd2 = sprintf('echo "%s" > %s/GNS_Request.sh',cmd,odir);
    [status,result] = system(cmd2);
    disp(result)
    
    if ~exist(ofile,'file')
        warning('problem with GNS request')
        disp(result)
    end
    
end
%%
s = dir(ofile);
if ~exist(ofile,'file') || s.bytes == 0
    catalog = [];
    return
end

disp('importing GNS formatted catalog...')
[catalog] = import1GNSfile(ofile);
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
    %         kmlName=['GNS_',int2str(vinfo.Vnum)];
    %         try
    %             mkKMLfileFromCatalog(catalog,fullfile(outDirName,kmlName));
    %         catch
    %             warning('KML file trouble')
    %         end
    
    t1a=datenum(params.YearRange(1),1,1);
    t2a=datenum(params.YearRange(2)+1,1,1);
    catalog = filterTime( catalog, t1a, t2a);% wingplot ISC
    figname=fullfile(outDirName,['map_GNS_',volcOutName]);
    fh_wingplot = wingPlot1(vinfo, t1a, t2a, catalog, mapdata, params,1);
    print(fh_wingplot,'-dpng',[figname,'.png'])
    close(fh_wingplot)
end

end