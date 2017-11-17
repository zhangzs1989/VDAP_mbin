function catalog = getANSScat(input,params,vinfo,mapdata)

warning('on','all')

% if isfield(input,'polygonFilter') && (strcmp(input.polygonFilter,'United States') || exist(input.polygonFilter,'file')) || ...
%         strcmp(vinfo.country,'United States')
if strcmp(vinfo.country,'United States')
    
    shscript='~/bin/catalog-search2.pl';
    volcOutName = fixStringName(vinfo.name);
    outDirName=fullfile(input.catalogsDir,fixStringName(vinfo.country),volcOutName);
    outCatName=fullfile(outDirName,['ANSS_',int2str(vinfo.Vnum)]);
    odir = outDirName;
    ofile = fullfile(odir,['ANSS_',volcOutName,'.csv']);
    s = dir(ofile);
    
    if ~exist(ofile,'file') || s.bytes == 0
        disp(['getting catalog from ANSS...'])
        
        cmd = sprintf('%s %f %f %d %d > %s',shscript,vinfo.lat,vinfo.lon,params.srad(2),params.DepthRange(2),ofile);
        [status,result] = system(cmd);
        disp(result)
        
        cmd2 = sprintf('echo "%s" > %s/ANSS_Request.sh',cmd,odir);
        [status,result] = system(cmd2);
        disp(result)
        
        if ~exist(ofile,'file')
            warning('problem with ANSS request')
            disp(result)
        end
        
    else
        warning('using existing catalog')
    end
    
    [catalog] = import1ANSSfile(ofile);
    pD = check4duplicateEvents(catalog);
    if pD > 0
        ID = findDuplicateEvents(catalog,0);
        catalog = catalog(~ID);
    end
    
    save(outCatName,'catalog');
    
    if params.wingPlot
        if numel(catalog) > params.maxEvents2plot
            warning('wingplot: too many events to plot all')
            catalog = catalog(2:round(numel(catalog)/params.maxEvents2plot):end);
        end
        
        %% make kml file
        kmlName=['ANSS_',int2str(vinfo.Vnum)];
        try
            mkKMLfileFromCatalog(catalog,fullfile(outDirName,kmlName));
        catch
            %             tmpName=regexprep(volcanoCat(i).Volcano,'\W','');
            %             mkKMLfileFromCatalog(catalog_a,kmlName);
            %             cmd=sprintf('mv %s.kml %s',kmlName,fullfile(outDirName,kmlName));
            %             [status,result] = system(cmd);
            warning('KML file trouble')
        end
        
        t1a=datenum(params.YearRange(1),1,1);
        t2a=datenum(params.YearRange(2)+1,1,1);
        catalog = filterTime( catalog, t1a, t2a);% wingplot ISC
        figname=fullfile(outDirName,['ANSS_',volcOutName]);
        fh_wingplot = wingPlot1(vinfo, t1a, t2a, catalog, mapdata, params,1);
        print(fh_wingplot,'-dpng',[figname,'.png'])
        close(fh_wingplot)
    end
    
else
    catalog = [];
end


end