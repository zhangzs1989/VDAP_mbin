function catalog = getComcatCat(input,params,vinfo,mapdata)

warning('on','all')

shscript='~/bin/wgetComcat.sh';
volcOutName = fixStringName(vinfo.name);
outDirName=fullfile(input.catalogsDir,fixStringName(vinfo.country),volcOutName);
outCatName=fullfile(outDirName,['ISC_',int2str(vinfo.Vnum)]);
odir = outDirName;
ofile = fullfile(odir,['Comcat_',volcOutName,'.csv']);
s = dir(ofile);

if ~exist(ofile,'file') || s.bytes == 0
    disp(['getting catalog from NEIC...'])
    
    cmd = sprintf('%s %s %f %f %d %d %s',shscript,volcOutName,vinfo.lat,vinfo.lon,params.srad(2),params.DepthRange(2),odir);
    [status,result] = system(cmd);
    disp(result)
    
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
catalog = import1comcatFile(ofile);
save(outCatName,'catalog');
if params.wingPlot
    
    t1a=datenum(params.YearRange(1),1,1);
    t2a=datenum(params.YearRange(2)+1,1,1);
    catalog = filterTime( catalog, t1a, t2a);% wingplot ISC
    figname=fullfile(outDirName,['Comcat_',volcOutName]);
    fh_wingplot = wingPlot1(vinfo, t1a, t2a, catalog, mapdata, params,1);
    print(fh_wingplot,'-dpng',[figname,'.png'])
    close(fh_wingplot)
end
end