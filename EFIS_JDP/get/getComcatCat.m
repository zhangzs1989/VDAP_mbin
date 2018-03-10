function catalog = getComcatCat(input,params,vinfo,mapdata)

warning('on','all')

if ~strcmp(vinfo.country,'United States')
    warning('comcat only for US')
    catalog = [];
    return
end

shscript='~/bin/wgetComcat.sh';
volcOutName = fixStringName(vinfo.name);
outDirName=fullfile(input.catalogsDir,fixStringName(vinfo.country),volcOutName);
outCatName=fullfile(outDirName,['Comcat_',int2str(vinfo.Vnum)]);
odir = outDirName;
ofile = fullfile(odir,['Comcat_',volcOutName,'.csv']);
s = dir(ofile);

if ~exist(ofile,'file') || s.bytes == 0
    disp(['getting catalog from NEIC...'])
    
    cmd = sprintf('%s %s %f %f %d %d %s',shscript,volcOutName,vinfo.lat,vinfo.lon,params.srad(2),params.DepthRange(2),odir);
    [status,result] = system(cmd);
    disp(result)
%     if status ~= 0  %% gives status one even though it seems to have
%     worked??
%         error('wget issue')
%     end
    
    
    cmd2 = sprintf('echo "%s" > %s/Comcat_Request.sh',cmd,odir);
    [status,result] = system(cmd2);
    disp(result)
    
    if ~exist(ofile,'file')
        warning('problem with comcat wget command')
        disp(result)
    end
    
else
    warning('using existing catalog')
    
end

if exist(ofile,'file')
    try
        catalog = load(outCatName);
        catalog = catalog.catalog;
    catch
        disp('importing comcat formatted catalog...')
        catalog = import1comcatFile(ofile);
        if numel(catalog)>1
            catalog = rmDuplicateEvents(catalog,0);
        end
        save(outCatName,'catalog');
    end
    
    if params.wingPlot
        
%         t1a=datenum(params.YearRange(1),1,1);
%         t2a=datenum(params.YearRange(2)+1,1,1);
        dts = datenum(datevec(extractfield(catalog,'DateTime')));
        t1a = floor(min(dts)); t2a = ceil(max(dts));
        catalog = filterTime( catalog, t1a, t2a);% wingplot ISC
        figname=fullfile(outDirName,['Comcat_',volcOutName]);
        fh_wingplot = wingPlot1(vinfo, t1a, t2a, catalog, mapdata, params,1);
        print(fh_wingplot,'-dpng',[figname,'.png'])
        close(fh_wingplot)
    end
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
    figname=fullfile(outDirName,['map_comcat_',volcOutName]);
    fh_wingplot = wingPlot1(vinfo, t1a, t2a, catalog, mapdata, params,1);
    print(fh_wingplot,'-dpng',[figname,'.png'])
    close(fh_wingplot)
end
