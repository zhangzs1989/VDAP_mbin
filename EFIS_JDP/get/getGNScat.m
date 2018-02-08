function catalog = getGNScat(input,params,vinfo,mapdata)

warning('on','all')

if strcmp(vinfo.country,'New Zealand')
    
    shscript='/Users/jpesicek/Dropbox/Research/EFIS/GNS/getGNZcat.sh';
    volcOutName = fixStringName(vinfo.name);
    outDirName=fullfile(input.catalogsDir,fixStringName(vinfo.country),volcOutName);
    outCatName=fullfile(outDirName,['cat_GNS_',int2str(vinfo.Vnum)]);
    odir = outDirName;
    ofile = fullfile(odir,['GNS_',volcOutName,'.csv']);
    s = dir(ofile);
    
    if ~exist(ofile,'file') || s.bytes == 0
        disp(['getting catalog from GNS...'])
        
        cmd = sprintf('%s %s %f %f %d %d %s',shscript,volcOutName,vinfo.lat,vinfo.lon,params.srad(2),params.DepthRange(2),odir);
        [status,result] = system(cmd);
        disp(result)
        
        cmd2 = sprintf('echo "%s" > %s/GNS_Request.sh',cmd,odir);
        [status,result] = system(cmd2);
        disp(result)
        
        if ~exist(ofile,'file')
            warning('problem with GNS request')
            disp(result)
        end
        
    else
        warning('using existing catalog')
    end
    
    if ~exist(ofile,'file') && s.bytes > 282
        disp('importing catalog from GNS...')
        [catalog] = import1GNSfile(ofile);
        catalog = rmDuplicateEvents(catalog,0);
        save(outCatName,'catalog');
    else
        warning('no events imported')
        catalog = [];
    end
    
    if params.wingPlot
        if numel(catalog) > params.maxEvents2plot
            warning('wingplot: too many events to plot all')
            catalog = catalog(2:round(numel(catalog)/params.maxEvents2plot):end);
        end
        
        %% make kml file
        kmlName=['GNS_',int2str(vinfo.Vnum)];
        try
            mkKMLfileFromCatalog(catalog,fullfile(outDirName,kmlName));
        catch
            warning('KML file trouble')
        end
        
        t1a=datenum(params.YearRange(1),1,1);
        t2a=datenum(params.YearRange(2)+1,1,1);
        catalog = filterTime( catalog, t1a, t2a);% wingplot ISC
        figname=fullfile(outDirName,['map_GNS_',volcOutName]);
        fh_wingplot = wingPlot1(vinfo, t1a, t2a, catalog, mapdata, params,1);
        print(fh_wingplot,'-dpng',[figname,'.png'])
        close(fh_wingplot)
    end
    
else
    catalog = [];
end


end